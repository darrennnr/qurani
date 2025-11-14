// lib/screens/main/home/screens/profile_page.dart
import 'package:cuda_qurani/screens/main/home/widgets/app_bar.dart';
import 'package:cuda_qurani/screens/main/home/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const ProfileAppBar(),
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
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildProfileHeader(double width, double height) {
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
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'd',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'dummy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'dummy@gmail.com',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black45,
                  ),
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
              : const BorderSide(color: Color(0xFFF0F0F0), width: 0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
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
              style: const TextStyle(
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
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
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
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFE74C3C),
            ),
          ),
        ),
      ),
    );
  }
}