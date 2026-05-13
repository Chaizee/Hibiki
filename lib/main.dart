import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/sanctuary_app.dart';
import 'core/config/app_config.dart';
import 'data/api/sanctuary_api_client.dart';
import 'services/voice_analysis_service.dart';
import 'services/voice_recording_service.dart';
import 'state/sanctuary_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final api = SanctuaryApiClient(baseUrl: AppConfig.apiBaseUrl);
  final recording = VoiceRecordingService();
  final analysis = VoiceAnalysisService(api: api);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SanctuaryState(
        api: api,
        recording: recording,
        analysis: analysis,
      )..initialize(),
      child: const SanctuaryApp(),
    ),
  );
}
