import 'package:flutter/material.dart';

class DayBalancePoint {
  const DayBalancePoint({
    required this.date,
    required this.weekdayIndex,
    required this.barHeight,
    required this.hasData,
    required this.isToday,
    required this.isPeak,
  });

  final DateTime date;
  final int weekdayIndex;
  final double barHeight;
  final bool hasData;
  final bool isToday;
  final bool isPeak;
}

class WeeklyVibeSummary {
  const WeeklyVibeSummary({
    required this.labelKey,
    required this.positivePercent,
    required this.icon,
    required this.daysWithData,
    required this.dominantEmotion,
  });

  final String labelKey;
  final int positivePercent;
  final IconData icon;
  final int daysWithData;
  final String? dominantEmotion;

  static const empty = WeeklyVibeSummary(
    labelKey: 'start',
    positivePercent: 0,
    icon: Icons.mic_none_rounded,
    daysWithData: 0,
    dominantEmotion: null,
  );
}

class MilestoneItem {
  const MilestoneItem({
    required this.id,
    required this.icon,
    required this.unlocked,
    this.iconBg = const Color(0xFFD9F2B1),
    this.calmDays = 0,
    this.joyfulDays = 0,
    this.totalDays = 0,
    this.journalCount = 0,
  });

  final String id;
  final IconData icon;
  final bool unlocked;
  final Color iconBg;
  final int calmDays;
  final int joyfulDays;
  final int totalDays;
  final int journalCount;
}
