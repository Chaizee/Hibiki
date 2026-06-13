import 'package:flutter/material.dart';

import '../data/models/me_profile_models.dart';
import '../data/models/mood_day_record.dart';
import '../data/models/streak_stats.dart';

class MeStatsService {
  List<DayBalancePoint> last7DayBalance(Map<String, MoodDayRecord> moodByDate) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final points = <DayBalancePoint>[];

    for (var i = 6; i >= 0; i--) {
      final date = todayDate.subtract(Duration(days: i));
      final record = moodByDate[MoodDayRecord.dateKeyFrom(date)];
      final hasData = record != null && record.emotion.isNotEmpty;
      final resonance = record?.resonanceScore ?? 0;
      final barHeight = hasData ? (resonance / 100).clamp(0.22, 1.0) : 0.14;
      points.add(
        DayBalancePoint(
          date: date,
          weekdayIndex: date.weekday,
          barHeight: barHeight,
          hasData: hasData,
          isToday: i == 0,
          isPeak: false,
        ),
      );
    }

    final withData = points.where((p) => p.hasData).toList();
    if (withData.isEmpty) return points;

    var peakIdx = 0;
    var peakVal = -1.0;
    for (var i = 0; i < points.length; i++) {
      if (!points[i].hasData) continue;
      final key = MoodDayRecord.dateKeyFrom(points[i].date);
      final r = moodByDate[key]!.resonanceScore;
      if (r > peakVal) {
        peakVal = r;
        peakIdx = i;
      }
    }
    final peakDate = points[peakIdx].date;
    return points
        .map(
          (p) => DayBalancePoint(
            date: p.date,
            weekdayIndex: p.weekdayIndex,
            barHeight: p.barHeight,
            hasData: p.hasData,
            isToday: p.isToday,
            isPeak: p.date == peakDate && p.hasData,
          ),
        )
        .toList();
  }

  WeeklyVibeSummary weeklyVibe(Map<String, MoodDayRecord> moodByDate) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final records = <MoodDayRecord>[];

    for (var i = 0; i < 7; i++) {
      final date = todayDate.subtract(Duration(days: i));
      final r = moodByDate[MoodDayRecord.dateKeyFrom(date)];
      if (r != null && r.emotion.isNotEmpty) records.add(r);
    }

    if (records.isEmpty) return WeeklyVibeSummary.empty;

    final avgResonance =
        records.map((r) => r.resonanceScore).reduce((a, b) => a + b) / records.length;
    final avgStress =
        records.map((r) => r.stressLevel).reduce((a, b) => a + b) / records.length;
    final positive = avgResonance.round().clamp(0, 100);

    final emotionCounts = <String, int>{};
    for (final r in records) {
      emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
    }
    final dominant = emotionCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return WeeklyVibeSummary(
      labelKey: _vibeLabelKey(avgStress, dominant),
      positivePercent: positive,
      icon: _vibeIcon(dominant, avgStress),
      daysWithData: records.length,
      dominantEmotion: dominant,
    );
  }

  String explorerTitleKey(StreakStats streak, Map<String, MoodDayRecord> moodByDate) {
    if (streak.totalCheckInDays == 0) return 'default';
    if (streak.level >= 8) return 'master';
    if (streak.level >= 4) return 'mentor';
    if (streak.currentStreak >= 7) return 'rhythm';
    final vibe = weeklyVibe(moodByDate);
    return switch (vibe.dominantEmotion) {
      'joyful' => 'bright',
      'tense' => 'seeker',
      'calm' => 'calm',
      _ => 'default',
    };
  }

  List<MilestoneItem> milestones({
    required StreakStats streak,
    required Map<String, MoodDayRecord> moodByDate,
    required int journalCount,
  }) {
    final calmDays = moodByDate.values.where((r) => r.emotion == 'calm').length;
    final joyfulDays = moodByDate.values.where((r) => r.emotion == 'joyful').length;
    final total = streak.totalCheckInDays;

    return [
      MilestoneItem(
        id: 'first',
        icon: Icons.workspace_premium,
        unlocked: total >= 1,
        totalDays: total,
      ),
      MilestoneItem(
        id: 'week',
        icon: Icons.local_fire_department,
        unlocked: streak.longestStreak >= 7,
        totalDays: total,
      ),
      MilestoneItem(
        id: 'sleep',
        icon: Icons.nightlight_round,
        unlocked: total >= 7,
        iconBg: const Color(0xFFE5E5E5),
        totalDays: total,
      ),
      MilestoneItem(
        id: 'calm',
        icon: Icons.spa_outlined,
        unlocked: calmDays >= 5,
        iconBg: const Color(0xFFD9E8E1),
        calmDays: calmDays,
        totalDays: total,
      ),
      MilestoneItem(
        id: 'joy',
        icon: Icons.auto_awesome,
        unlocked: joyfulDays >= 3,
        iconBg: const Color(0xFFFFF3C4),
        joyfulDays: joyfulDays,
        totalDays: total,
      ),
      MilestoneItem(
        id: 'journal',
        icon: Icons.menu_book_outlined,
        unlocked: journalCount >= 3,
        iconBg: const Color(0xFFE8E4DC),
        journalCount: journalCount,
        totalDays: total,
      ),
    ];
  }

  String _vibeLabelKey(double avgStress, String emotion) {
    if (avgStress < 35) {
      return emotion == 'joyful' ? 'radiant' : 'harmonious';
    }
    if (avgStress < 60) return 'balanced';
    return 'heavy';
  }

  IconData _vibeIcon(String emotion, double avgStress) {
    if (avgStress >= 60) return Icons.cloud_outlined;
    return switch (emotion) {
      'joyful' => Icons.sentiment_very_satisfied_outlined,
      'tense' => Icons.sentiment_neutral_outlined,
      _ => Icons.sentiment_satisfied_alt_outlined,
    };
  }
}
