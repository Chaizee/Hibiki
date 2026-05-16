import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'audio_mfcc_config.dart';

/// Extracts MFCC features from WAV audio using the same pipeline as the training notebook.
class AudioFeatureExtractor {
  const AudioFeatureExtractor();

  Future<List<double>> extractFromFile(String path) async {
    final bytes = await File(path).readAsBytes();
    return extractFromWavBytes(bytes);
  }

  /// RMS and peak (absolute sample) after resample + trim.
  Future<({double rms, double peak})> signalMetricsFromFile(String path) async {
    final bytes = await File(path).readAsBytes();
    final pcm = _decodeWavPcm(bytes);
    final mono16k = _toMono16k(pcm.samples, pcm.sampleRate);
    final trimmed = _fitDuration(mono16k, AudioMfccConfig.targetSamples);
    var peak = 0.0;
    for (final s in trimmed) {
      final a = s.abs();
      if (a > peak) peak = a;
    }
    return (rms: _rms(trimmed), peak: peak);
  }

  Future<double> rmsEnergyFromFile(String path) async {
    final m = await signalMetricsFromFile(path);
    return m.rms;
  }

  double _rms(List<double> samples) {
    if (samples.isEmpty) return 0;
    var sumSq = 0.0;
    for (final s in samples) {
      sumSq += s * s;
    }
    return math.sqrt(sumSq / samples.length);
  }

  List<double> extractFromWavBytes(Uint8List bytes) {
    final pcm = _decodeWavPcm(bytes);
    final mono16k = _toMono16k(pcm.samples, pcm.sampleRate);
    final trimmed = _fitDuration(mono16k, AudioMfccConfig.targetSamples);
    final mfccFrames = _computeMfccFrames(trimmed);
    return _meanPool(mfccFrames, AudioMfccConfig.nMfcc);
  }

  _WavPcm _decodeWavPcm(Uint8List bytes) {
    if (bytes.length < 44) {
      throw FormatException('Invalid WAV: too short');
    }
    final bd = ByteData.sublistView(bytes);
    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    if (riff != 'RIFF') throw FormatException('Not a RIFF/WAV file');

    var offset = 12;
    var sampleRate = 16000;
    var bitsPerSample = 16;
    var channels = 1;
    Uint8List? data;

    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = bd.getUint32(offset + 4, Endian.little);
      final chunkStart = offset + 8;
      if (chunkId == 'fmt ') {
        channels = bd.getUint16(chunkStart + 2, Endian.little);
        sampleRate = bd.getUint32(chunkStart + 4, Endian.little);
        bitsPerSample = bd.getUint16(chunkStart + 14, Endian.little);
      } else if (chunkId == 'data') {
        data = bytes.sublist(chunkStart, chunkStart + chunkSize);
      }
      offset = chunkStart + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (data == null) throw FormatException('WAV data chunk missing');

    final samples = <double>[];
    if (bitsPerSample == 16) {
      final pcmBd = ByteData.sublistView(data);
      final frameCount = data.length ~/ (2 * channels);
      for (var i = 0; i < frameCount; i++) {
        var sum = 0.0;
        for (var c = 0; c < channels; c++) {
          final raw = pcmBd.getInt16((i * channels + c) * 2, Endian.little);
          sum += raw / 32768.0;
        }
        samples.add(sum / channels);
      }
    } else {
      throw FormatException('Only 16-bit PCM WAV is supported');
    }

    return _WavPcm(samples: samples, sampleRate: sampleRate);
  }

  List<double> _toMono16k(List<double> samples, int sourceRate) {
    if (sourceRate == AudioMfccConfig.sampleRate) return samples;
    final ratio = sourceRate / AudioMfccConfig.sampleRate;
    final outLen = (samples.length / ratio).floor();
    final out = List<double>.filled(outLen, 0);
    for (var i = 0; i < outLen; i++) {
      final src = i * ratio;
      final i0 = src.floor().clamp(0, samples.length - 1);
      final i1 = (i0 + 1).clamp(0, samples.length - 1);
      final t = src - i0;
      out[i] = samples[i0] * (1 - t) + samples[i1] * t;
    }
    return out;
  }

  List<double> _fitDuration(List<double> samples, int targetLen) {
    if (samples.length == targetLen) return samples;
    if (samples.length > targetLen) {
      return samples.sublist(0, targetLen);
    }
    return [...samples, ...List<double>.filled(targetLen - samples.length, 0)];
  }

  List<List<double>> _computeMfccFrames(List<double> samples) {
    const preEmphasis = 0.97;
    final emphasized = List<double>.generate(samples.length, (i) {
      if (i == 0) return samples[i];
      return samples[i] - preEmphasis * samples[i - 1];
    });

    final frames = <List<double>>[];
    final frameLen = AudioMfccConfig.nFft;
    final hop = AudioMfccConfig.hopLength;
    for (var start = 0; start + frameLen <= emphasized.length; start += hop) {
      final frame = emphasized.sublist(start, start + frameLen);
      final windowed = List<double>.generate(frameLen, (n) {
        final hann = 0.5 * (1 - math.cos(2 * math.pi * n / (frameLen - 1)));
        return frame[n] * hann;
      });
      final powerSpec = _powerSpectrum(windowed);
      final melEnergies = _applyMelFilterbank(powerSpec);
      final logMel = melEnergies.map((e) => math.log(e + 1e-10)).toList();
      frames.add(_dct(logMel, AudioMfccConfig.nMfcc));
    }
    return frames;
  }

