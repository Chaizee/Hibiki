import '../data/models/mood_result.dart';
import 'app_strings.dart';

extension MoodResultL10n on MoodResult {
  String localizedMoodLabel(AppStrings l10n) {
    if (moodLabel == 'quiet') return l10n.moodQuiet;
    return l10n.moodLabelFor(emotion);
  }

  List<String> localizedTags(AppStrings l10n) =>
      tags.map(l10n.tagLabel).toList();

  String localizedHeadline(AppStrings l10n) =>
      l10n.insightHeadline(insightHeadline ?? 'calm_headline');

  String localizedBody(AppStrings l10n) {
    final rms = rawMlPayload?['rms'] as double?;
    final peak = rawMlPayload?['peak'] as double?;
    return l10n.insightBody(insightBody ?? 'analysis_body', rms: rms, peak: peak);
  }
}
