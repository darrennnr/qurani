// lib/screens/main/home/screens/surah_list_page.dart
// ✅ PROFESSIONAL UI IMPROVEMENT - Complete Refactor

import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';
import 'package:cuda_qurani/screens/main/home/services/juz_service.dart';
import 'package:cuda_qurani/screens/main/stt/stt_page.dart';
import 'package:cuda_qurani/services/local_database_service.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearchLoading = false;
  
  late Future<List<Map<String, dynamic>>> _futureSurahs;
  late Future<List<Map<String, dynamic>>> _futureJuz;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();

    _futureSurahs = LocalDatabaseService.getSurahs();
    _futureJuz = JuzService.getAllJuz();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty && _isSearching) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else if (query.isNotEmpty && !_isSearching) {
      setState(() => _isSearching = true);
      _performSearch(query);
    } else if (query.isNotEmpty) {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
    });

    try {
      final results = <Map<String, dynamic>>[];

      final numQuery = int.tryParse(query.trim());
      if (numQuery != null) {
        // Search Juz
        if (numQuery >= 1 && numQuery <= 30) {
          final juzData = await JuzService.getJuz(numQuery);
          if (juzData != null) {
            results.add({
              'type': 'juz',
              'juz_number': numQuery,
              'first_verse_key': juzData['first_verse_key'],
              'last_verse_key': juzData['last_verse_key'],
              'verses_count': juzData['verses_count'],
            });
          }
        }

        // Search Page
        if (numQuery >= 1 && numQuery <= 604) {
          results.add({'type': 'page', 'page_number': numQuery});
        }

        // Search Surah by number
        if (numQuery >= 1 && numQuery <= 114) {
          final surahMeta = await LocalDatabaseService.getSurahMetadata(numQuery);
          if (surahMeta != null) {
            results.add({
              'type': 'surah',
              'surah_number': numQuery,
              'surah_name': surahMeta['name_simple'],
              'surah_name_arabic': surahMeta['name_arabic'],
              'verses_count': surahMeta['verses_count'],
            });
          }
        }
      }

      // Search by text
      final textResults = await LocalDatabaseService.searchVerses(query);
      for (final result in textResults) {
        if (result['match_type'] == 'surah_name') {
          final surahNum = result['surah_number'] as int;
          if (!results.any(
            (r) => r['type'] == 'surah' && r['surah_number'] == surahNum,
          )) {
            results.add({
              'type': 'surah',
              'surah_number': surahNum,
              'surah_name': result['surah_name'],
              'surah_name_arabic': result['surah_name_arabic'],
              'verses_count': result.containsKey('verses_count')
                  ? result['verses_count']
                  : null,
            });
          }
        } else {
          results.add({'type': 'verse', ...result});
        }
      }

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('[Search] Error: $e');
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  }

  // ==================== NAVIGATION ====================
  
  Future<void> _openSurah(BuildContext context, int surahId) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SttPage(suratId: surahId)),
    );
  }

  Future<void> _openPage(BuildContext context, int pageNumber) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SttPage(pageId: pageNumber)),
    );
  }

  Future<void> _openSurahAtAyah(
    BuildContext context,
    int surahId,
    int ayahNumber,
  ) async {
    final page = await LocalDatabaseService.getPageNumber(surahId, ayahNumber);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SttPage(pageId: page)),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening page $page (Surah $surahId:$ayahNumber)'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
          ),
        ),
      );
    }
  }

  Future<void> _openJuz(
    BuildContext context,
    int juzNumber,
    String firstVerseKey,
  ) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SttPage(juzId: juzNumber)),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening Juz $juzNumber'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
          ),
        ),
      );
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: MenuAppBar(
        selectedIndex: 1,
        showSearch: true,
        searchController: _searchController,
        onSearchChanged: (_) => _onSearchChanged(),
        onSearchClear: () {
          _searchController.clear();
          setState(() {
            _isSearching = false;
            _searchResults = [];
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isSearching) _buildTabBar(),
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
    );
  }

  // ==================== TAB BAR ====================
  
  Widget _buildTabBar() {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignSystem.space20 * s,
              vertical: AppDesignSystem.space8 * s,
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2.5 * s,
                  color: AppColors.primary,
                ),
                insets: EdgeInsets.symmetric(horizontal: AppDesignSystem.space40 * s),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textDisabled,
              labelStyle: AppTypography.label(context, weight: AppTypography.semiBold),
              unselectedLabelStyle: AppTypography.label(context),
              tabs: const [
                Tab(text: 'Surah'),
                Tab(text: 'Juz'),
              ],
            ),
          ),
          Container(
            height: 1 * s,
            color: AppColors.borderLight,
          ),
        ],
      ),
    );
  }

  // ==================== BODY CONTENT ====================
  
  Widget _buildBodyContent() {
    if (_isSearching) {
      return _buildSearchResults();
    }

    return PageView(
      controller: _pageController,
      onPageChanged: (index) => _tabController.animateTo(index),
      children: [
        _buildSurahList(),
        _buildJuzList(),
      ],
    );
  }

  // ==================== SURAH LIST ====================
  
  Widget _buildSurahList() {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureSurahs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingIndicator();
        }
        if (snapshot.hasError) {
          return AppErrorState(
            message: snapshot.error.toString(),
            onRetry: () => setState(() {
              _futureSurahs = LocalDatabaseService.getSurahs();
            }),
          );
        }

        final surahs = snapshot.data ?? [];
        if (surahs.isEmpty) {
          return AppEmptyState(
            icon: Icons.menu_book_rounded,
            title: 'No Surahs Found',
            subtitle: 'Unable to load Quran data',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: AppDesignSystem.space4 * s,
            bottom: AppDesignSystem.space32 * s,
          ),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return _SurahTile(
              surah: surah,
              onTap: () => _openSurah(context, surah['id'] as int),
            );
          },
        );
      },
    );
  }

  // ==================== JUZ LIST ====================
  
  Widget _buildJuzList() {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureJuz,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingIndicator();
        }
        if (snapshot.hasError) {
          return AppErrorState(
            message: snapshot.error.toString(),
            onRetry: () => setState(() {
              _futureJuz = JuzService.getAllJuz();
            }),
          );
        }

        final juzList = snapshot.data ?? [];
        if (juzList.isEmpty) {
          return AppEmptyState(
            icon: Icons.auto_stories_rounded,
            title: 'No Juz Found',
            subtitle: 'Unable to load Juz data',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: AppDesignSystem.space4 * s,
            bottom: AppDesignSystem.space32 * s,
          ),
          itemCount: juzList.length,
          itemBuilder: (context, index) {
            final juz = juzList[index];
            return _JuzTile(
              juz: juz,
              onTap: () => _openJuz(
                context,
                juz['juz_number'] as int,
                juz['first_verse_key'] as String,
              ),
            );
          },
        );
      },
    );
  }

  // ==================== SEARCH RESULTS ====================
  
  Widget _buildSearchResults() {
    final s = AppDesignSystem.getScaleFactor(context);
    
    if (_isSearchLoading) {
      return const AppLoadingIndicator();
    }

    if (_searchResults.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Results Found',
        subtitle: 'Try searching with different keywords',
      );
    }

    // Group results by type
    final juzResults = _searchResults.where((r) => r['type'] == 'juz').toList();
    final pageResults = _searchResults.where((r) => r['type'] == 'page').toList();
    final surahResults = _searchResults.where((r) => r['type'] == 'surah').toList();
    final verseResults = _searchResults.where((r) => r['type'] == 'verse').toList();

    return ListView(
      padding: EdgeInsets.only(
        top: AppDesignSystem.space12 * s,
        bottom: AppDesignSystem.space32 * s,
      ),
      children: [
        if (juzResults.isNotEmpty) ...[
          AppCategoryHeader(title: 'JUZ', count: juzResults.length),
          ...juzResults.map((r) => _JuzSearchTile(
                result: r,
                onTap: () => _openJuz(
                  context,
                  r['juz_number'] as int,
                  r['first_verse_key'] as String,
                ),
              )),
          SizedBox(height: AppDesignSystem.space12 * s),
        ],
        if (pageResults.isNotEmpty) ...[
          AppCategoryHeader(title: 'PAGE', count: pageResults.length),
          ...pageResults.map((r) => _PageSearchTile(
                result: r,
                onTap: () => _openPage(context, r['page_number'] as int),
              )),
          SizedBox(height: AppDesignSystem.space12 * s),
        ],
        if (surahResults.isNotEmpty) ...[
          AppCategoryHeader(title: 'SURAH', count: surahResults.length),
          ...surahResults.map((r) => _SurahSearchTile(
                result: r,
                onTap: () => _openSurah(context, r['surah_number'] as int),
              )),
          SizedBox(height: AppDesignSystem.space12 * s),
        ],
        if (verseResults.isNotEmpty) ...[
          AppCategoryHeader(title: 'VERSES', count: verseResults.length),
          ...verseResults.map((r) => _VerseSearchTile(
                result: r,
                onTap: () => _openSurahAtAyah(
                  context,
                  r['surah_number'] as int,
                  r['ayah_number'] as int,
                ),
              )),
        ],
      ],
    );
  }
}

