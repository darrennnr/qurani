// lib/services/reciter_database_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class ReciterAudioData {
  final int surahNumber;
  final int ayahNumber;
  final String audioUrl;
  final int? duration; // in milliseconds
  final List<WordSegment> segments;

  ReciterAudioData({
    required this.surahNumber,
    required this.ayahNumber,
    required this.audioUrl,
    this.duration,
    required this.segments,
  });

  String get cacheFileName => '${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';
}

class WordSegment {
  final int wordIndex;
  final int startMs;
  final int endMs;

  WordSegment({
    required this.wordIndex,
    required this.startMs,
    required this.endMs,
  });

  factory WordSegment.fromJson(List<dynamic> json) {
    // Format: [word_index, ?, start_ms, end_ms]
    return WordSegment(
      wordIndex: json[0] as int,
      startMs: json[2] as int,
      endMs: json[3] as int,
    );
  }
}

class ReciterDatabaseService {
  static Database? _database;
  static const String _dbAssetPath = 'assets/reciters/ayah-recitation-abdul-basit-abdul-samad-murattal-hafs-950.db';

  // Initialize database
  static Future<void> initialize() async {
    if (_database != null) return;

    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, 'reciter_audio.db');

      // Check if database exists
      final exists = await databaseExists(dbPath);

      if (!exists) {
        print('📦 Copying reciter database from assets...');
        // Copy from assets
        final ByteData data = await rootBundle.load(_dbAssetPath);
        final List<int> bytes = data.buffer.asUint8List();
        await File(dbPath).writeAsBytes(bytes, flush: true);
        print('✅ Reciter database copied successfully');
      }

      _database = await openDatabase(dbPath, readOnly: true);
      print('✅ Reciter database initialized');
    } catch (e) {
      print('❌ Error initializing reciter database: $e');
      rethrow;
    }
  }

  // Get audio data for specific verse
  static Future<ReciterAudioData?> getVerseAudio(int surahNumber, int ayahNumber) async {
    if (_database == null) {
      await initialize();
    }

    try {
      final List<Map<String, dynamic>> results = await _database!.query(
        'verses',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber],
      );

      if (results.isEmpty) {
        print('⚠️ No audio found for ${surahNumber}:${ayahNumber}');
        return null;
      }

      final row = results.first;
      
      // Parse segments JSON
      final segmentsJson = row['segments'] as String?;
      final List<WordSegment> segments = [];
      
      if (segmentsJson != null && segmentsJson.isNotEmpty) {
        try {
          final List<dynamic> segmentsList = jsonDecode(segmentsJson);
          segments.addAll(segmentsList.map((s) => WordSegment.fromJson(s)));
        } catch (e) {
          print('⚠️ Error parsing segments: $e');
        }
      }

      return ReciterAudioData(
        surahNumber: row['surah_number'] as int,
        ayahNumber: row['ayah_number'] as int,
        audioUrl: row['audio_url'] as String,
        duration: row['duration'] as int?,
        segments: segments,
      );
    } catch (e) {
      print('❌ Error fetching verse audio: $e');
      return null;
    }
  }

  // Get multiple verses (batch)
  static Future<List<ReciterAudioData>> getVersesAudio(List<Map<String, int>> verses) async {
    if (_database == null) {
      await initialize();
    }

    final List<ReciterAudioData> results = [];

    for (final verse in verses) {
      final audio = await getVerseAudio(verse['surah']!, verse['ayah']!);
      if (audio != null) {
        results.add(audio);
      }
    }

    return results;
  }

  static void dispose() {
    _database?.close();
    _database = null;
  }
}