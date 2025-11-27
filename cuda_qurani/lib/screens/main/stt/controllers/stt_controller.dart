// lib\screens\main\stt\controllers\stt_controller.dart

import 'dart:async';
import 'package:cuda_qurani/models/playback_settings_model.dart';
import 'package:cuda_qurani/models/quran_models.dart';
import 'package:cuda_qurani/screens/main/home/services/juz_service.dart';
import 'package:cuda_qurani/services/listening_audio_services.dart';
import 'package:cuda_qurani/services/local_database_service.dart';
import 'package:cuda_qurani/services/reciter_database_service.dart';
import 'package:flutter/material.dart';
import '../data/models.dart' hide TartibStatus;
import '../services/quran_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'package:cuda_qurani/services/audio_service.dart';
import 'package:cuda_qurani/services/websocket_service.dart';
import 'package:cuda_qurani/services/supabase_service.dart'; // ✅ NEW: For session management
import 'package:cuda_qurani/services/auth_service.dart'; // ✅ NEW: For user UUID
import 'package:cuda_qurani/config/app_config.dart';
import 'package:cuda_qurani/services/metadata_cache_service.dart';

class SttController with ChangeNotifier {
  final int? suratId;
  final int? pageId;
  final int? juzId;

  int? _determinedSurahId;

  SttController({this.suratId, this.pageId, this.juzId}) {
    print(
      'ðŸ—ƒï¸ SttController: CONSTRUCTOR - surah:$suratId page:$pageId juz:$juzId',
    );
    _webSocketService = WebSocketService(serverUrl: AppConfig.websocketUrl);
    print(
      'ðŸ”§ SttController: WebSocketService initialized, calling _initializeWebSocket()...',
    );
    try {
      _initializeWebSocket();
      print('âœ… SttController: _initializeWebSocket() completed');
    } catch (e, stack) {
      print('âŒ SttController: _initializeWebSocket() FAILED: $e');
      print('Stack trace: $stack');
    }
  }

  // Services
  final QuranService _sqliteService = QuranService();
  final AppLogger appLogger = AppLogger();
  final SupabaseService _supabaseService = SupabaseService(); // ✅ NEW
  final AuthService _authService = AuthService(); // ✅ NEW

  // ✅ NEW: Resumable session detection
  bool _hasResumableSession = false;
  bool get hasResumableSession => _hasResumableSession;

  // Core State
  bool _isLoading = true;
  String? _errorMessage = '';
  List<AyatData> _ayatList = [];
  int _currentAyatIndex = 0;
  String _suratNameSimple = '';
  String _suratVersesCount = '';
  DateTime? _sessionStartTime;
  Map<int, AyatProgress> _ayatProgress = {};

  // UI State
  bool _isUIVisible = true;
  bool _isQuranMode = true;
  bool _hideUnreadAyat = false;
  bool _showLogs = false;
  int _currentPage = 1;
  int _listViewCurrentPage = 1;
  bool _isDataLoaded = false; // Prevent unnecessary reloads
  List<AyatData> _currentPageAyats = [];
  final ScrollController _scrollController = ScrollController();

  // Backend Integration - Recording & WebSocket
  final AudioService _audioService = AudioService();
  late final WebSocketService _webSocketService;
  bool _isRecording = false;
  bool _isConnected = false;
  String? _sessionId;
  int _expectedAyah = 1;
  final Map<int, TartibStatus> _tartibStatus = {};
  final Map<int, Map<int, WordStatus>> _wordStatusMap = {};
  List<WordFeedback> _currentWords =
      []; // âœ… ADD: Store current words for realtime updates
  StreamSubscription? _wsSubscription;
  StreamSubscription? _connectionSubscription;

  // Getters for recording state
  bool get isRecording => _isRecording;
  bool get isConnected => _isConnected;

  // âœ… NEW: Direct access to service connection state (always fresh)
  bool get isServiceConnected => _webSocketService.isConnected;

  int get expectedAyah => _expectedAyah;
  Map<int, TartibStatus> get tartibStatus => _tartibStatus;
  Map<int, Map<int, WordStatus>> get wordStatusMap => _wordStatusMap;
  List<WordFeedback> get currentWords =>
      _currentWords; // âœ… ADD: Getter for currentWords

  // Page Pre-loading Cache
  final Map<int, List<MushafPageLine>> pageCache = {};
  final MetadataCacheService _metadataCache = MetadataCacheService();

  bool _isPreloadingPages = false;

  // Getters for UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AyatData> get ayatList => _ayatList;
  int get currentAyatIndex => _currentAyatIndex;
  int get currentAyatNumber =>
      _ayatList.isNotEmpty ? _ayatList[_currentAyatIndex].ayah : 1;
  String get suratNameSimple => _suratNameSimple;
  String get suratVersesCount => _suratVersesCount;
  DateTime? get sessionStartTime => _sessionStartTime;
  Map<int, AyatProgress> get ayatProgress => _ayatProgress;
  bool get isUIVisible => _isUIVisible;
  bool get isQuranMode => _isQuranMode;
  bool get hideUnreadAyat => _hideUnreadAyat;
  bool get showLogs => _showLogs;
  int get currentPage => _currentPage;
  List<AyatData> get currentPageAyats => _currentPageAyats;
  ScrollController get scrollController => _scrollController;
  int get listViewCurrentPage => _listViewCurrentPage;

