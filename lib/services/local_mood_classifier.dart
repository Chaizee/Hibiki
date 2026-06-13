import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/models/mood_result.dart';
import 'audio_feature_extractor.dart';
/// On-device mood inference. Loads [voice_mood.tflite] from assets when present.
class LocalMoodClassifier {
  LocalMoodClassifier({
    AudioFeatureExtractor? featureExtractor,
  }) : _features = featureExtractor ?? const AudioFeatureExtractor();

  static const _modelAsset = 'assets/models/voice_mood.tflite';
  static const _labelsAsset = 'assets/models/labels.txt';

  final AudioFeatureExtractor _features;
  Interpreter? _interpreter;
  List<String> _labels = const ['calm', 'joyful', 'tense'];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      final labelsRaw = await rootBundle.loadString(_labelsAsset);
      _labels = labelsRaw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (_labels.isEmpty) _labels = const ['calm', 'joyful', 'tense'];
    } catch (e, st) {
      debugPrint('LocalMoodClassifier: model not loaded ($e). Using heuristic.\n$st');
      _interpreter = null;
    }
    _initialized = true;
  }

  static const double _silenceRmsMax = 0.026;
  static const double _silencePeakMax = 0.045;

  Future<MoodResult> analyzeFile(String audioPath) async {
    await initialize();
    final metrics = await _features.signalMetricsFromFile(audioPath);
    final vector = await _features.extractFromFile(audioPath);

    if (_isQuietInput(metrics.rms, metrics.peak)) {
      return _silenceResult(vector, metrics.rms, metrics.peak);
    }

    final prediction = _predictFromModel(vector);
    return _emotionToMoodResult(
      prediction.emotion,
      vector,
      probabilities: prediction.probabilities,
      rms: metrics.rms,
      peak: metrics.peak,
    );
  }

  bool _isQuietInput(double rms, double peak) {
    return rms < _silenceRmsMax && peak < _silencePeakMax;
  }

  MoodResult _silenceResult(List<double> features, double rms, double peak) {
    final stress = (12 + rms * 120 + peak * 40).clamp(10.0, 22.0);
    return MoodResult(
      stressLevel: stress,
      moodLabel: 'quiet',
      tags: const ['low_signal', 'speak_closer'],
      resonancePercent: (100 - stress).round(),
      emotion: 'calm',
      insightHeadline: 'quiet_headline',
      insightBody: 'quiet_body',
      rawMlPayload: {
        'emotion': 'calm',
        'silence_override': true,
        'rms': rms,
        'peak': peak,
        'mfcc_mean': features,
        'on_device': true,
      },
    );
  }

  ({String emotion, List<double>? probabilities}) _predictFromModel(
    List<double> features,
  ) {
    final interpreter = _interpreter;
    if (interpreter != null) {
      final input = [features];
      final output = [List<double>.filled(_labels.length, 0)];
      interpreter.run(input, output);
      var probs = List<double>.from(output[0]);
      final sum = probs.fold(0.0, (a, b) => a + b);
      if (sum <= 1e-9) {
        return (emotion: _heuristicEmotion(features), probabilities: null);
      }
      probs = probs.map((p) => p / sum).toList();

      var bestIdx = 0;
      var bestVal = probs[0];
      for (var i = 1; i < probs.length; i++) {
        if (probs[i] > bestVal) {
          bestVal = probs[i];
          bestIdx = i;
        }
      }

      if (bestVal < 0.38) {
        return (emotion: _heuristicEmotion(features), probabilities: null);
      }

      probs = _temperProbs(probs, temperature: 1.4);
      if (bestVal < 0.52) {
        probs = _mixUniform(probs, mix: 0.18);
      }

      bestIdx = 0;
      bestVal = probs[0];
      for (var i = 1; i < probs.length; i++) {
        if (probs[i] > bestVal) {
          bestVal = probs[i];
          bestIdx = i;
        }
      }
      return (
        emotion: _labels[bestIdx.clamp(0, _labels.length - 1)],
        probabilities: probs,
      );
    }
    return (emotion: _heuristicEmotion(features), probabilities: null);
  }

  List<double> _temperProbs(List<double> p, {required double temperature}) {
    final powered =
        p.map((x) => math.pow(math.max(x, 1e-9), 1 / temperature).toDouble()).toList();
    final s = powered.fold(0.0, (a, b) => a + b);
    if (s <= 0) return p;
    return powered.map((x) => x / s).toList();
  }

  List<double> _mixUniform(List<double> p, {required double mix}) {
    final k = p.length;
    final u = 1.0 / k;
    final m = mix.clamp(0.0, 1.0);
    return List.generate(k, (i) => p[i] * (1 - m) + u * m);
  }

  double _stressAnchor(String label) {
    return switch (label) {
      'tense' => 62.0,
      'joyful' => 32.0,
      _ => 22.0,
    };
  }

  double _stressFromProbabilities(List<double> probs) {
    var weighted = 0.0;
    for (var i = 0; i < probs.length && i < _labels.length; i++) {
      weighted += probs[i] * _stressAnchor(_labels[i]);
    }
    return weighted;
  }

  double _mfccBandEnergy(List<double> features, int start, int end) {
    if (features.isEmpty) return 0;
    final lo = start.clamp(0, features.length);
    final hi = end.clamp(lo, features.length);
    if (hi <= lo) return 0;
    var sum = 0.0;
    for (var i = lo; i < hi; i++) {
      sum += features[i].abs();
    }
    return sum / (hi - lo);
  }

  double _acousticStress(
    List<double> features,
    double rms,
    double peak,
    String emotion,
  ) {
    if (features.isEmpty) {
      return (18 + rms * 200 + peak * 90).clamp(12.0, 88.0);
    }

    final energy =
        features.map((f) => f.abs()).reduce((a, b) => a + b) / features.length;
    final variability = _std(features);
    final lowBand = _mfccBandEnergy(features, 0, 6);
    final midBand = _mfccBandEnergy(features, 6, 14);
    final highBand = _mfccBandEnergy(features, 14, features.length);
    final dynamicRange = peak - rms;

    var stress = 12.0 +
        rms * 240 +
        peak * 95 +
        dynamicRange * 55 +
        variability * 3.4 +
        energy * 2.4 +
        midBand * 2.8 +
        highBand * 3.2 -
        lowBand * 0.9;

    stress += switch (emotion) {
      'tense' => 6.0,
      'joyful' => -7.0,
      _ => 0.0,
    };

    return stress.clamp(10.0, 90.0);
  }

  double _probabilityEntropy(List<double> probs) {
    var h = 0.0;
    for (final p in probs) {
      if (p > 1e-9) {
        h -= p * math.log(p);
      }
    }
    return h;
  }

  double _computeStress({
    required String emotion,
    required List<double> features,
    required double rms,
    required double peak,
    List<double>? probabilities,
  }) {
    final acoustic = _acousticStress(features, rms, peak, emotion);

    if (probabilities != null && probabilities.length == _labels.length) {
      final modelStress = _stressFromProbabilities(probabilities);
      final entropy = _probabilityEntropy(probabilities);
      final uncertainty = (entropy / math.log(probabilities.length)).clamp(0.0, 1.0);
      final blended = acoustic * 0.62 +
          modelStress * 0.28 +
          uncertainty * 18;
      return blended.clamp(8.0, 94.0);
    }

    return acoustic.clamp(8.0, 94.0);
  }

  String _heuristicEmotion(List<double> features) {
    if (features.isEmpty) return 'calm';
    final energy =
        features.map((f) => f.abs()).reduce((a, b) => a + b) / features.length;
    final variability = _std(features);
    if (variability > 10 && energy < 4.5) return 'calm';
    if (variability > 8) return 'tense';
    if (energy > 5) return 'joyful';
    return 'calm';
  }

  double _std(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        values.length;
    return math.sqrt(variance);
  }

  MoodResult _emotionToMoodResult(
    String emotion,
    List<double> features, {
    List<double>? probabilities,
    required double rms,
    required double peak,
  }) {
    final stress = _computeStress(
      emotion: emotion,
      features: features,
      rms: rms,
      peak: peak,
      probabilities: probabilities,
    );
    final resonance = (100 - stress).round().clamp(0, 100);

    return MoodResult(
      stressLevel: stress,
      moodLabel: emotion,
      tags: _tagsFor(emotion),
      resonancePercent: resonance,
      emotion: emotion,
      insightHeadline: '${emotion}_headline',
      insightBody: 'analysis_body',
      rawMlPayload: <String, dynamic>{
        'emotion': emotion,
        'stress': stress,
        'rms': rms,
        'peak': peak,
        'mfcc_mean': features,
        'on_device': true,
        if (probabilities != null) 'probs': probabilities,
      },
    );
  }

  List<String> _tagsFor(String emotion) => switch (emotion) {
        'tense' => const ['variability', 'transients'],
        'joyful' => const ['bright', 'energy'],
        _ => const ['consistent', 'warm'],
      };

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
  }
}
