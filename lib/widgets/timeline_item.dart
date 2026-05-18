import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../data/models/journal_entry.dart';
import '../l10n/l10n_extensions.dart';

class TimelineItem extends StatelessWidget {
  const TimelineItem({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
    this.selected = false,
  });

  final JournalEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;

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
    final l10n = context.l10n;
    final time = DateFormat('MMM d · h:mm a').format(entry.timestamp);
    final title =
        entry.title.isEmpty ? l10n.notesEmptyTitle : entry.title;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.mintSoft : AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: selected
                ? Border.all(color: AppColors.sage.withValues(alpha: 0.65))
                : null,
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
                      title,
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
              if (onTap != null)
                IconButton(
                  onPressed: onTap,
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.forest,
                  tooltip: l10n.notesEdit,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textSecondary,
                  tooltip: l10n.notesDelete,
                ),
            ],
          ),
        ),
      ),
    );

    if (onDelete == null) return card;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete!(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade50),
      ),
      child: card,
    );
  }
}
