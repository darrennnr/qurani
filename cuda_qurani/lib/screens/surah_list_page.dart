import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_database_service.dart';
import '../screens/main/stt/stt_page.dart';
import '../providers/recitation_provider.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  late final RecitationProvider _recitationProvider;
  late Future<List<Map<String, dynamic>>> _futureSurahs;
  
  // Search state
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearchLoading = false;

  @override
  void initState() {
    super.initState();
    _futureSurahs = LocalDatabaseService.getSurahs();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    // Debounce search
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else {
      _performSearch(_searchController.text.trim());
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
      print('[Search] Query: "$query"');
      final results = await LocalDatabaseService.searchVerses(query);
      print('[Search] Found ${results.length} results');
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      print('[Search] Error: $e');
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recitationProvider = Provider.of<RecitationProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF8F4), Color(0xFFF7FFFB)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _isSearching
                    ? _buildSearchResults()
                    : FutureBuilder<List<Map<String, dynamic>>>(
                        future: _futureSurahs,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                    const SizedBox(height: 12),
                                    Text('Gagal memuat daftar surat\n${snapshot.error}', textAlign: TextAlign.center),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () => setState(() => _futureSurahs = LocalDatabaseService.getSurahs()),
                                      child: const Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final surahs = snapshot.data ?? [];
                          if (surahs.isEmpty) {
                            return const Center(child: Text('Daftar surat kosong'));
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24 + 72),
                            itemBuilder: (context, index) {
                              final s = surahs[index];
                              return _buildSurahCard(context, s);
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemCount: surahs.length,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF007F67),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF17C3A5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Qurani Hafidz",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF17C3A5).withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF17C3A5), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Cari ayat dalam Al-Qur\'an...',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              textDirection: TextDirection.ltr, // LTR for normal typing (kiri ke kanan)
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black38, size: 20),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    if (_isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'Tidak ada hasil',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Text(
              'Coba kata kunci lain',
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24 + 72),
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultCard(context, result);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: _searchResults.length,
    );
  }
  
  Widget _buildSearchResultCard(BuildContext context, Map<String, dynamic> result) {
    final int surahNumber = result['surah_number'];
    final int ayahNumber = result['ayah_number'];
    final String text = result['text'];
    final String surahName = result['surah_name'];
    final String surahNameArabic = result['surah_name_arabic'];
    
    // Highlight matching text
    final query = _searchController.text.trim();
    
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        // Navigate to specific ayah in surah
        await _openSurahAtAyah(context, surahNumber, ayahNumber);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Surah name and ayah number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17C3A5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$surahName : $ayahNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF007F67),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  surahNameArabic,
                  style: const TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 16,
                    color: Color(0xFF007F67),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.black38),
              ],
            ),
            const SizedBox(height: 10),
            // Ayah text with highlight
            Text(
              text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: 20,
                color: Colors.black87,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, Map<String, dynamic> s) {
    // Extract from local database structure
    // chapters table columns: id, name, name_simple, name_arabic, revelation_order, revelation_place, verses_count, bismillah_pre
    final int id = s['id'] as int;
    final String latin = s['name_simple'] ?? s['name'] ?? 'Surah $id';
    final String arabic = s['name_arabic'] ?? '';
    final int ayat = s['verses_count'] ?? 0;
    final String place = (s['revelation_place'] ?? '').toString().toLowerCase();
    final String typePretty = place == 'makkah' || place == 'mecca' 
        ? 'Makkiyah' 
        : place == 'madinah' || place == 'medina'
            ? 'Madaniyah'
            : (id < 90 ? 'Makkiyah' : 'Madaniyah');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await _openSurah(context, id);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF17C3A5),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                id.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latin,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF095B4B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$typePretty • $ayat Ayat',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  arabic,
                  style: const TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 20,
                    color: Color(0xFF007F67),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded, color: Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }

Future<void> _openSurah(BuildContext context, int surahId) async {
  // Langsung navigate tanpa loading dari database
  // karena SttPage akan load data sendiri
  await Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => SttPage(suratId: surahId),
    ),
  );
}
  
Future<void> _openSurahAtAyah(BuildContext context, int surahId, int ayahNumber) async {
  // Navigate ke SttPage dengan surah ID
  // Note: SttPage belum support initialAyah, jadi untuk sementara
  // akan open dari ayah pertama
  await Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => SttPage(suratId: surahId),
    ),
  );
  
  // Optional: Show snackbar untuk info ayah number
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening surah $surahId (scroll to ayah $ayahNumber coming soon)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0BB798),
        unselectedItemColor: Colors.black45,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_rounded), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Profil'),
        ],
        onTap: (i) {
          if (i != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu belum tersedia')),
            );
          }
        },
      ),
    );
  }
}