// ==================== SURAH TILE COMPONENT ====================

class _SurahTile extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;

  const _SurahTile({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    final int id = surah['id'] as int;
    final String name = surah['name_simple'] ?? surah['name'] ?? 'Surah $id';
    final int ayat = surah['verses_count'] ?? 0;
    final String place = (surah['revelation_place'] ?? '').toString().toLowerCase();
    final String type = place == 'makkah' || place == 'mecca'
        ? 'Makkiyah'
        : place == 'madinah' || place == 'medina'
            ? 'Madaniyah'
            : (id < 90 ? 'Makkiyah' : 'Madaniyah');

    return AppListTile(
      onTap: onTap,
      leading: AppNumberBadge(number: id),
      title: name,
      subtitle: '$type · $ayat Ayat',
      trailing: Text(
        'surah${id.toString().padLeft(3, '0')}',
        style: AppTypography.surahName(context),
      ),
    );
  }
}

// ==================== JUZ TILE COMPONENT ====================

class _JuzTile extends StatelessWidget {
  final Map<String, dynamic> juz;
  final VoidCallback onTap;

  const _JuzTile({
    required this.juz,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int juzNum = juz['juz_number'] as int;
    final String firstVerse = juz['first_verse_key'] as String;
    final String lastVerse = juz['last_verse_key'] as String;
    final int verseCount = juz['verses_count'] as int;

    return AppListTile(
      onTap: onTap,
      leading: AppNumberBadge(number: juzNum),
      title: 'Juz $juzNum',
      subtitle: '$firstVerse - $lastVerse',
      trailing: AppChip(label: '$verseCount Ayat'),
    );
  }
}

// ==================== SEARCH RESULT TILES ====================

class _JuzSearchTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const _JuzSearchTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final juzNum = result['juz_number'] as int;
    final firstVerse = result['first_verse_key'] as String;
    final lastVerse = result['last_verse_key'] as String;
    final versesCount = result['verses_count'] as int;

