// lib\screens\main\home\surah_list_page.dart

import 'package:cuda_qurani/screens/main/home/services/juz_service.dart';
import 'package:cuda_qurani/screens/main/stt/stt_page.dart';
import 'package:cuda_qurani/services/local_database_service.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;
import 'package:cuda_qurani/screens/main/home/widgets/bottom_nav_bar.dart';
import 'package:cuda_qurani/screens/main/home/widgets/app_bar.dart';

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
      setState(() {
        _isSearching = true;
      });
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
      
      // Search by number
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
          final surahMeta = await LocalDatabaseService.getSurahMetadata(
            numQuery,
          );
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
      print('[Search] Error: $e');
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  }

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
    await Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => SttPage(pageId: page)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membuka halaman $page (Surah $surahId:$ayahNumber)'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          content: Text('Membuka Juz $juzNumber'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    const double designWidth = 406.0;
    final double s = MediaQuery.of(context).size.width / designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: QuranAppBar(scaleFactor: s),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(s),
            if (!_isSearching) _buildTabBar(s),
            Expanded(child: _buildBodyContent(s)),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildSearchBar(double s) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.0 * s, 16.0 * s, 20.0 * s, 16.0 * s),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.0 * s),
          border: Border.all(
            color: _searchController.text.isNotEmpty
                ? constants.primaryColor.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            fontSize: 15 * s,
            color: const Color(0xFF2C2C2C),
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Cari surah, juz, atau halaman...',
            hintStyle: TextStyle(
              color: const Color(0xFF9E9E9E),
              fontSize: 15 * s,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0 * s),
              child: Icon(
                Icons.search_rounded,
                color: const Color(0xFF757575),
                size: 22 * s,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF757575),
                      size: 20 * s,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.0 * s,
              horizontal: 4.0 * s,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(double s) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0 * s),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2.5 * s,
                  color: constants.primaryColor,
                ),
                insets: EdgeInsets.symmetric(horizontal: 40.0 * s),
              ),
              labelColor: constants.primaryColor,
              unselectedLabelColor: const Color(0xFF9E9E9E),
              labelStyle: TextStyle(
                fontSize: 15 * s,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15 * s,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Surah'),
                Tab(text: 'Juz'),
              ],
            ),
          ),
          Container(
            height: 1 * s,
            color: const Color(0xFFE8E8E8),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(double s) {
    if (_isSearching) {
      return _buildSearchResults(s);
    }

    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _tabController.animateTo(index);
      },
      children: [_buildSurahList(s), _buildJuzList(s)],
    );
  }

  Widget _buildSurahList(double s) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureSurahs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: constants.primaryColor,
              strokeWidth: 2.5,
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(s, snapshot.error.toString());
        }

        final surahs = snapshot.data ?? [];
        if (surahs.isEmpty) {
          return _buildEmptyState(s, 'Daftar surah kosong');
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 4 * s, bottom: 80 * s),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final sData = surahs[index];
            return _buildSurahTile(context, sData, s);
          },
        );
      },
    );
  }

  Widget _buildJuzList(double s) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureJuz,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: constants.primaryColor,
              strokeWidth: 2.5,
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(s, snapshot.error.toString());
        }

        final juzList = snapshot.data ?? [];
        if (juzList.isEmpty) {
          return _buildEmptyState(s, 'Daftar juz kosong');
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 4 * s, bottom: 80 * s),
          itemCount: juzList.length,
          itemBuilder: (context, index) {
            final juz = juzList[index];
            return _buildJuzTile(context, juz, s);
          },
        );
      },
    );
  }

  Widget _buildSurahTile(BuildContext context, Map<String, dynamic> sData, double s) {
    final int id = sData['id'] as int;
    final String latin = sData['name_simple'] ?? sData['name'] ?? 'Surah $id';
    final int ayat = sData['verses_count'] ?? 0;
    final String place = (sData['revelation_place'] ?? '').toString().toLowerCase();
    final String typePretty = place == 'makkah' || place == 'mecca'
        ? 'Makkiyah'
        : place == 'madinah' || place == 'medina'
            ? 'Madaniyah'
            : (id < 90 ? 'Makkiyah' : 'Madaniyah');
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _openSurah(context, id);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.0 * s,
            vertical: 16.0 * s,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFF0F0F0),
                width: 1 * s,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42 * s,
                height: 42 * s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      constants.primaryColor.withOpacity(0.08),
                      constants.primaryColor.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  id.toString(),
                  style: TextStyle(
                    color: constants.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * s,
                  ),
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latin,
                      style: TextStyle(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      '$typePretty • $ayat Ayat',
                      style: TextStyle(
                        fontSize: 13 * s,
                        color: const Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * s),
              Text(
                'surah${id.toString().padLeft(3, '0')}',
                style: TextStyle(
                  fontFamily: 'surah-name-v1',
                  fontSize: 26 * s,
                  color: constants.primaryColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJuzTile(BuildContext context, Map<String, dynamic> juz, double s) {
    final int juzNumber = juz['juz_number'] as int;
    final String firstVerseKey = juz['first_verse_key'] as String;
    final String lastVerseKey = juz['last_verse_key'] as String;
    final int verseCount = juz['verses_count'] as int;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _openJuz(context, juzNumber, firstVerseKey);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.0 * s,
            vertical: 16.0 * s,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFF0F0F0),
                width: 1 * s,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42 * s,
                height: 42 * s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      constants.primaryColor.withOpacity(0.08),
                      constants.primaryColor.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  juzNumber.toString(),
                  style: TextStyle(
                    color: constants.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * s,
                  ),
                ),
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juz $juzNumber',
                      style: TextStyle(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      '$firstVerseKey - $lastVerseKey',
                      style: TextStyle(
                        fontSize: 13 * s,
                        color: const Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * s),
                Text(
                  '$verseCount Ayat',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(double s) {
    if (_isSearchLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: constants.primaryColor,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(s, 'Tidak ada hasil ditemukan');
    }

    final juzResults = _searchResults.where((r) => r['type'] == 'juz').toList();
    final pageResults = _searchResults.where((r) => r['type'] == 'page').toList();
    final surahResults = _searchResults.where((r) => r['type'] == 'surah').toList();
    final verseResults = _searchResults.where((r) => r['type'] == 'verse').toList();

    return ListView(
      padding: EdgeInsets.only(top: 8 * s, bottom: 80 * s),
      children: [
        if (juzResults.isNotEmpty) ...[
          _buildCategoryHeader('Juz', juzResults.length, s),
          ...juzResults.map((r) => _buildJuzResultTile(context, r, s)),
          SizedBox(height: 16 * s),
        ],
        if (pageResults.isNotEmpty) ...[
          _buildCategoryHeader('Halaman', pageResults.length, s),
          ...pageResults.map((r) => _buildPageResultTile(context, r, s)),
          SizedBox(height: 16 * s),
        ],
        if (surahResults.isNotEmpty) ...[
          _buildCategoryHeader('Surah', surahResults.length, s),
          ...surahResults.map((r) => _buildSurahResultTile(context, r, s)),
          SizedBox(height: 16 * s),
        ],
        if (verseResults.isNotEmpty) ...[
          _buildCategoryHeader('Ayat', verseResults.length, s),
          ...verseResults.map((r) => _buildVerseResultTile(context, r, s)),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, int count, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 8.0 * s),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF757575),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzResultTile(
    BuildContext context,
    Map<String, dynamic> result,
    double s,
  ) {
    final juzNum = result['juz_number'] as int;
    final firstVerse = result['first_verse_key'] as String;
    final lastVerse = result['last_verse_key'] as String;
    final versesCount = result['verses_count'] as int;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openJuz(context, juzNum, firstVerse),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0 * s, vertical: 14.0 * s),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFF5F5F5),
                width: 1 * s,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: constants.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: constants.primaryColor,
                  size: 18 * s,
                ),
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juz $juzNum',
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      '$firstVerse - $lastVerse • $versesCount Ayat',
                      style: TextStyle(
                        fontSize: 12 * s,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFBDBDBD),
                size: 20 * s,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageResultTile(
    BuildContext context,
    Map<String, dynamic> result,
    double s,
  ) {
    final pageNum = result['page_number'] as int;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPage(context, pageNum),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0 * s, vertical: 14.0 * s),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFF5F5F5),
                width: 1 * s,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: constants.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.description_rounded,
                  color: constants.primaryColor,
                  size: 18 * s,
                ),
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halaman $pageNum',
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      'Mushaf Al-Quran',
                      style: TextStyle(
                        fontSize: 12 * s,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFBDBDBD),
                size: 20 * s,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahResultTile(
    BuildContext context,
    Map<String, dynamic> result,
    double s,
  ) {
    final surahNum = result['surah_number'] as int;
    final surahName = result['surah_name'] as String;
    final versesCount = result['verses_count'] as int?;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openSurah(context, surahNum),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0 * s, vertical: 14.0 * s),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFF5F5F5),
                width: 1 * s,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: constants.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_book_rounded,
                  color: constants.primaryColor,
                  size: 18 * s,
                ),
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    if (versesCount != null) ...[
                      SizedBox(height: 3 * s),
                      Text(
                        '$versesCount Ayat',
                        style: TextStyle(
                          fontSize: 12 * s,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFBDBDBD),
                size: 20 * s,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseResultTile(
    BuildContext context,
    Map<String, dynamic> result,
    double s,
  ) {
    final surahNumber = result['surah_number'];
    final ayahNumber = result['ayah_number'];
    final text = result['text'];
    final surahName = result['surah_name'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _openSurahAtAyah(context, surahNumber, ayahNumber);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0 * s, vertical: 16.0 * s),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFF5F5F5),
                width: 1 * s,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * s,
                      vertical: 5 * s,
                    ),
                    decoration: BoxDecoration(
                      color: constants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6 * s),
                    ),
                    child: Text(
                      '$surahName : $ayahNumber',
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w600,
                        color: constants.primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFFBDBDBD),
                    size: 18 * s,
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              Text(
                text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: 19 * s,
                  color: const Color(0xFF2C2C2C),
                  height: 1.9,
                  letterSpacing: 0.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double s, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80 * s,
            height: 80 * s,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40 * s),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40 * s,
              color: const Color(0xFFBDBDBD),
            ),
          ),
          SizedBox(height: 20 * s),
          Text(
            message,
            style: TextStyle(
              fontSize: 16 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF757575),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            'Coba dengan kata kunci lain',
            style: TextStyle(
              fontSize: 13 * s,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(double s, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0 * s),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80 * s,
              height: 80 * s,
              decoration: BoxDecoration(
                color: constants.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40 * s),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: constants.errorColor,
                size: 40 * s,
              ),
            ),
            SizedBox(height: 20 * s),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 17 * s,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            SizedBox(height: 8 * s),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF757575),
                fontSize: 14 * s,
              ),
            ),
            SizedBox(height: 24 * s),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: constants.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 32 * s,
                  vertical: 14 * s,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * s),
                ),
              ),
              onPressed: () => setState(() {
                _futureSurahs = LocalDatabaseService.getSurahs();
                _futureJuz = JuzService.getAllJuz();
              }),
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}