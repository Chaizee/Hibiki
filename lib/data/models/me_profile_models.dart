import 'package:flutter/material.dart';

/// One bar in the Emotional Balance chart (last 7 days).
class DayBalancePoint {
  const DayBalancePoint({
    required this.date,
    required this.weekdayLabel,
    required this.barHeight,
    required this.hasData,
    required this.isToday,
    required this.isPeak,
  });

  final DateTime date;
  final String weekdayLabel;
  final double barHeight;
  final bool hasData;
  final bool isToday;
  final bool isPeak;
}

class WeeklyVibeSummary {
  const WeeklyVibeSummary({
    required this.label,
    required this.positivePercent,
    required this.icon,
    required this.daysWithData,
    required this.dominantEmotion,
  });

  final String label;
  final int positivePercent;
  final IconData icon;
  final int daysWithData;
  final String? dominantEmotion;

  static const empty = WeeklyVibeSummary(
    label: 'Начните путь',
    positivePercent: 0,
    icon: Icons.mic_none_rounded,
    daysWithData: 0,
    dominantEmotion: null,
  );
}

class MilestoneItem {
  const MilestoneItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unlocked,
    this.iconBg = const Color(0xFFD9F2B1),
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool unlocked;
  final Color iconBg;
}
