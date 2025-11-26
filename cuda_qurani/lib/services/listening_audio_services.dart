// lib/services/listening_audio_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import '../models/playback_settings_model.dart';
import 'reciter_database_service.dart';
import 'audio_download_services.dart';

class ListeningAudioService {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isPaused = false;

  StreamController<VerseReference>? _currentVerseController;
  StreamController<int>? _wordHighlightController;
  Timer? _wordHighlightTimer;

  PlaybackSettings? _currentSettings;
  List<ReciterAudioData> _playlist = [];
  int _currentTrackIndex = 0;
  int _currentVerseRepeat = 0;
  int _currentRangeRepeat = 0;

  // Audio chunk callback
  Function(String)? _onAudioChunkCallback;
  String? _currentFilePath; // Track current playing file

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  Stream<VerseReference>? get currentVerseStream =>
      _currentVerseController?.stream;
  Stream<int>? get wordHighlightStream => _wordHighlightController?.stream;
  AudioPlayer get player => _player;

  // Initialize and prepare playlist
  Future<void> initialize(PlaybackSettings settings) async {
    print('🎵 ListeningAudioService: Initializing...');
    _currentSettings = settings;
    _currentTrackIndex = 0;
    _currentVerseRepeat = 0;
    _currentRangeRepeat = 0;

    // Create stream controllers
    _currentVerseController = StreamController<VerseReference>.broadcast();
    _wordHighlightController = StreamController<int>.broadcast();

    // Set playback speed
    await _player.setSpeed(settings.speed);

    // Load playlist
    await _loadPlaylist();

    print(
      '✅ ListeningAudioService initialized with ${_playlist.length} tracks',
    );
  }

  // Load audio files for verse range
  Future<void> _loadPlaylist() async {
    _playlist.clear();

    if (_currentSettings == null) return;

    print(
      '📋 Loading playlist for range: ${_currentSettings!.startSurahId}:${_currentSettings!.startVerse} - ${_currentSettings!.endSurahId}:${_currentSettings!.endVerse}',
    );

    // Generate verse list
    final verses = <Map<String, int>>[];

    for (
      int surah = _currentSettings!.startSurahId;
      surah <= _currentSettings!.endSurahId;
      surah++
    ) {
      int startAyah = (surah == _currentSettings!.startSurahId)
          ? _currentSettings!.startVerse
          : 1;
      int endAyah = (surah == _currentSettings!.endSurahId)
          ? _currentSettings!.endVerse
          : 286; // Max ayah

      for (int ayah = startAyah; ayah <= endAyah; ayah++) {
        verses.add({'surah': surah, 'ayah': ayah});
      }
    }

    // Fetch audio data from database
    final audioDataList = await ReciterDatabaseService.getVersesAudio(verses);

    // Download audio files
    print('📥 Downloading ${audioDataList.length} audio files...');
    final urls = audioDataList.map((a) => a.audioUrl).toList();
    final downloadedFiles = await AudioDownloadService.downloadMultiple(
      urls,
      onProgress: (completed, total) {
        print('📥 Download progress: $completed/$total');
      },
    );

    // Verify all files downloaded
    _playlist = audioDataList.where((audio) {
      return downloadedFiles.containsKey(audio.audioUrl);
    }).toList();

    print('✅ Playlist ready: ${_playlist.length} tracks');
  }

