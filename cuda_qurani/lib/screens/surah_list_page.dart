import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_database_service.dart';
import '../screens/surah_page.dart';
import '../providers/recitation_provider.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  late final RecitationProvider _recitationProvider;
  late Future<List<Map<String, dynamic>>> _futureSurahs;

  @override
  void initState() {
    super.initState();
    _futureSurahs = LocalDatabaseService.getSurahs();
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
              _buildSectionTitle(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
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
                "Al-Qur'an",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Surat dalam Al-Qur\'an',
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

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Daftar Surat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pilih surat untuk membaca',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Load from local database
      final surah = await LocalDatabaseService.getSurah(surahId);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: _recitationProvider,
              child: SurahPage(surah: surah),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat surah: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
