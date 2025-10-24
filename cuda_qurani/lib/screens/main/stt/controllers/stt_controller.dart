// lib\screens\main\stt\controllers\stt_controller.dart

import 'dart:async';
import 'package:cuda_qurani/models/quran_models.dart';
import 'package:cuda_qurani/screens/main/home/services/juz_service.dart';
import 'package:cuda_qurani/services/local_database_service.dart';
import 'package:flutter/material.dart';
import '../data/models.dart' hide TartibStatus;
import '../services/quran_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'package:cuda_qurani/services/audio_service.dart';
import 'package:cuda_qurani/services/websocket_service.dart';
import 'package:cuda_qurani/config/app_config.dart';

class SttController with ChangeNotifier {
  final int? suratId;
  final int? pageId;
  final int? juzId;

  int? _determinedSurahId;

  SttController({this.suratId, this.pageId, this.juzId}) {
    print(
      '🗃️ SttController: CONSTRUCTOR - surah:$suratId page:$pageId juz:$juzId',
    );
    _webSocketService = WebSocketService(serverUrl: AppConfig.websocketUrl);
    _initializeWebSocket();
  }

  // Services
  final QuranService _sqliteService = QuranService();
  final AppLogger appLogger = AppLogger();

  // Core State
  bool _isLoading = true;
  String _errorMessage = '';
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
      []; // ✅ ADD: Store current words for realtime updates
  StreamSubscription? _wsSubscription;
  StreamSubscription? _connectionSubscription;

  // Getters for recording state
  bool get isRecording => _isRecording;
  bool get isConnected => _isConnected;
<<<<<<< HEAD

  // ✅ NEW: Direct access to service connection state (always fresh)
  bool get isServiceConnected => _webSocketService.isConnected;

=======
  
  // ✅ NEW: Direct access to service connection state (always fresh)
  bool get isServiceConnected => _webSocketService.isConnected;
  
>>>>>>> 9e576932e9651d1cf86c16c935f47e8cf883cf7b
  int get expectedAyah => _expectedAyah;
  Map<int, TartibStatus> get tartibStatus => _tartibStatus;
  Map<int, Map<int, WordStatus>> get wordStatusMap => _wordStatusMap;
  List<WordFeedback> get currentWords =>
      _currentWords; // ✅ ADD: Getter for currentWords

  // Page Pre-loading Cache
  final Map<int, List<MushafPageLine>> pageCache = {};

  bool _isPreloadingPages = false;

  // Getters for UI
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
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

