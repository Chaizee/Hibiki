import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/me_profile_models.dart';
import '../../l10n/l10n_extensions.dart';
import '../../state/sanctuary_state.dart';
import 'account_settings_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SanctuaryState>();
    final balance = state.last7DayBalance;
    final vibe = state.weeklyVibe;
    final unlockedMilestones =
        state.milestones.where((m) => m.unlocked).toList();

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
                      tooltip: l10n.accountSettings,
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.mint,
                        child: Icon(
                          Icons.face_retouching_natural,
                          size: 52,
                          color: AppColors.forestDeep,
                        ),
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
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.white,
                          ),
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
                    '🛡️ ${l10n.explorerTitle(state.explorerTitleKey)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Badge(
                        label: l10n.level(state.streakStats.level),
                        color: AppColors.limeBadge,
                      ),
                      const SizedBox(width: 10),
                      _Badge(
                        label: state.streakStats.currentStreak > 0
                            ? l10n.dayStreak(state.streakStats.currentStreak)
                            : l10n.meStartStreak,
                        color: const Color(0xFFE8E4DC),
                      ),
                    ],
                  ),
                  if (state.streakStats.totalCheckInDays > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.meBestStreak}: ${state.streakStats.longestStreak} · ${l10n.meTotalDays}: ${state.streakStats.totalCheckInDays}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 22),
                  _EmotionalBalanceCard(points: balance),
                  const SizedBox(height: 16),
                  _WeeklyVibeCard(vibe: vibe),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.milestonesTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (unlockedMilestones.isEmpty)
                    Text(
                      l10n.milestonesEmpty,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: unlockedMilestones.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final m = unlockedMilestones[i];
                          return _MilestoneCard(milestone: m);
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
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
  const _EmotionalBalanceCard({required this.points});

  final List<DayBalancePoint> points;

  static const _chartHeight = 124.0;
  static const _labelHeight = 18.0;
  static const _maxBarHeight = 92.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasAnyData = points.any((p) => p.hasData);

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
                  l10n.emotionalBalance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.show_chart, color: AppColors.sage),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasAnyData ? l10n.balanceHasData : l10n.balanceEmpty,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: _chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(points.length, (i) {
                final p = points[i];
                final barH = _maxBarHeight * p.barHeight;
                final highlight = p.isPeak && p.hasData;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: _chartHeight - _labelHeight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: double.infinity,
                              height: barH,
                              decoration: BoxDecoration(
                                color: highlight
                                    ? const Color(0xFF4B6332)
                                    : p.hasData
                                        ? AppColors.sageLight
                                            .withValues(alpha: 0.75)
                                        : AppColors.mintSoft,
                                borderRadius: BorderRadius.circular(10),
                                border: p.isToday
                                    ? Border.all(
                                        color: AppColors.forest
                                            .withValues(alpha: 0.35),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.weekdayLabel(p.weekdayIndex),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            color: p.isToday
                                ? AppColors.forest
                                : AppColors.textSecondary,
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
  const _WeeklyVibeCard({required this.vibe});

  final WeeklyVibeSummary vibe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ringFill = vibe.daysWithData == 0
        ? 0.15
        : (vibe.positivePercent / 100).clamp(0.2, 1.0);

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
            l10n.weeklyVibe,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            vibe.daysWithData == 0
                ? l10n.weeklyNoData
                : l10n.weeklyCheckIns(vibe.daysWithData),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: ringFill,
                    strokeWidth: 10,
                    backgroundColor: AppColors.sageLight.withValues(alpha: 0.25),
                    color: AppColors.forest,
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.forest,
                  ),
                  child: Icon(vibe.icon, color: AppColors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.vibeLabel(vibe.labelKey),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.forest,
            ),
          ),
          Text(
            vibe.daysWithData == 0
                ? l10n.weeklyRecordListen
                : l10n.positiveResonance(vibe.positivePercent),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.milestone});

  final MilestoneItem milestone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final texts = l10n.milestone(
      milestone.id,
      unlocked: milestone.unlocked,
      calmDays: milestone.calmDays,
      joyfulDays: milestone.joyfulDays,
      totalDays: milestone.totalDays,
      journalCount: milestone.journalCount,
    );

    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.sage.withValues(alpha: 0.4)),
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
            backgroundColor: milestone.iconBg,
            child: Icon(milestone.icon, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Text(
            texts.$1,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            texts.$2,
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
