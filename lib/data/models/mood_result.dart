/// Output of voice / ML analysis. Extend [rawMlPayload] as your model grows.
class MoodResult {
  const MoodResult({
    required this.stressLevel,
    required this.moodLabel,
    required this.tags,
    this.emotion,
    this.resonancePercent,
    this.insightHeadline,
    this.insightBody,
    this.rawMlPayload,
  });

  /// 0 = relaxed, 100 = high stress (adjust semantics in your backend contract).
  final double stressLevel;

  final String moodLabel;
  final List<String> tags;

  /// calm | joyful | tense — matches calendar colors and training labels.
  final String? emotion;

  /// Optional aggregate wellness score for History / Me screens.
  final int? resonancePercent;

  final String? insightHeadline;
  final String? insightBody;

  /// Opaque blob from ML service (spectrogram stats, embeddings, etc.).
  final Map<String, dynamic>? rawMlPayload;

  factory MoodResult.fromJson(Map<String, dynamic> json) {
    return MoodResult(
      stressLevel: (json['stress_level'] as num?)?.toDouble() ??
          (json['stressLevel'] as num?)?.toDouble() ??
          0,
      moodLabel: json['mood_label'] as String? ??
          json['moodLabel'] as String? ??
          'Balanced',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      emotion: json['emotion'] as String?,
      resonancePercent: (json['resonance_percent'] as num?)?.toInt() ??
          (json['resonancePercent'] as num?)?.toInt(),
      insightHeadline: json['insight_headline'] as String? ??
          json['insightHeadline'] as String?,
      insightBody:
          json['insight_body'] as String? ?? json['insightBody'] as String?,
      rawMlPayload: json['raw'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'stress_level': stressLevel,
        'mood_label': moodLabel,
        'tags': tags,
        if (emotion != null) 'emotion': emotion,
        if (resonancePercent != null) 'resonance_percent': resonancePercent,
        if (insightHeadline != null) 'insight_headline': insightHeadline,
        if (insightBody != null) 'insight_body': insightBody,
        if (rawMlPayload != null) 'raw': rawMlPayload,
      };

  static MoodResult mockSample() {
    return const MoodResult(
      stressLevel: 22,
      moodLabel: 'calm',
      tags: ['consistent', 'warm'],
      emotion: 'calm',
      resonancePercent: 84,
      insightHeadline: 'calm_headline',
      insightBody: 'analysis_body',
    );
  }
}
