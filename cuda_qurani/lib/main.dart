import 'package:cuda_qurani/screens/splash_screen.dart';
import 'package:cuda_qurani/screens/main/stt/database/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recitation_provider.dart';
import 'screens/main/home/services/juz_service.dart';

// Global flag to track DB initialization
bool _isDatabaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // Pre-initialize all databases BEFORE app starts
  await _initializeDatabases();
  await JuzService.initialize();
 
  runApp(const MainApp());
}

Future<void> _initializeDatabases() async {
  if (_isDatabaseInitialized) return;
 
  try {
    // Open all databases in parallel
    await Future.wait([
      DBHelper.openDB(DBType.metadata),
      DBHelper.openDB(DBType.qpc_v1_15),
      DBHelper.openDB(DBType.qpc_v1_wbw),
      DBHelper.openDB(DBType.uthmani),
    ]);
   
    _isDatabaseInitialized = true;
    print('✅ All databases pre-initialized successfully');
  } catch (e) {
    print('❌ Database initialization failed: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecitationProvider(),
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