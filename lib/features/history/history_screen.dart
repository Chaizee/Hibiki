import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/screen_layout.dart';
import '../../data/models/mood_day_record.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/mood_result_l10n.dart';
import '../../state/sanctuary_state.dart';
import '../../widgets/resonance_score_card.dart';
import '../../widgets/sanctuary_insight_card.dart';

/// Circle row + subtitle row so every column aligns; avoids “low” day numbers.
const double _kCalCircleExtent = 30;
const double _kCalSubtitleExtent = 11;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _displayedDate;

  @override
  void initState() {
    super.initState();
    _displayedDate = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _displayedDate = DateTime(_displayedDate.year, _displayedDate.month - 1);
    });
  }

  void _nextMonth() {
    final nextMonth = DateTime(_displayedDate.year, _displayedDate.month + 1);
    if (nextMonth.isAfter(DateTime(DateTime.now().year, DateTime.now().month + 1))) {
      return;
    }
    setState(() {
      _displayedDate = nextMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SanctuaryState>();
    final insight = state.lastResult;
    final todayRecord = state.moodByDate.forDate(DateTime.now());
    final resonance = todayRecord?.resonanceScore.round() ??
        insight?.resonancePercent ??
        0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: ScreenLayout.screenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.historyReflecting(l10n.monthName(_displayedDate.month)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _CalendarCard(
                  displayedDate: _displayedDate,
                  moodByDate: state.moodByDate,
                  revealDateKey: state.calendarRevealDateKey,
                  onRevealComplete: state.clearCalendarReveal,
                  onPrevious: _previousMonth,
                  onNext: _nextMonth,
                ),
                const SizedBox(height: 20),
                ResonanceScoreCard(
                  percent: resonance,
                  caption: todayRecord != null
                      ? l10n.historyTodayCaption(
                          l10n.moodLabelFor(todayRecord.emotion),
                        )
                      : l10n.historyEmptyCaption,
                ),
                const SizedBox(height: 20),
                _MoodFrequencyCard(counts: state.emotionDayCounts),
                const SizedBox(height: 20),
                SanctuaryInsightCard(
                  title: insight != null
                      ? insight.localizedHeadline(l10n)
                      : l10n.insightDefaultTitle,
                  body: insight != null
                      ? insight.localizedBody(l10n)
                      : l10n.insightDefaultBody,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.displayedDate,
    required this.moodByDate,
    required this.revealDateKey,
    required this.onRevealComplete,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime displayedDate;
  final Map<String, MoodDayRecord> moodByDate;
  final String? revealDateKey;
  final VoidCallback onRevealComplete;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
                '${l10n.monthName(displayedDate.month)} ${displayedDate.year}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.forest,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left, color: AppColors.forest),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right, color: AppColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const _WeekdayRow(),
          const SizedBox(height: 4),
          _MonthGrid(
            month: displayedDate.month,
            year: displayedDate.year,
            moodByDate: moodByDate,
            revealDateKey: revealDateKey,
            onRevealComplete: onRevealComplete,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = List.generate(7, (i) => l10n.weekdayLabel(i + 1));
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
  const _MonthGrid({
    required this.month,
    required this.year,
    required this.moodByDate,
    required this.revealDateKey,
    required this.onRevealComplete,
  });

  final int month;
  final int year;
  final Map<String, MoodDayRecord> moodByDate;
  final String? revealDateKey;
  final VoidCallback onRevealComplete;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = first.weekday - 1;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const _CalendarBlankSlot());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final key = MoodDayRecord.dateKeyFrom(date);
      cells.add(
        _DayCell(
          day: d,
          date: date,
          record: moodByDate[key],
          animateReveal: revealDateKey == key,
          onRevealComplete: onRevealComplete,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 4,
        childAspectRatio: 0.68,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) => Align(
        alignment: Alignment.topCenter,
        child: cells[index],
      ),
    );
  }
}

class _CalendarBlankSlot extends StatelessWidget {
  const _CalendarBlankSlot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kCalCircleExtent + _kCalSubtitleExtent,
      width: _kCalCircleExtent,
    );
  }
}

class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.record,
    required this.animateReveal,
    required this.onRevealComplete,
  });

  final int day;
  final DateTime date;
  final MoodDayRecord? record;
  final bool animateReveal;
  final VoidCallback onRevealComplete;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _revealed = widget.record != null && !widget.animateReveal;
    if (widget.record != null && widget.animateReveal) {
      _controller.forward().then((_) {
        widget.onRevealComplete();
        if (mounted) setState(() => _revealed = true);
      });
    } else if (widget.record != null) {
      _controller.value = 1;
      _revealed = true;
    }
  }

  @override
  void didUpdateWidget(covariant _DayCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.record != null &&
        widget.animateReveal &&
        oldWidget.record == null) {
      _controller.forward(from: 0).then((_) {
        widget.onRevealComplete();
        if (mounted) setState(() => _revealed = true);
      });
    }
    if (widget.record != null && !widget.animateReveal && !_revealed) {
      _controller.value = 1;
      _revealed = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = today.year == widget.date.year &&
        today.month == widget.date.month &&
        today.day == widget.day;
    final isFuture = widget.date.isAfter(
      DateTime(today.year, today.month, today.day),
    );

    if (isFuture) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _kCalCircleExtent,
            width: _kCalCircleExtent,
            child: Center(
              child: Text(
                '${widget.day}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          const SizedBox(height: _kCalSubtitleExtent),
        ],
      );
    }

    final record = widget.record;
    if (record == null || record.emotion.isEmpty) {
      return _dayCellLayout(
        isToday: isToday,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday
                  ? AppColors.forest.withValues(alpha: 0.5)
                  : AppColors.mintSoft,
              width: isToday ? 2 : 1,
            ),
          ),
          child: Text(
            '${widget.day}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return _dayCellLayout(
      isToday: isToday,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.2, end: 1).animate(_scale),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: record.moodColor,
            border: isToday
                ? Border.all(color: AppColors.forest, width: 2)
                : null,
          ),
          child: Icon(
            record.emotionIcon,
            size: 14,
            color: AppColors.forestDeep,
          ),
        ),
      ),
    );
  }

  Widget _dayCellLayout({required bool isToday, required Widget child}) {
    final todayLabel = isToday ? context.l10n.todayLabel : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: _kCalCircleExtent,
          width: _kCalCircleExtent,
          child: Center(child: child),
        ),
        SizedBox(
          height: _kCalSubtitleExtent,
          child: Align(
            alignment: Alignment.topCenter,
            child: todayLabel != null
                ? Text(
                    todayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: GoogleFonts.inter(
                      fontSize: 7,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forest,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _MoodFrequencyCard extends StatelessWidget {
  const _MoodFrequencyCard({required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final calm = counts['calm'] ?? 0;
    final joyful = counts['joyful'] ?? 0;
    final tense = counts['tense'] ?? 0;

    double ratio(int n) => total == 0 ? 0 : n / total;

    final rows = [
      _FreqRow(
        label: l10n.emotionCalm,
        emoji: '😌',
        value: ratio(calm),
        days: total == 0 ? '—' : l10n.daysCount(calm),
        color: AppColors.forest,
      ),
      _FreqRow(
        label: l10n.emotionJoyful,
        emoji: '😊',
        value: ratio(joyful),
        days: total == 0 ? '—' : l10n.daysCount(joyful),
        color: AppColors.sage,
      ),
      _FreqRow(
        label: l10n.emotionTense,
        emoji: '🤯',
        value: ratio(tense),
        days: total == 0 ? '—' : l10n.daysCount(tense),
        color: AppColors.tenseBar,
      ),
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
            l10n.moodFrequency,
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: r,
            ),
          ),
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
