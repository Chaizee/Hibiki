/// Compile-time configuration for API and ML pipeline.
///
/// Run with backend:
/// `flutter run --dart-define=SANCTUARY_API_BASE=https://your.api --dart-define=MOCK_API=false`
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'SANCTUARY_API_BASE',
    defaultValue: 'https://api.resonant-sanctuary.example',
  );

  /// When true, [VoiceAnalysisService] skips HTTP and returns a deterministic sample.
  static const bool useMockApi = bool.fromEnvironment(
    'MOCK_API',
    defaultValue: false,
  );

  /// When true (and mock is off), runs [LocalMoodClassifier] inside the app.
  static const bool useOnDeviceModel = bool.fromEnvironment(
    'ON_DEVICE_ML',
    defaultValue: true,
  );
}
