// lib/services/listening_audio_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cuda_qurani/services/audio_download_services.dart';
import 'package:just_audio/just_audio.dart';
import '../models/playback_settings_model.dart';
import 'reciter_database_service.dart';

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

  // Start playback (Tarteel-style: audio only, no backend)
  Future<void> startPlayback() async {
    if (_playlist.isEmpty) {
      throw Exception('Playlist is empty');
    }

    _isPlaying = true;
    _isPaused = false;

    print('▶️ Starting playback (Listening Mode - Passive)...');
    await _playNextTrack();
  }

  // Play next track in playlist
  Future<void> _playNextTrack() async {
    if (!_isPlaying || _currentTrackIndex >= _playlist.length) {
      // Range completed, check repeat
      if (_shouldRepeatRange()) {
        _currentRangeRepeat++;
        _currentTrackIndex = 0;
        _currentVerseRepeat = 0;
        print(
          '🔁 Repeating range (${_currentRangeRepeat}/${_currentSettings!.rangeRepeat})',
        );
        await _playNextTrack();
      } else {
        print('🏁 Playback completed');

        // ✅ Auto-stop and cleanup
        await stopPlayback();

        // ✅ Notify completion via stream
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
      _moveToNextTrack();
      return;
    }

    try {
      // ✅ Store current file path
      _currentFilePath = filePath;

      // Load audio file
      await _player.setFilePath(filePath);

      // Start word highlight timer
      _startWordHighlightTimer(currentAudio.segments);

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
        await _playNextTrack();
      } else {
        _currentVerseRepeat = 0;
        _moveToNextTrack();
      }
    } catch (e) {
      print('❌ Error playing track: $e');
      _moveToNextTrack();
    }
  }

  // Move to next track
  void _moveToNextTrack() {
    _currentTrackIndex++;
    _playNextTrack();
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

  // Pause playback
  Future<void> pausePlayback() async {
    if (_isPlaying && !_isPaused) {
      await _player.pause();
      _isPaused = true;
      print('⏸️ Playback paused');
    }
  }

  // Resume playback
  Future<void> resumePlayback() async {
    if (_isPlaying && _isPaused) {
      await _player.play();
      _isPaused = false;
      print('▶️ Playback resumed');
    }
  }

  // Stop playback
  Future<void> stopPlayback() async {
    _isPlaying = false;
    _isPaused = false;
    _stopWordHighlightTimer();

    await _player.stop();

    _currentVerseController?.add(VerseReference(surahId: 0, verseNumber: 0));

    print('⏹️ Playback stopped');
  }

  // Dispose
  void dispose() {
    _stopWordHighlightTimer();
    _player.dispose();
    _currentVerseController?.close();
    _wordHighlightController?.close();
  }
}
