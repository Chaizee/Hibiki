import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_day_record.dart';

class MoodHistoryRepository {
  static const _storageKey = 'sanctuary_mood_history_v1';

  Future<Map<String, MoodDayRecord>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        MoodDayRecord.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> saveAll(Map<String, MoodDayRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = records.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_storageKey, jsonEncode(encoded));
  }

  Future<void> upsert(MoodDayRecord record) async {
    final all = await loadAll();
    all[record.dateKey] = record;
    await saveAll(all);
  }
}
