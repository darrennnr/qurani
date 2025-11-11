// lib\screens\main\home\surah_list_page.dart

import 'package:cuda_qurani/screens/main/home/services/juz_service.dart';
import 'package:cuda_qurani/screens/main/stt/stt_page.dart';
import 'package:cuda_qurani/services/local_database_service.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;

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
      // 🔍 SEARCH BY NUMBER (Juz, Page, Surah)
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
              'verses_count': surahMeta['verses_count'], // ✅ ADD THIS
            });
          }
        }
      }

      // 🔍 SEARCH BY TEXT (Surah name or verse content)
      final textResults = await LocalDatabaseService.searchVerses(query);
      for (final result in textResults) {
        if (result['match_type'] == 'surah_name') {
          // Add surah results
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
                  : null, // ✅ Handle missing verses_count
            });
          }
        } else {
          // Add verse results
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
    // Get page for this ayah
    final page = await LocalDatabaseService.getPageNumber(surahId, ayahNumber);
    await Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => SttPage(pageId: page)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membuka halaman $page (Surah $surahId:$ayahNumber)'),
          duration: const Duration(seconds: 2),
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Responsive Setup ---
    const double designWidth = 406.0;
    final double s = MediaQuery.of(context).size.width / designWidth;
    // --- End Responsive Setup ---

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(s),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(s),
            _buildTabBar(s),
            Expanded(child: _buildBodyContent(s)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double s) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: false,
      title: Image.asset(
        'assets/images/qurani-white-text.png',
        height: 30 * s,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        color: constants.primaryColor,
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0 * s),
        child: Container(color: Colors.grey[200], height: 1.0 * s),
      ),
    );
  }

  Widget _buildSearchBar(double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0 * s, 16.0 * s, 16.0 * s, 8.0 * s),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 16 * s, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Cari surah, juz atau halaman...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16 * s),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500]),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0 * s),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14.0 * s),
        ),
      ),
    );
  }

  Widget _buildTabBar(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * s, vertical: 0.0),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3.0 * s, color: constants.primaryColor),
          insets: EdgeInsets.symmetric(horizontal: 28.0 * s),
        ),
        labelColor: constants.primaryColor,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
          fontSize: 15 * s,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Surah'),
          Tab(text: 'Juz'),
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
            child: CircularProgressIndicator(color: constants.primaryColor),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(s, snapshot.error.toString());
        }

        final surahs = snapshot.data ?? [];
        if (surahs.isEmpty) {
          return const Center(child: Text('Daftar surat kosong.'));
        }

        return ListView.separated(
          padding: EdgeInsets.only(bottom: 80 * s),
          itemCount: surahs.length,
          separatorBuilder: (context, index) => Divider(
            height: 1 * s,
            thickness: 1 * s,
            color: Colors.grey[200],
            indent: 16 * s,
            endIndent: 16 * s,
          ),
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
            child: CircularProgressIndicator(color: constants.primaryColor),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(s, snapshot.error.toString());
        }

        final juzList = snapshot.data ?? [];
        if (juzList.isEmpty) {
          return const Center(child: Text('Daftar juz kosong.'));
        }

        return ListView.separated(
          padding: EdgeInsets.only(bottom: 80 * s),
          itemCount: juzList.length,
          separatorBuilder: (context, index) => Divider(
            height: 1 * s,
            thickness: 1 * s,
            color: Colors.grey[200],
            indent: 16 * s,
            endIndent: 16 * s,
          ),
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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 24.0 * s,
        vertical: 0.0,
      ),
      onTap: () async {
        await _openSurah(context, id);
      },
      leading: Container(
        width: 44 * s,
        height: 44 * s,
        decoration: BoxDecoration(
          color: constants.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          id.toString(),
          style: TextStyle(
            color: constants.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 16 * s,
          ),
        ),
      ),
      title: Text(
        latin,
        style: TextStyle(
          fontSize: 17 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        '$typePretty • $ayat Ayat',
        style: TextStyle(fontSize: 13 * s, color: Colors.grey[600]),
      ),
      trailing: Text(
        'surah${id.toString().padLeft(3, '0')}',
        style: TextStyle(
          fontFamily: 'surah-name-v1',
          fontSize: 22 * s,
          color: constants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildJuzTile(BuildContext context, Map<String, dynamic> juz, double s) {
    final int juzNumber = juz['juz_number'] as int;
    final String firstVerseKey = juz['first_verse_key'] as String;
    final String lastVerseKey = juz['last_verse_key'] as String;
    final int verseCount = juz['verses_count'] as int;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 24.0 * s,
        vertical: 0.0,
      ),
      onTap: () async {
        await _openJuz(context, juzNumber, firstVerseKey);
      },
      leading: Container(
        width: 44 * s,
        height: 44 * s,
        decoration: BoxDecoration(
          color: constants.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          juzNumber.toString(),
          style: TextStyle(
            color: constants.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 16 * s,
          ),
        ),
      ),
      title: Text(
        'Juz $juzNumber',
        style: TextStyle(
          fontSize: 17 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        '$firstVerseKey - $lastVerseKey • $verseCount Ayat',
        style: TextStyle(fontSize: 13 * s, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.bookmark_outline,
        color: constants.primaryColor.withOpacity(0.6),
        size: 24 * s,
      ),
    );
  }

  // --- 💡 UI SEARCH RESULTS 💡 ---

  Widget _buildSearchResults(double s) {
    if (_isSearchLoading) {
      return const Center(
        child: CircularProgressIndicator(color: constants.primaryColor),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 64 * s, color: Colors.grey[400]),
            SizedBox(height: 16 * s),
            Text(
              'Tidak ada hasil',
              style: TextStyle(
                fontSize: 18 * s,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8 * s),
            Text(
              'Coba cari dengan kata kunci lain',
              style: TextStyle(fontSize: 14 * s, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Group results by type
    final juzResults = _searchResults.where((r) => r['type'] == 'juz').toList();
    final pageResults = _searchResults
        .where((r) => r['type'] == 'page')
        .toList();
    final surahResults = _searchResults
        .where((r) => r['type'] == 'surah')
        .toList();
    final verseResults = _searchResults
        .where((r) => r['type'] == 'verse')
        .toList();
    return ListView(
      padding: EdgeInsets.only(bottom: 80 * s),
      children: [
        if (juzResults.isNotEmpty) ...[
          _buildCategoryHeader('Juz', juzResults.length, s),
          ...juzResults.map((r) => _buildJuzResultTile(context, r, s)),
          SizedBox(height: 10 * s),
        ],
        if (pageResults.isNotEmpty) ...[
          _buildCategoryHeader('Halaman', pageResults.length, s),
          ...pageResults.map((r) => _buildPageResultTile(context, r, s)),
          SizedBox(height: 10 * s),
        ],
        if (surahResults.isNotEmpty) ...[
          _buildCategoryHeader('Surah', surahResults.length, s),
          ...surahResults.map((r) => _buildSurahResultTile(context, r, s)),
          SizedBox(height: 10 * s),
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
      padding: EdgeInsets.fromLTRB(24.0 * s, 16.0 * s, 24.0 * s, 8.0 * s),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13 * s,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5 * s,
        ),
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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0 * s, vertical: 4.0 * s),
      leading: Icon(
        Icons.book_outlined,
        color: Colors.grey[600],
      ),
      title: Text(
        'Juz $juzNum',
        style: TextStyle(
          fontSize: 16 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        '$firstVerse - $lastVerse • $versesCount Ayat',
        style: TextStyle(fontSize: 13 * s, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16 * s),
      onTap: () => _openJuz(context, juzNum, firstVerse),
    );
  }

  Widget _buildPageResultTile(
    BuildContext context,
    Map<String, dynamic> result,
    double s,
  ) {
    final pageNum = result['page_number'] as int;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0 * s, vertical: 4.0 * s),
      leading: Icon(
        Icons.article_outlined,
        color: Colors.grey[600],
      ),
      title: Text(
        'Halaman $pageNum',
        style: TextStyle(
          fontSize: 16 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        'Mushaf Al-Quran',
        style: TextStyle(fontSize: 13 * s, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16 * s),
      onTap: () => _openPage(context, pageNum),
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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0 * s, vertical: 4.0 * s),
      leading: Icon(
        Icons.auto_stories_outlined,
        color: Colors.grey[600],
      ),
      title: Text(
        surahName,
        style: TextStyle(
          fontSize: 16 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: (versesCount != null)
          ? Text(
              '$versesCount Ayat',
              style: TextStyle(fontSize: 13 * s, color: Colors.grey[600]),
            )
          : null,
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16 * s),
      onTap: () => _openSurah(context, surahNum),
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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0 * s, vertical: 12.0 * s),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * s,
              vertical: 4 * s,
            ),
            decoration: BoxDecoration(
              color: constants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Text(
              '$surahName : $ayahNumber',
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: constants.primaryColor,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 12.0 * s),
        child: Text(
          text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'UthmanicHafs',
            fontSize: 20 * s,
            color: Colors.black87,
            height: 1.8, // Tetap
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      isThreeLine: true,
      onTap: () async {
        await _openSurahAtAyah(context, surahNumber, ayahNumber);
      },
    );
  }

  // --- 💡 UI LAMA (TIDAK TERPAKAI) - JUGA DISESUAIKAN 💡 ---

  Widget _buildSearchResultCard(
    BuildContext context,
    Map<String, dynamic> result,
    double s,
  ) {
    final int surahNumber = result['surah_number'];
    final int ayahNumber = result['ayah_number'];
    final String text = result['text'];
    final String surahName = result['surah_name'];
    return InkWell(
      borderRadius: BorderRadius.circular(12 * s),
      onTap: () async {
        await _openSurahAtAyah(context, surahNumber, ayahNumber);
      },
      child: Container(
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$surahName : $ayahNumber',
              style: TextStyle(
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
                color: constants.primaryColor,
              ),
            ),
            SizedBox(height: 12 * s),
            Text(
              text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: 22 * s,
                color: Colors.black87,
                height: 1.8, // Tetap
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(double s, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0 * s),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: constants.errorColor,
              size: 48 * s,
            ),
            SizedBox(height: 16 * s),
            Text(
              'Gagal memuat daftar\n$error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 16 * s),
            ),
            SizedBox(height: 20 * s),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: constants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                ),
              ),
              onPressed: () => setState(() {
                _futureSurahs = LocalDatabaseService.getSurahs();
                _futureJuz = JuzService.getAllJuz();
              }),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}