import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class SanctuaryBottomNav extends StatelessWidget {
  const SanctuaryBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _items = [
    _NavSpec('Listen', Icons.mic_none_rounded),
    _NavSpec('History', Icons.calendar_month_outlined),
    _NavSpec('Notes', Icons.description_outlined),
    _NavSpec('Me', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final spec = _items[i];
              final selected = i == currentIndex;
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onSelect(i),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.navHighlight
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          spec.icon,
                          color: selected
                              ? AppColors.forest
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spec.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selected
                                  ? AppColors.forest
                                  : AppColors.textSecondary,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.label, this.icon);
  final String label;
  final IconData icon;
}
