import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hibiki1/app/sanctuary_app.dart';
import 'package:hibiki1/core/config/app_config.dart';
import 'package:hibiki1/data/api/sanctuary_api_client.dart';
import 'package:hibiki1/services/voice_analysis_service.dart';
import 'package:hibiki1/services/voice_recording_service.dart';
import 'package:hibiki1/state/sanctuary_state.dart';

void main() {
  testWidgets('Sanctuary shell shows Listen tab', (WidgetTester tester) async {
    final api = SanctuaryApiClient(baseUrl: AppConfig.apiBaseUrl);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SanctuaryState(
          api: api,
          recording: VoiceRecordingService(),
          analysis: VoiceAnalysisService(api: api),
        )..initialize(),
        child: const SanctuaryApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resonant Sanctuary'), findsWidgets);
    expect(find.text('RECORD'), findsOneWidget);
  });
}
