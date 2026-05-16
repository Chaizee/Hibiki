import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../data/api/sanctuary_api_client.dart';
import '../data/models/journal_entry.dart';
import '../data/models/me_profile_models.dart';
import '../data/models/mood_day_record.dart';
import '../data/models/mood_result.dart';
import '../data/models/recommendation.dart';
import '../data/models/streak_stats.dart';
import '../data/repositories/journal_repository.dart';
import '../data/repositories/mood_history_repository.dart';
import '../services/me_stats_service.dart';
import '../services/streak_calculator.dart';
import '../services/voice_analysis_service.dart';
import '../services/voice_recording_service.dart';

enum VoiceSessionPhase { idle, recording, processing }

class SanctuaryState extends ChangeNotifier {
  SanctuaryState({
    required SanctuaryApiClient api,
    required VoiceRecordingService recording,
    required VoiceAnalysisService analysis,
    MoodHistoryRepository? moodHistoryRepository,
    JournalRepository? journalRepository,
    StreakCalculator? streakCalculator,
  })  : _api = api,
        _recording = recording,
        _analysis = analysis,
        _moodHistoryRepo = moodHistoryRepository ?? MoodHistoryRepository(),
        _journalRepo = journalRepository ?? JournalRepository(),
        _streakCalculator = streakCalculator ?? StreakCalculator(),
        _meStats = MeStatsService();

  final SanctuaryApiClient _api;
  final VoiceRecordingService _recording;
  final VoiceAnalysisService _analysis;
  final MoodHistoryRepository _moodHistoryRepo;
  final JournalRepository _journalRepo;
  final StreakCalculator _streakCalculator;
  final MeStatsService _meStats;

  int tabIndex = 0;

  VoiceSessionPhase phase = VoiceSessionPhase.idle;
  MoodResult? lastResult;
  String? lastError;

  Map<String, MoodDayRecord> moodByDate = {};
  StreakStats streakStats = StreakStats.empty;

  String? calendarRevealDateKey;

  List<Recommendation> recommendations = _defaultRecommendations();
  List<JournalEntry> journalEntries = [];

  String notesPulseKey = 'steady';

  Future<void> initialize() async {
    await _analysis.initialize();
    moodByDate = await _moodHistoryRepo.loadAll();
    journalEntries = await _journalRepo.loadAll();
    _recomputeStreak();
    await refreshRecommendations();
    notifyListeners();
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

  void _recomputeStreak() {
    streakStats = _streakCalculator.compute(moodByDate.keys.toSet());
  }

  List<DayBalancePoint> get last7DayBalance =>
      _meStats.last7DayBalance(moodByDate);

  WeeklyVibeSummary get weeklyVibe => _meStats.weeklyVibe(moodByDate);

  String get explorerTitleKey =>
      _meStats.explorerTitleKey(streakStats, moodByDate);

  List<MilestoneItem> get milestones => _meStats.milestones(
        streak: streakStats,
        moodByDate: moodByDate,
        journalCount: journalEntries.length,
      );

  Map<String, int> get emotionDayCounts {
    final counts = {'calm': 0, 'joyful': 0, 'tense': 0};
    for (final record in moodByDate.values) {
      if (counts.containsKey(record.emotion)) {
        counts[record.emotion] = counts[record.emotion]! + 1;
      }
    }
    return counts;
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  void setNotesPulseKey(String key) {
    notesPulseKey = key;
    notifyListeners();
  }

  void clearCalendarReveal() {
    if (calendarRevealDateKey == null) return;
    calendarRevealDateKey = null;
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
      await _persistVoiceResult(lastResult!);
      phase = VoiceSessionPhase.idle;
      notifyListeners();
    } catch (e, st) {
      debugPrint('analyze: $e\n$st');
      phase = VoiceSessionPhase.idle;
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> _persistVoiceResult(MoodResult result) async {
    final now = DateTime.now();
    final key = MoodDayRecord.dateKeyFrom(now);
    final emotion = result.emotion ?? _emotionFromStress(result.stressLevel);
    final resonance =
        (result.resonancePercent ?? (100 - result.stressLevel)).toDouble();

    final record = MoodDayRecord(
      dateKey: key,
      emotion: emotion,
      resonanceScore: resonance,
      stressLevel: result.stressLevel,
      moodLabel: result.moodLabel,
      recordedAt: now,
    );

    moodByDate = {...moodByDate, key: record};
    await _moodHistoryRepo.upsert(record);
    _recomputeStreak();
    calendarRevealDateKey = key;
  }

  String _emotionFromStress(double stress) {
    if (stress >= 60) return 'tense';
    if (stress <= 35) return 'joyful';
    return 'calm';
  }

  Future<bool> saveReflection({
    required String title,
    required String body,
    List<String> tags = const [],
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return false;

    final entry = JournalEntry.create(
      title: title,
      body: trimmed,
      pulse: notesPulseKey,
    );

    if (!AppConfig.useMockApi) {
      try {
        await _api.postReflection(title: title, body: trimmed, tags: tags);
      } catch (e, st) {
        debugPrint('postReflection: $e\n$st');
      }
    }

    await _journalRepo.add(entry);
    journalEntries = await _journalRepo.loadAll();
    notifyListeners();
    return true;
  }

  Future<void> deleteJournalEntry(String id) async {
    await _journalRepo.delete(id);
    journalEntries = await _journalRepo.loadAll();
    notifyListeners();
  }

  @override
  void dispose() {
    _recording.dispose();
    _analysis.dispose();
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
}
