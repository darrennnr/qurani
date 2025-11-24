// lib/screens/main/home/screens/settings/widgets/audio_manager.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';
import 'package:cuda_qurani/services/metadata_cache_service.dart';

/// ==================== AUDIO MANAGER PAGE ====================
/// Halaman untuk mengelola download audio per surah untuk reciter tertentu

class AudioManagerPage extends StatefulWidget {
  final String reciterName;
  final String reciterIdentifier;

  const AudioManagerPage({
    Key? key,
    required this.reciterName,
    required this.reciterIdentifier,
  }) : super(key: key);

  @override
  State<AudioManagerPage> createState() => _AudioManagerPageState();
}

class _AudioManagerPageState extends State<AudioManagerPage> {
  // Track download progress for each surah (dummy state)
  Map<int, double> _downloadProgress = {};
  
  // Track which surahs are being downloaded
  Set<int> _downloadingIds = {};

  List<Map<String, dynamic>> _allSurahs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all surahs from metadata cache
      await MetadataCacheService().initialize();
      _allSurahs = MetadataCacheService().allSurahs;

      // Initialize all download progress to 0%
      for (var surah in _allSurahs) {
        _downloadProgress[surah['id'] as int] = 0.0;
      }
    } catch (e) {
      print('[AudioManager] Error loading surahs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _downloadSurah(int surahId) {
    setState(() {
      _downloadingIds.add(surahId);
    });
    AppHaptics.selection();

    // TODO: Implement actual download logic
    print('[AudioManager] Downloading surah $surahId for ${widget.reciterIdentifier}');

    // Simulate download progress
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _downloadingIds.contains(surahId)) {
        setState(() {
          _downloadProgress[surahId] = 0.5;
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _downloadingIds.contains(surahId)) {
        setState(() {
          _downloadProgress[surahId] = 1.0;
          _downloadingIds.remove(surahId);
        });
      }
    });
  }

  void _downloadAll() {
    AppHaptics.selection();
    
    // TODO: Implement download all logic
    print('[AudioManager] Downloading all surahs for ${widget.reciterIdentifier}');

    for (var surah in _allSurahs) {
      final surahId = surah['id'] as int;
      if (_downloadProgress[surahId] == 0.0) {
        _downloadSurah(surahId);
      }
    }
  }

  String _getSurahDisplayName(Map<String, dynamic> surah) {
    final nameSimple = surah['name_simple'] as String?;
    final transliteration = surah['name_transliterated'] as String?;
    
    return transliteration ?? nameSimple ?? 'Surah ${surah['id']}';
  }

  Widget _buildSurahItem({
    required int surahId,
    required String surahName,
    required double progress,
    required bool isDownloading,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space16 * s * 0.9,
        vertical: AppDesignSystem.space16 * s * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1.0 * s * 0.9,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              surahName,
              style: TextStyle(
                fontSize: 16 * s * 0.9,
                fontWeight: AppTypography.regular,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppDesignSystem.space12 * s * 0.9),
          // Progress percentage
          SizedBox(
            width: 35 * s * 0.9,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12 * s * 0.9,
                fontWeight: AppTypography.regular,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: AppDesignSystem.space8 * s * 0.9),
          // Download button
          InkWell(
            onTap: progress < 1.0 && !isDownloading
                ? () => _downloadSurah(surahId)
                : null,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 32 * s * 0.9,
              height: 32 * s * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: progress >= 1.0
                    ? Color(0xFF4CAF50)
                    : AppColors.borderLight,
              ),
              child: Center(
                child: isDownloading
                    ? SizedBox(
                        width: 16 * s * 0.9,
                        height: 16 * s * 0.9,
                        child: CircularProgressIndicator(
                          strokeWidth: 2 * s * 0.9,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        progress >= 1.0
                            ? Icons.check
                            : Icons.arrow_downward,
                        size: 16 * s * 0.9,
                        color: progress >= 1.0
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(
        title: 'Audio Manager',
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with reciter name and storage info
                  Padding(
                    padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reciterName,
                          style: TextStyle(
                            fontSize: 16 * s * 0.9,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppDesignSystem.space4 * s * 0.9),
                        Text(
                          'Using 0KB',
                          style: TextStyle(
                            fontSize: 14 * s * 0.9,
                            fontWeight: AppTypography.regular,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Download all button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignSystem.space20 * s * 0.9,
                    ),
                    child: InkWell(
                      onTap: _downloadAll,
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusRound * s * 0.9,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDesignSystem.space12 * s * 0.9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppDesignSystem.radiusRound * s * 0.9,
                          ),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1.0 * s * 0.9,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download,
                              size: 20 * s * 0.9,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: AppDesignSystem.space8 * s * 0.9),
                            Text(
                              'Download all',
                              style: TextStyle(
                                fontSize: 16 * s * 0.9,
                                fontWeight: AppTypography.regular,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppDesignSystem.space20 * s * 0.9),

                  // List of surahs
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.borderLight,
                            width: 1.0 * s * 0.9,
                          ),
                        ),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _allSurahs.length,
                        itemBuilder: (context, index) {
                          final surah = _allSurahs[index];
                          final surahId = surah['id'] as int;
                          final surahName = _getSurahDisplayName(surah);
                          final progress = _downloadProgress[surahId] ?? 0.0;
                          final isDownloading = _downloadingIds.contains(surahId);

                          return _buildSurahItem(
                            surahId: surahId,
                            surahName: surahName,
                            progress: progress,
                            isDownloading: isDownloading,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}