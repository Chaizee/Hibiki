import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../data/api/sanctuary_api_client.dart';
import '../data/models/journal_entry.dart';
import '../data/models/mood_result.dart';
import '../data/models/recommendation.dart';
import '../services/voice_analysis_service.dart';
import '../services/voice_recording_service.dart';

enum VoiceSessionPhase { idle, recording, processing }

class SanctuaryState extends ChangeNotifier {
  SanctuaryState({
    required SanctuaryApiClient api,
    required VoiceRecordingService recording,
    required VoiceAnalysisService analysis,
  })  : _api = api,
        _recording = recording,
        _analysis = analysis;

  final SanctuaryApiClient _api;
  final VoiceRecordingService _recording;
  final VoiceAnalysisService _analysis;

  int tabIndex = 0;

  VoiceSessionPhase phase = VoiceSessionPhase.idle;
  MoodResult? lastResult;
  String? lastError;

  List<Recommendation> recommendations = _defaultRecommendations();
  List<JournalEntry> journalEntries = _seedJournal();

  String notesPulse = 'Steady';

  Future<void> initialize() async {
    await refreshRecommendations();
  }

  Future<void> refreshRecommendations() async {
    if (AppConfig.useMockApi) {
      recommendations = _defaultRecommendations();
      notifyListeners();
      return;
    }
    try {
      recommendations = await _api.getRecommendations();
    } catch (e, st) {
      debugPrint('recommendations: $e\n$st');
      recommendations = _defaultRecommendations();
    }
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  void setNotesPulse(String value) {
    notesPulse = value;
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    lastError = null;
    if (phase == VoiceSessionPhase.recording) {
      await _stopAndAnalyze();
      return;
    }
    if (phase == VoiceSessionPhase.processing) return;

    try {
      phase = VoiceSessionPhase.recording;
      notifyListeners();
      await _recording.start();
    } catch (e, st) {
      debugPrint('record start: $e\n$st');
      phase = VoiceSessionPhase.idle;
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> _stopAndAnalyze() async {
    try {
      phase = VoiceSessionPhase.processing;
      notifyListeners();
      final path = await _recording.stop();
      if (path == null || path.isEmpty) {
        throw StateError('No audio file produced');
      }
      lastResult = await _analysis.analyzeVoice(path);
      phase = VoiceSessionPhase.idle;
      notifyListeners();
    } catch (e, st) {
      debugPrint('analyze: $e\n$st');
      phase = VoiceSessionPhase.idle;
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveReflection({
    required String title,
    required String body,
    List<String> tags = const [],
  }) async {
    if (AppConfig.useMockApi) {
      journalEntries = [
        JournalEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.isEmpty ? 'Untitled' : title,
          timestamp: DateTime.now(),
          snippet: body.length > 80 ? '${body.substring(0, 80)}…' : body,
          iconKey: 'smile',
        ),
        ...journalEntries,
      ];
      notifyListeners();
      return;
    }
    await _api.postReflection(title: title, body: body, tags: tags);
    final remote = await _api.getJournalTimeline();
    journalEntries = remote;
    notifyListeners();
  }

  @override
  void dispose() {
    _recording.dispose();
    super.dispose();
  }

  static List<Recommendation> _defaultRecommendations() {
    return const [
      Recommendation(
        id: 'morning',
        title: 'Morning Reflection',
        subtitle: 'Guided flow',
        durationLabel: '5 min',
        icon: Icons.waves,
      ),
      Recommendation(
        id: 'binaural',
        title: 'Binaural Beats',
        subtitle: 'Focus & calm',
        durationLabel: '12 min',
        icon: Icons.headphones,
      ),
      Recommendation(
        id: 'breath',
        title: 'Breathing Tool',
        subtitle: 'Grounding',
        durationLabel: '3 min',
        icon: Icons.air,
      ),
    ];
  }

  static List<JournalEntry> _seedJournal() {
    final now = DateTime.now();
    return [
      JournalEntry(
        id: '1',
        title: 'Morning Clarity',
        timestamp: now.subtract(const Duration(hours: 3)),
        snippet: 'Voice check-in felt light and steady…',
        iconKey: 'smile',
      ),
      JournalEntry(
        id: '2',
        title: 'Evening Wind-down',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        snippet: 'Noticed deeper tone before sleep.',
        iconKey: 'moon',
      ),
      JournalEntry(
        id: '3',
        title: 'Midday Spark',
        timestamp: now.subtract(const Duration(days: 2)),
        snippet: 'Higher energy — logged peak moment.',
        iconKey: 'bolt',
      ),
    ];
  }
}
