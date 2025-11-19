// lib/screens/main/home/screens/completion_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/services/metadata_cache_service.dart';
import 'package:cuda_qurani/screens/main/stt/stt_page.dart';

// ==================== DUMMY COMPLETION SERVICE ====================

class CompletionService {
  static final CompletionService _instance = CompletionService._internal();
  factory CompletionService() => _instance;

  // ✅ Dummy data untuk demo (nanti diganti dengan real data dari database)
  final Map<int, SurahCompletion> _completionData = {
    1: SurahCompletion(surahId: 1, versesRead: 7, totalVerses: 7, percentage: 100.0),
    2: SurahCompletion(surahId: 2, versesRead: 5, totalVerses: 286, percentage: 1.7),
    3: SurahCompletion(surahId: 3, versesRead: 8, totalVerses: 200, percentage: 4.0),
    5: SurahCompletion(surahId: 5, versesRead: 6, totalVerses: 120, percentage: 5.0),
    // Sisanya auto-generate di constructor
  };

  // Last read position untuk "Continue Reading"
  final Map<String, dynamic> lastRead = {
    'surah_id': 2,
    'surah_name': 'Al-Baqarah',
    'page': 3,
    'ayah': 6,
  };

  CompletionService._internal() {
    _generateDummyData();
  }

  void _generateDummyData() {
    // Generate random progress untuk surah lainnya
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 4; i <= 114; i++) {
      if (_completionData.containsKey(i)) continue;
      
      // Simulasi: beberapa surah sudah dibaca, sisanya 0%
      int versesRead = 0;
      if (i % 7 == 0) versesRead = (i * 0.3).toInt(); // ~30%
      if (i % 11 == 0) versesRead = (i * 0.5).toInt(); // ~50%
      
      _completionData[i] = SurahCompletion(
        surahId: i,
        versesRead: versesRead,
        totalVerses: i * 3, // Dummy total (nanti ambil dari metadata)
        percentage: versesRead > 0 ? (versesRead / (i * 3) * 100) : 0.0,
      );
    }
  }

  SurahCompletion? getCompletion(int surahId) {
    return _completionData[surahId];
  }

  List<SurahCompletion> getAllCompletions() {
    return _completionData.values.toList();
  }

  // Calculate overall stats
  CompletionStats getOverallStats() {
    const totalPages = 604;
    int totalCompleted = 0;
    int totalStarted = 0;
    
    for (final completion in _completionData.values) {
      if (completion.percentage >= 100) totalCompleted++;
      if (completion.percentage > 0) totalStarted++;
    }

    // Simulasi pages read (dummy)
    double pagesRead = totalCompleted * 5.3 + totalStarted * 1.2;
    double remaining = totalPages - pagesRead;
    double percentage = (pagesRead / totalPages * 100);

    return CompletionStats(
      totalPages: totalPages,
      pagesRead: pagesRead,
      remainingPages: remaining > 0 ? remaining : 0.1,
      completions: totalCompleted,
      percentage: percentage,
    );
  }
}

class SurahCompletion {
  final int surahId;
  final int versesRead;
  final int totalVerses;
  final double percentage;

  SurahCompletion({
    required this.surahId,
    required this.versesRead,
    required this.totalVerses,
    required this.percentage,
  });

  bool get isComplete => percentage >= 100;
  bool get isStarted => percentage > 0;
  bool get isIncomplete => percentage > 0 && percentage < 100;
}

class CompletionStats {
  final int totalPages;
  final double pagesRead;
  final double remainingPages;
  final int completions;
  final double percentage;

  CompletionStats({
    required this.totalPages,
    required this.pagesRead,
    required this.remainingPages,
    required this.completions,
    required this.percentage,
  });
}

// ==================== COMPLETION PAGE ====================

class CompletionPage extends StatefulWidget {
  const CompletionPage({super.key});

