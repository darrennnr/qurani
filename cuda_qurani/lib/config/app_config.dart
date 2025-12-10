import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String websocketUrl = 'ws://192.168.1.40:8000/ws/recite';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
