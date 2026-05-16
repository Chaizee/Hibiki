/// Aggregated check-in streak metrics for the Me screen.
class StreakStats {
  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckInDays,
    required this.level,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalCheckInDays;
  final int level;

  static const empty = StreakStats(
    currentStreak: 0,
    longestStreak: 0,
    totalCheckInDays: 0,
    level: 1,
  );
}
