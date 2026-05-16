import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../l10n/l10n_extensions.dart';

class SanctuaryInsightCard extends StatelessWidget {
  const SanctuaryInsightCard({
    super.key,
    required this.title,
    required this.body,
    this.onAction,
  });

  final String title;
  final String body;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: AppColors.forest),
                const SizedBox(width: 6),
                Text(
                  l10n.insightCardBadge,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.forestDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onAction,
            child: Text(
              '${l10n.insightExploreTrends} →',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.forest,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forest.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.graphic_eq, size: 36, color: AppColors.forest),
                  const SizedBox(height: 6),
                  Text(
                    l10n.insightFrequencyShift,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
