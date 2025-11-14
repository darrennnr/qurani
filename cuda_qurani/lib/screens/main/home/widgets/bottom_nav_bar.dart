// lib/screens/main/home/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/profile_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/surah_list_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final double? width;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    this.width,
  }) : super(key: key);

  void _onBottomNavTap(BuildContext context, int index) {
    if (selectedIndex == index) return;

    HapticFeedback.lightImpact();

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
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Home', 0),
              _buildNavItem(context, Icons.menu_book_rounded, 'Quran', 1),
              _buildNavItem(context, Icons.flag_rounded, 'Goal', 2),
              _buildNavItem(context, Icons.person_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onBottomNavTap(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? constants.primaryColor : Colors.black26,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? constants.primaryColor : Colors.black26,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}