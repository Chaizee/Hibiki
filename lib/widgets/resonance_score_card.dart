import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

class ResonanceScoreCard extends StatelessWidget {
  const ResonanceScoreCard({
    super.key,
    required this.percent,
    required this.caption,
  });

  final int percent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.forestDeep,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDeep.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESONANCE SCORE',
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$percent %',
            style: GoogleFonts.inter(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            caption,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.45,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
