import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/quran_models.dart';
import '../services/audio_service.dart';
import '../services/websocket_service.dart';

class RecitationProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final WebSocketService _webSocketService;
  
  bool _isRecording = false;
  bool _isConnected = false;
  int? _currentVerseIndex;
  List<WordFeedback> _currentWords = [];
  RecitationSummary? _summary;
  String? _errorMessage;
  
  // 🔐 SESSION MANAGEMENT
  String? _sessionId;  // Persist session ID for recovery
  String? get sessionId => _sessionId;
  
  // Permanent verse status map (legacy for word-level feedback)
  final Map<int, WordStatus> _verseStatus = {};
  Map<int, WordStatus> get verseStatus => _verseStatus;
  
  // Tartib (sequence) evaluation system
  final Map<int, TartibStatus> _tartibStatus = {};
  Map<int, TartibStatus> get tartibStatus => _tartibStatus;
  int _expectedAyah = 1; // Ayat yang diharapkan dibaca selanjutnya
  int get expectedAyah => _expectedAyah;
  
  // 📝 NEW: Per-word status tracking untuk highlight individual kata
  // Map: {ayah_number: {word_index: WordStatus}}
  final Map<int, Map<int, WordStatus>> _wordStatusMap = {};
  Map<int, Map<int, WordStatus>> get wordStatusMap => _wordStatusMap;
  
  StreamSubscription? _wsSubscription;
  StreamSubscription? _connectionSubscription;

  RecitationProvider()
      : _webSocketService = WebSocketService(serverUrl: AppConfig.websocketUrl) {
    _initialize();
  }

  bool get isRecording => _isRecording;
  bool get isConnected => _isConnected;
  int? get currentVerseIndex => _currentVerseIndex;
  List<WordFeedback> get currentWords => _currentWords;
  RecitationSummary? get summary => _summary;
  String? get errorMessage => _errorMessage;

  void _initialize() {
    _wsSubscription = _webSocketService.messages.listen(_handleWebSocketMessage);
    _connectionSubscription = _webSocketService.connectionStatus.listen((isConnected) {
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        if (_isConnected) {
          _errorMessage = null; // Clear error on successful reconnection
          print('WebSocket reconnected successfully');
        } else {
          if (_isRecording) {
            _errorMessage = 'Connection lost. Attempting to reconnect...';
          }
          print('WebSocket connection lost');
        }
        notifyListeners();
      }
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'];
    print('🔔 RecitationProvider: Received message type: $type');
    
    switch (type) {
      case 'word_processing':
        // 🎨 REALTIME: Show processing indicator immediately
        final int ayah = message['ayah'] ?? 0;
        final int wordIndex = message['word_index'] ?? 0;
        final String transcribedText = message['transcribed_text'] ?? '';
        
        print('🎨 Processing word $wordIndex in ayah $ayah: "$transcribedText"');
        
        // Update current verse index
        _currentVerseIndex = ayah;
        
        // Initialize ayah word map if not exists
        if (!_wordStatusMap.containsKey(ayah)) {
          _wordStatusMap[ayah] = {};
        }
        
        // Set status "processing" untuk kata ini (REALTIME)
        _wordStatusMap[ayah]![wordIndex] = WordStatus.processing;
        
        print('  🔵 Word $wordIndex: PROCESSING (realtime indicator)');
        
        // INSTANT UI UPDATE untuk show blue/yellow indicator
        notifyListeners();
        break;
      
      case 'skip_rejected':
        // 🚫 User tried to skip ayah - show warning
        final int detectedAyah = message['detected_ayah'] ?? 0;
        final int expectedAyah = message['expected_ayah'] ?? 0;
        final String msg = message['message'] ?? 'Please read ayah $expectedAyah first';
        
        print('🚫 SKIP REJECTED: User tried to read ayah $detectedAyah but must read $expectedAyah');
        
        _errorMessage = msg;
        notifyListeners();
        
        // Clear error after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_errorMessage == msg) {
            _errorMessage = null;
            notifyListeners();
          }
        });
        break;
      
      case 'multi_word_start':
        // 🆕 MULTI-WORD: User baca beberapa kata sekaligus (continuous reading)
        final int wordCount = message['word_count'] ?? 0;
        final int processedCount = message['processed_count'] ?? 0;
        print('📝 MULTI-WORD detected: $wordCount words continuous, $processedCount will be processed');
        // Optional: Show brief notification to user
        // Future implementation: Could show "Continuous reading: X words" banner
        break;
      
      case 'word_feedback':
        // 📝 STRICT PER-WORD: Update status untuk 1 KATA saja
        final int ayah = message['ayah'] ?? 0;
        final int wordIndex = message['word_index'] ?? 0;
        final String status = message['status'] ?? 'pending';
        final double similarity = message['similarity']?.toDouble() ?? 0.0;
        final bool shouldAdvance = message['should_advance'] ?? false;
        
        print('📝 Word $wordIndex: $status (sim: ${similarity.toStringAsFixed(2)}) ${shouldAdvance ? "→ ADVANCE" : "→ RETRY"}');
        
        // Update current verse index
        _currentVerseIndex = ayah;
        
        // Initialize ayah word map jika belum ada
        if (!_wordStatusMap.containsKey(ayah)) {
          _wordStatusMap[ayah] = {};
        }
        
        // Set status untuk KATA ini
        final wordStatus = _mapWordStatus(status);
        _wordStatusMap[ayah]![wordIndex] = wordStatus;
        
        // Jika matched, beri feedback visual
        if (wordStatus == WordStatus.matched) {
          print('  ✅ Word $wordIndex: CORRECT → Hijau');
        } else {
          print('  ❌ Word $wordIndex: INCORRECT → Merah, retry!');
        }
        
        // INSTANT UI UPDATE untuk highlight kata ini
        notifyListeners();
        break;
      
      case 'ayah_complete':
        // 📖 Ayah selesai, siap untuk ayah berikutnya
        final int completedAyah = message['ayah'] ?? 0;
        final int nextAyah = message['next_ayah'] ?? 0;
        
        print('✅ Ayah $completedAyah completed! Next: $nextAyah');
        
        // Mark ayah as correct in tartib
        _tartibStatus[completedAyah] = TartibStatus.correct;
        
        // DON'T clear wordStatusMap - keep it for display history
        _currentWords.clear();
        _currentVerseIndex = nextAyah;
        
        notifyListeners();
        break;
      
      case 'started':
        // New session started: clear previous permanent statuses and UI state
        _verseStatus.clear();
        _tartibStatus.clear();
        _wordStatusMap.clear(); // Clear per-word status
        _expectedAyah = message['expected_ayah'] ?? 1;  // Get from backend
        _currentVerseIndex = null;
        _currentWords = [];
        _summary = null;
        
        // 🆕 SAVE SESSION ID from backend
        if (message['session_id'] != null) {
          _sessionId = message['session_id'];
          print('💾 Session ID saved: $_sessionId');
        }
        
        print('🎆 New session started - reset per-word tracking');
        notifyListeners();
        break;
      
      case 'session_recovered':
        // ✅ SESSION RECOVERED: Restore state from backend
        print('✅ Session recovered successfully');
        if (message['state'] != null) {
          _restoreSessionState(message['state']);
        }
        notifyListeners();
        break;
        
      case 'pong':
        // 💓 Health check response
        print('💓 Connection alive (pong received)');
        break;

      case 'progress':
        _currentVerseIndex = message['ayah'];
        print('📥 Progress for ayah $_currentVerseIndex');
        print('📝 Words data: ${message['words']}');
        
        _currentWords = (message['words'] as List)
            .map((w) => WordFeedback.fromJson(w))
            .toList();
        
        print('🎨 Parsed ${_currentWords.length} words for display');
        if (_currentWords.isNotEmpty) {
          print('   First word: ${_currentWords.first.text} - ${_currentWords.first.status}');
        }

        // 🎯 TARTIB: Sync with backend tartib evaluation
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
        
        // Update expected ayah from backend
        if (message['expected_ayah'] != null) {
          _expectedAyah = message['expected_ayah'];
        }

        // Merge permanent verse status from progress (do NOT overwrite existing)
        if (message['verse_status_map'] != null) {
          final Map<String, dynamic> statusMap = message['verse_status_map'];
          statusMap.forEach((key, value) {
            final int ayahNum = int.tryParse(key) ?? -1;
            if (ayahNum <= 0) return;
            if (!_verseStatus.containsKey(ayahNum)) {
              final String statusStr = value.toString().toLowerCase();
              switch (statusStr) {
                case 'matched':
                case 'correct':
                case 'success':
                  _verseStatus[ayahNum] = WordStatus.matched;
                  break;
                case 'skipped':
                case 'timeout':
                  _verseStatus[ayahNum] = WordStatus.skipped;
                  break;
                case 'mismatched':
                case 'incorrect':
                case 'error':
                case 'wrong':
                default:
                  _verseStatus[ayahNum] = WordStatus.mismatched;
                  break;
              }
            }
          });
        }

        notifyListeners();
        break;
        
      case 'summary':
        _summary = RecitationSummary.fromJson(message);
        
        // 🎯 TARTIB: Sync final tartib status from backend
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
        
        // Update final expected ayah
        if (message['expected_ayah'] != null) {
          _expectedAyah = message['expected_ayah'];
        }
        
        // Log tartib statistics if available
        if (message['tartib_stats'] != null) {
          print('📊 TARTIB SUMMARY:');
          print('  🟩 Correct: ${message['tartib_stats']['correct']}');
          print('  🟥 Skipped: ${message['tartib_stats']['skipped']}');
          print('  📋 Total: ${message['tartib_stats']['total']}');
        }
        
        // Handle permanent verse status update (ONLY if not already set)
        if (message['ayah'] != null && message['status'] != null) {
          final int ayah = message['ayah'];
          final String status = message['status'];

          // 🔒 PERMANENT RULE: Never overwrite existing status
          if (!_verseStatus.containsKey(ayah)) {
            switch (status.toLowerCase()) {
              case 'matched':
              case 'correct':
              case 'success':
                _verseStatus[ayah] = WordStatus.matched;
                break;
              case 'skipped':
              case 'timeout':
                _verseStatus[ayah] = WordStatus.skipped;
                break;
              case 'mismatched':
              case 'incorrect':
              case 'error':
              case 'wrong':
              default:
                _verseStatus[ayah] = WordStatus.mismatched;
                break;
            }
          }
        }
        
        // Handle verse status map if provided (PERMANENT)
        if (message['verse_status_map'] != null) {
          final Map<String, dynamic> statusMap = message['verse_status_map'];
          statusMap.forEach((key, value) {
            final int ayahNum = int.parse(key);
            
            // 🔒 PERMANENT RULE: Never overwrite existing status
            if (!_verseStatus.containsKey(ayahNum)) {
              final String statusStr = value.toString().toLowerCase();
              switch (statusStr) {
                case 'matched':
                case 'correct':
                case 'success':
                  _verseStatus[ayahNum] = WordStatus.matched;
                  break;
                case 'skipped':
                case 'timeout':
                  _verseStatus[ayahNum] = WordStatus.skipped;
                  break;
                case 'mismatched':
                case 'incorrect':
                case 'error':
                case 'wrong':
                default:
                  _verseStatus[ayahNum] = WordStatus.mismatched;
                  break;
              }
            }
          });
        }
        
        notifyListeners();
        break;
        
      case 'word_auto_skipped':
        // Handle mid-ayah word skip
        final skippedWord = message['skipped_word'] as Map<String, dynamic>?;
        
        if (skippedWord != null) {
          final ayah = skippedWord['ayah'] as int;
          final wordIndex = skippedWord['word_index'] as int;
          
          // 🔴 Mark word as SKIPPED (RED, not matched)
          if (!_wordStatusMap.containsKey(ayah)) {
            _wordStatusMap[ayah] = {};
          }
          _wordStatusMap[ayah]![wordIndex] = WordStatus.skipped;
          
          print('🔴 Word marked as SKIPPED (RED): Ayah $ayah, Word $wordIndex');
        }
        
        // Show error message
        _errorMessage = message['message'];
        notifyListeners();
        break;
      
      case 'ayah_auto_skipped':
        // Handle ayah overflow auto-skip
        final fromAyah = message['from_ayah'] as int?;
        final toAyah = message['to_ayah'] as int?;
        final skippedWord = message['skipped_word'] as Map<String, dynamic>?;
        
        if (skippedWord != null) {
          final ayah = skippedWord['ayah'] as int;
          final wordIndex = skippedWord['word_index'] as int;
          
          // 🔴 Mark word as SKIPPED (RED, not matched)
          if (!_wordStatusMap.containsKey(ayah)) {
            _wordStatusMap[ayah] = {};
          }
          _wordStatusMap[ayah]![wordIndex] = WordStatus.skipped;
          
          print('🔴 Word marked as SKIPPED (RED): Ayah $ayah, Word $wordIndex');
        }
        
        if (toAyah != null) {
          _currentVerseIndex = toAyah;
        }
        
        // Show error message
        _errorMessage = message['message'];
        notifyListeners();
        break;
      
      case 'error':
        _errorMessage = message['message'];
        notifyListeners();
        break;
    }
  }

  Future<void> connect() async {
    try {
      _webSocketService.enableAutoReconnect();
      await _webSocketService.connect();
      _isConnected = _webSocketService.isConnected;
      _errorMessage = null;
      print('Successfully connected to WebSocket server');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to connect: $e';
      _isConnected = false;
      print('Connection failed: $e');
      notifyListeners();
    }
  }

  Future<void> startRecitation(int surahNumber) async {
    print('🎬 Starting recitation for Surah $surahNumber...');
    
    // 🔄 AUTO-RECONNECT: Always try to connect/reconnect before starting
    if (!_isConnected || !_webSocketService.isConnected) {
      print('🔌 Not connected, attempting to connect...');
      _errorMessage = 'Connecting to server...';
      notifyListeners();
      
      try {
        _webSocketService.enableAutoReconnect();
        await _webSocketService.connect();
        
        // Wait a bit for connection to stabilize
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!_webSocketService.isConnected) {
          throw Exception('Connection failed after retry');
        }
        
        _isConnected = true;
        _errorMessage = null;
        print('✅ Connected successfully!');
        notifyListeners();
        
      } catch (e) {
        _errorMessage = 'Unable to connect to server. Please check your connection and try again.';
        _isConnected = false;
        print('❌ Connection failed: $e');
        notifyListeners();
        return;
      }
    }

    // 🔒 Final connection check
    if (!_webSocketService.isConnected) {
      _errorMessage = 'Connection not stable. Please try again.';
      notifyListeners();
      return;
    }

    try {
      // 🧹 FRESH SESSION: Clear ALL previous state before starting new surah
      print('🧹 Clearing all previous state for new surah...');
      _verseStatus.clear();
      _tartibStatus.clear();
      _wordStatusMap.clear();  // ← FIX: Clear per-word status map!
      _expectedAyah = 1;
      _currentVerseIndex = null;
      _currentWords = [];
      _summary = null;
      _errorMessage = null;
      
      // 🗑️ Clear old session_id (new session will get fresh ID from backend)
      _sessionId = null;
      
      print('✅ State cleared - ready for new session');
      print('🎆 Starting new tartib session for Surah $surahNumber');

      _webSocketService.sendStartRecording(surahNumber);
      
      await _audioService.startRecording(
        onAudioChunk: (base64Audio) {
          if (_webSocketService.isConnected) {
            _webSocketService.sendAudioChunk(base64Audio);
          } else {
            print('⚠️ Warning: Audio chunk lost - WebSocket disconnected');
          }
        },
      );

      _isRecording = true;
      print('Recording started for Surah $surahNumber');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start recording: $e';
      _isRecording = false;
      print('Recording start failed: $e');
      notifyListeners();
    }
  }

  Future<void> stopRecitation() async {
    try {
      await _audioService.stopRecording();
      _webSocketService.sendStopRecording();
      _isRecording = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to stop recording: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    print('🧹 Error cleared');
    notifyListeners();
  }
  
  /// Manual reconnect method
  Future<void> reconnect() async {
    print('🔄 Manual reconnect triggered...');
    _errorMessage = 'Reconnecting...';
    _isConnected = false;
    notifyListeners();
    
    try {
      // Disconnect terlebih dahulu
      _webSocketService.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Connect ulang
      await connect();
      
      if (_isConnected) {
        // 🔁 Try to recover session if we have session_id
        if (_sessionId != null && _sessionId!.isNotEmpty) {
          print('🔁 Attempting session recovery with ID: $_sessionId');
          _webSocketService.sendRecoverSession(_sessionId!);
        }
        
        _errorMessage = null;
        print('✅ Reconnect successful!');
      } else {
        throw Exception('Reconnect failed');
      }
    } catch (e) {
      _errorMessage = 'Reconnect failed: $e';
      print('❌ Reconnect failed: $e');
    }
    
    notifyListeners();
  }
  
  /// Silent reconnect without showing error banner
  Future<void> silentReconnect() async {
    print('🔄 Silent reconnect triggered...');
    final wasConnected = _isConnected;
    try {
      // Reset connection state
      _webSocketService.disconnect();
      await Future.delayed(const Duration(milliseconds: 300));

      // Re-enable auto reconnect and connect immediately
      _webSocketService.enableAutoReconnect();
      await _webSocketService.connect();

      _isConnected = _webSocketService.isConnected;
      if (_isConnected) {
        print('✅ Silent reconnect successful!');
      } else if (wasConnected) {
        print('⚠️ Silent reconnect: still disconnected, auto-reconnect timer active.');
      }
    } catch (e) {
      // Do not set _errorMessage to keep UI silent
      print('❌ Silent reconnect failed: $e');
    }
    notifyListeners();
  }
  
  /// Evaluasi tartib (urutan ayat) berdasarkan aturan yang diberikan
  void _evaluateTartib(int detectedAyah) {
    print('Evaluating tartib: detected=$detectedAyah, expected=$_expectedAyah');
    
    if (detectedAyah == _expectedAyah) {
      // 🟩 Ayat dibaca dengan benar dan urut
      _tartibStatus[detectedAyah] = TartibStatus.correct;
      _expectedAyah = detectedAyah + 1;
      print('✅ Ayat $detectedAyah: CORRECT (urut)');
    } 
    else if (detectedAyah > _expectedAyah) {
      // 🟥 Ada ayat yang dilewati
      // Tandai semua ayat di antara expected dan detected sebagai skipped
      for (int i = _expectedAyah; i < detectedAyah; i++) {
        if (_tartibStatus[i] != TartibStatus.correct) {
          _tartibStatus[i] = TartibStatus.skipped;
          print('❌ Ayat $i: SKIPPED (dilewati)');
        }
      }
      
      // Tandai ayat yang terdeteksi sebagai correct
      _tartibStatus[detectedAyah] = TartibStatus.correct;
      _expectedAyah = detectedAyah + 1;
      print('✅ Ayat $detectedAyah: CORRECT (tapi ada yang dilewati)');
    }
    else {
      // detectedAyah < _expectedAyah
      // Ayat yang sudah pernah ditandai skipped tidak berubah status
      if (_tartibStatus[detectedAyah] == TartibStatus.skipped) {
        print('❌ Ayat $detectedAyah: tetap SKIPPED (dibaca ulang tapi sudah terlambat)');
        // Status tidak berubah
      } else if (_tartibStatus[detectedAyah] != TartibStatus.correct) {
        // Jika belum pernah dibaca sama sekali, tandai sebagai correct
        _tartibStatus[detectedAyah] = TartibStatus.correct;
        print('✅ Ayat $detectedAyah: CORRECT (dibaca mundur tapi belum pernah dilewati)');
      }
    }
    
    // Debug: Print status after each evaluation
    debugPrintTartibStatus();
  }
  
  /// Get tartib summary for debugging or UI display
  Map<String, int> getTartibSummary() {
    int correct = 0;
    int skipped = 0;
    int unread = 0;
    
    _tartibStatus.forEach((ayahNum, status) {
      switch (status) {
        case TartibStatus.correct:
          correct++;
          break;
        case TartibStatus.skipped:
          skipped++;
          break;
        case TartibStatus.unread:
          unread++;
          break;
      }
    });
    
    return {
      'correct': correct,
      'skipped': skipped,
      'unread': unread,
      'total': _tartibStatus.length,
    };
  }
  
  /// Print current tartib status for debugging
  void debugPrintTartibStatus() {
    print('📊 TARTIB STATUS SUMMARY:');
    print('Expected next ayah: $_expectedAyah');
    
    final summary = getTartibSummary();
    print('🟩 Correct: ${summary["correct"]}');
    print('🟥 Skipped: ${summary["skipped"]}');
    print('⬜ Unread: ${summary["unread"]}');
    print('Total evaluated: ${summary["total"]}');
    
    print('\nDetailed status:');
    _tartibStatus.forEach((ayah, status) {
      final emoji = status == TartibStatus.correct ? '🟩' : 
                   status == TartibStatus.skipped ? '🟥' : '⬜';
      print('$emoji Ayat $ayah: ${status.name}');
    });
    print('=' * 40);
  }


  // Helper: Map status string to WordStatus enum
  WordStatus _mapWordStatus(String status) {
    switch (status.toLowerCase()) {
      case 'matched':
      case 'correct':
        return WordStatus.matched;
      case 'processing':
        return WordStatus.processing;
      case 'close':
        return WordStatus.pending; // Close enough, show as pending
      case 'mismatched':
      case 'incorrect':
        return WordStatus.mismatched;
      default:
        return WordStatus.pending;
    }
  }

  /// Restore session state after recovery
  void _restoreSessionState(Map<String, dynamic> state) {
    print('🔄 Restoring session state...');
    
    // Restore tartib status
    if (state['tartib_status'] != null) {
      _tartibStatus.clear();
      (state['tartib_status'] as Map<String, dynamic>).forEach((key, value) {
        final ayahNum = int.tryParse(key) ?? -1;
        if (ayahNum > 0) {
          final statusStr = value.toString().toLowerCase();
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
      print('  ✅ Restored tartib status: ${_tartibStatus.length} ayahs');
    }
    
    // Restore word status map
    if (state['word_status_map'] != null) {
      _wordStatusMap.clear();
      (state['word_status_map'] as Map<String, dynamic>).forEach((ayahKey, words) {
        final ayahNum = int.tryParse(ayahKey) ?? -1;
        if (ayahNum > 0 && words is Map) {
          _wordStatusMap[ayahNum] = {};
          (words as Map<String, dynamic>).forEach((wordKey, status) {
            final wordIndex = int.tryParse(wordKey) ?? -1;
            if (wordIndex >= 0) {
              final statusStr = status.toString().toLowerCase();
              switch (statusStr) {
                case 'matched':
                  _wordStatusMap[ayahNum]![wordIndex] = WordStatus.matched;
                  break;
                case 'processing':
                  _wordStatusMap[ayahNum]![wordIndex] = WordStatus.processing;
                  break;
                case 'skipped':
                  _wordStatusMap[ayahNum]![wordIndex] = WordStatus.skipped;
                  break;
                case 'mismatched':
                  _wordStatusMap[ayahNum]![wordIndex] = WordStatus.mismatched;
                  break;
                default:
                  _wordStatusMap[ayahNum]![wordIndex] = WordStatus.pending;
              }
            }
          });
        }
      });
      print('  ✅ Restored word status: ${_wordStatusMap.length} ayahs');
    }
    
    // Restore verse status
    if (state['verse_status'] != null) {
      _verseStatus.clear();
      (state['verse_status'] as Map<String, dynamic>).forEach((key, value) {
        final ayahNum = int.tryParse(key) ?? -1;
        if (ayahNum > 0) {
          final statusStr = value.toString().toLowerCase();
          switch (statusStr) {
            case 'matched':
              _verseStatus[ayahNum] = WordStatus.matched;
              break;
            case 'skipped':
              _verseStatus[ayahNum] = WordStatus.skipped;
              break;
            default:
              _verseStatus[ayahNum] = WordStatus.mismatched;
          }
        }
      });
      print('  ✅ Restored verse status: ${_verseStatus.length} ayahs');
    }
    
    // Restore current state
    if (state['current_ayah'] != null) {
      _currentVerseIndex = state['current_ayah'];
      print('  ✅ Restored current ayah: $_currentVerseIndex');
    }
    
    if (state['expected_ayah'] != null) {
      _expectedAyah = state['expected_ayah'];
      print('  ✅ Restored expected ayah: $_expectedAyah');
    }
    
    print('🎉 Session state restored successfully!');
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _connectionSubscription?.cancel();
    _audioService.dispose();
    _webSocketService.dispose();
    super.dispose();
  }
}
