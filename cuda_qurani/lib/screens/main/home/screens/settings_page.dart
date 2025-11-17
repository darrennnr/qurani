// lib/screens/main/home/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 406.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const ProfileAppBar(title: 'Settings'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20 * s),
                _buildSectionHeader('Experiences', s),
                SizedBox(height: 12 * s),
                _buildSettingsCard(
                  s,
                  children: [
                    _buildSettingItem(
                      icon: Icons.mic_outlined,
                      label: 'Recitation',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to recitation settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.play_arrow_rounded,
                      label: 'Listening',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to listening settings
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),
                _buildSectionHeader('Quran Appearance', s),
                SizedBox(height: 12 * s),
                _buildSettingsCard(
                  s,
                  children: [
                    _buildSettingItem(
                      icon: Icons.menu_book_outlined,
                      label: 'Mushaf Layout',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to mushaf layout settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.visibility_off_outlined,
                      label: 'Hidden Verses',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to hidden verses settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.edit_outlined,
                      label: 'Marking',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to marking settings
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),
                _buildSectionHeader('Appearance', s),
                SizedBox(height: 12 * s),
                _buildSettingsCard(
                  s,
                  children: [
                    _buildSettingItem(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to language settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.brightness_6_outlined,
                      label: 'Theme',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to theme settings
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),
                _buildSectionHeader('Notifications', s),
                SizedBox(height: 12 * s),
                _buildSettingsCard(
                  s,
                  children: [
                    _buildSettingItem(
                      icon: Icons.notifications_outlined,
                      label: 'Reminders',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to reminders settings
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),
                _buildSectionHeader('Sounds & Haptics', s),
                SizedBox(height: 12 * s),
                _buildSettingsCard(
                  s,
                  children: [
                    _buildSettingItem(
                      icon: Icons.error_outline,
                      label: 'Mistake Feedback',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to mistake feedback settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.mic_outlined,
                      label: 'Session Start & Stop',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to session settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.wifi_off_outlined,
                      label: 'Dropped Connection',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to connection settings
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),
                _buildSectionHeader('Downloads', s),
                SizedBox(height: 12 * s),
                _buildSettingsCard(
                  s,
                  children: [
                    _buildSettingItem(
                      icon: Icons.record_voice_over_outlined,
                      label: 'Reciters',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to reciters settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.translate_outlined,
                      label: 'Translations',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to translations settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.book_outlined,
                      label: 'Tafsir',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to tafsir settings
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24 * s),
                _buildSectionHeader('Privacy', s),
                SizedBox(height: 12 * s),
                _buildSettingsCard(
                  s,
                  children: [
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      label: 'Data Usage',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to data usage settings
                      },
                    ),
                    _buildDivider(s),
                    _buildSettingItem(
                      icon: Icons.delete_outline,
                      label: 'Delete All Audio Data',
                      s: s,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showDeleteAudioDialog();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 100 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double s) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18 * s,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSettingsCard(double s, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required double s,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * s),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 16 * s),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22 * s,
              color: Colors.black87,
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16 * s,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * s),
      child: Divider(
        height: 1 * s,
        thickness: 1 * s,
        color: const Color(0xFFF0F0F0),
      ),
    );
  }

  void _showDeleteAudioDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete All Audio Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete all audio recordings? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete audio data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio data deleted successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: constants.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}