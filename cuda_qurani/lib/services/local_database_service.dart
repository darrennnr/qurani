import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/quran_models.dart';

class LocalDatabaseService {
  static Database? _wordsDb;
  static Database? _chaptersDb;
  
  /// Initialize all databases from assets
  static Future<void> initializeDatabases() async {
    if (_wordsDb != null && _chaptersDb != null) {
      print('[DB] Databases already initialized');
      return;
    }
    
    try {
      final databasesPath = await getDatabasesPath();
      print('[DB] Database path: $databasesPath');
      
      // Copy words database
      final wordsPath = join(databasesPath, 'uthmani.db');
      if (!await File(wordsPath).exists()) {
        print('[DB] Copying uthmani.db from assets...');
        final data = await rootBundle.load('assets/data/uthmani.db');
        final bytes = data.buffer.asUint8List();
        await File(wordsPath).writeAsBytes(bytes, flush: true);
        print('[DB] uthmani.db copied successfully');
      }
      _wordsDb = await openDatabase(wordsPath, readOnly: true);
      print('[DB] uthmani.db opened');
      

      
      // Copy chapters database
      final chaptersPath = join(databasesPath, 'quran-metadata-surah-name.sqlite');
      if (!await File(chaptersPath).exists()) {
        print('[DB] Copying quran-metadata-surah-name.sqlite from assets...');
        final data = await rootBundle.load('assets/data/quran-metadata-surah-name.sqlite');
        final bytes = data.buffer.asUint8List();
        await File(chaptersPath).writeAsBytes(bytes, flush: true);
        print('[DB] quran-metadata-surah-name.sqlite copied successfully');
      }
      _chaptersDb = await openDatabase(chaptersPath, readOnly: true);
      print('[DB] quran-metadata-surah-name.sqlite opened');
      
      print('[DB] All databases initialized successfully');
    } catch (e, stackTrace) {
      print('[DB] Error initializing databases: $e');
      print('[DB] Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Get list of all surahs (chapters)
  static Future<List<Map<String, dynamic>>> getSurahs() async {
    if (_chaptersDb == null) await initializeDatabases();
    
    final result = await _chaptersDb!.query(
      'chapters',
      orderBy: 'id ASC',
    );
    
    return result;
  }
  
  /// Get surah metadata by ID
  static Future<Map<String, dynamic>?> getSurahMetadata(int surahId) async {
    if (_chaptersDb == null) await initializeDatabases();
    
    final result = await _chaptersDb!.query(
      'chapters',
      where: 'id = ?',
      whereArgs: [surahId],
      limit: 1,
    );
    
    return result.isNotEmpty ? result.first : null;
  }
  
  /// Get complete Surah with verses
  static Future<Surah> getSurah(int surahId) async {
    if (_wordsDb == null || _chaptersDb == null) {
      await initializeDatabases();
    }
    
    print('[DB] Loading surah $surahId from local database...');
    
    // Get metadata
    final metadata = await getSurahMetadata(surahId);
    if (metadata == null) {
      throw Exception('Surah $surahId not found in database');
    }
    
    // Get all words for this surah
    final words = await _wordsDb!.query(
      'words',
      where: 'surah = ?',
      whereArgs: [surahId],
      orderBy: 'ayah ASC, word ASC',
    );
    
    if (words.isEmpty) {
      throw Exception('No words found for surah $surahId');
    }
    
    // Group words by ayah (keep ALL words including numbers for display)
    Map<int, List<String>> ayahWordsMap = {};
    for (var word in words) {
      int ayahNum = word['ayah'] as int;
      String wordText = word['text'] as String;
      
      if (!ayahWordsMap.containsKey(ayahNum)) {
        ayahWordsMap[ayahNum] = [];
      }
      ayahWordsMap[ayahNum]!.add(wordText);
    }
    
    // Convert to Verse objects
    List<Verse> verses = ayahWordsMap.entries.map((entry) {
      int ayahNum = entry.key;
      List<String> words = entry.value;
      String fullText = words.join(' ');
      
      return Verse(
        number: ayahNum,
        text: fullText,
        words: words,
      );
    }).toList();
    
    // Sort verses by number
    verses.sort((a, b) => a.number.compareTo(b.number));
    
    print('[DB] Surah $surahId loaded: ${verses.length} verses');
    
    return Surah(
      number: surahId,
      name: metadata['name_simple'] ?? metadata['name'] ?? 'Unknown',
      nameArabic: metadata['name_arabic'] ?? 'سورة',
      verses: verses,
    );
  }
  
  /// Search verses by Arabic text OR surah name (Latin/Arabic)
  static Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    if (_wordsDb == null || _chaptersDb == null) {
      await initializeDatabases();
    }
    
    if (query.trim().isEmpty) {
      return [];
    }
    
    print('[DB] Searching for: "$query"');
    
    List<Map<String, dynamic>> results = [];
    
    // 1. Search by SURAH NAME (Latin or Arabic)
    // Use case-insensitive search with LOWER()
    String queryLower = query.toLowerCase();
    
    // Try multiple variations for better matching
    // Remove spaces, hyphens, and normalize
    String queryNorm = queryLower.replaceAll(' ', '').replaceAll('-', '');
    
    final surahMatches = await _chaptersDb!.rawQuery('''
      SELECT * FROM chapters 
      WHERE LOWER(name) LIKE ? 
         OR LOWER(name_simple) LIKE ? 
         OR LOWER(name_arabic) LIKE ?
         OR REPLACE(REPLACE(LOWER(name), ' ', ''), '-', '') LIKE ?
         OR REPLACE(REPLACE(LOWER(name_simple), ' ', ''), '-', '') LIKE ?
    ''', [
      '%$queryLower%',
      '%$queryLower%', 
      '%$queryLower%',
      '%$queryNorm%',
      '%$queryNorm%',
    ]);
    
    if (surahMatches.isNotEmpty) {
      print('[DB] Found ${surahMatches.length} matching surahs by name');
      
      // Return all verses from matching surahs (first 10 verses only)
      for (var surahMeta in surahMatches) {
        int surahNum = surahMeta['id'] as int;
        
        // Get first 10 verses of this surah
        final versesInSurah = await _wordsDb!.query(
          'words',
          where: 'surah = ?',
          whereArgs: [surahNum],
          orderBy: 'ayah ASC, word ASC',
          limit: 100, // Get words for ~10 verses
        );
        
        // Group by ayah
        Map<int, List<String>> ayahWordsMap = {};
        for (var word in versesInSurah) {
          int ayahNum = word['ayah'] as int;
          String wordText = word['text'] as String;
          
          if (!ayahWordsMap.containsKey(ayahNum)) {
            ayahWordsMap[ayahNum] = [];
          }
          ayahWordsMap[ayahNum]!.add(wordText);
          
          // Limit to 10 verses
          if (ayahWordsMap.length > 10) break;
        }
        
        // Build results
        for (var entry in ayahWordsMap.entries) {
          results.add({
            'surah_number': surahNum,
            'ayah_number': entry.key,
            'text': entry.value.join(' '),
            'surah_name': surahMeta['name_simple'] ?? 'Surah $surahNum',
            'surah_name_arabic': surahMeta['name_arabic'] ?? '',
            'match_type': 'surah_name', // Indicate this matched by surah name
          });
        }
      }
      
      // 🔒 IMPORTANT: If surah name matched, SKIP verse text search
      // This prevents "al baqarah" from returning random verses with "al" (which is very common)
      print('[DB] Surah name matched, skipping verse text search');
      print('[DB] Found ${results.length} total results (surah name only)');
      return results;
    }
    
    // 2. Search by VERSE TEXT (Arabic) - ONLY if no surah name match
    // Skip if query is too short (common words like "al" would match too many)
    if (query.length < 3) {
      print('[DB] Query too short for verse text search (min 3 characters)');
      return results;
    }
    
    final words = await _wordsDb!.query(
      'words',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'surah ASC, ayah ASC, word ASC',
      limit: 100, // Limit results
    );
    
    if (words.isNotEmpty) {
      print('[DB] Found ${words.length} matching words by text');
      
      // Group by surah and ayah
      Map<String, List<String>> ayahWordsMap = {};
      for (var word in words) {
        int surahNum = word['surah'] as int;
        int ayahNum = word['ayah'] as int;
        String wordText = word['text'] as String;
        
        String key = '$surahNum:$ayahNum';
        if (!ayahWordsMap.containsKey(key)) {
          ayahWordsMap[key] = [];
        }
        ayahWordsMap[key]!.add(wordText);
      }
      
      // Build result list
      for (var entry in ayahWordsMap.entries) {
        final parts = entry.key.split(':');
        final surahNum = int.parse(parts[0]);
        final ayahNum = int.parse(parts[1]);
        final fullText = entry.value.join(' ');
        
        // Get surah metadata
        final metadata = await getSurahMetadata(surahNum);
        
        results.add({
          'surah_number': surahNum,
          'ayah_number': ayahNum,
          'text': fullText,
          'surah_name': metadata?['name_simple'] ?? 'Surah $surahNum',
          'surah_name_arabic': metadata?['name_arabic'] ?? '',
          'match_type': 'verse_text', // Indicate this matched by verse text
        });
      }
    }
    
    if (results.isEmpty) {
      print('[DB] No results found');
    } else {
      print('[DB] Found ${results.length} total results');
    }
    
    return results;
  }
  
  /// Close all databases
  static Future<void> close() async {
    await _wordsDb?.close();
    await _chaptersDb?.close();
    _wordsDb = null;
    _chaptersDb = null;
  }
}
//     if (_pagesDb == null) await initializeDatabases();
    
//     final result = await _pagesDb!.query(
//       'pages',
//       where: 'page_number = ?',
//       whereArgs: [pageNumber],
//       orderBy: 'line_number ASC',
//     );
    
//     return result;
//   }
  
//   /// Get words by IDs
//   static Future<List<Map<String, dynamic>>> getWordsByIds(int firstId, int lastId) async {
//     if (_wordsDb == null) await initializeDatabases();
    
//     final result = await _wordsDb!.query(
//       'words',
//       where: 'id >= ? AND id <= ?',
//       whereArgs: [firstId, lastId],
//       orderBy: 'id ASC',
//     );
    
//     return result;
//   }
  
//   /// Get mushaf page with all words (FAST - no network needed!)
//   static Future<Map<String, dynamic>> getMushafPage(int pageNumber) async {
//     if (_pagesDb == null || _wordsDb == null) {
//       await initializeDatabases();
//     }
    
//     print('[DB] Loading page $pageNumber from local database...');
    
//     // Get page layout
//     final pageLines = await getPageLayout(pageNumber);
    
//     if (pageLines.isEmpty) {
//       return {
//         'page': pageNumber,
//         'total_lines': 0,
//         'lines': [],
//         'error': 'No data found for this page',
//       };
//     }
    
//     // Get all word IDs for this page
//     final wordIds = <int>[];
//     for (final line in pageLines) {
//       final firstId = line['first_word_id'];
//       final lastId = line['last_word_id'];
      
//       if (firstId != null && lastId != null && firstId is int && lastId is int) {
//         for (int id = firstId; id <= lastId; id++) {
//           wordIds.add(id);
//         }
//       }
//     }
    
//     // Get all words
//     final allWords = <int, Map<String, dynamic>>{};
//     if (wordIds.isNotEmpty) {
//       final minId = wordIds.reduce((a, b) => a < b ? a : b);
//       final maxId = wordIds.reduce((a, b) => a > b ? a : b);
      
//       final words = await getWordsByIds(minId, maxId);
//       for (final word in words) {
//         allWords[word['id'] as int] = word;
//       }
//     }
    
//     // Build lines structure
//     final lines = <Map<String, dynamic>>[];
//     for (final lineInfo in pageLines) {
//       final lineNumber = lineInfo['line_number'] as int;
//       final isCentered = (lineInfo['is_centered'] as int) == 1;
//       final lineType = lineInfo['line_type'] as String?;
//       final surahNumber = lineInfo['surah_number'];
//       final firstId = lineInfo['first_word_id'];
//       final lastId = lineInfo['last_word_id'];
      
//       // Get words for this line
//       final lineWords = <Map<String, dynamic>>[];
//       if (firstId is int && lastId is int) {
//         for (int id = firstId; id <= lastId; id++) {
//           if (allWords.containsKey(id)) {
//             final word = allWords[id]!;
//             lineWords.add({
//               'id': word['id'],
//               'text': word['text'],
//               'surah': word['surah'],
//               'ayah': word['ayah'],
//               'word': word['word'],
//               'location': word['location'],
//             });
//           }
//         }
//       }
      
//       lines.add({
//         'line_number': lineNumber,
//         'is_centered': isCentered,
//         'line_type': lineType ?? 'normal',
//         'surah_number': surahNumber,
//         'words': lineWords,
//       });
//     }
    
//     print('[DB] Page $pageNumber loaded: ${lines.length} lines, ${allWords.length} words (INSTANT!)');
    
//     return {
//       'page': pageNumber,
//       'total_lines': lines.length,
//       'lines': lines,
//       'error': null,
//     };
//   }
  
//   /// Get surah start page
//   static Future<int> getSurahStartPage(int surahNumber) async {
//     if (_pagesDb == null) await initializeDatabases();
    
//     final result = await _pagesDb!.query(
//       'pages',
//       where: 'surah_number = ?',
//       whereArgs: [surahNumber],
//       orderBy: 'page_number ASC',
//       limit: 1,
//     );
    
//     if (result.isNotEmpty) {
//       return result.first['page_number'] as int;
//     }
    
//     // Fallback: estimate based on surah number
//     return 1;
//   }
  
//   /// Close all databases
//   static Future<void> close() async {
//     await _wordsDb?.close();
//     await _pagesDb?.close();
//     await _chaptersDb?.close();
//     _wordsDb = null;
//     _pagesDb = null;
//     _chaptersDb = null;
//   }
// }
