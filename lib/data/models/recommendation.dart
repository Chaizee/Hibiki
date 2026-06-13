import 'package:flutter/material.dart';

class Recommendation {
  const Recommendation({
    required this.id,
    required this.title,
    this.subtitle,
    this.durationLabel,
    this.icon = Icons.self_improvement,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? durationLabel;
  final IconData icon;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String? ?? json['title'] as String? ?? 'item',
      title: json['title'] as String? ?? 'Practice',
      subtitle: json['subtitle'] as String?,
      durationLabel: json['duration'] as String?,
      icon: _iconFromKey(json['icon'] as String?),
    );
  }

  static IconData _iconFromKey(String? key) {
    switch (key) {
      case 'headphones':
        return Icons.headphones;
      case 'air':
        return Icons.air;
      case 'mic':
        return Icons.mic_none_rounded;
      default:
        return Icons.spa_outlined;
    }
  }
}
