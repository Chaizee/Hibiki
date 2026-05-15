import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../state/sanctuary_state.dart';
import 'account_settings_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  static const _week = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _heights = [0.45, 0.55, 0.5, 0.85, 0.48, 0.62, 0.58];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SanctuaryState>();
    final stress = state.lastResult?.stressLevel ?? 30;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.forest,
                    tooltip: 'Account settings',
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.mint,
                      child: Icon(Icons.face_retouching_natural,
                          size: 52, color: AppColors.forestDeep),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.sage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Elena Vance',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  '🛡️ Mindfulness Explorer',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _Badge(label: 'LEVEL 14', color: AppColors.limeBadge),
                    SizedBox(width: 10),
                    _Badge(label: '32 DAY STREAK', color: Color(0xFFE8E4DC)),
                  ],
                ),
                const SizedBox(height: 22),
                _EmotionalBalanceCard(heights: _heights),
                const SizedBox(height: 16),
                _WeeklyVibeCard(stress: stress),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Personal Milestones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _MilestoneCard(
                        title: 'First Word',
                        subtitle: 'FIRST SESSION RECORDED',
                        icon: Icons.workspace_premium,
                      ),
                      SizedBox(width: 12),
                      _MilestoneCard(
                        title: 'Sleep Sage',
                        subtitle: '7 NIGHT RECORDINGS',
                        icon: Icons.nightlight_round,
                        iconBg: Color(0xFFE5E5E5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmotionalBalanceCard extends StatelessWidget {
  const _EmotionalBalanceCard({required this.heights});

  final List<double> heights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Emotional Balance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.show_chart, color: AppColors.sage),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Voice frequency analysis over 7 days',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final highlight = i == 3;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: 110 * heights[i],
                              decoration: BoxDecoration(
                                color: highlight
                                    ? const Color(0xFF4B6332)
                                    : AppColors.sageLight.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          MeScreen._week[i],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyVibeCard extends StatelessWidget {
  const _WeeklyVibeCard({required this.stress});

  final double stress;

  @override
  Widget build(BuildContext context) {
    final label = stress < 40 ? 'Radiant' : stress < 65 ? 'Balanced' : 'Heavy';
    final pct = (100 - stress).clamp(40, 98).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.mintSoft,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            'Weekly Vibe',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sageLight.withValues(alpha: 0.25),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sage.withValues(alpha: 0.35),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.forest,
                  ),
                  child: const Icon(Icons.sentiment_satisfied_alt,
                      color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.forest,
            ),
          ),
          Text(
            '$pct% Positive Resonance',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconBg = AppColors.limeBadge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconBg,
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
