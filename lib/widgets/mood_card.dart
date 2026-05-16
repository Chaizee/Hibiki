import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import 'sanctuary_chip.dart';

class MoodCard extends StatelessWidget {
  const MoodCard({
    super.key,
    required this.moodLabel,
    required this.tags,
    this.stressLevel,
    this.stressCaption,
  });

  final String moodLabel;
  final List<String> tags;
  final double? stressLevel;
  final String? stressCaption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.mintSoft, AppColors.mint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stressLevel != null)
                      Text(
                        stressCaption ?? 'Stress level · ${stressLevel!.round()}%',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.forest,
                              letterSpacing: 0.4,
                            ),
                      ),
                    if (stressLevel != null) const SizedBox(height: 6),
                    Text(
                      moodLabel,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestDeep,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco, color: AppColors.sage, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((t) => SanctuaryChip(label: t, filled: true))
                .toList(),
          ),
        ],
      ),
    );
  }
}
