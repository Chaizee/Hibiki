import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../data/models/journal_entry.dart';

class TimelineItem extends StatelessWidget {
  const TimelineItem({super.key, required this.entry});

  final JournalEntry entry;

  IconData _icon() {
    switch (entry.iconKey) {
      case 'moon':
        return Icons.nightlight_round;
      case 'bolt':
        return Icons.bolt_rounded;
      default:
        return Icons.sentiment_satisfied_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('MMM d · h:mm a').format(entry.timestamp);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.mint,
            child: Icon(_icon(), color: AppColors.forest),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  entry.snippet,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
