// lib/screens/main/home/screens/settings/submenu/reciters_download.dart

import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/audio_manager.dart';
import 'package:cuda_qurani/services/audio_download_services.dart';
import 'package:cuda_qurani/services/reciter_manager_services.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';

class RecitersDownloadPage extends StatefulWidget {
  const RecitersDownloadPage({Key? key}) : super(key: key);

  @override
  State<RecitersDownloadPage> createState() =>
      _RecitersDownloadPageState();
}

class _RecitersDownloadPageState
    extends State<RecitersDownloadPage> {
  List<ReciterInfo> _reciters = [];
  Map<String, Map<String, dynamic>> _storageInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadReciters();
    await _loadStorageInfo();
  }

  Future<void> _loadReciters() async {
    try {
      final reciters = await ReciterManagerService.getAllReciters();
      if (mounted) {
        setState(() {
          _reciters = reciters;
        });
      }
    } catch (e) {
      print('❌ Error loading reciters: $e');
    }
  }

  Future<void> _loadStorageInfo() async {
    for (final reciter in _reciters) {
      final info = await AudioDownloadService.getReciterStorageInfo(
        reciter.identifier,
      );
      _storageInfo[reciter.identifier] = info;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllCaches() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Caches'),
        content: const Text(
          'Are you sure you want to delete all downloaded audio for all reciters?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AudioDownloadService.clearAllCaches();
      await _loadStorageInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All caches cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _openAudioManager(ReciterInfo reciter) {
    AppHaptics.light();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AudioManagerPage(
          reciterName: reciter.name,
          reciterIdentifier: reciter.identifier,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.03, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        transitionDuration: AppDesignSystem.durationNormal,
      ),
    ).then((_) {
      // Refresh storage info when returning
      _loadStorageInfo();
    });
  }

  Widget _buildReciterItem(ReciterInfo reciter) {
  final s = AppDesignSystem.getScaleFactor(context);
  final storageInfo = _storageInfo[reciter.identifier];
  final storageSize = storageInfo?['formattedSize'] ?? '0 KB';
  final fileCount = storageInfo?['fileCount'] ?? 0;
  final hasDownloads = fileCount > 0;  // ✅ FIX: Clear boolean logic

  return InkWell(
    onTap: () => _openAudioManager(reciter),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space16 * s,
        vertical: AppDesignSystem.space16 * s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1.0 * s,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reciter.name,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: AppTypography.regular,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (hasDownloads) ...[
                  SizedBox(height: 4 * s),
                  Row(
                    children: [
                      Icon(
                        Icons.storage,
                        size: 12 * s,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4 * s),
                      Text(
                        storageSize,
                        style: TextStyle(
                          fontSize: 12 * s,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 24 * s,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    // Calculate total storage
    int totalBytes = 0;
    int totalFiles = 0;
    for (final info in _storageInfo.values) {
      totalBytes += info['totalBytes'] as int;
      totalFiles += info['fileCount'] as int;
    }
    final totalSize = totalBytes < 1024
        ? '$totalBytes B'
        : totalBytes < 1024 * 1024
            ? '${(totalBytes / 1024).toStringAsFixed(1)} KB'
            : totalBytes < 1024 * 1024 * 1024
                ? '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
                : '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(
        title: 'Manage Downloads',
        actions: [
          if (totalBytes > 0)
            IconButton(
              icon: Icon(Icons.delete_sweep, size: 24 * s),
              onPressed: _clearAllCaches,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total storage header
                  if (totalBytes > 0)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDesignSystem.space20 * s),
                      color: AppColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Storage Used',
                            style: TextStyle(
                              fontSize: 14 * s,
                              fontWeight: AppTypography.medium,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppDesignSystem.space8 * s),
                          Row(
                            children: [
                              Icon(
                                Icons.storage,
                                size: 20 * s,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: AppDesignSystem.space8 * s),
                              Text(
                                totalSize,
                                style: TextStyle(
                                  fontSize: 24 * s,
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: AppDesignSystem.space8 * s),
                              Text(
                                '($totalFiles files)',
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: AppDesignSystem.space12 * s),

                  // Section header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignSystem.space20 * s,
                      vertical: AppDesignSystem.space8 * s,
                    ),
                    child: Text(
                      'Available Reciters',
                      style: TextStyle(
                        fontSize: 14 * s,
                        fontWeight: AppTypography.medium,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Reciters list
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.borderLight,
                            width: 1.0 * s,
                          ),
                        ),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _reciters.length,
                        itemBuilder: (context, index) {
                          return _buildReciterItem(_reciters[index]);
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