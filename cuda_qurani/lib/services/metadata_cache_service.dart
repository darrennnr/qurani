// lib/services/metadata_cache_service.dart

import 'package:cuda_qurani/services/local_database_service.dart';
import 'package:cuda_qurani/screens/main/home/services/juz_service.dart';

/// ✅ SINGLETON: Pre-load ALL metadata for instant access
class MetadataCacheService {
  static final MetadataCacheService _instance =
      MetadataCacheService._internal();
  factory MetadataCacheService() => _instance;
  MetadataCacheService._internal();

  // ==================== CACHED DATA ====================
  List<Map<String, dynamic>> _allSurahs = [];
  List<Map<String, dynamic>> _allJuz = [];
  Map<int, Map<String, dynamic>> _surahMap = {}; // Fast lookup by ID
  Map<int, Map<String, dynamic>> _juzMap = {}; // Fast lookup by number
  Map<int, List<int>> _pageSurahMap = {}; // page → [surahIds on that page]

  bool _isInitialized = false;

  // ==================== GETTERS ====================
  bool get isInitialized => _isInitialized;

  List<Map<String, dynamic>> get allSurahs => _allSurahs;
  List<Map<String, dynamic>> get allJuz => _allJuz;

  Map<String, dynamic>? getSurah(int id) => _surahMap[id];
  Map<String, dynamic>? getJuz(int number) => _juzMap[number];

  /// Get surah names that appear on a specific page
  List<String> getSurahNamesForPage(int pageNumber) {
    final surahIds = _pageSurahMap[pageNumber] ?? [];
    return surahIds
        .map((id) => _surahMap[id]?['name_simple'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Get primary surah for a page (first surah on that page)
  String getPrimarySurahForPage(int pageNumber) {
    final names = getSurahNamesForPage(pageNumber);
    return names.isNotEmpty ? names.first : 'Page $pageNumber';
  }

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    if (_isInitialized) {
      print('[MetadataCache] Already initialized');
      return;
    }

    print('[MetadataCache] 🔄 Starting pre-cache...');
    final startTime = DateTime.now();

    try {
      // ✅ Load ALL metadata in parallel
      final results = await Future.wait([
        LocalDatabaseService.getSurahs(),
        JuzService.getAllJuz(),
        _buildPageSurahMapping(),
      ]);

      _allSurahs = results[0] as List<Map<String, dynamic>>;
      _allJuz = results[1] as List<Map<String, dynamic>>;

      // Build fast lookup maps
      for (final surah in _allSurahs) {
        _surahMap[surah['id'] as int] = surah;
      }

      for (final juz in _allJuz) {
        _juzMap[juz['juz_number'] as int] = juz;
      }

      _isInitialized = true;

      final duration = DateTime.now().difference(startTime);
      print(
        '[MetadataCache] ✅ Pre-cache complete in ${duration.inMilliseconds}ms',
      );
      print('   - ${_allSurahs.length} surahs');
      print('   - ${_allJuz.length} juz');
      print('   - ${_pageSurahMap.length} page mappings');
    } catch (e) {
      print('[MetadataCache] ❌ Pre-cache failed: $e');
      rethrow;
    }
  }

  /// Build page → surah mapping for instant lookup
  Future<void> _buildPageSurahMapping() async {
    print('[MetadataCache] Building page-surah mapping...');

    try {
      // ✅ Use optimized query from LocalDatabaseService
      _pageSurahMap = await LocalDatabaseService.buildPageSurahMapping();

      print(
        '[MetadataCache] Page-surah mapping complete: ${_pageSurahMap.length} pages',
      );
    } catch (e) {
      print('[MetadataCache] Fallback: Building basic mapping...');

      // Fallback: basic mapping by querying page by page (slower but works)
      for (int page = 1; page <= 604; page++) {
        try {
          final ayahInfo = await LocalDatabaseService.getFirstAyahInPage(page);
          final surahId = ayahInfo['surah'] as int;

          if (!_pageSurahMap.containsKey(page)) {
            _pageSurahMap[page] = [];
          }

          if (!_pageSurahMap[page]!.contains(surahId)) {
            _pageSurahMap[page]!.add(surahId);
          }
        } catch (e) {
          print('[MetadataCache] Error mapping page $page: $e');
        }

        // Progress indicator
        if (page % 100 == 0) {
          print('[MetadataCache] Progress: $page/604 pages mapped');
        }
      }
    }
  }

  List<int> getSurahIdsForPage(int pageNumber) {
    return _pageSurahMap[pageNumber] ?? [];
  }

  /// Clear cache (for testing/debugging)
  void clear() {
    _allSurahs.clear();
    _allJuz.clear();
    _surahMap.clear();
    _juzMap.clear();
    _pageSurahMap.clear();
    _isInitialized = false;
  }
}
