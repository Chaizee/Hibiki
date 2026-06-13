import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class SanctuaryChip extends StatelessWidget {
  const SanctuaryChip({
    super.key,
    required this.label,
    this.filled = false,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool filled;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? AppColors.white.withValues(alpha: 0.85)
        : selected
            ? AppColors.navHighlight
            : AppColors.white;
    final border = selected
        ? Border.all(color: AppColors.sage, width: 1.2)
        : Border.all(color: AppColors.mint.withValues(alpha: 0.6));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Container(
                  width: 3,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.sage,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
