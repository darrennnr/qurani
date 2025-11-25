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
    int? ayah,
    int? position,
    String? userId,
    String? userUuid,
    String? status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // ✅ FIX: Gunakan table 'live_sessions' sesuai backend
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/live_sessions'),
        headers: _headers,
        body: jsonEncode({
          'session_id': sessionId,
          'user_id': userId ?? 'anonymous',
          'surah_id': surah,
          'ayah': ayah ?? 1,
          'position': position ?? 0,
          'mode': 'surah',
          'data': {
            'matched': matched,
            'errors': errors,
            'skipped': skipped,
            ...?additionalData, // Additional data like word_status_map, tartib_status
          },
          'status': status ?? 'completed',
          if (userUuid != null) 'user_uuid': userUuid,
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

  Future<List<Map<String, dynamic>>> getSessions({String? userUuid}) async {
    try {
      // ✅ FIX: Gunakan table 'live_sessions' sesuai backend
      String url = '$supabaseUrl/rest/v1/live_sessions?order=created_at.desc';
      
      // Filter by user if provided
      if (userUuid != null) {
        url += '&user_uuid=eq.$userUuid';
      }
      
      final response = await http.get(
        Uri.parse(url),
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
  
  /// Get last paused session for resume functionality
  Future<Map<String, dynamic>?> getLastPausedSession(String userUuid) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$supabaseUrl/rest/v1/live_sessions?user_uuid=eq.$userUuid&status=eq.paused&order=updated_at.desc&limit=1',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final sessions = jsonDecode(response.body) as List;
        if (sessions.isNotEmpty) {
          return sessions[0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching last paused session: $e');
      return null;
    }
  }
  
  /// ✅ NEW: Get latest session (any status) for continue functionality
  Future<Map<String, dynamic>?> getLatestSession(String userUuid, {
    List<String>? statuses, // Filter by specific statuses (optional)
  }) async {
    try {
      // Build query
      String query = 'user_uuid=eq.$userUuid';
      
      // Filter by statuses if provided
      if (statuses != null && statuses.isNotEmpty) {
        // Use OR operator for multiple statuses
        // Example: status=in.(paused,active)
        query += '&status=in.(${statuses.join(',')})';
      }
      
      final response = await http.get(
        Uri.parse(
          '$supabaseUrl/rest/v1/live_sessions?$query&order=updated_at.desc&limit=1',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final sessions = jsonDecode(response.body) as List;
        if (sessions.isNotEmpty) {
          final session = sessions[0] as Map<String, dynamic>;
          print('📥 Latest session found:');
          print('   Session ID: ${session['session_id']}');
          print('   Status: ${session['status']}');
          print('   Surah: ${session['surah_id']}, Ayah: ${session['ayah']}, Position: ${session['position']}');
          print('   Updated: ${session['updated_at']}');
          return session;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching latest session: $e');
      return null;
    }
  }
  
  /// ✅ NEW: Get resumable session (paused or active only)
  Future<Map<String, dynamic>?> getResumableSession(String userUuid) async {
    return getLatestSession(userUuid, statuses: ['paused', 'active']);
  }
}
