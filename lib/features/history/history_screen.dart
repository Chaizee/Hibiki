import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../state/sanctuary_state.dart';
import '../../widgets/resonance_score_card.dart';
import '../../widgets/sanctuary_insight_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SanctuaryState>();
    final insight = state.lastResult;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Emotional Landscape',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reflecting on your journey through ${_historyMonthName(DateTime.now().month)}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                const _CalendarCard(),
                const SizedBox(height: 20),
                ResonanceScoreCard(
                  percent: insight?.resonancePercent ?? 84,
                  caption:
                      'Your mood stability is 12% higher than last month. Consistency is key.',
                ),
                const SizedBox(height: 20),
                const _MoodFrequencyCard(),
                const SizedBox(height: 20),
                SanctuaryInsightCard(
                  title: insight?.insightHeadline ??
                      'Your voice tends to be deeper on calm days.',
                  body: insight?.insightBody ??
                      'We noticed a correlation between your evening voice notes and morning mood entries.',
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _historyMonthName(int month) {
  const names = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return names[month];
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_monthName(now.month)} ${now.year}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.forest,
                ),
              ),
              const Icon(Icons.expand_more, color: AppColors.forest),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _WeekdayRow(),
          const SizedBox(height: 8),
          _MonthGrid(month: now.month, year: now.year),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m];
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (d) => Text(
              d,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.year});

  final int month;
  final int year;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = first.weekday - 1;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(_DayCell(day: d, month: month, year: year));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 6,
      childAspectRatio: 0.72,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.month, required this.year});

  final int day;
  final int month;
  final int year;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday =
        today.year == year && today.month == month && today.day == day;
    final isFuture = DateTime(year, month, day).isAfter(today);
    final isAddSlot = day == today.day + 1 &&
        today.year == year &&
        today.month == month &&
        day <= DateTime(year, month + 1, 0).day;

    if (isFuture && !isAddSlot) {
      return Center(
        child: Text(
          '$day',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    if (isAddSlot) {
      return Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.sage.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(Icons.add, size: 18, color: AppColors.sage),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _moodTint(day),
            border: isToday
                ? Border.all(color: AppColors.forest, width: 2.5)
                : null,
          ),
          child: Icon(Icons.pets, size: 18, color: AppColors.forestDeep),
        ),
        if (isToday)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'TODAY',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
          )
        else
          const SizedBox(height: 4),
      ],
    );
  }

  Color _moodTint(int d) {
    final tints = [
      AppColors.mint,
      AppColors.mintSoft,
      const Color(0xFFFFE4E6),
    ];
    return tints[d % tints.length];
  }
}

class _MoodFrequencyCard extends StatelessWidget {
  const _MoodFrequencyCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      _FreqRow(label: 'Calm', emoji: '😌', value: 0.75, days: '12 days', color: AppColors.forest),
      _FreqRow(label: 'Joyful', emoji: '😊', value: 0.5, days: '8 days', color: AppColors.sage),
      _FreqRow(label: 'Tense', emoji: '🤯', value: 0.22, days: '3 days', color: AppColors.tenseBar),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOOD FREQUENCY',
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: r,
              )),
        ],
      ),
    );
  }
}

class _FreqRow extends StatelessWidget {
  const _FreqRow({
    required this.label,
    required this.emoji,
    required this.value,
    required this.days,
    required this.color,
  });

  final String label;
  final String emoji;
  final double value;
  final String days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.mintSoft,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: value.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          days,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
