class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.snippet,
    this.iconKey = 'smile',
  });

  final String id;
  final String title;
  final DateTime timestamp;
  final String snippet;

  /// smile | moon | bolt — maps to UI icons.
  final String iconKey;
}
