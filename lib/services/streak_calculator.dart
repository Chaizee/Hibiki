import '../data/models/mood_day_record.dart';
import '../data/models/streak_stats.dart';

class StreakCalculator {
  StreakStats compute(Set<String> dateKeys) {
    if (dateKeys.isEmpty) return StreakStats.empty;

    final sorted = dateKeys.map(DateTime.parse).toList()..sort();
    final longest = _longestStreak(sorted);
    final current = _currentStreak(dateKeys);
    final total = dateKeys.length;
    final level = (total / 7).floor() + 1;

    return StreakStats(
      currentStreak: current,
      longestStreak: longest,
      totalCheckInDays: total,
      level: level.clamp(1, 99),
    );
  }

  int _currentStreak(Set<String> dateKeys) {
    final today = MoodDayRecord.dateKeyFrom(DateTime.now());
    final yesterday = MoodDayRecord.dateKeyFrom(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    String startKey;
    if (dateKeys.contains(today)) {
      startKey = today;
    } else if (dateKeys.contains(yesterday)) {
      startKey = yesterday;
    } else {
      return 0;
    }

    var cursor = DateTime.parse(startKey);
    var streak = 0;
    while (dateKeys.contains(MoodDayRecord.dateKeyFrom(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _longestStreak(List<DateTime> sorted) {
    if (sorted.isEmpty) return 0;
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        run++;
        if (run > best) best = run;
      } else if (diff > 1) {
        run = 1;
      }
    }
    return best;
  }
}
