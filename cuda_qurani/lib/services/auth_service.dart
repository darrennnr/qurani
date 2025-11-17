import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import './websocket_service.dart'; // ✅ Import WebSocketService

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _currentUser;

  // Getters
  User? get supabaseUser => _supabase.auth.currentUser;
  UserModel? get currentUser => _currentUser;
  String? get userId => supabaseUser?.id;
  String? get accessToken => _supabase.auth.currentSession?.accessToken;
  bool get isAuthenticated => supabaseUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Initialize
  Future<void> initialize() async {
    print('🔐 Initializing AuthService...');
    print('   - Current User: ${supabaseUser?.email ?? "null"}');
    print('   - Current Session: ${_supabase.auth.currentSession != null}');

    if (supabaseUser != null) {
      _currentUser = UserModel.fromSupabaseUser(supabaseUser!);
      print('✅ User already signed in: ${_currentUser!.email}');
    } else {
      print('⚠️ No user session found');
    }

    // Listen to auth changes
    authStateChanges.listen((AuthState data) {
      print('🔔 AuthService: Auth state event: ${data.event}');
      
      if (data.session?.user != null) {
        _currentUser = UserModel.fromSupabaseUser(data.session!.user);
        print('✅ User logged in: ${_currentUser!.email}');
      } else {
        _currentUser = null;
        print('⚠️ User logged out');
      }
    });
    
    print('✅ AuthService initialized');
  }

  /// Sign Up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      print('📝 Signing up: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        _currentUser = UserModel.fromSupabaseUser(response.user!);
        print('✅ Sign up successful');
      }

      return response;
    } catch (e) {
      print('❌ Sign up failed: $e');
      rethrow;
    }
  }

  /// Sign In
  Future<AuthResponse> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      print('🔑 Signing in: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = UserModel.fromSupabaseUser(response.user!);

        // Save remember me preference
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('remember_me', true);
        }

        print('✅ Sign in successful');
      }

      return response;
    } catch (e) {
      print('❌ Sign in failed: $e');
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      print('👋 Signing out...');

      // ✅ CRITICAL: Disconnect and reset WebSocket before logout
      try {
        print('🔌 Disconnecting WebSocket before logout...');
        final ws = WebSocketService();
        if (ws.isConnected) {
          ws.disconnect();
        }
        // ✅ Reset singleton so next user gets fresh connection
        WebSocketService.resetInstance();
        print('✅ WebSocket disconnected and reset');
      } catch (e) {
        print('⚠️ Failed to disconnect WebSocket: $e');
        // Continue with logout anyway
      }

      await _supabase.auth.signOut();
      _currentUser = null;

      // Clear remember me
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');

      print('✅ Signed out');
    } catch (e) {
      print('❌ Sign out failed: $e');
      rethrow;
    }
  }

  /// Reset Password
  Future<void> resetPassword(String email) async {
    try {
      print('📧 Sending reset email to: $email');

      await _supabase.auth.resetPasswordForEmail(email);

      print('✅ Reset email sent');
    } catch (e) {
      print('❌ Reset failed: $e');
      rethrow;
    }
  }
}
