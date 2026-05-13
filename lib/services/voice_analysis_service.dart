import '../core/config/app_config.dart';
import '../data/api/sanctuary_api_client.dart';
import '../data/models/mood_result.dart';

/// Bridges local audio file → backend ML. Toggle behavior with [AppConfig.useMockApi].
class VoiceAnalysisService {
  VoiceAnalysisService({required SanctuaryApiClient api}) : _api = api;

  final SanctuaryApiClient _api;

  Future<MoodResult> analyzeVoice(String audioFilePath) async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return MoodResult.mockSample();
    }
    return _api.analyzeVoice(audioFilePath);
  }
}
