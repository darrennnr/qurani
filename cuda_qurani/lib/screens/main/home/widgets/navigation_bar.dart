// lib/screens/main/home/widgets/app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/surah_list_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/profile_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings_page.dart';
// BAGIAN YANG PERLU DIUPDATE di MenuAppBar class

class MenuAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final bool showSearch;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchClear;

  const MenuAppBar({
    Key? key,
    required this.selectedIndex,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.onSearchClear,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(120); // Increased from 116

  @override
  State<MenuAppBar> createState() => _MenuAppBarState();
}

class _MenuAppBarState extends State<MenuAppBar> {
  bool _isSearchFocused = false;
  late FocusNode _searchFocusNode;
  
  // TAMBAHKAN: Menu items list
  final List<Map<String, dynamic>> _menuItems = [
    {'label': 'Home', 'index': 0},
    {'label': 'Quran', 'index': 1},
    {'label': 'Goal', 'index': 2},
    {'label': 'Bookmark', 'index': 4},
    {'label': 'History', 'index': 5},
    {'label': 'Settings', 'index': 6},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 406.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8), width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // TAMBAHKAN: Prevent overflow
          children: [
            _buildTopBar(context, s), 
            _buildMenuBar(context, s)
          ],
        ),
      ),
    );
  }

  // _buildTopBar tetap sama, tidak ada perubahan
  Widget _buildTopBar(BuildContext context, double s) {
    return Container(
      height: 60 * s,
      padding: EdgeInsets.symmetric(horizontal: 20 * s),
      child: Row(
        children: [
          Image.asset(
            'assets/images/qurani-white-text.png',
            height: 26 * s,
            color: constants.primaryColor,
          ),
          SizedBox(width: 20 * s),
          if (widget.showSearch)
            Expanded(child: _buildSearchField(s))
          else
            const Spacer(),
          SizedBox(width: 12 * s),
          _buildIconButton(
            Icons.person_outline_rounded,
            () => _navigateToPage(context, 3),
            isSelected: widget.selectedIndex == 3,
            s: s,
          ),
          SizedBox(width: 8 * s),
          _buildIconButton(
            Icons.settings_outlined,
            () => _navigateToPage(context, 6),
            s: s,
          ),
        ],
      ),
    );
  }

  // _buildSearchField tetap sama, tidak ada perubahan
  Widget _buildSearchField(double s) {
    return Container(
      height: 40 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(
          color: _isSearchFocused
              ? constants.primaryColor.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5 * s,
        ),
      ),
      child: TextField(
        controller: widget.searchController,
        focusNode: _searchFocusNode,
        onChanged: widget.onSearchChanged,
        style: TextStyle(
          fontSize: 14 * s,
          color: const Color(0xFF2C2C2C),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search for sura, juz, or page...',
          hintStyle: TextStyle(
            color: const Color(0xFF9E9E9E),
            fontSize: 12 * s,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(10 * s),
            child: Icon(
              Icons.search_rounded,
              color: const Color(0xFF757575),
              size: 20 * s,
            ),
          ),
          suffixIcon: widget.searchController?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF757575),
                    size: 18 * s,
                  ),
                  onPressed: widget.onSearchClear,
                  padding: EdgeInsets.zero,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 10 * s,
            horizontal: 4 * s,
          ),
          isDense: true,
        ),
      ),
    );
  }

  // _buildIconButton tetap sama, tidak ada perubahan
  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
    required double s,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(10 * s),
      child: Container(
        width: 40 * s,
        height: 40 * s,
        decoration: BoxDecoration(
          color: isSelected
              ? constants.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10 * s),
        ),
        child: Icon(
          icon,
          color: isSelected ? constants.primaryColor : const Color(0xFF2C2C2C),
          size: 22 * s,
        ),
      ),
    );
  }

  // REPLACE COMPLETELY: _buildMenuBar dengan scrollable version
  Widget _buildMenuBar(BuildContext context, double s) {
    return Container(
      height: 56 * s,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4 * s),
        child: Row(
          children: _menuItems.map((item) {
            return _buildMenuItem(
              item['label'] as String,
              item['index'] as int,
              s,
            );
          }).toList(),
        ),
      ),
    );
  }

  // UPDATE: _buildMenuItem untuk fixed width items
  Widget _buildMenuItem(String label, int index, double s) {
    final isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _navigateToPage(context, index);
      },
      child: Container(
        width: 100 * s, // Fixed width untuk consistency
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? constants.primaryColor : Colors.transparent,
              width: 2 * s,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15 * s,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? constants.primaryColor
                  : const Color(0xFF9E9E9E),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  // _navigateToPage tetap sama dengan tambahan case baru
  void _navigateToPage(BuildContext context, int index) {
    if (widget.selectedIndex == index) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const HomePage();
        break;
      case 1:
        targetPage = const SurahListPage();
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/goal');
        return;
      case 3:
        targetPage = const ProfilePage();
        break;
      case 4:
        // Bookmark page - implement later
        targetPage = const HomePage(); // Temporary
        break;
      case 5:
        // History page - implement later
        targetPage = const HomePage(); // Temporary
        break;
      case 6:
        // Settings page - implement later
        targetPage = const SettingsPage(); // Temporary
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => targetPage)
    );
  }
}
// REPLACE ProfileAppBar class dengan kode ini
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  
  const ProfileAppBar({
    Key? key,
    this.title = 'Account',
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 406.0;
    
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(left: 12 * s),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20 * s,
            color: Colors.black87,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}