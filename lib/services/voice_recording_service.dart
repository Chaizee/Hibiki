import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'audio_mfcc_config.dart';

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
    _activePath =
        '${dir.path}/sanctuary_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: AudioMfccConfig.sampleRate,
        numChannels: 1,
        bitRate: 128000,
      ),
      path: _activePath!,
    );
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