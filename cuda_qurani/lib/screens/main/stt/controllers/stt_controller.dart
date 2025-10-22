// lib\screens\main\stt\controllers\stt_controller.dart

import 'dart:async';
import 'package:cuda_qurani/models/quran_models.dart';
import 'package:flutter/material.dart';
import '../data/models.dart' hide TartibStatus;
import '../services/quran_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'package:cuda_qurani/services/audio_service.dart';
import 'package:cuda_qurani/services/websocket_service.dart';
import 'package:cuda_qurani/config/app_config.dart';

class SttController with ChangeNotifier {
  final int suratId;
  SttController({required this.suratId}) {
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
  StreamSubscription? _wsSubscription;
  StreamSubscription? _connectionSubscription;

  // Getters for recording state
  bool get isRecording => _isRecording;
  bool get isConnected => _isConnected;
  int get expectedAyah => _expectedAyah;
  Map<int, TartibStatus> get tartibStatus => _tartibStatus;
  Map<int, Map<int, WordStatus>> get wordStatusMap => _wordStatusMap;

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
    appLogger.log('APP_INIT', 'Starting instant app initialization');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Database already initialized in main.dart, just verify
      await _sqliteService.initialize();

      // Load data immediately
      await _loadAyatData();
      _sessionStartTime = DateTime.now();

      // Mark as ready INSTANTLY
      _isLoading = false;
      notifyListeners();

      appLogger.log('APP_INIT', 'App ready - ${_ayatList.length} ayat loaded');

      // Background tasks - don't block UI
      Future.microtask(() {
        if (_isQuranMode) {
          _preloadAdjacentPagesAggressively();
        }
      });
    } catch (e) {
      final errorString = 'Failed to initialize app: $e';
      appLogger.log('APP_INIT_ERROR', errorString);
      _errorMessage = errorString;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAyatData() async {
    appLogger.log('DATA', 'Loading ayat data for surah_id $suratId');
    try {
      // Use optimized batch loading
      final results = await Future.wait([
        _sqliteService.getChapterInfo(suratId),
        _sqliteService.getSurahAyatDataOptimized(
          suratId,
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

    appLogger.log('NAV', 'Navigating from page $_currentPage to $newPage');

    _currentPage = newPage;
    notifyListeners();

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
        appLogger.log('NAV', 'Updated ayat index to $_currentAyatIndex');
      }
      notifyListeners();
    }

    Future.microtask(() => _preloadAdjacentPagesAggressively());
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
    _wsSubscription = _webSocketService.messages.listen(
      _handleWebSocketMessage,
    );
    _connectionSubscription = _webSocketService.connectionStatus.listen((
      isConnected,
    ) {
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        if (_isConnected) {
          _errorMessage = '';
        } else if (_isRecording) {
          _errorMessage = 'Connection lost. Attempting to reconnect...';
        }
        notifyListeners();
      }
    });

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
        _currentAyatIndex = _ayatList.indexWhere((a) => a.ayah == ayah);
        if (!_wordStatusMap.containsKey(ayah)) _wordStatusMap[ayah] = {};
        _wordStatusMap[ayah]![wordIndex] = _mapWordStatus(status);
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
    if (!_isConnected) {
      _errorMessage = 'Connecting...';
      notifyListeners();
      await _connectWebSocket();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isConnected) {
        _errorMessage = 'Cannot connect to server';
        notifyListeners();
        return;
      }
    }

    try {
      _tartibStatus.clear();
      _wordStatusMap.clear();
      _expectedAyah = 1;
      _sessionId = null;
      _errorMessage = '';

      _webSocketService.sendStartRecording(suratId);
      await _audioService.startRecording(
        onAudioChunk: (base64Audio) {
          if (_webSocketService.isConnected) {
            _webSocketService.sendAudioChunk(base64Audio);
          }
        },
      );

      _isRecording = true;
      appLogger.log('RECORDING', 'Started for surah $suratId');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start: $e';
      _isRecording = false;
      appLogger.log('RECORDING_ERROR', e.toString());
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    try {
      await _audioService.stopRecording();
      _webSocketService.sendStopRecording();
      _isRecording = false;
      appLogger.log('RECORDING', 'Stopped');
      notifyListeners();
    } catch (e) {
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

  // ===== DISPOSAL =====
  @override
  void dispose() {
    appLogger.log('DISPOSAL', 'Starting cleanup process');
    _wsSubscription?.cancel();
    _connectionSubscription?.cancel();
    _audioService.dispose();
    _webSocketService.dispose();
    // JANGAN dispose sqliteService karena menggunakan singleton
    // _sqliteService.dispose(); // HAPUS BARIS INI
    _scrollController.dispose();
    appLogger.dispose();
    super.dispose();
  }
}
