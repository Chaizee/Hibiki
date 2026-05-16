import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../models/journal_entry.dart';
import '../models/mood_result.dart';
import '../models/recommendation.dart';

/// HTTP boundary for your backend. Replace paths with your OpenAPI routes.
class SanctuaryApiClient {
  SanctuaryApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final String baseUrl;

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  /// POST multipart audio → ML / stress pipeline.
  ///
  /// Expected JSON keys compatible with [MoodResult.fromJson].
  Future<MoodResult> analyzeVoice(String audioFilePath) async {
    final request = http.MultipartRequest('POST', _u('/v1/voice/analyze'));
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFilePath),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SanctuaryApiException(
        'Voice analyze failed: ${response.statusCode} ${response.body}',
      );
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return MoodResult.fromJson(map);
  }

  /// GET personalized cards for Listen tab.
  Future<List<Recommendation>> getRecommendations() async {
    final response = await http.get(_u('/v1/recommendations'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SanctuaryApiException(
        'Recommendations failed: ${response.statusCode}',
      );
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST saved journal / reflection body.
  Future<void> postReflection({
    required String title,
    required String body,
    List<String> tags = const [],
  }) async {
    final response = await http.post(
      _u('/v1/reflections'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'body': body,
        'tags': tags,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SanctuaryApiException(
        'Reflection save failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Optional: sync timeline entries.
  Future<List<JournalEntry>> getJournalTimeline() async {
    final response = await http.get(_u('/v1/reflections'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SanctuaryApiException('Timeline failed: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final snippet = (m['snippet'] as String?) ?? (m['body'] as String?) ?? '';
      return JournalEntry(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        body: (m['body'] as String?) ?? snippet,
        timestamp: DateTime.parse(m['created_at'] as String),
        snippet: snippet,
        iconKey: m['icon'] as String? ?? 'smile',
      );
    }).toList();
  }
}

class SanctuaryApiException implements Exception {
  SanctuaryApiException(this.message);
  final String message;

  @override
  String toString() => 'SanctuaryApiException: $message';
}
