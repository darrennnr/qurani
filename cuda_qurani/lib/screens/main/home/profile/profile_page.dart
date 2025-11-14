// lib/screens/main/home/profile/profile_page.dart
import 'package:cuda_qurani/screens/main/home/home_page.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;
import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;

  void _onBottomNavTap(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      HapticFeedback.lightImpact();

      // Navigation logic with pushReplacement
      switch (index) {
        case 0:
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/quran');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/goal');
          break;
        case 3:
          // Already on Profile
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(width, height),
                const SizedBox(height: 24),
                _buildInfoRow('Joined', '08/05/2025', width),
                Divider(height: 1, color: const Color(0xFFF0F0F0)),
                _buildInfoRow('Subscription Status', 'Free Plan', width),
                const SizedBox(height: 20),
                _buildActionButton('SWITCH ACCOUNT', width, false),
                const SizedBox(height: 12),
                _buildActionButton('LOG OUT', width, false),
                const SizedBox(height: 28),
                _buildMenuItem('About Qurani', Icons.info_outline, width),
                _buildMenuItem('Request a Feature', Icons.chat_bubble_outline, width),
                _buildMenuItem('Help Center', Icons.help_outline, width),
                _buildMenuItem('Share Application', Icons.share_outlined, width),
                _buildMenuItem('Rate Application', Icons.star_outline, width),
                _buildMenuItem('Terms of Service', Icons.arrow_forward_ios, width),
                _buildMenuItem('Privacy Policy', Icons.arrow_forward_ios, width),
                const SizedBox(height: 16),
                _buildDeleteAccount(width),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildMinimalBottomNav(width),
    );
  }

  Widget _buildProfileHeader(double width, double height) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    
    // Get first letter of name or email for avatar
    String avatarLetter = 'U';
    String displayName = 'User';
    String displayEmail = 'user@email.com';
    
    if (user != null) {
      displayEmail = user.email;
      if (user.fullName != null && user.fullName!.isNotEmpty) {
        displayName = user.fullName!;
        avatarLetter = user.fullName![0].toUpperCase();
      } else {
        displayName = user.email.split('@')[0];
        // Capitalize first letter
        if (displayName.isNotEmpty) {
          displayName = displayName[0].toUpperCase() + displayName.substring(1);
        }
        avatarLetter = displayName[0].toUpperCase();
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  constants.primaryColor.withOpacity(0.2),
                  constants.primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: constants.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double width) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: label == 'Joined' 
            ? BorderSide.none 
            : BorderSide(color: const Color(0xFFF0F0F0), width: 0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, double width, bool isLogout) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String label, IconData icon, double width) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            Icon(
              icon,
              size: 16,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccount(double width) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFE74C3C),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomNav(double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0, width),
              _buildNavItem(Icons.menu_book_rounded, 'Quran', 1, width),
              _buildNavItem(Icons.flag_rounded, 'Goal', 2, width),
              _buildNavItem(Icons.person_rounded, 'Profile', 3, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, double width) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onBottomNavTap(index),
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