    return AppListTile(
      onTap: onTap,
      leading: AppIconContainer(icon: Icons.auto_stories_rounded),
      title: 'Juz $juzNum',
      subtitle: '$firstVerse - $lastVerse · $versesCount Ayat',
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.borderDark,
        size: AppDesignSystem.iconMedium,
      ),
    );
  }
}

class _PageSearchTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const _PageSearchTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pageNum = result['page_number'] as int;

    return AppListTile(
      onTap: onTap,
      leading: AppIconContainer(icon: Icons.description_rounded),
      title: 'Page $pageNum',
      subtitle: 'Mushaf Al-Quran',
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.borderDark,
        size: AppDesignSystem.iconMedium,
      ),
    );
  }
}

class _SurahSearchTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const _SurahSearchTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surahName = result['surah_name'] as String;
    final versesCount = result['verses_count'] as int?;

    return AppListTile(
      onTap: onTap,
      leading: AppIconContainer(icon: Icons.menu_book_rounded),
      title: surahName,
      subtitle: versesCount != null ? '$versesCount Ayat' : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.borderDark,
        size: AppDesignSystem.iconMedium,
      ),
    );
  }
}

class _VerseSearchTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const _VerseSearchTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    final surahNumber = result['surah_number'] as int;
    final ayahNumber = result['ayah_number'] as int;
    final text = result['text'] as String;
    final surahName = result['surah_name'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppComponentStyles.rippleColor,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space20 * s,
            vertical: AppDesignSystem.space16 * s,
          ),
          decoration: AppComponentStyles.divider(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppChip(label: '$surahName : $ayahNumber'),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.borderDark,
                    size: AppDesignSystem.iconMedium * s,
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.space12 * s),
              Text(
                text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTypography.arabic(context),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}