  // ✅ FIXED: Stream MP3 file chunks to backend (better sync)
  Future<void> _streamMP3ToBackend(String filePath) async {
    try {
      print('🎵 Streaming MP3 to backend: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ MP3 file not found: $filePath');
        return;
      }

      final bytes = await file.readAsBytes();

      // ✅ FIX: Smaller chunks for better streaming (2KB chunks)
      const chunkSize = 2048; // 2KB per chunk
      final totalChunks = (bytes.length / chunkSize).ceil();

      print(
        '📊 MP3 stats: ${bytes.length} bytes, $totalChunks chunks (2KB each)',
      );

      int chunkCount = 0;

      // ✅ FIX: Stream ALL chunks rapidly at start (backend will buffer)
      for (int i = 0; i < bytes.length; i += chunkSize) {
        if (!_isPlaying) {
          print('⏹️ Streaming stopped by user');
          break;
        }

        final endIndex = (i + chunkSize).clamp(0, bytes.length);
        final chunk = bytes.sublist(i, endIndex);
        final base64Chunk = base64Encode(chunk);

        _onAudioChunkCallback?.call(base64Chunk);

        chunkCount++;

        if (chunkCount % 10 == 1) {
          print('📤 Sent MP3 chunk #$chunkCount/$totalChunks');
        }

        // ✅ Small delay to prevent overwhelming WebSocket
        await Future.delayed(const Duration(milliseconds: 10));
      }

      print('✅ MP3 streaming complete: $chunkCount chunks sent');
    } catch (e) {
      print('❌ Error streaming MP3: $e');
    }
  }

  // Start playback with MP3 streaming
  Future<void> startPlayback({required Function(String) onAudioChunk}) async {
    if (_playlist.isEmpty) {
      throw Exception('Playlist is empty');
    }

    _isPlaying = true;
    _isPaused = false;
    _onAudioChunkCallback = onAudioChunk;

    print('▶️ Starting playback with MP3 streaming...');

    await _playNextTrack(onAudioChunk: onAudioChunk);
  }

  // Play next track in playlist
  Future<void> _playNextTrack({required Function(String) onAudioChunk}) async {
    if (!_isPlaying || _currentTrackIndex >= _playlist.length) {
      // Range completed, check repeat
      if (_shouldRepeatRange()) {
        _currentRangeRepeat++;
        _currentTrackIndex = 0;
        _currentVerseRepeat = 0;
        print(
          '🔁 Repeating range (${_currentRangeRepeat}/${_currentSettings!.rangeRepeat})',
        );
        await _playNextTrack(onAudioChunk: onAudioChunk);
      } else {
        print('🏁 Playback completed');

        // Auto-stop and cleanup
        await stopPlayback();

        // Notify completion via stream
        _currentVerseController?.add(
          VerseReference(surahId: -1, verseNumber: -1),
        );
      }
      return;
    }

    final currentAudio = _playlist[_currentTrackIndex];

    // Notify current verse
    _currentVerseController?.add(
      VerseReference(
        surahId: currentAudio.surahNumber,
        verseNumber: currentAudio.ayahNumber,
      ),
    );

    print(
      '🎵 Playing: ${currentAudio.surahNumber}:${currentAudio.ayahNumber} (repeat ${_currentVerseRepeat + 1})',
    );

    // Get cached file path
    final filePath = await AudioDownloadService.getCachedFilePath(
      currentAudio.audioUrl,
    );

    if (filePath == null) {
      print('⚠️ Audio file not found, skipping...');
      _moveToNextTrack(onAudioChunk);
      return;
    }

    try {
      // Store current file path
      _currentFilePath = filePath;

      // Load audio file
      await _player.setFilePath(filePath);

      // Start word highlight timer
      _startWordHighlightTimer(currentAudio.segments);

      // ✅ Start streaming MP3 to backend (synchronized with playback)
      _streamMP3ToBackend(filePath);

      // Start playback
      await _player.play();

      // Wait for audio to finish
      await _player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );

      // Stop word highlighting
      _stopWordHighlightTimer();
      // Check verse repeat
      if (_shouldRepeatVerse()) {
        _currentVerseRepeat++;
        await _playNextTrack(onAudioChunk: onAudioChunk);
      } else {
        _currentVerseRepeat = 0;
        _moveToNextTrack(onAudioChunk);
      }
    } catch (e) {
      print('❌ Error playing track: $e');
      _moveToNextTrack(onAudioChunk);
    }
  }

  // Move to next track
  void _moveToNextTrack(Function(String) onAudioChunk) {
    _currentTrackIndex++;
    _playNextTrack(onAudioChunk: onAudioChunk);
  }

  // Check if should repeat current verse
  bool _shouldRepeatVerse() {
    if (_currentSettings == null) return false;

    final repeatCount = _currentSettings!.eachVerseRepeat;
    if (repeatCount == -1) return true; // Loop forever

    return _currentVerseRepeat < (repeatCount - 1);
  }

  // Check if should repeat entire range
  bool _shouldRepeatRange() {
    if (_currentSettings == null) return false;

    final repeatCount = _currentSettings!.rangeRepeat;
    if (repeatCount == -1) return true; // Loop forever

    return _currentRangeRepeat < (repeatCount - 1);
  }

  // Start word-level highlighting based on segments
  void _startWordHighlightTimer(List<WordSegment> segments) {
    if (segments.isEmpty) return;

    _stopWordHighlightTimer();

    final speed = _currentSettings?.speed ?? 1.0;

    for (final segment in segments) {
      final adjustedStartMs = (segment.startMs / speed).round();
      final adjustedDurationMs = ((segment.endMs - segment.startMs) / speed)
          .round();

      // Schedule highlight
      Timer(Duration(milliseconds: adjustedStartMs), () {
        if (_isPlaying) {
          _wordHighlightController?.add(segment.wordIndex);
        }
      });

      // Schedule un-highlight
      Timer(Duration(milliseconds: adjustedStartMs + adjustedDurationMs), () {
        if (_isPlaying) {
          _wordHighlightController?.add(-1); // Clear highlight
        }
      });
    }
  }

  void _stopWordHighlightTimer() {
    _wordHighlightTimer?.cancel();
    _wordHighlightTimer = null;
  }

  Future<void> pausePlayback() async {
    if (_isPlaying && !_isPaused) {
      await _player.pause();
      _isPaused = true;
      print('⏸️ Playback paused');
    }
  }

  Future<void> resumePlayback() async {
    if (_isPlaying && _isPaused) {
      await _player.play();
      _isPaused = false;
      print('▶️ Playback resumed');
    }
  }

  Future<void> stopPlayback() async {
    _isPlaying = false;
    _isPaused = false;
    _stopWordHighlightTimer();

    await _player.stop();
  }
  // ✅ FIX: Proper dispose method
  void dispose() {
    print('🗑️ ListeningAudioService: Disposing...');
    _stopWordHighlightTimer();
    _player.dispose();
    _currentVerseController?.close();
    _wordHighlightController?.close();
    _onAudioChunkCallback = null;
    _currentFilePath = null;
    print('✅ ListeningAudioService disposed');
  }
}