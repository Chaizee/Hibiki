import '../core/config/app_config.dart';
import '../data/api/sanctuary_api_client.dart';
import '../data/models/mood_result.dart';
import 'local_mood_classifier.dart';

/// Bridges local audio file → on-device TFLite (or API when configured).
class VoiceAnalysisService {
  VoiceAnalysisService({
    required SanctuaryApiClient api,
    LocalMoodClassifier? localClassifier,
  })  : _api = api,
        _local = localClassifier ?? LocalMoodClassifier();

  final SanctuaryApiClient _api;
  final LocalMoodClassifier _local;

  Future<void> initialize() => _local.initialize();

  Future<MoodResult> analyzeVoice(String audioFilePath) async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return MoodResult.mockSample();
    }
    if (AppConfig.useOnDeviceModel) {
      return _local.analyzeFile(audioFilePath);
    }
    return _api.analyzeVoice(audioFilePath);
  }

  void dispose() => _local.dispose();
}
