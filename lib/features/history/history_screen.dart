import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../state/sanctuary_state.dart';
import '../../widgets/resonance_score_card.dart';
import '../../widgets/sanctuary_insight_card.dart';

// ВРЕМЕННЫЕ ДАННЫЕ ДЛЯ ПРИМЕРА — замените на ваш API
class _MockMoodData {
  static Map<DateTime, MoodEntry> generateForMonth(int year, int month) {
    final entries = <DateTime, MoodEntry>{};
    final random = DateTime.now().day; // псевдо-рандом
    
    for (int d = 1; d <= DateTime(year, month + 1, 0).day; d++) {
      final date = DateTime(year, month, d);
      if (date.isAfter(DateTime.now())) break;
      
      // Имитация данных (замените на реальные из SanctuaryState)
      entries[date] = MoodEntry(
        date: date,
        resonanceScore: (d * 7 + random) % 101, // 0-100
        emotion: ['calm', 'joyful', 'tense'][d % 3],
      );
    }
    return entries;
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _displayedDate;
  Map<DateTime, MoodEntry>? _moodData;

  @override
  void initState() {
    super.initState();
    _displayedDate = DateTime.now();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    // TODO: Замените на реальный вызов вашей модели
    // final state = context.read<SanctuaryState>();
    // final data = await state.fetchMoodData(year: _displayedDate.year, month: _displayedDate.month);
    
    setState(() {
      _moodData = _MockMoodData.generateForMonth(_displayedDate.year, _displayedDate.month);
    });
  }

  void _previousMonth() {
    setState(() {
      _displayedDate = DateTime(_displayedDate.year, _displayedDate.month - 1);
      _loadMoodData();
    });
  }

  void _nextMonth() {
    final nextMonth = DateTime(_displayedDate.year, _displayedDate.month + 1);
    if (nextMonth.isAfter(DateTime(DateTime.now().year, DateTime.now().month + 1))) {
      // Нельзя переключаться на будущие месяцы (опционально)
      return;
    }
    setState(() {
      _displayedDate = nextMonth;
      _loadMoodData();
    });
  }

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
                  'Ваше Эмоциональное Состояние',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reflecting on your journey through ${_historyMonthName(_displayedDate.month)}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _CalendarCard(
                  displayedDate: _displayedDate,
                  moodData: _moodData,
                  onPrevious: _previousMonth,
                  onNext: _nextMonth,
                ),
                const SizedBox(height: 20),
                ResonanceScoreCard(
                  percent: insight?.resonancePercent ?? 84,
                  caption:
                      'Ваше настроение стало стабильнее на 12%, по сравнению с прошлым месяцем. Не сбивайтесь с ритма.',
                ),
                const SizedBox(height: 20),
                const _MoodFrequencyCard(),
                const SizedBox(height: 20),
                SanctuaryInsightCard(
                  title: insight?.insightHeadline ??
                      'Когда вы спокойны, ваш голос обретает глубину.',
                  body: insight?.insightBody ??
                      'Мы заметили связь между вечерними голосовыми заметками и вашим утренним настроением.',
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
  const names = ['', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];
  return names[month];
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.displayedDate,
    required this.moodData,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime displayedDate;
  final Map<DateTime, MoodEntry>? moodData;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
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
                '${_monthName(displayedDate.month)} ${displayedDate.year}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.forest,
                ),
              ),
              //const Icon(Icons.expand_more, color: AppColors.forest),
            
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
          const SizedBox(height: 8),
          const _WeekdayRow(),
          const SizedBox(height: 8),
          _MonthGrid(
            month: displayedDate.month,
            year: displayedDate.year,
            moodData: moodData,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = ['', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];
    return names[m];
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    const days = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) => Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary))).toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.year,
    required this.moodData,
  });

  final int month;
  final int year;
  final Map<DateTime, MoodEntry>? moodData;

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
      final date = DateTime(year, month, d);
      final entry = moodData?[date];
      cells.add(_DayCell(
        day: d,
        month: month,
        year: year,
        moodEntry: entry,
      ));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 6,
        childAspectRatio: 0.72,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) => cells[index],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.month,
    required this.year,
    required this.moodEntry,
  });

  final int day;
  final int month;
  final int year;
  final MoodEntry? moodEntry;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final date = DateTime(year, month, day);
    final isToday = today.year == year && today.month == month && today.day == day;
    final isFuture = date.isAfter(today);
    final isAddSlot = day == today.day + 1 && today.year == year && today.month == month && day <= DateTime(year, month + 1, 0).day;

    // Будущие дни (недоступны)
    if (isFuture && !isAddSlot) {
      return Center(
        child: Text('$day', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.35))),
      );
    }

    // Кнопка добавления записи
    if (isAddSlot) {
      return Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sage.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.add, size: 18, color: AppColors.sage),
          ),
        ],
      );
    }

    // Цвет из модели или серый по умолчанию
    final backgroundColor = moodEntry?.moodColor ?? AppColors.mintSoft;
    
    // Иконка в зависимости от эмоции
    IconData emotionIcon = Icons.favorite;
    switch (moodEntry?.emotion) {
      case 'calm':
        emotionIcon = Icons.pets;
        break;
      case 'joyful':
        emotionIcon = Icons.pets;
        break;
      case 'tense':
        emotionIcon = Icons.pets;
        break;
      default:
        emotionIcon = Icons.pets;
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: isToday ? Border.all(color: AppColors.forest, width: 2.5) : null,
          ),
          child: Icon(emotionIcon, size: 18, color: AppColors.forestDeep),
        ),
        if (isToday)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('СЕГОДНЯ', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.forest)),
          )
        else
          const SizedBox(height: 4),
      ],
    );
  }
}


// Класс MoodEntry (вынесите в отдельный файл)
class MoodEntry {
  final DateTime date;
  final double? resonanceScore;
  final String? emotion;

  MoodEntry({required this.date, this.resonanceScore, this.emotion});

  Color get moodColor {
    if (resonanceScore == null) return AppColors.mintSoft;
    if (resonanceScore! >= 75) return const Color.fromARGB(255, 168, 194, 182);
    if (resonanceScore! >= 50) return const Color.fromARGB(255, 222, 213, 187);
    return const Color.fromARGB(255, 227, 184, 184);
  }
}


class _MoodFrequencyCard extends StatelessWidget {
  const _MoodFrequencyCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      _FreqRow(label: 'Спокойствие', emoji: '😌', value: 0.75, days: '12 дней', color: AppColors.forest),
      _FreqRow(label: 'Радость', emoji: '😊', value: 0.5, days: '8 дней', color: AppColors.sage),
      _FreqRow(label: 'Напряжение', emoji: '🤯', value: 0.22, days: '3 дня', color: AppColors.tenseBar),
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
