import 'app_locale.dart';

class AppStrings {
  AppStrings(this.locale);

  final AppLocale locale;
  bool get isRu => locale == AppLocale.ru;

  String _t(String en, String ru) => isRu ? ru : en;

  // Nav
  String get navListen => _t('Listen', 'Слушать');
  String get navHistory => _t('History', 'История');
  String get navNotes => _t('Notes', 'Заметки');
  String get navMe => _t('Me', 'Профиль');

  // Listen
  String get listenTitle1 => _t('How is your ', 'Как ваш ');
  String get listenTitleEmphasis => _t('inner voice', 'внутренний голос');
  String get listenTitle2 => _t(' today?', ' сегодня?');
  String get listenSubtitle =>
      _t('Your sanctuary is ready for a check-in.', 'Ваше убежище готово к check-in.');
  String get listenRecordHint =>
      _t('Tap to capture your essence.', 'Нажмите, чтобы записать голос.');
  String get listenRecordingHint =>
      _t('Tap again to finish and analyze', 'Нажмите снова, чтобы завершить и проанализировать');
  String get listenProcessingHint =>
      _t('Processing your voice…', 'Обработка голоса…');
  String stressLevel(int pct) =>
      _t('Stress level · $pct%', 'Уровень стресса · $pct%');
  String get listenPersonalized => _t('Personalized For You', 'Для вас');
  String get stop => _t('STOP', 'СТОП');
  String get record => _t('RECORD', 'ЗАПИСЬ');
  String get peakVibrant => _t(
        'You sound vibrant today! Log this as a peak moment?',
        'Сегодня голос звучит ярко! Записать пиковый момент?',
      );
  String get peakTense => _t(
        'Your voice shows tension. A short breathing reset may help.',
        'В голосе слышно напряжение. Короткое дыхание может помочь.',
      );
  String get viewAll => _t('View All', 'Все');
  String get logMoment => _t('LOG MOMENT', 'ЗАПИСАТЬ МОМЕНТ');
  String get moodSerene => _t('Serene & Calm', 'Спокойный');
  String get moodJoyful => _t('Joyful & Bright', 'Радостный');
  String get moodTense => _t('Tense & Heavy', 'Напряжённый');
  String get moodQuiet => _t('Quiet input', 'Тихий сигнал');
  String get tagConsistent => _t('Consistent Frequency', 'Стабильная частота');
  String get tagWarm => _t('Warm Tone', 'Тёплый тон');
  String get tagBright => _t('Bright Tone', 'Яркий тон');
  String get tagEnergy => _t('Higher Energy', 'Больше энергии');
  String get tagVariability => _t('Elevated Variability', 'Повышенная вариативность');
  String get tagTransients => _t('Sharp Transients', 'Резкие переходы');
  String get tagLowSignal => _t('Low signal', 'Слабый сигнал');
  String get tagSpeakCloser => _t('Try speaking closer', 'Говорите ближе к микрофону');

