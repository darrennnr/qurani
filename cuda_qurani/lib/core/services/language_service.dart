// lib/core/services/language_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ==================== LANGUAGE SERVICE ====================
/// Service untuk handle multi-language dengan JSON files
/// Supports dynamic loading dan caching

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'en';

  // Cache untuk menyimpan translations yang sudah di-load
  final Map<String, Map<String, dynamic>> _translationsCache = {};

  // Current language code
  String _currentLanguage = _defaultLanguage;

  // Singleton instance
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  /// Get current language code
  String get currentLanguage => _currentLanguage;

  /// Initialize language service
  /// Load saved language dari SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Load available languages dari language.json
  Future<List<LanguageModel>> loadAvailableLanguages() async {
    try {

      final String jsonString = await rootBundle.loadString(
        'assets/lang/data/language.json',
      );

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> languagesJson = jsonData['languages'] as List;

      final languages = languagesJson
          .map((lang) => LanguageModel.fromJson(lang))
          .toList();

      return languages;
    } catch (e, stackTrace) {

      // Return default languages as fallback
      return [
        LanguageModel(
          code: 'en',
          name: 'English',
          nativeName: 'English',
          flag: '🇺🇸',
        ),
        LanguageModel(
          code: 'id',
          name: 'Indonesian',
          nativeName: 'Bahasa Indonesia',
          flag: '🇮🇩',
        ),
      ];
    }
  }

  /// Change language dan save ke SharedPreferences
  Future<bool> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _currentLanguage = languageCode;

      // Clear cache agar translations baru di-load
      _translationsCache.clear();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load translation file berdasarkan path
  /// Example path: 'home/home' akan load 'assets/lang/en/home/home.json'
  Future<Map<String, dynamic>> loadTranslation(String path) async {
    final cacheKey = '${_currentLanguage}_$path';

    // Check cache dulu
    if (_translationsCache.containsKey(cacheKey)) {
      return _translationsCache[cacheKey]!;
    }

    try {
      final String filePath = 'assets/lang/$_currentLanguage/$path.json';
      final String jsonString = await rootBundle.loadString(filePath);
      final Map<String, dynamic> translations = json.decode(jsonString);

      // Cache the translations
      _translationsCache[cacheKey] = translations;

      return translations;
    } catch (e) {

      // Fallback ke bahasa default jika file tidak ditemukan
      if (_currentLanguage != _defaultLanguage) {
        try {
          final String fallbackPath =
              'assets/lang/$_defaultLanguage/$path.json';
          final String jsonString = await rootBundle.loadString(fallbackPath);
          return json.decode(jsonString);
        } catch (e) {
        }
      }

      return {};
    }
  }

  /// Get translation dengan nested key support
  /// Example: translate('home.welcome') atau translate('settings.appearance.title')
  String translate(
    Map<String, dynamic> translations,
    String key, {
    Map<String, String>? params,
  }) {
    final keys = key.split('.');
    dynamic value = translations;

    // Navigate through nested keys
    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }

    String result = value.toString();

    // Replace parameters jika ada
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{$paramKey}', paramValue);
      });
    }

    return result;
  }

  /// Clear cache (useful saat change language)
  void clearCache() {
    _translationsCache.clear();
  }
}

/// ==================== LANGUAGE MODEL ====================
class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['native_name'] as String,
      flag: json['flag'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'native_name': nativeName,
      'flag': flag,
    };
  }

  @override
  String toString() => nativeName;
}