  // ===== INITIALIZATION =====
  Future<void> initializeApp() async {
    appLogger.log('APP_INIT', 'Starting OPTIMIZED page-based initialization');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _sqliteService.initialize();

      // 🚀 STEP 1: Determine target page FIRST
      int targetPage = await _determineTargetPage();
      _currentPage = targetPage;

      appLogger.log('APP_INIT', 'Target page determined: $targetPage');

      // 🚀 STEP 2: Load ONLY that page (minimal data)
      await _loadSinglePageData(targetPage);

      _sessionStartTime = DateTime.now();

      // Mark as ready INSTANTLY
      _isLoading = false;
      notifyListeners();

      appLogger.log(
        'APP_INIT',
        'App ready - Page $targetPage loaded instantly',
      );

      // 🚀 STEP 3: Background tasks
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
    appLogger.log('DATA', '🚀 INSTANT LOAD: Page $pageNumber + adjacent pages');

    try {
      // ✅ STEP 1: Determine pages to load (main + 2 before + 2 after = 5 pages)
      final pagesToLoad = <int>[];

      // Add main page first (priority)
      pagesToLoad.add(pageNumber);

      // Add adjacent pages
      if (pageNumber > 1) pagesToLoad.add(pageNumber - 1);
      if (pageNumber > 2) pagesToLoad.add(pageNumber - 2);
      if (pageNumber < 604) pagesToLoad.add(pageNumber + 1);
      if (pageNumber < 603) pagesToLoad.add(pageNumber + 2);

      // ✅ STEP 2: Load all pages in PARALLEL
      await _loadMultiplePagesParallel(pagesToLoad);

      // ✅ STEP 3: Extract main page data for UI
      final pageLines = pageCache[pageNumber];
      if (pageLines == null || pageLines.isEmpty) {
        throw Exception('Main page $pageNumber failed to load');
      }

      // ✅ STEP 4: Determine and STORE surah ID from first ayah
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
            '✅ Instant load complete: ${_ayatList.length} ayahs on page $pageNumber (Surah $_determinedSurahId)',
          );
          appLogger.log(
            'DATA',
            '📦 Cache status: ${pageCache.length} pages cached (${pagesToLoad.length} just loaded)',
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

    appLogger.log('NAV', '🔄 Navigating from page $_currentPage to $newPage');

    _currentPage = newPage;

    // ✅ Check if target page is already cached
    if (pageCache.containsKey(newPage)) {
      appLogger.log('NAV', '⚡ INSTANT: Page $newPage already in cache');

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
      // ✅ Page not cached - load it + adjacent pages immediately
      appLogger.log('NAV', '📥 Loading page $newPage + adjacent pages...');

      // Load with parallel fetch (will cache adjacent pages too)
      _loadSinglePageData(newPage)
          .then((_) {
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

  void updatePageCache(int page, List<MushafPageLine> lines) {
    pageCache[page] = lines;
  }

  // ===== UI TOGGLES & ACTIONS =====
  void toggleUIVisibility() {
    _isUIVisible = !_isUIVisible;
    notifyListeners();
  }

  void toggleQuranMode() async {
    _isQuranMode = !_isQuranMode;
    await _loadAyatData();
    await _loadCurrentPageAyats();
    notifyListeners();
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
    return RegExp(r'[٠-٩]+').hasMatch(text);
  }

  static bool isPureArabicNumber(String text) {
    final trimmedText = text.trim();
    return RegExp(r'^[٠-٩۰۱۲۳۴۵۶۷۸۹ۺۻ۞ﮞﮟ\s]+$').hasMatch(trimmedText) &&
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
    print('🔌 SttController: Initializing WebSocket subscriptions...');
<<<<<<< HEAD

    // ✅ Cancel old subscriptions if they exist
    _wsSubscription?.cancel();
    _connectionSubscription?.cancel();

=======
    
    // ✅ Cancel old subscriptions if they exist
    _wsSubscription?.cancel();
    _connectionSubscription?.cancel();
    
>>>>>>> 9e576932e9651d1cf86c16c935f47e8cf883cf7b
    // ✅ Create new subscriptions (will get fresh streams if controllers were recreated)
    _wsSubscription = _webSocketService.messages.listen(
      _handleWebSocketMessage,
      onError: (error) {
        print('❌ SttController: Message stream error: $error');
      },
      onDone: () {
        print('⚠️ SttController: Message stream closed');
      },
    );
<<<<<<< HEAD

    _connectionSubscription = _webSocketService.connectionStatus.listen(
      (isConnected) {
        if (_isConnected != isConnected) {
          _isConnected = isConnected;
          if (_isConnected) {
            _errorMessage = '';
            print('✅ SttController: Connection status changed to CONNECTED');
          } else if (_isRecording) {
            _errorMessage = 'Connection lost. Attempting to reconnect...';
            print(
              '⚠️ SttController: Connection status changed to DISCONNECTED',
            );
          }
          notifyListeners();
        }
      },
      onError: (error) {
        print('❌ SttController: Connection stream error: $error');
      },
      onDone: () {
        print('⚠️ SttController: Connection stream closed');
      },
    );

=======
    
    _connectionSubscription = _webSocketService.connectionStatus.listen((
      isConnected,
    ) {
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        if (_isConnected) {
          _errorMessage = '';
          print('✅ SttController: Connection status changed to CONNECTED');
        } else if (_isRecording) {
          _errorMessage = 'Connection lost. Attempting to reconnect...';
          print('⚠️ SttController: Connection status changed to DISCONNECTED');
        }
        notifyListeners();
      }
    }, onError: (error) {
      print('❌ SttController: Connection stream error: $error');
    }, onDone: () {
      print('⚠️ SttController: Connection stream closed');
    });
    
>>>>>>> 9e576932e9651d1cf86c16c935f47e8cf883cf7b
    print('✅ SttController: WebSocket subscriptions initialized');

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

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'];
    appLogger.log('WS_MESSAGE', 'Received: $type');
    print('🔔 STT CONTROLLER: Received message type: $type');

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

        // ✅ UPDATE _wordStatusMap (existing behavior)
        if (!_wordStatusMap.containsKey(ayah)) _wordStatusMap[ayah] = {};
        _wordStatusMap[ayah]![wordIndex] = _mapWordStatus(status);
        print(
          '🗺️ STT: Updated wordStatusMap[$ayah][$wordIndex] = ${_mapWordStatus(status)}',
        );
        print('🗺️ STT: Full wordStatusMap[$ayah] = ${_wordStatusMap[ayah]}');

        // 🔥 NEW: Update _currentWords REALTIME
        if (_currentWords.isEmpty || _currentWords.length != totalWords) {
          print(
            '🔥 STT: Initializing _currentWords for ayah $ayah with $totalWords words',
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
            '🔥 STT REALTIME: Updated _currentWords[$wordIndex] = $expectedWord (${_mapWordStatus(status)})',
          );
        }

        notifyListeners();
        break;

      case 'progress':
        final int completedAyah = message['ayah'];
        print('📥 STT: Progress for ayah $completedAyah');

        // 🚫 DON'T overwrite _currentWords if still recording same ayah!
        // word_feedback updates are more accurate and realtime
        if (!_isRecording ||
            _currentAyatIndex !=
                _ayatList.indexWhere((a) => a.ayah == completedAyah)) {
          if (message['words'] != null) {
            _currentWords = (message['words'] as List)
                .map((w) => WordFeedback.fromJson(w))
                .toList();
            print('🎨 STT: Parsed ${_currentWords.length} words for display');
          }

          // Update expected ayah from backend
          if (message['expected_ayah'] != null) {
            _expectedAyah = message['expected_ayah'];
            print('✅ STT: Updated expected_ayah to: $_expectedAyah');
          }

          // ✅ Only update currentAyatIndex if NOT recording
          if (!_isRecording) {
            _currentAyatIndex = _ayatList.indexWhere(
              (a) => a.ayah == _expectedAyah,
            );
            print('✅ STT: Moved currentAyatIndex to: $_currentAyatIndex');
          }
        } else {
          print(
            '🚫 STT SKIP: Keeping realtime word_feedback data (recording in progress)',
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
    }
  }

  WordStatus _mapWordStatus(String status) {
    switch (status.toLowerCase()) {
      case 'matched':
      case 'correct':
      case 'close': // ✅ Close = hampir benar = HIJAU
        return WordStatus.matched;
      case 'processing':
        return WordStatus.processing;
      case 'mismatched':
      case 'incorrect':
        return WordStatus.mismatched;
      case 'skipped':
        return WordStatus.skipped;
      default:
        return WordStatus.pending;
    }
  }

  Future<void> startRecording() async {
    // ✅ FIX: Sync provider flag from service FIRST
    final serviceConnected = _webSocketService.isConnected;
    _isConnected = serviceConnected;
    print('🎤 startRecording(): Called.');
    print('   - _isConnected (cached) = $_isConnected');
    print('   - service.isConnected (fresh) = $serviceConnected');
<<<<<<< HEAD

=======
    
>>>>>>> 9e576932e9651d1cf86c16c935f47e8cf883cf7b
    if (!_isConnected) {
      print('⚠️ startRecording(): Not connected, attempting to connect...');
      _errorMessage = 'Connecting...';
      notifyListeners();
      await _connectWebSocket();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isConnected) {
        print('❌ startRecording(): Connect failed!');
        _errorMessage = 'Cannot connect to server';
        notifyListeners();
        return;
      }
    }

    try {
      print('✅ startRecording(): Connected, clearing state...');
      _tartibStatus.clear();
      _wordStatusMap.clear();
      _expectedAyah = 1;
      _sessionId = null;
      _errorMessage = '';

      // ✅ FIX: Determine surah ID with proper priority
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
        '📤 startRecording(): Sending START message for surah $recordingSurahId...',
      );
      _webSocketService.sendStartRecording(recordingSurahId);

      print('🎙️ startRecording(): Starting audio recording...');
      await _audioService.startRecording(
        onAudioChunk: (base64Audio) {
          if (_webSocketService.isConnected) {
            _webSocketService.sendAudioChunk(base64Audio);
          }
        },
      );

      _isRecording = true;
      appLogger.log('RECORDING', 'Started for surah $recordingSurahId');
      print('✅ startRecording(): Recording started successfully');
      notifyListeners();
    } catch (e) {
      print('❌ startRecording(): Exception: $e');
      _errorMessage = 'Failed to start: $e';
      _isRecording = false;
      appLogger.log('RECORDING_ERROR', e.toString());
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    print('🛑 stopRecording(): Called');
    try {
      await _audioService.stopRecording();
      _webSocketService.sendStopRecording();
      _isRecording = false;
      appLogger.log('RECORDING', 'Stopped');
      print('✅ stopRecording(): Stopped successfully');
      notifyListeners();
    } catch (e) {
      print('❌ stopRecording(): Exception: $e');
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
      _currentPage = pageNumber;

      // Trigger pre-loading for both modes
      if (!_isQuranMode) {
        Future.microtask(() => _preloadAdjacentPagesAggressively());
      }

      notifyListeners();
    }
  }

  // ===== DISPOSAL =====
<<<<<<< HEAD
  @override
  void dispose() {
    print('💀 SttController: DISPOSE CALLED for surah $suratId');
    appLogger.log('DISPOSAL', 'Starting cleanup process');

    // ✅ Cancel subscriptions
    _wsSubscription?.cancel();
    _connectionSubscription?.cancel();

    // ✅ Dispose audio service
    _audioService.dispose();

    // ✅ DON'T dispose singleton WebSocketService!
    // _webSocketService.dispose();  // ← REMOVED: Singleton should not be disposed
    // ✅ QuranService singleton - jangan dispose, database tetap hidup
    _scrollController.dispose();
    appLogger.dispose();
    super.dispose();
  }
=======
@override
void dispose() {
  print('💀 SttController: DISPOSE CALLED for surah $suratId');
  appLogger.log('DISPOSAL', 'Starting cleanup process');
  
  // ✅ Cancel subscriptions
  _wsSubscription?.cancel();
  _connectionSubscription?.cancel();
  
  // ✅ Dispose audio service
  _audioService.dispose();
  
  // ✅ DON'T dispose singleton WebSocketService!
  // _webSocketService.dispose();  // ← REMOVED: Singleton should not be disposed
  // ✅ QuranService singleton - jangan dispose, database tetap hidup
  _scrollController.dispose();
  appLogger.dispose();
  super.dispose();
}
>>>>>>> 9e576932e9651d1cf86c16c935f47e8cf883cf7b
}