  // History
  String get historyTitle => _t('Your Emotional State', 'Ваше эмоциональное состояние');
  String historyReflecting(String month) =>
      _t('Reflecting on your journey through $month.', 'Ваш путь за $month.');
  String historyTodayCaption(String label) => _t(
        'Today: $label. Keep your daily check-ins going.',
        'Сегодня: $label. Продолжайте ежедневные check-in.',
      );
  String get historyEmptyCaption => _t(
        'Record your voice on Listen — the day will appear after analysis.',
        'Запишите голос на Listen — день появится после анализа.',
      );
  String get insightDefaultTitle => _t(
        'When you are calm, your voice gains depth.',
        'Когда вы спокойны, ваш голос обретает глубину.',
      );
  String get insightDefaultBody => _t(
        'We noticed a link between evening voice notes and your morning mood.',
        'Мы заметили связь между вечерними заметками и утренним настроением.',
      );
  String get insightCardBadge => _t('SANCTUARY INSIGHT', 'ИНСАЙТ УБЕЖИЩА');
  String get insightExploreTrends => _t('Explore Trends', 'Смотреть тренды');
  String get insightFrequencyShift =>
      _t('FREQUENCY SHIFT', 'СДВИГ ЧАСТОТЫ');
  String get moodFrequency => _t('MOOD FREQUENCY', 'ЧАСТОТА НАСТРОЕНИЙ');
  String get emotionCalm => _t('Calm', 'Спокойствие');
  String get emotionJoyful => _t('Joy', 'Радость');
  String get emotionTense => _t('Tension', 'Напряжение');
  String daysCount(int n) => _t('$n days', _daysRu(n));
  String get todayLabel => _t('Today', 'Сегодня');
  String monthName(int month) {
    const en = [
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
    const ru = [
      '',
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return isRu ? ru[month] : en[month];
  }

  List<String> get weekdayShort =>
      isRu ? ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'] : ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  List<String> get weekdayShortRu =>
      ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

  String weekdayLabel(int weekday) {
    if (isRu) return weekdayShortRu[weekday - 1];
    return weekdayShort[weekday - 1];
  }

  String _daysRu(int n) {
    if (n % 10 == 1 && n % 100 != 11) return '$n день';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return '$n дня';
    }
    return '$n дней';
  }

  // Notes
  String get notesTimeline => _t('Timeline', 'Лента');
  String get notesPulse => _t('Today\'s Pulse', 'Пульс дня');
  String get notesPulseHint =>
      _t('How are your thoughts flowing right now?', 'Как течут ваши мысли сейчас?');
  String get notesDailyEntry => _t('Daily Entry', 'Запись дня');
  String get notesTitleHint => _t('Title your reflection…', 'Название заметки…');
  String get notesBodyHint =>
      _t('Start writing from the heart…', 'Начните писать от сердца…');
  String get notesDiscard => _t('Discard', 'Отменить');
  String get notesSave => _t('Save Reflection', 'Сохранить');
  String get notesSaved => _t('Reflection saved', 'Заметка сохранена');
  String get notesEmptyTitle => _t('Untitled', 'Без названия');
  String get notesEmptyBodyError =>
      _t('Write something before saving.', 'Напишите текст перед сохранением.');
  String get notesEmptyList => _t(
        'No notes yet — create your first one below.',
        'Пока нет заметок — создайте первую ниже.',
      );
  String get notesDelete => _t('Delete', 'Удалить');
  String get notesDeleted => _t('Note deleted', 'Заметка удалена');
  String get pulseSteady => _t('Steady', 'Ровно');
  String get pulseVibrant => _t('Vibrant', 'Ярко');
  String get pulseFoggy => _t('Foggy', 'Туманно');
  String get pulseGentle => _t('Gentle', 'Мягко');

  static const pulseKeys = ['steady', 'vibrant', 'foggy', 'gentle'];

  String recoTitle(String id) => switch (id) {
        'morning' => _t('Morning Reflection', 'Утренняя рефлексия'),
        'binaural' => _t('Binaural Beats', 'Бинауральные ритмы'),
        'breath' => _t('Breathing Tool', 'Дыхательная практика'),
        _ => id,
      };

  String recoSubtitle(String id) => switch (id) {
        'morning' => _t('Guided flow', 'С гидом'),
        'binaural' => _t('Focus & calm', 'Фокус и спокойствие'),
        'breath' => _t('Grounding', 'Заземление'),
        _ => '',
      };

  String pulseLabel(String key) => switch (key) {
        'vibrant' => pulseVibrant,
        'foggy' => pulseFoggy,
        'gentle' => pulseGentle,
        _ => pulseSteady,
      };

  // Me
  String get meBestStreak => _t('Best streak', 'Лучшая серия');
  String get meTotalDays => _t('Total days', 'Всего дней');
  String get meStartStreak => _t('START STREAK', 'НАЧАТЬ СЕРИЮ');
  String dayStreak(int n) => _t('$n DAY STREAK', 'СЕРИЯ $n ДН.');
  String level(int n) => _t('LEVEL $n', 'УРОВЕНЬ $n');
  String get emotionalBalance => _t('Emotional Balance', 'Эмоциональный баланс');
  String get balanceHasData => _t(
        'Voice resonance over the last 7 days',
        'Резонанс голоса за последние 7 дней',
      );
  String get balanceEmpty => _t(
        'Record your voice — the chart fills automatically',
        'Запишите голос — график заполнится автоматически',
      );
  String get weeklyVibe => _t('Weekly Vibe', 'Недельный вайб');
  String get weeklyNoData => _t('No check-ins this week', 'Нет записей за неделю');
  String weeklyCheckIns(int n) =>
      _t('$n of 7 days with check-in', '$n из 7 дней с check-in');
  String get weeklyRecordListen =>
      _t('Make a recording on Listen', 'Сделайте запись на Listen');
  String positiveResonance(int pct) =>
      _t('$pct% Positive Resonance', '$pct% позитивный резонанс');
  String get milestonesTitle => _t('Personal Milestones', 'Достижения');
  String get milestonesEmpty => _t(
        'Complete tasks below — achievements will appear here.',
        'Выполняйте задания — достижения появятся здесь.',
      );
  String get accountSettings => _t('Account Settings', 'Настройки');
  String get language => _t('Language', 'Язык');
  String get languageEnglish => _t('English', 'English');
  String get languageRussian => _t('Russian', 'Русский');

  String explorerTitle(String key) => switch (key) {
        'master' => _t('Resonance Master', 'Мастер резонанса'),
        'mentor' => _t('Voice Mentor', 'Голосовой наставник'),
        'rhythm' => _t('Rhythm Keeper', 'Хранитель ритма'),
        'bright' => _t('Bright Voice', 'Светлый голос'),
        'seeker' => _t('Balance Seeker', 'Искатель баланса'),
        'calm' => _t('Calm Keeper', 'Хранитель спокойствия'),
        _ => _t('Mindfulness Explorer', 'Исследователь осознанности'),
      };

  String vibeLabel(String key) => switch (key) {
        'radiant' => _t('Radiant', 'Сияющий'),
        'harmonious' => _t('Harmonious', 'Гармоничный'),
        'balanced' => _t('Balanced', 'Уравновешенный'),
        'heavy' => _t('Heavy', 'Напряжённый'),
        _ => _t('Start your journey', 'Начните путь'),
      };

  (String title, String subtitle) milestone(String id, {required bool unlocked, int calmDays = 0, int joyfulDays = 0, int totalDays = 0, int journalCount = 0, int streakLongest = 0}) {
    return switch (id) {
      'first' => (
          _t('First Word', 'Первое слово'),
          unlocked
              ? _t('FIRST VOICE RECORDING', 'ПЕРВАЯ ЗАПИСЬ ГОЛОСА')
              : _t('RECORD ON LISTEN', 'ЗАПИСЬ НА LISTEN'),
        ),
      'week' => (
          _t('Power Week', 'Неделя силы'),
          unlocked
              ? _t('7 DAYS IN A ROW', '7 ДНЕЙ ПОДРЯД')
              : _t('7-DAY STREAK', 'СЕРИЯ 7 ДНЕЙ'),
        ),
      'sleep' => (
          _t('Evening Sage', 'Вечерний мудрец'),
          unlocked
              ? _t('7 CHECK-INS', '7 CHECK-IN')
              : _t('${7 - totalDays} TO 7 CHECK-INS', 'ДО 7: ${7 - totalDays}'),
        ),
      'calm' => (
          _t('Calm Flow', 'Поток спокойствия'),
          unlocked
              ? _t('5 CALM DAYS', '5 СПОКОЙНЫХ ДНЕЙ')
              : _t('$calmDays / 5 CALM', '$calmDays / 5 СПОКОЙНЫХ'),
        ),
      'joy' => (
          _t('Joy Spark', 'Искра радости'),
          unlocked
              ? _t('3 JOYFUL DAYS', '3 РАДОСТНЫХ ДНЯ')
              : _t('$joyfulDays / 3 JOYFUL', '$joyfulDays / 3 РАДОСТНЫХ'),
        ),
      'journal' => (
          _t('Soul Journal', 'Дневник души'),
          unlocked
              ? _t('3 NOTES SAVED', '3 ЗАПИСИ В NOTES')
              : _t('$journalCount / 3 NOTES', '$journalCount / 3 ЗАПИСЕЙ'),
        ),
      _ => ('', ''),
    };
  }

  String moodLabelFor(String? emotion) => switch (emotion) {
        'joyful' => moodJoyful,
        'tense' => moodTense,
        'calm' => moodSerene,
        _ => moodSerene,
      };

  String tagLabel(String key) => switch (key) {
        'bright' => tagBright,
        'energy' => tagEnergy,
        'variability' => tagVariability,
        'transients' => tagTransients,
        'low_signal' => tagLowSignal,
        'speak_closer' => tagSpeakCloser,
        'consistent' => tagConsistent,
        'warm' => tagWarm,
        _ => key,
      };

  String insightHeadline(String key) => switch (key) {
        'joyful_headline' =>
          _t('Your tone sounds open and energized.', 'Тон звучит открыто и энергично.'),
        'tense_headline' => _t(
              'Your voice carries extra tension today.',
              'В голосе слышно напряжение.',
            ),
        'quiet_headline' =>
          _t('Almost no voice detected.', 'Голос почти не обнаружен.'),
        _ => _t(
              'Your voice tends to be deeper on calm days.',
              'В спокойные дни голос звучит глубже.',
            ),
      };

  String insightBody(String key, {double? rms, double? peak}) {
    if (key == 'quiet_body' && rms != null && peak != null) {
      return _t(
        'Speech is too quiet or far from the mic (RMS ${rms.toStringAsFixed(4)}, peak ${peak.toStringAsFixed(4)}).',
        'Речь слишком тихая или далеко от микрофона (RMS ${rms.toStringAsFixed(4)}, peak ${peak.toStringAsFixed(4)}).',
      );
    }
    return _t(
      'Analysis used 20 MFCC coefficients at 16000 Hz.',
      'Анализ: 20 MFCC-коэффициентов при 16000 Гц.',
    );
  }
}
