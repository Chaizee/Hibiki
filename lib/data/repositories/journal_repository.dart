import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';

class JournalRepository {
  static const _storageKey = 'sanctuary_journal_v1';

  Future<List<JournalEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  Future<void> saveAll(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(encoded));
  }

  Future<JournalEntry> add(JournalEntry entry) async {
    final all = await loadAll();
    all.insert(0, entry);
    await saveAll(all);
    return entry;
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }

  Future<void> replaceAll(List<JournalEntry> entries) async {
    await saveAll(entries);
  }
}
