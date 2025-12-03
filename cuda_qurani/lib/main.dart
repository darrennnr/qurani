import 'package:cuda_qurani/screens/main/stt/controllers/stt_controller.dart';
import 'package:cuda_qurani/screens/main/stt/database/db_helper.dart';
import 'package:cuda_qurani/services/local_database_service.dart';
import 'package:cuda_qurani/services/reciter_database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recitation_provider.dart';
import 'screens/main/home/services/juz_service.dart';
import 'package:cuda_qurani/screens/auth_wrapper.dart';
import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cuda_qurani/config/app_config.dart';
import 'package:cuda_qurani/screens/splash_screen.dart';
import 'package:cuda_qurani/services/metadata_cache_service.dart';

// ✅ NEW: Import Language Provider
import 'package:cuda_qurani/core/providers/language_provider.dart';

// ✅ NEW: Import Premium Provider
import 'package:cuda_qurani/providers/premium_provider.dart';

// Global flag to track DB initialization
bool _isDatabaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  print('✅ Supabase initialized');
  
  // ✅ Pre-initialize ALL databases BEFORE app starts
  await _initializeDatabases();
  await JuzService.initialize();
  await _initializeListeningServices();
  
  // ✅ NEW: Initialize Language Service
  await _initializeLanguageService();
  
  runApp(const MainApp());
}

/// ✅ NEW: Initialize Language Service
Future<void> _initializeLanguageService() async {
  try {
    print('🔄 [MAIN] Initializing language service...');
    final languageProvider = LanguageProvider();
    await languageProvider.initialize();
    print('✅ [MAIN] Language service initialized: ${languageProvider.currentLanguageCode}');
  } catch (e, stackTrace) {
    print('⚠️ [MAIN] Language service initialization failed: $e');
    print('🔍 Stack trace: $stackTrace');
    // Don't throw - app should still work with default language
  }
}

Future<void> _initializeListeningServices() async {
  try {
    await ReciterDatabaseService.initialize();
    print('✅ Reciter database initialized');
  } catch (e) {
    print('⚠️ Failed to initialize reciter database: $e');
  }
}

Future<void> _initializeDatabases() async {
  if (_isDatabaseInitialized) {
    print('⚠️ Databases already initialized, skipping...');
    return;
  }

  try {
    print('🔄 [MAIN] Starting database pre-initialization...');

    // ✅ STEP 1: Initialize databases
    await Future.wait([
      DBHelper.preInitializeAll(),
      LocalDatabaseService.preInitialize(),
    ]);

    // ✅ STEP 2: Pre-cache metadata (CRITICAL for performance)
    await MetadataCacheService().initialize();

    _isDatabaseInitialized = true;
    print('✅ [MAIN] All databases + metadata pre-initialized successfully');
  } catch (e, stackTrace) {
    print('❌ [MAIN] Database initialization FAILED: $e');
    print('🔍 Stack trace: $stackTrace');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false,
        ),
        
        // ✅ NEW: Language Provider (lazy: false agar langsung available)
        ChangeNotifierProvider(
          create: (_) => LanguageProvider()..initialize(),
          lazy: false,
        ),
        
        // ✅ NEW: Premium Provider (lazy: false untuk load plan saat start)
        ChangeNotifierProvider(
          create: (_) => PremiumProvider()..initialize(),
          lazy: false,
        ),
        
        // ✅ Recitation Provider (lazy to prevent WebSocket issues)
        ChangeNotifierProvider(
          create: (_) => RecitationProvider(),
          lazy: true,
        ),
      ],
      child: MaterialApp(
        title: 'Qurani Hafidz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF247C64),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        ),
        home: const InitialSplashScreen(),
      ),
    );
  }
}

/// ✅ Initial splash screen that shows ONCE on app start
/// Separate from auth loading state
class InitialSplashScreen extends StatefulWidget {
  const InitialSplashScreen({super.key});

  @override
  State<InitialSplashScreen> createState() => _InitialSplashScreenState();
}

class _InitialSplashScreenState extends State<InitialSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuth();
  }

  Future<void> _navigateToAuth() async {
    // Show splash for minimum 2 seconds (for branding)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate to AuthWrapper (no animation for smooth transition)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthWrapper(),
        transitionDuration: Duration.zero, // No animation
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Reuse existing SplashScreen widget
  }
}