  @override
  State<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<CompletionPage> {
  final MetadataCacheService _cache = MetadataCacheService();
  final CompletionService _completionService = CompletionService();
  final TextEditingController _searchController = TextEditingController();
  
  Timer? _searchDebounce;
  bool _isSearching = false;
  String _searchQuery = '';
  
  // Filter states
  bool _filterComplete = true;
  bool _filterIncomplete = true;
  bool _filterStarted = true;

  List<Map<String, dynamic>> _allSurahs = [];
  List<Map<String, dynamic>> _filteredSurahs = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_cache.isInitialized) {
      setState(() {
        _allSurahs = _cache.allSurahs;
        _applyFilters();
        _isInitialized = true;
      });
    } else {
      await _cache.initialize();
      if (mounted) {
        setState(() {
          _allSurahs = _cache.allSurahs;
          _applyFilters();
          _isInitialized = true;
        });
      }
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
          _isSearching = _searchQuery.isNotEmpty;
          _applyFilters();
        });
      }
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allSurahs);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((surah) {
        final name = (surah['name_simple'] as String? ?? '').toLowerCase();
        final nameArabic = surah['name_arabic'] as String? ?? '';
        final id = surah['id'].toString();
        
        return name.contains(_searchQuery) || 
               nameArabic.contains(_searchQuery) ||
               id.contains(_searchQuery);
      }).toList();
    }

    // Apply completion filters
    filtered = filtered.where((surah) {
      final completion = _completionService.getCompletion(surah['id'] as int);
      if (completion == null) return _filterIncomplete; // Default: treat as incomplete

      final isComplete = completion.isComplete;
      final isStarted = completion.isStarted;
      final isIncomplete = completion.isIncomplete;

      if (_filterComplete && _filterIncomplete && _filterStarted) return true;
      
      if (_filterComplete && isComplete) return true;
      if (_filterIncomplete && isIncomplete) return true;
      if (_filterStarted && isStarted) return true;
      
      return false;
    }).toList();

    setState(() {
      _filteredSurahs = filtered;
    });
  }

  void _toggleFilter(String filterType) {
    AppHaptics.light();
    setState(() {
      switch (filterType) {
        case 'complete':
          _filterComplete = !_filterComplete;
          break;
        case 'incomplete':
          _filterIncomplete = !_filterIncomplete;
          break;
        case 'started':
          _filterStarted = !_filterStarted;
          break;
      }
      _applyFilters();
    });
  }

  Future<void> _navigateToSurah(int surahId) async {
    AppHaptics.light();
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SttPage(suratId: surahId)),
    );
  }

  Future<void> _continueReading() async {
    AppHaptics.medium();
    final lastRead = _completionService.lastRead;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SttPage(pageId: lastRead['page'] as int),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        appBar: MenuAppBar(selectedIndex: 2),
        body: const AppLoadingIndicator(message: 'Loading completion data...'),
      );
    }

    final stats = _completionService.getOverallStats();

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: MenuAppBar(selectedIndex: 2),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Section: Progress Circle + Stats
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildProgressSection(stats),
                  _buildContinueReading(),
                  _buildFilterSection(),
                ],
              ),
            ),

            // List Section: Surah Completion List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    return _buildSectionHeader();
                  }
                  
                  final surah = _filteredSurahs[index - 1];
                  return _buildSurahCompletionTile(surah);
                },
                childCount: _filteredSurahs.length + 1,
              ),
            ),

            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: AppDesignSystem.space32),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROGRESS CIRCLE SECTION ====================

  Widget _buildProgressSection(CompletionStats stats) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Container(
      margin: EdgeInsets.all(AppDesignSystem.space16 * s),
      padding: EdgeInsets.all(AppDesignSystem.space16 * s),
      decoration: AppComponentStyles.card(),
      child: Column(
        children: [
          // Circular Progress Chart
          SizedBox(
            height: 160 * s,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: stats.percentage,
                        color: AppColors.primary,
                        radius: 24 * s,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: 100 - stats.percentage,
                        color: AppColors.primaryWithOpacity(0.15),
                        radius: 24 * s,
                        showTitle: false,
                      ),
                    ],
                    sectionsSpace: 0,
                    centerSpaceRadius: 56 * s,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${stats.percentage.toStringAsFixed(0)}%',
                      style: AppTypography.h2(
                        context,
                        weight: AppTypography.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppDesignSystem.space12 * s),

          Text(
            'Complete the Quran (khatm)',
            style: AppTypography.title(
              context,
              weight: AppTypography.semiBold,
            ),
          ),

          SizedBox(height: AppDesignSystem.space16 * s),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Total Pages',
                  value: stats.totalPages.toString(),
                ),
              ),
              SizedBox(width: AppDesignSystem.space8 * s),
              Expanded(
                child: _buildStatCard(
                  label: 'Remaining Pages',
                  value: stats.remainingPages.toStringAsFixed(1),
                ),
              ),
              SizedBox(width: AppDesignSystem.space8 * s),
              Expanded(
                child: _buildStatCard(
                  label: 'Completions',
                  value: stats.completions.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space8 * s,
        vertical: AppDesignSystem.space12 * s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall * s),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.captionSmall(
              context,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppDesignSystem.space4 * s),
          Text(
            value,
            style: AppTypography.titleLarge(
              context,
              weight: AppTypography.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== CONTINUE READING BUTTON ====================

  Widget _buildContinueReading() {
    final s = AppDesignSystem.getScaleFactor(context);
    final lastRead = _completionService.lastRead;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.space16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue Reading',
            style: AppTypography.title(
              context,
              weight: AppTypography.semiBold,
            ),
          ),
          SizedBox(height: AppDesignSystem.space8 * s),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _continueReading,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s),
              child: Container(
                padding: EdgeInsets.all(AppDesignSystem.space16 * s),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDesignSystem.space10 * s),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall * s),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: AppDesignSystem.iconMedium * s,
                      ),
                    ),
                    SizedBox(width: AppDesignSystem.space12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lastRead['surah_name']}, ${lastRead['ayah']}',
                            style: AppTypography.body(
                              context,
                              color: Colors.white,
                              weight: AppTypography.semiBold,
                            ),
                          ),
                          SizedBox(height: AppDesignSystem.space2 * s),
                          Text(
                            'Page ${lastRead['page']}',
                            style: AppTypography.captionSmall(
                              context,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: AppDesignSystem.iconSmall * s,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppDesignSystem.space16 * s),
        ],
      ),
    );
  }

  // ==================== FILTER SECTION ====================

  Widget _buildFilterSection() {
    final s = AppDesignSystem.getScaleFactor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.space16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s),
              border: Border.all(
                color: _searchController.text.isNotEmpty
                    ? AppColors.borderFocus
                    : AppColors.borderLight,
                width: AppDesignSystem.borderNormal * s,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: AppTypography.body(context),
              decoration: InputDecoration(
                hintText: 'Search by surah',
                hintStyle: AppTypography.body(
                  context,
                  color: AppColors.textHint,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _searchController.text.isNotEmpty
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  size: AppDesignSystem.iconMedium * s,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: AppDesignSystem.iconMedium * s,
                        ),
                        onPressed: () {
                          AppHaptics.light();
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppDesignSystem.space10 * s,
                ),
              ),
            ),
          ),

          SizedBox(height: AppDesignSystem.space12 * s),

          // Filter Toggles
          Row(
            children: [
              _buildFilterToggle(
                label: 'Complete',
                isSelected: _filterComplete,
                onTap: () => _toggleFilter('complete'),
              ),
              SizedBox(width: AppDesignSystem.space8 * s),
              _buildFilterToggle(
                label: 'Incomplete',
                isSelected: _filterIncomplete,
                onTap: () => _toggleFilter('incomplete'),
              ),
              SizedBox(width: AppDesignSystem.space8 * s),
              _buildFilterToggle(
                label: 'Started',
                isSelected: _filterStarted,
                onTap: () => _toggleFilter('started'),
              ),
            ],
          ),

          SizedBox(height: AppDesignSystem.space16 * s),
        ],
      ),
    );
  }

  Widget _buildFilterToggle({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall * s),
        child: AnimatedContainer(
          duration: AppDesignSystem.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space10 * s,
            vertical: AppDesignSystem.space6 * s,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall * s),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.borderMedium,
              width: AppDesignSystem.borderNormal * s,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: AppDesignSystem.iconSmall * s,
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
              SizedBox(width: AppDesignSystem.space4 * s),
              Text(
                label,
                style: AppTypography.labelSmall(
                  context,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  weight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SECTION HEADER ====================

  Widget _buildSectionHeader() {
    final s = AppDesignSystem.getScaleFactor(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDesignSystem.space16 * s,
        AppDesignSystem.space8 * s,
        AppDesignSystem.space16 * s,
        AppDesignSystem.space8 * s,
      ),
      child: Text(
        'COMPLETION BY CHAPTER',
        style: AppTypography.overline(context),
      ),
    );
  }

  // ==================== SURAH COMPLETION TILE ====================

  Widget _buildSurahCompletionTile(Map<String, dynamic> surah) {
    final s = AppDesignSystem.getScaleFactor(context);
    final int id = surah['id'] as int;
    final String name = surah['name_simple'] ?? 'Surah $id';
    final int totalVerses = surah['verses_count'] ?? 0;
    
    final completion = _completionService.getCompletion(id);
    final percentage = completion?.percentage ?? 0.0;
    final versesRead = completion?.versesRead ?? 0;

    // Calculate remaining ranges
    String remainingText = 'Remaining: 1-$totalVerses';
    if (versesRead > 0 && versesRead < totalVerses) {
      if (versesRead == totalVerses - 1) {
        remainingText = 'Remaining: $totalVerses';
      } else {
        remainingText = 'Remaining: ${versesRead + 1}-$totalVerses';
      }
    } else if (versesRead >= totalVerses) {
      remainingText = 'None remaining';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToSurah(id),
        splashColor: AppComponentStyles.rippleColor,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space16 * s,
            vertical: AppDesignSystem.space12 * s,
          ),
          decoration: AppComponentStyles.divider(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name - ${percentage.toStringAsFixed(0)}% ($versesRead/$totalVerses)',
                          style: AppTypography.body(
                            context,
                            weight: AppTypography.semiBold,
                          ),
                        ),
                        SizedBox(height: AppDesignSystem.space2 * s),
                        Text(
                          remainingText,
                          style: AppTypography.captionSmall(
                            context,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.borderDark,
                    size: AppDesignSystem.iconMedium * s,
                  ),
                ],
              ),

              SizedBox(height: AppDesignSystem.space8 * s),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusRound * s),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6 * s,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage >= 100
                        ? AppColors.success
                        : percentage >= 50
                        ? AppColors.primary
                        : percentage > 0
                        ? AppColors.warning
                        : AppColors.borderLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}