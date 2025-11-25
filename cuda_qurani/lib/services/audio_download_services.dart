          // lib/services/audio_download_service.dart

          import 'dart:io';
          import 'package:http/http.dart' as http;
          import 'package:path_provider/path_provider.dart';
          import 'package:path/path.dart' as path;

          class AudioDownloadService {
            static final Map<String, String> _downloadCache = {};
            static final Set<String> _downloadingUrls = {};

            // Get cache directory
            static Future<Directory> _getCacheDirectory() async {
              final appDir = await getApplicationDocumentsDirectory();
              final cacheDir = Directory(path.join(appDir.path, 'audio_cache'));

              if (!await cacheDir.exists()) {
                await cacheDir.create(recursive: true);
              }

              return cacheDir;
            }

            // Generate cache file name from URL
            static String _getCacheFileName(String url) {
              final uri = Uri.parse(url);
              final fileName = path.basename(uri.path);
              return fileName;
            }

            // Check if audio file exists in cache
            static Future<String?> getCachedFilePath(String url) async {
              // Check memory cache first
              if (_downloadCache.containsKey(url)) {
                final cachedPath = _downloadCache[url]!;
                if (await File(cachedPath).exists()) {
                  return cachedPath;
                } else {
                  _downloadCache.remove(url);
                }
              }

              // Check disk cache
              final cacheDir = await _getCacheDirectory();
              final fileName = _getCacheFileName(url);
              final filePath = path.join(cacheDir.path, fileName);
              final file = File(filePath);

              if (await file.exists()) {
                _downloadCache[url] = filePath;
                return filePath;
              }

              return null;
            }

            // Download audio file
            static Future<String> downloadAudio(
              String url, {
              Function(int received, int total)? onProgress,
            }) async {
              // Check cache first
              final cachedPath = await getCachedFilePath(url);
              if (cachedPath != null) {
                print('✅ Using cached audio: $cachedPath');
                return cachedPath;
              }

              // Prevent duplicate downloads
              if (_downloadingUrls.contains(url)) {
                print('⏳ Already downloading: $url');
                // Wait for existing download
                while (_downloadingUrls.contains(url)) {
                  await Future.delayed(const Duration(milliseconds: 500));
                }
                final cachedPath = await getCachedFilePath(url);
                if (cachedPath != null) return cachedPath;
              }

              _downloadingUrls.add(url);

              try {
                print('📥 Downloading audio from: $url');

                final response = await http.get(Uri.parse(url));

                if (response.statusCode != 200) {
                  throw Exception('Failed to download audio: ${response.statusCode}');
                }

                final cacheDir = await _getCacheDirectory();
                final fileName = _getCacheFileName(url);
                final filePath = path.join(cacheDir.path, fileName);
                final file = File(filePath);

                await file.writeAsBytes(response.bodyBytes);

                _downloadCache[url] = filePath;
                _downloadingUrls.remove(url);

                print(
                  '✅ Audio downloaded: $filePath (${response.bodyBytes.length} bytes)',
                );
                return filePath;
              } catch (e) {
                _downloadingUrls.remove(url);
                print('❌ Download failed: $e');
                rethrow;
              }
            }

            // Batch download multiple files
            static Future<Map<String, String>> downloadMultiple(
              List<String> urls, {
              Function(int completed, int total)? onProgress,
            }) async {
              final Map<String, String> results = {};
              int completed = 0;

              for (final url in urls) {
                try {
                  final filePath = await downloadAudio(url);
                  results[url] = filePath;
                  completed++;
                  onProgress?.call(completed, urls.length);
                } catch (e) {
                  print('⚠️ Skipping failed download: $url');
                }
              }

              return results;
            }

            // Clear cache
            static Future<void> clearCache() async {
              final cacheDir = await _getCacheDirectory();
              if (await cacheDir.exists()) {
                await cacheDir.delete(recursive: true);
                _downloadCache.clear();
                print('🗑️ Audio cache cleared');
              }
            }

            // Get cache size
            static Future<int> getCacheSize() async {
              final cacheDir = await _getCacheDirectory();
              if (!await cacheDir.exists()) return 0;

              int totalSize = 0;
              await for (final entity in cacheDir.list(recursive: true)) {
                if (entity is File) {
                  totalSize += await entity.length();
                }
              }

              return totalSize;
            }
          }