  List<double> _powerSpectrum(List<double> frame) {
    final n = frame.length;
    final real = Float64List(n);
    final imag = Float64List(n);
    for (var i = 0; i < n; i++) {
      real[i] = frame[i];
    }
    _fft(real, imag);
    final half = n ~/ 2 + 1;
    return List<double>.generate(half, (k) {
      return real[k] * real[k] + imag[k] * imag[k];
    });
  }

  void _fft(Float64List real, Float64List imag) {
    final n = real.length;
    var j = 0;
    for (var i = 0; i < n; i++) {
      if (i < j) {
        final tr = real[i];
        real[i] = real[j];
        real[j] = tr;
        final ti = imag[i];
        imag[i] = imag[j];
        imag[j] = ti;
      }
      var m = n >> 1;
      while (m >= 1 && j >= m) {
        j -= m;
        m >>= 1;
      }
      j += m;
    }
    for (var len = 2; len <= n; len <<= 1) {
      final ang = -2 * math.pi / len;
      final wlenR = math.cos(ang);
      final wlenI = math.sin(ang);
      for (var i = 0; i < n; i += len) {
        var wR = 1.0;
        var wI = 0.0;
        for (var k = 0; k < len ~/ 2; k++) {
          final uR = real[i + k];
          final uI = imag[i + k];
          final vR = real[i + k + len ~/ 2] * wR - imag[i + k + len ~/ 2] * wI;
          final vI = real[i + k + len ~/ 2] * wI + imag[i + k + len ~/ 2] * wR;
          real[i + k] = uR + vR;
          imag[i + k] = uI + vI;
          real[i + k + len ~/ 2] = uR - vR;
          imag[i + k + len ~/ 2] = uI - vI;
          final nextWR = wR * wlenR - wI * wlenI;
          wI = wR * wlenI + wI * wlenR;
          wR = nextWR;
        }
      }
    }
  }

  List<double> _applyMelFilterbank(List<double> powerSpec) {
    final nMels = AudioMfccConfig.nMels;
    final sr = AudioMfccConfig.sampleRate;
    final nFft = AudioMfccConfig.nFft;
    final fMax = sr / 2.0;

    double hzToMel(double hz) => 2595 * (math.log(1 + hz / 700) / math.ln10);
    double melToHz(double mel) => 700 * (math.pow(10, mel / 2595) - 1);

    final melMin = hzToMel(0);
    final melMax = hzToMel(fMax);
    final melPoints = List<double>.generate(
      nMels + 2,
      (i) => melMin + (melMax - melMin) * i / (nMels + 1),
    );
    final hzPoints = melPoints.map(melToHz).toList();
    final bins = hzPoints
        .map((hz) => ((nFft + 1) * hz / sr).floor().clamp(0, powerSpec.length - 1))
        .toList();

    final filters = List.generate(nMels, (m) {
      final filter = List<double>.filled(powerSpec.length, 0);
      for (var k = bins[m]; k < bins[m + 1] && k < filter.length; k++) {
        filter[k] = (k - bins[m]) / (bins[m + 1] - bins[m] + 1e-9);
      }
      for (var k = bins[m + 1]; k < bins[m + 2] && k < filter.length; k++) {
        filter[k] = (bins[m + 2] - k) / (bins[m + 2] - bins[m + 1] + 1e-9);
      }
      return filter;
    });

    return List<double>.generate(nMels, (m) {
      var sum = 0.0;
      for (var k = 0; k < powerSpec.length; k++) {
        sum += powerSpec[k] * filters[m][k];
      }
      return sum;
    });
  }

  List<double> _dct(List<double> input, int nCoeffs) {
    final n = input.length;
    return List<double>.generate(nCoeffs, (k) {
      var sum = 0.0;
      for (var i = 0; i < n; i++) {
        sum += input[i] * math.cos(math.pi * k * (i + 0.5) / n);
      }
      return sum;
    });
  }

  List<double> _meanPool(List<List<double>> frames, int nMfcc) {
    if (frames.isEmpty) return List<double>.filled(nMfcc, 0);
    final out = List<double>.filled(nMfcc, 0);
    for (final frame in frames) {
      for (var i = 0; i < nMfcc; i++) {
        out[i] += frame[i];
      }
    }
    return out.map((v) => v / frames.length).toList();
  }
}

class _WavPcm {
  const _WavPcm({required this.samples, required this.sampleRate});
  final List<double> samples;
  final int sampleRate;
}
