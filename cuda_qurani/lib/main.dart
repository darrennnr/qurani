import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/quran_models.dart';
import 'providers/recitation_provider.dart';
import 'screens/main/stt/stt_page.dart';
import 'screens/surah_list_page.dart';
import 'services/quran_service.dart';

void main() {
  runApp(const MainApp());
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
          primaryColor: const Color(0xFF1B5E20),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: const SurahListPage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Surah? _surahYasin;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  Future<void> _loadSurahData() async {
    try {
      final quranService = QuranService();
      // Load any surah dynamically (or from last opened)
      final surah = await quranService.getSurah(1); // Default: Al-Fatihah
      setState(() {
        _surahYasin = surah;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load Surah from Supabase: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadSurahData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Use SttPage with surah ID
    return SttPage(suratId: _surahYasin?.number ?? 1);
  }
}