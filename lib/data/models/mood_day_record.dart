import 'package:flutter/material.dart';

/// One calendar day filled after a successful voice check-in.
class MoodDayRecord {
  const MoodDayRecord({
    required this.dateKey,
    required this.emotion,
    required this.resonanceScore,
    required this.stressLevel,
    required this.moodLabel,
    this.recordedAt,
  });

  final String dateKey;
  final String emotion;
  final double resonanceScore;
  final double stressLevel;
  final String moodLabel;
  final DateTime? recordedAt;

  DateTime get date {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  Color get moodColor {
    switch (emotion) {
      case 'calm':
        return const Color(0xFFA8C2B6);
      case 'joyful':
        return const Color(0xFFDED5BB);
      case 'tense':
        return const Color(0xFFE3B8B8);
      default:
        if (resonanceScore >= 75) return const Color(0xFFA8C2B6);
        if (resonanceScore >= 50) return const Color(0xFFDED5BB);
        return const Color(0xFFE3B8B8);
    }
  }

  IconData get emotionIcon {
    switch (emotion) {
      case 'calm':
        return Icons.spa_outlined;
      case 'joyful':
        return Icons.pets;
      case 'tense':
        return Icons.cloud_outlined;
      default:
        return Icons.favorite_border;
    }
  }

  factory MoodDayRecord.fromJson(Map<String, dynamic> json) {
    return MoodDayRecord(
      dateKey: json['date_key'] as String,
      emotion: json['emotion'] as String? ?? 'calm',
      resonanceScore: (json['resonance_score'] as num).toDouble(),
      stressLevel: (json['stress_level'] as num).toDouble(),
      moodLabel: json['mood_label'] as String? ?? 'Balanced',
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'date_key': dateKey,
        'emotion': emotion,
        'resonance_score': resonanceScore,
        'stress_level': stressLevel,
        'mood_label': moodLabel,
        if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
      };

  static String dateKeyFrom(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static MoodDayRecord emptyPlaceholder(DateTime dt) {
    return MoodDayRecord(
      dateKey: dateKeyFrom(dt),
      emotion: '',
      resonanceScore: 0,
      stressLevel: 0,
      moodLabel: '',
    );
  }
}

extension MoodDayRecordMap on Map<String, MoodDayRecord> {
  MoodDayRecord? forDate(DateTime dt) {
  final key = MoodDayRecord.dateKeyFrom(dt);
    return this[key];
  }
}