  // Listening
  bool _isListeningMode = false;
  PlaybackSettings? _playbackSettings;
  ListeningAudioService? _listeningAudioService;
  StreamSubscription? _verseChangeSubscription;
  StreamSubscription? _wordHighlightSubscription;
  bool get isListeningMode => _isListeningMode;
  PlaybackSettings? get playbackSettings => _playbackSettings;
  ListeningAudioService? get listeningAudioService => _listeningAudioService;
  // ===== INITIALIZATION =====
  Future<void> initializeApp() async {
    appLogger.log('APP_INIT', 'Starting OPTIMIZED page-based initialization');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // ✅ NEW: Check for resumable session
    await _checkForResumableSession();

    try {
      await _sqliteService.initialize();

      // ðŸš€ STEP 1: Determine target page FIRST
      int targetPage = await _determineTargetPage();
      _currentPage = targetPage;
      _listViewCurrentPage = targetPage;
      _isDataLoaded = false;

      appLogger.log('APP_INIT', 'Target page determined: $targetPage');

      // ðŸš€ STEP 2: Load ONLY that page (minimal data)
      await _loadSinglePageData(targetPage);

      _sessionStartTime = DateTime.now();

      _isDataLoaded = true;

      // Mark as ready INSTANTLY
      _isLoading = false;
      notifyListeners();

      appLogger.log(
        'APP_INIT',
        'App ready - Page $targetPage loaded instantly',
      );

      // ðŸš€ STEP 3: Background tasks
      Future.microtask(() {
        if (_isQuranMode) {
          _preloadAdjacentPagesAggressively();
        }
      });
    } catch (e) {
      final errorString = 'Failed to initialize: $e';
      appLogger.log('APP_INIT_ERROR', errorString);
      _errorMessage = errorString;
      _isLoading = false;
      notifyListeners();
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

  Future<void> startListening(PlaybackSettings settings) async {
    appLogger.log(
      'LISTENING',
      'Starting listening mode with settings: $settings',
    );

    // ✅ Listening Mode: No backend connection needed (Tarteel-style)
    print('🎧 Listening Mode: Passive learning (no detection)');

    try {
      // 🧹 Clear previous state
      _tartibStatus.clear();
      _wordStatusMap.clear();
      _expectedAyah = settings.startVerse;
      _sessionId = null;
      _errorMessage = '';

      // 🎵 Initialize listening audio service
      _listeningAudioService = ListeningAudioService();
      await _listeningAudioService!.initialize(settings);

      _playbackSettings = settings;
      _isListeningMode = true;

      print('🎧 Starting Listening Mode (Passive - No Backend Detection)');

      // 🎧 Subscribe to verse changes
      _verseChangeSubscription = _listeningAudioService!.currentVerseStream
          ?.listen((verse) {
            print('📖 Now playing: ${verse.surahId}:${verse.verseNumber}');

            // ✅ FIX: Handle completion signal
            if (verse.surahId == -999 && verse.verseNumber == -999) {
              print('🏁 Listening completed - resetting state');
              _handleListeningCompletion();
              return;
            }

            // Update current ayat index
            final ayatIndex = _ayatList.indexWhere(
              (a) => a.surah_id == verse.surahId && a.ayah == verse.verseNumber,
            );

            if (ayatIndex >= 0) {
              // ✅ Clear previous ayat's wordStatusMap when moving to next ayat
              if (_currentAyatIndex >= 0 &&
                  _currentAyatIndex < _ayatList.length) {
                final previousAyah = _ayatList[_currentAyatIndex].ayah;
                _wordStatusMap[previousAyah]?.clear();
                print(
                  '🧹 Cleared wordStatusMap for previous ayah: $previousAyah',
                );
              }

              _currentAyatIndex = ayatIndex;
              notifyListeners();
            }
          });

      // 🎨 Subscribe to word highlights (for visual feedback)
      _wordHighlightSubscription = _listeningAudioService!.wordHighlightStream
          ?.listen((wordIndex) {
            print('✨ Highlight word: $wordIndex in listening mode');

            // ✅ Ignore wordIndex -1 (word transition marker) - don't reset!
            if (wordIndex == -1) {
              return; // Skip reset, keep previous highlights
            }

            // ✅ Update UI to show current word being highlighted
            // This allows visual feedback in listening mode (gray color for current word)
            if (_currentAyatIndex >= 0 &&
                _currentAyatIndex < _ayatList.length) {
              final currentAyat = _ayatList[_currentAyatIndex];
              final currentAyah = currentAyat.ayah;
              final words = currentAyat.words; // Use words from AyatData

              // ✅ Initialize wordStatusMap for this ayah if not exists
              if (!_wordStatusMap.containsKey(currentAyah)) {
                _wordStatusMap[currentAyah] = {};
              }

              // ✅ Update all words status in wordStatusMap (used by UI)
              for (int i = 0; i < words.length; i++) {
                if (i == wordIndex) {
                  // Current word being played (dark gray)
                  _wordStatusMap[currentAyah]![i] = WordStatus.processing;
                } else if (i < wordIndex) {
                  // Already played words (light gray - same as pending visually)
                  _wordStatusMap[currentAyah]![i] = WordStatus.pending;
                } else {
                  // Not yet played (light gray)
                  _wordStatusMap[currentAyah]![i] = WordStatus.pending;
                }
              }

              notifyListeners();
            }
          });

      // ▶️ Start playback (audio only, no backend streaming)
      await _listeningAudioService!.startPlayback();

      _isRecording = true; // Treat as recording session
      _hideUnreadAyat = false; // ✅ SHOW all ayat in listening mode (don't hide)

      appLogger.log('LISTENING', 'Listening mode started successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start listening: $e';
      _isListeningMode = false;
      _isRecording = false;
      appLogger.log('LISTENING_ERROR', e.toString());
      print('❌ Start listening failed: $e');
      notifyListeners();
    }
  }

  /// Stop Listening Mode
  /// Stop Listening Mode
  Future<void> stopListening() async {
    print('🛑 Manually stopping listening mode...');

    try {
      // Stop audio playback
      await _listeningAudioService?.stopPlayback();

      // Cancel subscriptions
      await _verseChangeSubscription?.cancel();
      await _wordHighlightSubscription?.cancel();

      // Dispose audio service
      _listeningAudioService?.dispose();
      _listeningAudioService = null;

      // ✅ FIX: Reset state properly
      _isListeningMode = false;
      _isRecording = false;
      _playbackSettings = null;

      // Clear visual states
      _tartibStatus.clear();
      _wordStatusMap.clear();

      appLogger.log('LISTENING', 'Stopped manually');
      print('✅ Listening mode stopped');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to stop listening: $e';
      appLogger.log('LISTENING_ERROR', e.toString());
      print('❌ Stop listening failed: $e');
      notifyListeners();
    }
  }

  /// ✅ NEW: Handle listening mode completion
Future<void> _handleListeningCompletion() async {
  print('🎉 Listening session completed');
  
  try {
    // Stop audio playback (if not already stopped)
    await _listeningAudioService?.stopPlayback();
    
    // Cancel subscriptions
    await _verseChangeSubscription?.cancel();
    await _wordHighlightSubscription?.cancel();
    
    // Dispose audio service
    _listeningAudioService?.dispose();
    _listeningAudioService = null;
    
    // ✅ CRITICAL: Reset all state flags
    _isListeningMode = false;
    _isRecording = false;
    _playbackSettings = null;
    
    // Clear visual states
    _tartibStatus.clear();
    _wordStatusMap.clear();
    
    appLogger.log('LISTENING', 'Completed and reset');
    print('✅ All listening state reset');
    
    notifyListeners();
    
  } catch (e) {
    appLogger.log('LISTENING_ERROR', 'Completion error: $e');
    print('❌ Completion handler failed: $e');
    
    // ✅ Still reset state even if error occurs
    _isListeningMode = false;
    _isRecording = false;
    notifyListeners();
  }
}

  /// Pause listening (pause audio, but keep WebSocket alive)
  Future<void> pauseListening() async {
    if (_listeningAudioService != null && _isListeningMode) {
      await _listeningAudioService!.pausePlayback();
      print('⏸️ Listening paused');
      notifyListeners();
    }
  }

  /// Resume listening
  Future<void> resumeListening() async {
    if (_listeningAudioService != null && _isListeningMode) {
      await _listeningAudioService!.resumePlayback();
      print('▶️ Listening resumed');
      notifyListeners();
    }
  }

  // ADD NEW METHOD: Determine target page from navigation params
  Future<int> _determineTargetPage() async {
    // Priority: pageId > juzId > suratId

    if (pageId != null) {
      appLogger.log('NAV', 'Direct navigation to page $pageId');
      return pageId!;
    }

    if (juzId != null) {
      appLogger.log('NAV', 'Navigation from Juz $juzId');

      // Get juz metadata
      final juzData = await JuzService.getJuz(juzId!);
      if (juzData == null) {
        throw Exception('Juz $juzId not found');
      }

      // Parse first_verse_key (format: "surah:ayah")
      final firstVerseKey = juzData['first_verse_key'] as String;
      final parts = firstVerseKey.split(':');
      final surahNum = int.parse(parts[0]);
      final ayahNum = int.parse(parts[1]);

      // Get page number for this ayah
      final page = await LocalDatabaseService.getPageNumber(surahNum, ayahNum);
      appLogger.log(
        'NAV',
        'Juz $juzId starts at page $page (${surahNum}:${ayahNum})',
      );
      return page;
    }

    if (suratId != null) {
      appLogger.log('NAV', 'Navigation from Surah $suratId');

      // Get first page of this surah
      final page = await LocalDatabaseService.getPageNumber(suratId!, 1);
      appLogger.log('NAV', 'Surah $suratId starts at page $page');
      return page;
    }

    // Fallback (should never happen due to assertion)
    return 1;
  }

  // ADD NEW METHOD: Load multiple pages in parallel (instant swipe preparation)
  Future<void> _loadMultiplePagesParallel(List<int> pageNumbers) async {
    if (pageNumbers.isEmpty) return;

    appLogger.log(
      'PARALLEL_LOAD',
      'Loading ${pageNumbers.length} pages: $pageNumbers',
    );

    try {
      // Fetch all pages in parallel
      final results = await Future.wait(
        pageNumbers.map((pageNum) async {
          if (pageCache.containsKey(pageNum)) {
            appLogger.log('PARALLEL_LOAD', 'Page $pageNum already cached');
            return MapEntry(pageNum, pageCache[pageNum]!);
          }

          try {
            final lines = await _sqliteService.getMushafPageLines(pageNum);
            appLogger.log(
              'PARALLEL_LOAD',
              'Page $pageNum loaded (${lines.length} lines)',
            );
            return MapEntry(pageNum, lines);
          } catch (e) {
            appLogger.log('PARALLEL_LOAD_ERROR', 'Failed page $pageNum: $e');
            return null;
          }
        }),
        eagerError: false,
      );

      // Update cache with successful results
      int successCount = 0;
      for (final entry in results) {
        if (entry != null) {
          pageCache[entry.key] = entry.value;
          successCount++;
        }
      }

      appLogger.log(
        'PARALLEL_LOAD',
        'Successfully cached $successCount/${pageNumbers.length} pages',
      );
    } catch (e) {
      appLogger.log('PARALLEL_LOAD_ERROR', 'Batch load failed: $e');
    }
  }

  // REPLACE existing _loadSinglePageData method
  Future<void> _loadSinglePageData(int pageNumber) async {
    appLogger.log(
      'DATA',
      'ðŸš€ INSTANT LOAD: Page $pageNumber + adjacent pages',
    );

    try {
      // âœ… STEP 1: Determine pages to load (main + 2 before + 2 after = 5 pages)
      final pagesToLoad = <int>[];

      // Add main page first (priority)
      pagesToLoad.add(pageNumber);

      // Add adjacent pages
      if (pageNumber > 1) pagesToLoad.add(pageNumber - 1);
      if (pageNumber > 2) pagesToLoad.add(pageNumber - 2);
      if (pageNumber < 604) pagesToLoad.add(pageNumber + 1);
      if (pageNumber < 603) pagesToLoad.add(pageNumber + 2);

      // âœ… STEP 2: Load all pages in PARALLEL
      await _loadMultiplePagesParallel(pagesToLoad);

      // âœ… STEP 3: Extract main page data for UI
      final pageLines = pageCache[pageNumber];
      if (pageLines == null || pageLines.isEmpty) {
        throw Exception('Main page $pageNumber failed to load');
      }

      // âœ… STEP 4: Determine and STORE surah ID from first ayah
      for (final line in pageLines) {
        if (line.ayahSegments != null && line.ayahSegments!.isNotEmpty) {
          final firstSegment = line.ayahSegments!.first;
          _determinedSurahId = firstSegment.surahId;

          // Get surah metadata (minimal)
          final chapter = await _sqliteService.getChapterInfo(
            _determinedSurahId!,
          );
          _suratNameSimple = chapter.nameSimple;
          _suratVersesCount = chapter.versesCount.toString();

          // Build minimal ayat list for THIS PAGE ONLY
          final Set<String> uniqueAyahs = {};
          for (final line in pageLines) {
            if (line.ayahSegments != null) {
              for (final segment in line.ayahSegments!) {
                final key = '${segment.surahId}:${segment.ayahNumber}';
                uniqueAyahs.add(key);
              }
            }
          }

          // Load only ayahs on this page
          _ayatList = [];
          for (final ayahKey in uniqueAyahs) {
            final parts = ayahKey.split(':');
            final surahId = int.parse(parts[0]);
            final ayahNum = int.parse(parts[1]);

            final ayahWords = await _sqliteService.getAyahWords(
              surahId,
              ayahNum,
              isQuranMode: true,
            );
            final juz = _sqliteService.calculateJuzAccurate(surahId, ayahNum);

            _ayatList.add(
              AyatData(
                surah_id: surahId,
                ayah: ayahNum,
                words: ayahWords,
                page: pageNumber,
                juz: juz,
                fullArabicText: ayahWords.map((w) => w.text).join(' '),
              ),
            );
          }

          // Sort by surah then ayah
          _ayatList.sort((a, b) {
            if (a.surah_id != b.surah_id)
              return a.surah_id.compareTo(b.surah_id);
            return a.ayah.compareTo(b.ayah);
          });

          _currentAyatIndex = 0;
          _currentPageAyats = _ayatList;

          appLogger.log(
            'DATA',
            'âœ… Instant load complete: ${_ayatList.length} ayahs on page $pageNumber (Surah $_determinedSurahId)',
          );
          appLogger.log(
            'DATA',
            'ðŸ“¦ Cache status: ${pageCache.length} pages cached (${pagesToLoad.length} just loaded)',
          );

          notifyListeners();
          return;
        }
      }

      throw Exception('No valid data on page $pageNumber');
    } catch (e) {
      appLogger.log('DATA_ERROR', 'Failed to load page $pageNumber: $e');
      rethrow;
    }
  }

  Future<void> _loadAyatData() async {
    appLogger.log('DATA', 'Loading ayat data for surah_id $suratId');
    try {
      // Use optimized batch loading
      final results = await Future.wait([
        _sqliteService.getChapterInfo(suratId!),
        _sqliteService.getSurahAyatDataOptimized(
          suratId!,
          isQuranMode: _isQuranMode,
        ),
      ]);

      final chapter = results[0] as ChapterData;
      _ayatList = results[1] as List<AyatData>;

      _suratNameSimple = chapter.nameSimple;
      _suratVersesCount = chapter.versesCount.toString();

      if (_ayatList.isNotEmpty) {
        _currentPage = _ayatList.first.page;
        // Load page data in background, don't await
        _loadCurrentPageAyats();
      }

      appLogger.log('DATA', 'Loaded ${_ayatList.length} ayat instantly');
      notifyListeners();
    } catch (e) {
      appLogger.log('DATA_ERROR', 'Failed to load ayat data - $e');
      throw Exception('Data loading failed: $e');
    }
  }

  // ✅ NEW: Optimized data loading that preserves page position
  Future<void> _loadAyatDataOptimized(int targetPage) async {
    appLogger.log(
      'DATA_OPTIMIZED',
      'Loading data with target page: $targetPage',
    );

    try {
      // ✅ FIX: Initialize with nullable type, then validate
      int? surahIdForPage;

      // Determine surah ID from target page
      if (suratId != null) {
        surahIdForPage = suratId!;
        appLogger.log(
          'DATA_OPTIMIZED',
          'Using direct suratId: $surahIdForPage',
        );
      } else if (_determinedSurahId != null) {
        surahIdForPage = _determinedSurahId!;
        appLogger.log(
          'DATA_OPTIMIZED',
          'Using determined surahId: $surahIdForPage',
        );
      } else {
        // Get surah from cached page data or database
        if (pageCache.containsKey(targetPage)) {
          final pageLines = pageCache[targetPage]!;
          for (final line in pageLines) {
            if (line.ayahSegments != null && line.ayahSegments!.isNotEmpty) {
              surahIdForPage = line.ayahSegments!.first.surahId;
              appLogger.log(
                'DATA_OPTIMIZED',
                'Found surahId from cache: $surahIdForPage',
              );
              break;
            }
          }
        }

        // ✅ FIX: Fallback if still null
        if (surahIdForPage == null) {
          appLogger.log(
            'DATA_OPTIMIZED',
            'Loading from database to find surahId...',
          );
          final pageLines = await _sqliteService.getMushafPageLines(targetPage);

          // Find first valid ayah segment
          for (final line in pageLines) {
            if (line.ayahSegments != null && line.ayahSegments!.isNotEmpty) {
              surahIdForPage = line.ayahSegments!.first.surahId;
              appLogger.log(
                'DATA_OPTIMIZED',
                'Found surahId from DB: $surahIdForPage',
              );
              break;
            }
          }
        }
      }

      // ✅ VALIDATION: Throw error if still null
      if (surahIdForPage == null) {
        throw Exception('Cannot determine surah ID for page $targetPage');
      }

      // Load chapter info
      final chapter = await _sqliteService.getChapterInfo(surahIdForPage);
      _suratNameSimple = chapter.nameSimple;
      _suratVersesCount = chapter.versesCount.toString();
      _determinedSurahId = surahIdForPage;

      // Load ayat list if not already loaded
      if (_ayatList.isEmpty) {
        _ayatList = await _sqliteService.getSurahAyatDataOptimized(
          surahIdForPage,
          isQuranMode: _isQuranMode,
        );
        appLogger.log('DATA_OPTIMIZED', 'Loaded ${_ayatList.length} ayats');
      }

      // ✅ CRITICAL: Set to target page, NOT first page
      _currentPage = targetPage;

      // Update current ayat index based on target page
      if (_ayatList.isNotEmpty) {
        final targetAyat = _ayatList.firstWhere(
          (a) => a.page == targetPage,
          orElse: () => _ayatList.first,
        );
        _currentAyatIndex = _ayatList.indexOf(targetAyat);
        appLogger.log(
          'DATA_OPTIMIZED',
          'Set current ayat index to: $_currentAyatIndex',
        );
      }

      await _loadCurrentPageAyats();
      _isDataLoaded = true;

      appLogger.log(
        'DATA_OPTIMIZED',
        'Data loaded successfully, positioned at page $targetPage',
      );
    } catch (e) {
      appLogger.log('DATA_OPTIMIZED_ERROR', 'Failed to load data: $e');
      rethrow;
    }
  }

  Future<void> _loadCurrentPageAyats() async {
    if (!_isQuranMode) {
      _currentPageAyats = _ayatList;
      notifyListeners();
      return;
    }
    try {
      if (pageCache.containsKey(_currentPage)) {
        _currentPageAyats = await _sqliteService.getCurrentPageAyats(
          _currentPage,
        );
        appLogger.log(
          'DATA',
          'Loaded ${_currentPageAyats.length} ayats from cache for page $_currentPage',
        );
      } else {
        _currentPageAyats = await _sqliteService.getCurrentPageAyats(
          _currentPage,
        );
        appLogger.log(
          'DATA',
          'Loaded ${_currentPageAyats.length} ayats for page $_currentPage',
        );
      }
      notifyListeners();
      _preloadAdjacentPagesAggressively();
    } catch (e) {
      appLogger.log('DATA_PAGE_ERROR', 'Error loading page ayats - $e');
      _currentPageAyats = [];
      notifyListeners();
    }
  }

  Future<void> _preloadAdjacentPagesAggressively() async {
    if (_isPreloadingPages) return;
    _isPreloadingPages = true;

    try {
      final pagesToPreload = <int>[];

      if (_currentPage > 1) pagesToPreload.add(_currentPage - 1);
      if (_currentPage < 604) pagesToPreload.add(_currentPage + 1);

      for (int i = 2; i <= cacheRadius; i++) {
        if (_currentPage - i >= 1) pagesToPreload.add(_currentPage - i);
        if (_currentPage + i <= 604) pagesToPreload.add(_currentPage + i);
      }

      final pagesToLoad = pagesToPreload
          .where((page) => !pageCache.containsKey(page))
          .toList();

      if (pagesToLoad.isEmpty) {
        _isPreloadingPages = false;
        return;
      }

      await Future.wait(
        pagesToLoad.map((page) async {
          try {
            final lines = await _sqliteService.getMushafPageLines(page);
            pageCache[page] = lines;
            appLogger.log(
              'CACHE',
              'Preloaded page $page (${lines.length} lines)',
            );
          } catch (e) {
            appLogger.log('CACHE_ERROR', 'Failed to preload page $page: $e');
          }
        }),
        eagerError: false,
      );

      _cleanupDistantCache();
    } finally {
      _isPreloadingPages = false;
    }
  }

  void _cleanupDistantCache() {
    if (pageCache.length > maxCacheSize) {
      final sortedKeys = pageCache.keys.toList()
        ..sort(
          (a, b) =>
              (a - _currentPage).abs().compareTo((b - _currentPage).abs()),
        );

      final keysToRemove = sortedKeys.skip(maxCacheSize).toList();
      for (final key in keysToRemove) {
        pageCache.remove(key);
        appLogger.log('CACHE', 'Removed distant page $key from cache');
      }
    }
  }

  void navigateToPage(int newPage) {
    if (newPage < 1 || newPage > 604 || newPage == _currentPage) {
      appLogger.log('NAV', 'Invalid navigation to page $newPage');
      return;
    }

    appLogger.log('NAV', 'ðŸ“„ Navigating from page $_currentPage to $newPage');

    _currentPage = newPage;

    // âœ… Check if target page is already cached
    if (pageCache.containsKey(newPage)) {
      appLogger.log('NAV', 'âš¡ INSTANT: Page $newPage already in cache');

      // Update surah name immediately from cache
      _updateSurahNameForPage(newPage);

      // Update current page ayats immediately (no loading)
      _loadCurrentPageAyats();

      // Update ayat index
      if (_currentPageAyats.isNotEmpty) {
        final firstAyatOnPage = _currentPageAyats.first;
        final newIndex = _ayatList.indexWhere(
          (a) =>
              a.surah_id == firstAyatOnPage.surah_id &&
              a.ayah == firstAyatOnPage.ayah,
        );
        if (newIndex >= 0) {
          _currentAyatIndex = newIndex;
          appLogger.log('NAV', 'Updated ayat index to $_currentAyatIndex');
        }
      }

      notifyListeners();

      // Preload more pages in background
      Future.microtask(() => _preloadAdjacentPagesAggressively());
    } else {
      // âœ… Page not cached - load it + adjacent pages immediately
      appLogger.log('NAV', 'ðŸ”¥ Loading page $newPage + adjacent pages...');

      // Load with parallel fetch (will cache adjacent pages too)
      _loadSinglePageData(newPage)
          .then((_) {
            // Update surah name after page loaded
            _updateSurahNameForPage(newPage);

            _loadCurrentPageAyats();

            if (_currentPageAyats.isNotEmpty) {
              final firstAyatOnPage = _currentPageAyats.first;
              final newIndex = _ayatList.indexWhere(
                (a) =>
                    a.surah_id == firstAyatOnPage.surah_id &&
                    a.ayah == firstAyatOnPage.ayah,
              );
              if (newIndex >= 0) {
                _currentAyatIndex = newIndex;
              }
            }

            notifyListeners();

            // Continue preloading in background
            Future.microtask(() => _preloadAdjacentPagesAggressively());
          })
          .catchError((e) {
            appLogger.log(
              'NAV_ERROR',
              'Failed to navigate to page $newPage: $e',
            );
          });
    }
  }

  // ===== NEW METHOD: Update surah name for current page =====
  Future<void> _updateSurahNameForPage(int pageNumber) async {
    try {
      // âœ… Priority 1: Use metadata cache (FASTEST - no database query)
      final surahName = _metadataCache.getPrimarySurahForPage(pageNumber);

      if (surahName.isNotEmpty && surahName != 'Page $pageNumber') {
        // Extract surah ID from cache
        final surahIds = _metadataCache.getSurahIdsForPage(pageNumber);
        if (surahIds != null && surahIds.isNotEmpty) {
          final surahId = surahIds.first;

          if (_determinedSurahId != surahId) {
            _determinedSurahId = surahId;

            // Get full metadata from cache
            final surahMeta = _metadataCache.getSurah(surahId);
            if (surahMeta != null) {
              _suratNameSimple = surahMeta['name_simple'] as String;
              _suratVersesCount = surahMeta['verses_count'].toString();

              appLogger.log(
                'SURAH_UPDATE',
                'Updated to: $_suratNameSimple (Page $pageNumber) - FROM CACHE',
              );
              notifyListeners();
              return;
            }
          }
        }
      }

      // Priority 2: Use cached page data (fallback)
      if (pageCache.containsKey(pageNumber)) {
        final pageLines = pageCache[pageNumber]!;

        for (final line in pageLines) {
          if (line.ayahSegments != null && line.ayahSegments!.isNotEmpty) {
            final firstSegment = line.ayahSegments!.first;
            final surahId = firstSegment.surahId;

            if (_determinedSurahId != surahId) {
              _determinedSurahId = surahId;

              final chapter = await _sqliteService.getChapterInfo(surahId);
              _suratNameSimple = chapter.nameSimple;
              _suratVersesCount = chapter.versesCount.toString();

              appLogger.log(
                'SURAH_UPDATE',
                'Updated to: $_suratNameSimple (Page $pageNumber) - FROM PAGE CACHE',
              );
              notifyListeners();
            }
            return;
          }
        }
      }

      // Priority 3: Use _currentPageAyats if available
      if (_currentPageAyats.isNotEmpty) {
        final firstAyat = _currentPageAyats.first;
        final surahId = firstAyat.surah_id;

        if (_determinedSurahId != surahId) {
          _determinedSurahId = surahId;

          final chapter = await _sqliteService.getChapterInfo(surahId);
          _suratNameSimple = chapter.nameSimple;
          _suratVersesCount = chapter.versesCount.toString();

          appLogger.log(
            'SURAH_UPDATE',
            'Updated to: $_suratNameSimple (from ayats)',
          );
          notifyListeners();
        }
        return;
      }

      // Priority 4: Load from database (slowest fallback)
      final pageLines = await _sqliteService.getMushafPageLines(pageNumber);
      for (final line in pageLines) {
        if (line.ayahSegments != null && line.ayahSegments!.isNotEmpty) {
          final firstSegment = line.ayahSegments!.first;
          final surahId = firstSegment.surahId;

          _determinedSurahId = surahId;

          final chapter = await _sqliteService.getChapterInfo(surahId);
          _suratNameSimple = chapter.nameSimple;
          _suratVersesCount = chapter.versesCount.toString();

          appLogger.log(
            'SURAH_UPDATE',
            'Updated to: $_suratNameSimple (loaded from DB)',
          );
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      appLogger.log('SURAH_UPDATE_ERROR', 'Failed to update surah name: $e');
    }
  }

  void updatePageCache(int page, List<MushafPageLine> lines) {
    pageCache[page] = lines;
  }

  // ===== UI TOGGLES & ACTIONS =====
  void toggleUIVisibility() {
    _isUIVisible = !_isUIVisible;
    notifyListeners();
  }

  Future<void> toggleQuranMode() async {
    appLogger.log(
      'MODE_TOGGLE',
      'Switching from ${_isQuranMode ? "Mushaf" : "List"} to ${!_isQuranMode ? "Mushaf" : "List"}',
    );

    // ✅ STEP 1: Preserve current position
    final targetPage = _isQuranMode ? _currentPage : _listViewCurrentPage;
    appLogger.log('MODE_TOGGLE', 'Target page after toggle: $targetPage');

    // ✅ STEP 2: Toggle mode flag FIRST
    _isQuranMode = !_isQuranMode;

    // ✅ IMMEDIATE: Notify UI of mode change (quick feedback)
    notifyListeners();

    // ✅ STEP 3: Smart data loading (skip if already loaded)
    if (!_isDataLoaded || _ayatList.isEmpty) {
      appLogger.log('MODE_TOGGLE', 'Loading data (first time or empty)');
      await _loadAyatDataOptimized(targetPage);
    } else {
      appLogger.log('MODE_TOGGLE', 'Skipping reload - data already loaded');

      // Just update current page without reloading
      _currentPage = targetPage;

      // Update surah name for target page
      await _updateSurahNameForPage(targetPage);

      // Load page-specific data if switching to mushaf
      if (_isQuranMode) {
        await _loadCurrentPageAyats();

        // ✅ IMPORTANT: Ensure page is in cache before switching
        if (!pageCache.containsKey(targetPage)) {
          appLogger.log(
            'MODE_TOGGLE',
            'Loading target page $targetPage to cache',
          );
          final lines = await _sqliteService.getMushafPageLines(targetPage);
          pageCache[targetPage] = lines;
        }

        // Preload adjacent pages
        Future.microtask(() => _preloadAdjacentPagesAggressively());
      }
    }

    // ✅ FINAL: Notify UI again after data ready
    notifyListeners();

    appLogger.log(
      'MODE_TOGGLE',
      'Toggle complete - now at page $_currentPage (${_isQuranMode ? "Mushaf" : "List"})',
    );
  }

  void toggleHideUnread() {
    _hideUnreadAyat = !_hideUnreadAyat;
    notifyListeners();
  }

  void toggleLogs() {
    _showLogs = !_showLogs;
    notifyListeners();
  }

  void clearLogs() {
    appLogger.clear();
    notifyListeners();
  }

  void handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'logs':
        toggleLogs();
        break;
      case 'reset':
        _showResetDialog(context);
        break;
      case 'export':
        exportSession(context);
        break;
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: warningColor, size: 18),
            SizedBox(width: 4),
            Text('Reset Session', style: TextStyle(fontSize: 14)),
          ],
        ),
        content: const Text(
          'Reset current session? This will restart the app.',
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performReset(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Reset', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _performReset(BuildContext context) {
    appLogger.log('RESET', 'Performing session reset');
    _currentAyatIndex = 0;
    _sessionStartTime = DateTime.now();
    notifyListeners();
  }

  void exportSession(BuildContext context) {
    final sessionData = {
      'surah': _suratNameSimple,
      'session_duration': _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!).inMinutes
          : 0,
      'total_ayat': _ayatList.length,
    };
    appLogger.log('EXPORT', 'Session exported - $sessionData');
  }

  // ===== UTILITY & HELPER METHODS =====
  String formatSurahIdForGlyph(int surahId) {
    if (surahId <= 9) return 'surah00$surahId';
    if (surahId <= 99) return 'surah0$surahId';
    return 'surah$surahId';
  }

  int calculateJuz(int surahId, int ayahNumber) {
    return _sqliteService.calculateJuzAccurate(surahId, ayahNumber);
  }

  static bool containsArabicNumbers(String text) {
    return RegExp(r'[Ù -Ù©]+').hasMatch(text);
  }

  static bool isPureArabicNumber(String text) {
    final trimmedText = text.trim();
    return RegExp(
          r'^[Ù -Ù©Û°Û±Û²Û³Û´ÛµÛ¶Û·Û¸Û¹ÛºÛ»Ûžï®žï®Ÿ\s]+$',
        ).hasMatch(trimmedText) &&
        containsArabicNumbers(trimmedText);
  }

  List<TextSegment> segmentText(String text) {
    List<TextSegment> segments = [];
    List<String> words = text.split(' ');
    for (String word in words) {
      if (word.trim().isEmpty) continue;
      if (isPureArabicNumber(word)) {
        segments.add(TextSegment(text: word, isArabicNumber: true));
      } else {
        segments.add(TextSegment(text: word, isArabicNumber: false));
      }
    }
    return segments;
  }

  // ===== WEBSOCKET & RECORDING =====
  void _initializeWebSocket() {
    print('ðŸ”Œ SttController: Initializing WebSocket subscriptions...');

    // âœ… Cancel old subscriptions if they exist
    _wsSubscription?.cancel();
    _connectionSubscription?.cancel();

    // âœ… Create new subscriptions (will get fresh streams if controllers were recreated)
    _wsSubscription = _webSocketService.messages.listen(
      _handleWebSocketMessage,
      onError: (error) {
        print('âŒ SttController: Message stream error: $error');
      },
      onDone: () {
        print('âš ï¸ SttController: Message stream closed');
      },
    );

    _connectionSubscription = _webSocketService.connectionStatus.listen(
      (isConnected) {
        if (_isConnected != isConnected) {
          _isConnected = isConnected;
          if (_isConnected) {
            _errorMessage = '';
            print('âœ… SttController: Connection status changed to CONNECTED');
          } else if (_isRecording) {
            _errorMessage = 'Connection lost. Attempting to reconnect...';
            print(
              'âš ï¸ SttController: Connection status changed to DISCONNECTED',
            );
          }
          notifyListeners();
        }
      },
      onError: (error) {
        print('âŒ SttController: Connection stream error: $error');
      },
      onDone: () {
        print('âš ï¸ SttController: Connection stream closed');
      },
    );

    print('âœ… SttController: WebSocket subscriptions initialized');

    // Auto-connect
    _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      _webSocketService.enableAutoReconnect();
      await _webSocketService.connect();
      _isConnected = _webSocketService.isConnected;
      appLogger.log('WEBSOCKET', 'Connected: $_isConnected');
    } catch (e) {
      appLogger.log('WEBSOCKET_ERROR', 'Connection failed: $e');
    }
  }

  Future<void> _handleWebSocketMessage(Map<String, dynamic> message) async {
    final type = message['type'];
    appLogger.log('WS_MESSAGE', 'Received: $type');
    print('ðŸ”” STT CONTROLLER: Received message type: $type');

    switch (type) {
      case 'word_processing':
        final int ayah = message['ayah'] ?? 0;
        final int wordIndex = message['word_index'] ?? 0;
        _currentAyatIndex = _ayatList.indexWhere((a) => a.ayah == ayah);
        if (!_wordStatusMap.containsKey(ayah)) _wordStatusMap[ayah] = {};
        _wordStatusMap[ayah]![wordIndex] = WordStatus.processing;
        notifyListeners();
        break;

      case 'skip_rejected':
        _errorMessage = message['message'] ?? 'Please read in order';
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), () {
          if (_errorMessage == message['message']) {
            _errorMessage = '';
            notifyListeners();
          }
        });
        break;

      case 'word_feedback':
        final int ayah = message['ayah'] ?? 0;
        final int wordIndex = message['word_index'] ?? 0;
        final String status = message['status'] ?? 'pending';
        final String expectedWord = message['expected_word'] ?? '';
        final String transcribedWord = message['transcribed_word'] ?? '';
        final int totalWords = message['total_words'] ?? 0;

        _currentAyatIndex = _ayatList.indexWhere((a) => a.ayah == ayah);

        // âœ… UPDATE _wordStatusMap (existing behavior)
        if (!_wordStatusMap.containsKey(ayah)) _wordStatusMap[ayah] = {};
        _wordStatusMap[ayah]![wordIndex] = _mapWordStatus(status);
        print(
          'ðŸ—ºï¸ STT: Updated wordStatusMap[$ayah][$wordIndex] = ${_mapWordStatus(status)}',
        );
        print(
          'ðŸ—ºï¸ STT: Full wordStatusMap[$ayah] = ${_wordStatusMap[ayah]}',
        );

        // ðŸ”¥ NEW: Update _currentWords REALTIME
        if (_currentWords.isEmpty || _currentWords.length != totalWords) {
          print(
            'ðŸ”¥ STT: Initializing _currentWords for ayah $ayah with $totalWords words',
          );
          _currentWords = List.generate(
            totalWords,
            (i) => WordFeedback(
              text: '',
              status: WordStatus.pending,
              wordIndex: i,
              similarity: 0.0,
            ),
          );
        }

        if (wordIndex >= 0 && wordIndex < _currentWords.length) {
          _currentWords[wordIndex] = WordFeedback(
            text: expectedWord,
            status: _mapWordStatus(status),
            wordIndex: wordIndex,
            similarity: (message['similarity'] ?? 0.0).toDouble(),
            transcribedWord: transcribedWord,
          );
          print(
            'ðŸ”¥ STT REALTIME: Updated _currentWords[$wordIndex] = $expectedWord (${_mapWordStatus(status)})',
          );
        }

        notifyListeners();
        break;

      case 'progress':
        final int completedAyah = message['ayah'];
        print('ðŸ“¥ STT: Progress for ayah $completedAyah');

        // ðŸš« DON'T overwrite _currentWords if still recording same ayah!
        // word_feedback updates are more accurate and realtime
        if (!_isRecording ||
            _currentAyatIndex !=
                _ayatList.indexWhere((a) => a.ayah == completedAyah)) {
          if (message['words'] != null) {
            _currentWords = (message['words'] as List)
                .map((w) => WordFeedback.fromJson(w))
                .toList();
            print('ðŸŽ¨ STT: Parsed ${_currentWords.length} words for display');
          }

          // Update expected ayah from backend
          if (message['expected_ayah'] != null) {
            _expectedAyah = message['expected_ayah'];
            print('âœ… STT: Updated expected_ayah to: $_expectedAyah');
          }

          // âœ… Only update currentAyatIndex if NOT recording
          if (!_isRecording) {
            _currentAyatIndex = _ayatList.indexWhere(
              (a) => a.ayah == _expectedAyah,
            );
            print('âœ… STT: Moved currentAyatIndex to: $_currentAyatIndex');
          }
        } else {
          print(
            'ðŸš« STT SKIP: Keeping realtime word_feedback data (recording in progress)',
          );
        }

        // Update tartib status from backend
        if (message['tartib_status'] != null) {
          final Map<String, dynamic> backendTartib = message['tartib_status'];
          backendTartib.forEach((key, value) {
            final int ayahNum = int.tryParse(key) ?? -1;
            if (ayahNum > 0) {
              final String statusStr = value.toString().toLowerCase();
              switch (statusStr) {
                case 'correct':
                  _tartibStatus[ayahNum] = TartibStatus.correct;
                  break;
                case 'skipped':
                  _tartibStatus[ayahNum] = TartibStatus.skipped;
                  break;
                default:
                  _tartibStatus[ayahNum] = TartibStatus.unread;
              }
            }
          });
        }

        notifyListeners();
        break;

      case 'ayah_complete':
        final int completedAyah = message['ayah'] ?? 0;
        final int nextAyah = message['next_ayah'] ?? 0;
        _tartibStatus[completedAyah] = TartibStatus.correct;
        _currentAyatIndex = _ayatList.indexWhere((a) => a.ayah == nextAyah);
        notifyListeners();
        break;

      case 'started':
        _tartibStatus.clear();
        _wordStatusMap.clear();
        _expectedAyah = message['expected_ayah'] ?? 1;
        _sessionId = message['session_id'];
        appLogger.log('SESSION', 'Started: $_sessionId');
        notifyListeners();
        break;

      case 'error':
        _errorMessage = message['message'];
        notifyListeners();
        break;

      // ✅ NEW: Handle paused message from backend
      case 'paused':
        final pausedSessionId = message['session_id'];
        final pausedSurah = message['surah'] ?? 0;
        final pausedAyah = message['ayah'] ?? 0;
        final pausedPosition = message['position'] ?? 0;

        print('⏸️ STT: Session PAUSED');
        print('   Session ID: $pausedSessionId');
        print(
          '   Location: Surah $pausedSurah, Ayah $pausedAyah, Word ${pausedPosition + 1}',
        );

        _sessionId = pausedSessionId;
        _isRecording = false;

        // Show pause confirmation message
        _errorMessage = 'Session paused. You can resume anytime.';
        notifyListeners();

        // Clear message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_errorMessage == 'Session paused. You can resume anytime.') {
            _errorMessage = '';
            notifyListeners();
          }
        });
        break;

      // ✅ NEW: Handle resumed message from backend
      case 'resumed':
        final resumedSurah = message['surah'] ?? 0;
        final resumedAyah = message['ayah'] ?? 0;
        final resumedPosition = message['position'] ?? 0;

        print('▶️ STT: Session RESUMED');
        print(
          '   Location: Surah $resumedSurah, Ayah $resumedAyah, Word ${resumedPosition + 1}',
        );

        // ✅ CRITICAL: Navigate to the correct PAGE for this ayah
        try {
          final targetPage = await LocalDatabaseService.getPageNumber(
            resumedSurah,
            resumedAyah,
          );

          print(
            '📍 Resume target page: $targetPage (for Surah $resumedSurah, Ayah $resumedAyah)',
          );

          // Update page if different from current
          if (_currentPage != targetPage) {
            print('📄 Navigating from page $_currentPage to page $targetPage');
            _currentPage = targetPage;
            _listViewCurrentPage = targetPage;

            // Load ayats for the target page
            await _loadCurrentPageAyats();
          }
        } catch (e) {
          print('⚠️ Failed to get page number: $e');
          // Continue anyway with current page
        }

        // Update current ayat index
        _currentAyatIndex = _ayatList.indexWhere((a) => a.ayah == resumedAyah);

        // If ayat not found in current list, try to find it
        if (_currentAyatIndex == -1) {
          print('⚠️ Ayah $resumedAyah not found in current ayat list');
          // Try to find any ayat from the resumed surah
          _currentAyatIndex = _ayatList.indexWhere(
            (a) => a.surah_id == resumedSurah,
          );
          if (_currentAyatIndex == -1) {
            print('⚠️ Surah $resumedSurah not found, defaulting to index 0');
            _currentAyatIndex = 0;
          }
        }

        print('📍 Resume ayat index: $_currentAyatIndex');

        // Restore word status map if provided
        if (message['word_status_map'] != null) {
          final Map<String, dynamic> backendWordMap =
              message['word_status_map'];
          backendWordMap.forEach((ayahKey, wordMap) {
            final int ayahNum = int.tryParse(ayahKey) ?? -1;
            if (ayahNum > 0 && wordMap is Map) {
              _wordStatusMap[ayahNum] = {};
              (wordMap as Map<String, dynamic>).forEach((wordIndexKey, status) {
                final int wordIndex = int.tryParse(wordIndexKey) ?? -1;
                if (wordIndex >= 0) {
                  _wordStatusMap[ayahNum]![wordIndex] = _mapWordStatus(
                    status.toString(),
                  );
                }
              });
            }
          });
          print('✅ Restored word status for ${_wordStatusMap.length} ayahs');
        }

        // ✅ Restore verse status (ayah-level colors: matched/mismatched)
        if (message['verse_status_map'] != null) {
          final Map<String, dynamic> verseStatusMap =
              message['verse_status_map'] as Map<String, dynamic>;
          verseStatusMap.forEach((ayahKey, status) {
            final int ayahNum = int.tryParse(ayahKey) ?? -1;
            if (ayahNum > 0) {
              // Store verse status for UI display
              // This is used for ayah-level coloring (entire ayah hijau/merah)
              // You can add this to your state if needed
              print('✅ Restored verse status: Ayah $ayahNum = $status');
            }
          });
        }

        // ✅ Restore tartib status
        if (message['tartib_status'] != null) {
          final Map<String, dynamic> tartibMap =
              message['tartib_status'] as Map<String, dynamic>;
          tartibMap.forEach((ayahKey, status) {
            final int ayahNum = int.tryParse(ayahKey) ?? -1;
            if (ayahNum > 0) {
              final String statusStr = status.toString().toLowerCase();
              switch (statusStr) {
                case 'correct':
                  _tartibStatus[ayahNum] = TartibStatus.correct;
                  break;
                case 'skipped':
                  _tartibStatus[ayahNum] = TartibStatus.skipped;
                  break;
                default:
                  _tartibStatus[ayahNum] = TartibStatus.unread;
              }
            }
          });
          print('✅ Restored tartib status for ${_tartibStatus.length} ayahs');
        }

        _errorMessage =
            'Session resumed: Surah $resumedSurah, Ayah $resumedAyah, Word ${resumedPosition + 1}';
        notifyListeners();

        // Clear message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_errorMessage ==
              'Session resumed: Surah $resumedSurah, Ayah $resumedAyah, Word ${resumedPosition + 1}') {
            _errorMessage = '';
            notifyListeners();
          }
        });
        break;

      // ✅ NEW: Handle summary message from backend
      case 'summary':
        print('📊 STT: Received session SUMMARY');

        final summaryAyah = message['ayah'] ?? 0;
        final wordResults = message['word_results'] as List?;
        final accuracy = message['accuracy'] as Map<String, dynamic>?;

        if (accuracy != null) {
          final benar = accuracy['benar'] ?? 0;
          final salah = accuracy['salah'] ?? 0;
          final total = accuracy['total'] ?? 0;
          final accuracyPct = accuracy['accuracy'] ?? 0.0;

          print('   ✅ Benar: $benar');
          print('   ❌ Salah: $salah');
          print('   📈 Total: $total');
          print('   🎯 Accuracy: ${accuracyPct.toStringAsFixed(1)}%');
        }

        if (wordResults != null) {
          print('   📝 Word results: ${wordResults.length} words');
        }

        _isRecording = false;
        notifyListeners();
        break;

      // ✅ NEW: Handle completed message from backend
      case 'completed':
        print('✅ STT: Session COMPLETED');

        _isRecording = false;
        _errorMessage = 'Session completed successfully!';
        notifyListeners();

        // Clear message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_errorMessage == 'Session completed successfully!') {
            _errorMessage = '';
            notifyListeners();
          }
        });
        break;
    }
  }

  WordStatus _mapWordStatus(String status) {
    switch (status.toLowerCase()) {
      case 'matched':
      case 'correct':
      case 'close': // âœ… Close = hampir benar = HIJAU
      case 'benar': // ✅ Backend sends "benar" for correct words
        return WordStatus.matched;
      case 'processing':
        return WordStatus.processing;
      case 'mismatched':
      case 'incorrect':
      case 'salah': // ✅ Backend sends "salah" for incorrect words
        return WordStatus.mismatched;
      case 'skipped':
        return WordStatus.skipped;
      default:
        return WordStatus.pending;
    }
  }

  /// ✅ NEW: Resume from existing session
  Future<void> resumeFromSession(Map<String, dynamic> session) async {
    print('▶️ Resuming session: ${session['session_id']}');
    print(
      '   Location: Surah ${session['surah_id']}, Ayah ${session['ayah']}, Word ${(session['position'] ?? 0) + 1}',
    );

    try {
      // Connect WebSocket if not connected
      if (!_webSocketService.isConnected) {
        print('🔌 Connecting to WebSocket...');
        await _webSocketService.connect();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Send resume request
      _webSocketService.sendResumeSession(
        sessionId: session['session_id'],
        surahNumber: session['surah_id'],
        position: session['position'],
      );

      print('✅ Resume request sent, waiting for backend response...');
    } catch (e) {
      print('❌ Failed to resume session: $e');
      _errorMessage = 'Failed to resume session: $e';
      notifyListeners();
    }
  }

  /// ✅ NEW: Check for resumable session (internal)
  Future<void> _checkForResumableSession() async {
    try {
      if (!_authService.isAuthenticated) {
        print('⚠️ User not authenticated, no resumable session');
        _hasResumableSession = false;
        return;
      }

      final userUuid = _authService.userId;
      if (userUuid == null) {
        print('⚠️ User UUID is null');
        _hasResumableSession = false;
        return;
      }

      print('🔍 Checking for resumable session...');
      final latestSession = await _supabaseService.getResumableSession(
        userUuid,
      );

      if (latestSession != null) {
        print('✅ Found resumable session: ${latestSession['session_id']}');
        print(
          '   Surah: ${latestSession['surah_id']}, Ayah: ${latestSession['ayah']}',
        );
        _hasResumableSession = true;
      } else {
        print('⚠️ No resumable session found');
        _hasResumableSession = false;
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error checking for resumable session: $e');
      _hasResumableSession = false;
      notifyListeners();
    }
  }

  /// ✅ NEW: Resume last session (called by button)
  Future<void> resumeLastSession() async {
    try {
      if (!_authService.isAuthenticated) {
        print('⚠️ Cannot resume: User not authenticated');
        return;
      }

      final userUuid = _authService.userId;
      if (userUuid == null) {
        print('⚠️ Cannot resume: User UUID is null');
        return;
      }

      print('📡 Fetching resumable session...');
      final session = await _supabaseService.getResumableSession(userUuid);

      if (session != null) {
        print('✅ Resuming session: ${session['session_id']}');
        await resumeFromSession(session);
        _hasResumableSession = false; // Clear flag after resume
        notifyListeners();
      } else {
        print('⚠️ No session to resume');
        _errorMessage = 'No paused session found';
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error resuming last session: $e');
      _errorMessage = 'Failed to resume session: $e';
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    // âœ… FIX: Sync provider flag from service FIRST
    final serviceConnected = _webSocketService.isConnected;
    _isConnected = serviceConnected;
    print('ðŸŽ¤ startRecording(): Called.');
    print('   - _isConnected (cached) = $_isConnected');
    print('   - service.isConnected (fresh) = $serviceConnected');

    if (!_isConnected) {
      print('âš ï¸ startRecording(): Not connected, attempting to connect...');
      _errorMessage = 'Connecting...';
      notifyListeners();
      await _connectWebSocket();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isConnected) {
        print('âŒ startRecording(): Connect failed!');
        _errorMessage = 'Cannot connect to server';
        notifyListeners();
        return;
      }
    }

    try {
      print('âœ… startRecording(): Connected, clearing state...');
      _tartibStatus.clear();
      _wordStatusMap.clear();
      _expectedAyah = 1;
      _sessionId = null;
      _errorMessage = '';

      // âœ… FIX: Determine surah ID with proper priority
      int recordingSurahId;

      if (suratId != null) {
        // Direct surah navigation
        recordingSurahId = suratId!;
        appLogger.log('RECORDING', 'Using direct suratId: $recordingSurahId');
      } else if (_determinedSurahId != null) {
        // From page/juz navigation - use determined surah
        recordingSurahId = _determinedSurahId!;
        appLogger.log(
          'RECORDING',
          'Using determined suratId from page: $recordingSurahId',
        );
      } else if (_ayatList.isNotEmpty) {
        // Fallback: use first ayat's surah
        recordingSurahId = _ayatList.first.surah_id;
        appLogger.log(
          'RECORDING',
          'Fallback: Using first ayat surah: $recordingSurahId',
        );
      } else {
        throw Exception(
          'Cannot determine surah ID for recording - no data loaded',
        );
      }

      print(
        'ðŸ“¤ startRecording(): Sending START message for surah $recordingSurahId...',
      );

      // ✅ Send with page/juz info if available
      final firstAyah = _ayatList.isNotEmpty ? _ayatList.first.ayah : 1;
      _webSocketService.sendStartRecording(
        recordingSurahId,
        pageId: pageId,
        juzId: juzId,
        ayah: firstAyah,
      );

      print('ðŸŽ™ï¸ startRecording(): Starting audio recording...');
      await _audioService.startRecording(
        onAudioChunk: (base64Audio) {
          if (_webSocketService.isConnected) {
            _webSocketService.sendAudioChunk(base64Audio);
          }
        },
      );
      _hideUnreadAyat = true;
      _isRecording = true;
      appLogger.log('RECORDING', 'Started for surah $recordingSurahId');
      print('âœ… startRecording(): Recording started successfully');
      notifyListeners();
    } catch (e) {
      print('âŒ startRecording(): Exception: $e');
      _errorMessage = 'Failed to start: $e';
      _isRecording = false;
      appLogger.log('RECORDING_ERROR', e.toString());
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    print('ðŸ›‘ stopRecording(): Called');
    try {
      await _audioService.stopRecording();
      _webSocketService
          .sendPauseRecording(); // ✅ Changed: PAUSE (was sendStopRecording)
      _isRecording = false;
      appLogger.log('RECORDING', 'Stopped');
      print('âœ… stopRecording(): Stopped successfully');
      notifyListeners();
    } catch (e) {
      print('âŒ stopRecording(): Exception: $e');
      _errorMessage = 'Failed to stop: $e';
      appLogger.log('RECORDING_ERROR', e.toString());
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> reconnect() async {
    _errorMessage = 'Reconnecting...';
    _isConnected = false;
    notifyListeners();

    _webSocketService.disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await _connectWebSocket();

    if (_isConnected && _sessionId != null) {
      _webSocketService.sendRecoverSession(_sessionId!);
    }

    _errorMessage = _isConnected ? '' : 'Reconnect failed';
    notifyListeners();
  }

  // REPLACE method updateVisiblePage dengan:
  void updateVisiblePage(int pageNumber) {
    if (_currentPage != pageNumber) {
      appLogger.log(
        'VISIBLE_PAGE',
        'Updating visible page: $_currentPage → $pageNumber',
      );

      _currentPage = pageNumber;

      // ✅ CRITICAL: Track list view position separately
      if (!_isQuranMode) {
        _listViewCurrentPage = pageNumber;
        appLogger.log('VISIBLE_PAGE', 'List view position saved: $pageNumber');
      }

      _updateSurahNameForPage(pageNumber);

      // Update current ayat index based on visible page
      if (_ayatList.isNotEmpty) {
        final firstAyatOnPage = _ayatList.firstWhere(
          (a) => a.page == pageNumber,
          orElse: () => _ayatList.first,
        );
        final newIndex = _ayatList.indexOf(firstAyatOnPage);
        if (newIndex >= 0) {
          _currentAyatIndex = newIndex;
          appLogger.log(
            'VISIBLE_PAGE',
            'Updated ayat index to: $_currentAyatIndex',
          );
        }
      }

      if (!_isQuranMode) {
        Future.microtask(() => _preloadAdjacentPagesAggressively());
      }

      notifyListeners();
    }
  }

  // ===== DISPOSAL =====
  @override
  void dispose() {
    print('ðŸ’€ SttController: DISPOSE CALLED for surah $suratId');
    appLogger.log('DISPOSAL', 'Starting cleanup process');

    _verseChangeSubscription?.cancel();
    _wordHighlightSubscription?.cancel();
    _listeningAudioService?.dispose();
    ReciterDatabaseService.dispose();

    // âœ… Cancel subscriptions
    _wsSubscription?.cancel();
    _connectionSubscription?.cancel();

    // âœ… Dispose audio service
    _audioService.dispose();

    // âœ… DON'T dispose singleton WebSocketService!
    // _webSocketService.dispose();  // â† REMOVED: Singleton should not be disposed
    // âœ… QuranService singleton - jangan dispose, database tetap hidup
    _scrollController.dispose();
    appLogger.dispose();
    super.dispose();
  }
}
