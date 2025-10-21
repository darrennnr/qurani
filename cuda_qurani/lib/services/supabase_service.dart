import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class SupabaseService {
  final String supabaseUrl;
  final String anonKey;

  SupabaseService()
      : supabaseUrl = AppConfig.supabaseUrl,
        anonKey = AppConfig.supabaseAnonKey;

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  Future<void> saveSession({
    required String sessionId,
    required int surah,
    required double matched,
    required double errors,
    required double skipped,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/sessions'),
        headers: _headers,
        body: jsonEncode({
          'session_id': sessionId,
          'surah': surah,
          'matched': matched,
          'errors': errors,
          'skipped': skipped,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to save session: ${response.body}');
      }
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/sessions?order=created_at.desc'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch sessions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      return [];
    }
  }
}
