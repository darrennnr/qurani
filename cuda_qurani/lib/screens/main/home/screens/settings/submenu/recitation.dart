// lib/screens/main/home/screens/settings/submenu/recitation.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';

/// ==================== RECITATION SETTINGS PAGE ====================
/// Halaman untuk mengatur pengaturan recitation/pembacaan Quran

class RecitationPage extends StatefulWidget {
  const RecitationPage({Key? key}) : super(key: key);

  @override
  State<RecitationPage> createState() => _RecitationPageState();
}

class _RecitationPageState extends State<RecitationPage> {
  // Default states untuk semua toggle (dummy state)
  bool _detectMistakes = true;
  bool _detectTashkeelMistakes = true;
  bool _dontProgressUntilFixed = false;
  bool _resumableSessions = false;

  void _toggleDetectMistakes(bool value) {
    setState(() {
      _detectMistakes = value;
    });
    AppHaptics.selection();
    
    // TODO: Implement toggle logic
  }

  void _toggleDetectTashkeel(bool value) {
    setState(() {
      _detectTashkeelMistakes = value;
    });
    AppHaptics.selection();
    
    // TODO: Implement toggle logic
  }

  void _toggleDontProgress(bool value) {
    setState(() {
      _dontProgressUntilFixed = value;
    });
    AppHaptics.selection();
    
    // TODO: Implement toggle logic
  }

  void _toggleResumableSessions(bool value) {
    setState(() {
      _resumableSessions = value;
    });
    AppHaptics.selection();
    
    // TODO: Implement toggle logic
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(
        title: 'Recitation',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mistake Detection Section
                Text(
                  'Mistake Detection',
                  style: TextStyle(
                    fontSize: 14 * s * 0.9,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Mistake Detection Container
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s * 0.9),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.0 * s * 0.9,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Detect mistakes
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignSystem.space16 * s * 0.9,
                          vertical: AppDesignSystem.space16 * s * 0.4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 20 * s * 0.9,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                            Expanded(
                              child: Text(
                                'Detect mistakes',
                                style: TextStyle(
                                  fontSize: 16 * s * 0.9,
                                  fontWeight: AppTypography.regular,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: _detectMistakes,
                              onChanged: _toggleDetectMistakes,
                              activeColor: Color(0xFF4CAF50),
                              inactiveThumbColor: AppColors.borderMedium,
                              inactiveTrackColor: AppColors.borderLight,
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Divider(
                        height: 1,
                        thickness: 1 * s * 0.9,
                        color: AppColors.borderLight,
                      ),

                      // Detect Tashkeel (diacritics) mistakes
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignSystem.space16 * s * 0.9,
                          vertical: AppDesignSystem.space16 * s * 0.9,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ت',
                                  style: TextStyle(
                                    fontSize: 20 * s * 0.9,
                                    fontWeight: AppTypography.semiBold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                                Expanded(
                                  child: Text(
                                    'Detect Tashkeel (diacritics) mistakes',
                                    style: TextStyle(
                                      fontSize: 16 * s * 0.9,
                                      fontWeight: AppTypography.regular,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _detectTashkeelMistakes,
                                  onChanged: _toggleDetectTashkeel,
                                  activeColor: Color(0xFF4CAF50),
                                  inactiveThumbColor: AppColors.borderMedium,
                                  inactiveTrackColor: AppColors.borderLight,
                                ),
                              ],
                            ),
                            SizedBox(height: AppDesignSystem.space8 * s * 0.9),
                            Padding(
                              padding: EdgeInsets.only(left: 32 * s * 0.9),
                              child: Text(
                                'Tashkeel mistake detection is a new feature and may miss some of your tashkeel mistakes.',
                                style: TextStyle(
                                  fontSize: 13 * s * 0.9,
                                  fontWeight: AppTypography.regular,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Divider(
                        height: 1,
                        thickness: 1 * s * 0.9,
                        color: AppColors.borderLight,
                      ),

                      // Don't progress until mistake is fixed
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignSystem.space16 * s * 0.9,
                          vertical: AppDesignSystem.space16 * s * 0.9,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  size: 20 * s * 0.9,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                                Expanded(
                                  child: Text(
                                    'Don\'t progress until mistake is fixed',
                                    style: TextStyle(
                                      fontSize: 16 * s * 0.9,
                                      fontWeight: AppTypography.regular,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _dontProgressUntilFixed,
                                  onChanged: _toggleDontProgress,
                                  activeColor: Color(0xFF4CAF50),
                                  inactiveThumbColor: AppColors.borderMedium,
                                  inactiveTrackColor: AppColors.borderLight,
                                ),
                              ],
                            ),
                            SizedBox(height: AppDesignSystem.space8 * s * 0.9),
                            Padding(
                              padding: EdgeInsets.only(left: 32 * s * 0.9),
                              child: Text(
                                'Require every single word to be recited correctly before moving on to the next word.',
                                style: TextStyle(
                                  fontSize: 13 * s * 0.9,
                                  fontWeight: AppTypography.regular,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppDesignSystem.space24 * s * 0.9),

                // Sessions Section
                Text(
                  'Sessions',
                  style: TextStyle(
                    fontSize: 14 * s * 0.9,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Resumable Sessions Container
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space16 * s * 0.9,
                    vertical: AppDesignSystem.space16 * s * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s * 0.9),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.0 * s * 0.9,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pause_circle_outline,
                            size: 20 * s * 0.9,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                          Expanded(
                            child: Text(
                              'Resumable Sessions',
                              style: TextStyle(
                                fontSize: 16 * s * 0.9,
                                fontWeight: AppTypography.regular,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Switch(
                            value: _resumableSessions,
                            onChanged: _toggleResumableSessions,
                            activeColor: Color(0xFF4CAF50),
                            inactiveThumbColor: AppColors.borderMedium,
                            inactiveTrackColor: AppColors.borderLight,
                          ),
                        ],
                      ),
                      SizedBox(height: AppDesignSystem.space8 * s * 0.9),
                      Padding(
                        padding: EdgeInsets.only(left: 32 * s * 0.9),
                        child: Text(
                          'Control whether to resume the current session, or start a new session every time recording is started.',
                          style: TextStyle(
                            fontSize: 13 * s * 0.9,
                            fontWeight: AppTypography.regular,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                                            SizedBox(height: AppDesignSystem.space8 * s * 0.9),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}