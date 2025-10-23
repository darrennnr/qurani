import 'package:cuda_qurani/screens/splash_screen.dart';
import 'package:cuda_qurani/screens/main/stt/database/db_helper.dart';
import 'package:cuda_qurani/services/local_database_service.dart'; // ✅ ADD THIS
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recitation_provider.dart';
import 'screens/main/home/services/juz_service.dart';

// Global flag to track DB initialization
bool _isDatabaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // ✅ Pre-initialize ALL databases BEFORE app starts
  await _initializeDatabases();
  await JuzService.initialize();
 
  runApp(const MainApp());
}

Future<void> _initializeDatabases() async {
  if (_isDatabaseInitialized) {
    print('⚠️ Databases already initialized, skipping...');
    return;
  }
 
  try {
    print('🔄 [MAIN] Starting database pre-initialization...');
    
    // ✅ CRITICAL: Initialize BOTH database services in parallel
    await Future.wait([
      // DBHelper - untuk QuranService (qpc-v1 databases)
      DBHelper.preInitializeAll(),
      
      // LocalDatabaseService - untuk search & metadata
      LocalDatabaseService.preInitialize(),
    ]);
   
    _isDatabaseInitialized = true;
    print('✅ [MAIN] All databases pre-initialized successfully');
    print('   - DBHelper: qpc-v1 databases ready');
    print('   - LocalDatabaseService: uthmani.db & chapters ready');
  } catch (e, stackTrace) {
    print('❌ [MAIN] Database initialization FAILED: $e');
    print('🔍 Stack trace: $stackTrace');
    // ⚠️ CRITICAL: Jangan throw error, biarkan app tetap jalan
    // Database akan di-reinitialize on-demand jika pre-init gagal
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        print('🏗️ MAIN: Creating RecitationProvider...');
        final provider = RecitationProvider();
        print('✅ MAIN: RecitationProvider created');
        return provider;
      },
      lazy: false,  // ✅ Force create immediately!
      child: MaterialApp(
        title: 'Qurani Hafidz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF247C64),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}