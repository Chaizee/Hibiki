import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/models/mood_result.dart';
import 'audio_feature_extractor.dart';
import 'audio_mfcc_config.dart';

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

  /// Below these levels (normalized waveform −1..1) ML output is unreliable → calm / low stress.
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
    );
  }

  bool _isQuietInput(double rms, double peak) {
    return rms < _silenceRmsMax && peak < _silencePeakMax;
  }

  MoodResult _silenceResult(List<double> features, double rms, double peak) {
    return MoodResult(
      stressLevel: 14,
      moodLabel: 'Quiet input',
      tags: const ['Low signal', 'Try speaking closer'],
      resonancePercent: 86,
      emotion: 'calm',
      insightHeadline: 'Almost no voice detected.',
      insightBody:
          'Речь слишком тихая или далеко от микрофона — почти нет сигнала (RMS ${rms.toStringAsFixed(4)}, peak ${peak.toStringAsFixed(4)}).',
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

  /// Softmax output from TFLite (same order as [labels.txt]).
  ({String emotion, List<double>? probabilities}) _predictFromModel(
    List<double> features,
  ) {
    final interpreter = _interpreter;
    if (interpreter != null) {
      final input = [features];
      final output = [List<double>.filled(_labels.length, 0)];
      interpreter.run(input, output);
      var probs = List<double>.from(output[0]);
      var sum = probs.fold(0.0, (a, b) => a + b);
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
      final confidence = bestVal;

      // Weak / flat softmax → heuristic label; stress still uses softened probs below when non-null.
      if (confidence < 0.42) {
        return (emotion: _heuristicEmotion(features), probabilities: null);
      }

      // Softer distribution so one hot argmax does not always map to fixed 72% stress.
      probs = _temperProbs(probs, temperature: 1.35);
      if (confidence < 0.55) {
        probs = _mixUniform(probs, mix: 0.22);
      }

      bestIdx = 0;
      bestVal = probs[0];
      for (var i = 1; i < probs.length; i++) {
        if (probs[i] > bestVal) {
          bestVal = probs[i];
          bestIdx = i;
        }
      }
      final emotion = _labels[bestIdx.clamp(0, _labels.length - 1)];
      return (emotion: emotion, probabilities: probs);
    }
    return (emotion: _heuristicEmotion(features), probabilities: null);
  }

  /// Raise probabilities to 1/T then renormalize (T>1 → smoother).
  List<double> _temperProbs(List<double> p, {required double temperature}) {
    final powered = p.map((x) => math.pow(math.max(x, 1e-9), 1 / temperature)).toList();
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
      'tense' => 58.0,
      'joyful' => 30.0,
      _ => 22.0,
    };
  }

  double _stressFromProbabilities(List<double> probs) {
    var num = 0.0;
    var den = 0.0;
    for (var i = 0; i < probs.length && i < _labels.length; i++) {
      num += probs[i] * _stressAnchor(_labels[i]);
      den += probs[i];
    }
    if (den <= 1e-9) return 28.0;
    return (num / den).clamp(18.0, 76.0);
  }

  String _heuristicEmotion(List<double> features) {
    if (features.isEmpty) return 'calm';
    final energy = features.map((f) => f.abs()).reduce((a, b) => a + b) / features.length;
    final variability = _std(features);
    // Noise-like MFCCs without loud speech → calm.
    if (variability > 10 && energy < 4.5) return 'calm';
    if (variability > 8) return 'tense';
    if (energy > 5) return 'joyful';
    return 'calm';
  }

  double _std(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  MoodResult _emotionToMoodResult(
    String emotion,
    List<double> features, {
    List<double>? probabilities,
  }) {
    final stress = probabilities != null && probabilities.length == _labels.length
        ? _stressFromProbabilities(probabilities)
        : switch (emotion) {
            'tense' => 58.0,
            'joyful' => 30.0,
            _ => 22.0,
          };
    final resonance = (100 - stress).round().clamp(0, 100);
    final label = switch (emotion) {
      'tense' => 'Tense & Heavy',
      'joyful' => 'Joyful & Bright',
      _ => 'Serene & Calm',
    };
    final tags = switch (emotion) {
      'tense' => const ['Elevated Variability', 'Sharp Transients'],
      'joyful' => const ['Bright Tone', 'Higher Energy'],
      _ => const ['Consistent Frequency', 'Warm Tone'],
    };

    return MoodResult(
      stressLevel: stress,
      moodLabel: label,
      tags: tags,
      resonancePercent: resonance,
      emotion: emotion,
      insightHeadline: switch (emotion) {
        'tense' => 'Your voice carries extra tension today.',
        'joyful' => 'Your tone sounds open and energized.',
        _ => 'Your voice tends to be deeper on calm days.',
      },
      insightBody:
          'Analysis used ${AudioMfccConfig.nMfcc} MFCC coefficients at ${AudioMfccConfig.sampleRate} Hz.',
      rawMlPayload: <String, dynamic>{
        'emotion': emotion,
        'mfcc_mean': features,
        'on_device': true,
        if (probabilities != null) 'probs': probabilities,
      },
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
  }
}
