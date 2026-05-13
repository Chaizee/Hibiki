import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Wraps `record` so you can swap implementations (e.g. Web) later.
class VoiceRecordingService {
  VoiceRecordingService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _activePath;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start() async {
    final allowed = await hasPermission();
    if (!allowed) {
      throw StateError('Microphone permission not granted');
    }
    final dir = await getTemporaryDirectory();
    final ext = _encoder == AudioEncoder.wav ? 'wav' : 'm4a';
    _activePath =
        '${dir.path}/sanctuary_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _recorder.start(
      RecordConfig(encoder: _encoder, bitRate: 128000, sampleRate: 44100),
      path: _activePath!,
    );
  }

  AudioEncoder get _encoder {
    if (kIsWeb) return AudioEncoder.wav;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return AudioEncoder.wav;
      default:
        return AudioEncoder.aacLc;
    }
  }

  Future<String?> stop() async {
    final path = await _recorder.stop();
    _activePath = null;
    return path;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}