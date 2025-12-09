// lib/core/providers/language_provider.dart
import 'package:cuda_qurani/main.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/services/language_service.dart';

/// ==================== LANGUAGE PROVIDER ====================
/// Provider untuk manage state bahasa di aplikasi
/// Menggunakan ChangeNotifier agar UI auto-update saat bahasa berubah

class LanguageProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();
  
  List<LanguageModel> _availableLanguages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<LanguageModel> get availableLanguages => _availableLanguages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentLanguageCode => _languageService.currentLanguage;
  
  LanguageModel? get currentLanguage {
    return _availableLanguages.firstWhere(
      (lang) => lang.code == currentLanguageCode,
      orElse: () => _availableLanguages.isNotEmpty 
          ? _availableLanguages.first 
          : LanguageModel(
              code: 'en',
              name: 'English',
              nativeName: 'English',
              flag: '🇺🇸',
            ),
    );
  }

  /// Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _languageService.initialize();
      _availableLanguages = await _languageService.loadAvailableLanguages();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change language
  Future<bool> changeLanguage(String languageCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _languageService.changeLanguage(languageCode);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load translation untuk specific page
  Future<Map<String, dynamic>> loadTranslation(String path) async {
    return await _languageService.loadTranslation(path);
  }

  /// Helper method untuk translate
  String translate(
    Map<String, dynamic> translations,
    String key, {
    Map<String, String>? params,
  }) {
    return _languageService.translate(translations, key, params: params);
  }
  /// Restart app setelah ganti bahasa
  /// Method ini akan trigger full app restart
  Future<void> restartApp(BuildContext context) async {
    // Clear all navigation stack dan restart dari main
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const RestartWidget(),
      ),
      (route) => false,
    );
  }
}

/// Widget helper untuk restart app
class RestartWidget extends StatefulWidget {
  const RestartWidget({Key? key}) : super(key: key);

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  @override
  void initState() {
    super.initState();
    _restart();
  }

  Future<void> _restart() async {
    // Delay sebentar untuk smooth transition
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    // Navigate ke InitialSplashScreen (restart point)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const InitialSplashScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}