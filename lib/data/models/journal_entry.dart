class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.snippet,
    this.iconKey = 'smile',
    this.pulse,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String snippet;
  final String iconKey;
  final String? pulse;

  factory JournalEntry.create({
    required String title,
    required String body,
    DateTime? timestamp,
    String iconKey = 'smile',
    String? pulse,
  }) {
    final trimmed = body.trim();
    return JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? '' : title.trim(),
      body: trimmed,
      timestamp: timestamp ?? DateTime.now(),
      snippet: trimmed.length > 120 ? '${trimmed.substring(0, 120)}…' : trimmed,
      iconKey: iconKey,
      pulse: pulse,
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final body = json['body'] as String? ?? json['snippet'] as String? ?? '';
    final snippet = json['snippet'] as String? ??
        (body.length > 120 ? '${body.substring(0, 120)}…' : body);
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: body,
      timestamp: DateTime.parse(json['timestamp'] as String),
      snippet: snippet,
      iconKey: json['icon_key'] as String? ?? 'smile',
      pulse: json['pulse'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'snippet': snippet,
        'timestamp': timestamp.toIso8601String(),
        'icon_key': iconKey,
        if (pulse != null) 'pulse': pulse,
      };
}
