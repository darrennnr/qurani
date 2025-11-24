// lib/screens/main/home/screens/settings/settings_page.dart
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/dropped_connection.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/hidden_verses.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/language.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/listening.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/marking.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/mistake_feedback.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/recitation.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/reciters_download.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/reminders.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/tafsir_download.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/theme.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/session_start&Stop.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/translation_download.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/data_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showDivider = true,
    Color? iconColor,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignSystem.space16 * s,
          vertical: AppDesignSystem.space12 * s,
        ),
        decoration: showDivider ? AppComponentStyles.divider() : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: AppDesignSystem.iconMedium * s,
              color: iconColor ?? AppColors.textPrimary,
            ),
            SizedBox(width: AppDesignSystem.space16 * s),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14 * s,
                  fontWeight: AppTypography.medium,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppDesignSystem.iconSmall * s,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final s = AppDesignSystem.getScaleFactor(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppDesignSystem.space8 * s),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11 * s,
          fontWeight: AppTypography.bold,
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ProfileAppBar(title: 'Settings'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: AppPadding.horizontal(context, AppDesignSystem.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppMargin.gapLarge(context),

                // ==================== EXPERIENCES ====================
                _buildSectionHeader('EXPERIENCES'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.mic_outlined,
                        label: 'Recitation',
                        onTap: () {
                          AppHaptics.light();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const RecitationPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(-0.03, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(
                                      tween,
                                    );
                                    var fadeAnimation = animation.drive(
                                      Tween(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).chain(CurveTween(curve: curve)),
                                    );

                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration:
                                  AppDesignSystem.durationNormal,
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.play_arrow_rounded,
                        label: 'Listening',
                        onTap: () {
                          AppHaptics.light();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ListeningPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(-0.03, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(
                                      tween,
                                    );
                                    var fadeAnimation = animation.drive(
                                      Tween(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).chain(CurveTween(curve: curve)),
                                    );

                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration:
                                  AppDesignSystem.durationNormal,
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                AppMargin.gapLarge(context),

                // ==================== QURAN APPEARANCE ====================
                _buildSectionHeader('QURAN APPEARANCE'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.menu_book_outlined,
                        label: 'Mushaf Layout',
                        onTap: () {
                          AppHaptics.light();
                          // TODO: Navigate to mushaf layout settings
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.visibility_off_outlined,
                        label: 'Hidden Verses',
                        onTap: () {
                          AppHaptics.light();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const HiddenVersesPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(-0.03, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(
                                      tween,
                                    );
                                    var fadeAnimation = animation.drive(
                                      Tween(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).chain(CurveTween(curve: curve)),
                                    );

                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration:
                                  AppDesignSystem.durationNormal,
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.edit_outlined,
                        label: 'Marking',
                        onTap: () {
                          AppHaptics.light();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const MarkingPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(-0.03, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(
                                      tween,
                                    );
                                    var fadeAnimation = animation.drive(
                                      Tween(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).chain(CurveTween(curve: curve)),
                                    );

                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration:
                                  AppDesignSystem.durationNormal,
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                AppMargin.gapLarge(context),

                // ==================== APPEARANCE ====================
                _buildSectionHeader('APPEARANCE'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        onTap: () {
                          AppHaptics.light();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LanguagePage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(-0.03, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(
                                      tween,
                                    );
                                    var fadeAnimation = animation.drive(
                                      Tween(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).chain(CurveTween(curve: curve)),
                                    );

                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration:
                                  AppDesignSystem.durationNormal,
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.brightness_6_outlined,
                        label: 'Theme',
                        onTap: () {
                          AppHaptics.light();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ThemePage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(-0.03, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(
                                      tween,
                                    );
                                    var fadeAnimation = animation.drive(
                                      Tween(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).chain(CurveTween(curve: curve)),
                                    );

                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration:
                                  AppDesignSystem.durationNormal,
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                AppMargin.gapLarge(context),

                // ==================== NOTIFICATIONS ====================
                _buildSectionHeader('NOTIFICATIONS'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    label: 'Reminders',
                    onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const RemindersPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                    showDivider: false,
                  ),
                ),

                AppMargin.gapLarge(context),

                // ==================== SOUNDS & HAPTICS ====================
                _buildSectionHeader('SOUNDS & HAPTICS'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.error_outline,
                        label: 'Mistake Feedback',
onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const MistakeFeedbackPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                      ),
                      _buildSettingItem(
                        icon: Icons.mic_outlined,
                        label: 'Session Start & Stop',
onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SessionStartStopPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                      ),
                      _buildSettingItem(
                        icon: Icons.wifi_off_outlined,
                        label: 'Dropped Connection',
                        onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const DroppedConnectionPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                AppMargin.gapLarge(context),

                // ==================== DOWNLOADS ====================
                _buildSectionHeader('DOWNLOADS'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.record_voice_over_outlined,
                        label: 'Reciters',
                        onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const RecitersDownloadPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                      ),
                      _buildSettingItem(
                        icon: Icons.translate_outlined,
                        label: 'Translations',
                        onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const TranslationDownloadPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                      ),
                      _buildSettingItem(
                        icon: Icons.book_outlined,
                        label: 'Tafsir',
                        onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const TafsirDownloadPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                AppMargin.gapLarge(context),

                // ==================== PRIVACY ====================
                _buildSectionHeader('PRIVACY'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.lock_outline,
                        label: 'Data Usage',
                        onTap: () {
                      AppHaptics.light();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const DataUsagePage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-0.03, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                var fadeAnimation = animation.drive(
                                  Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: curve)),
                                );

                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: AppDesignSystem.durationNormal,
                        ),
                      );
                    },
                      ),
                      _buildSettingItem(
                        icon: Icons.delete_outline,
                        label: 'Delete All Audio Data',
                        iconColor: AppColors.error,
                        onTap: () {
                          AppHaptics.medium();
                          _showDeleteAudioDialog();
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                AppMargin.customGap(context, AppDesignSystem.space80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAudioDialog() {
    final s = AppDesignSystem.getScaleFactor(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge * s),
        ),
        elevation: AppDesignSystem.elevationHigh,
        child: Container(
          padding: AppPadding.all(context, AppDesignSystem.space24),
          decoration: AppComponentStyles.dialogDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon & Title
              Row(
                children: [
                  Container(
                    width: 48 * s,
                    height: 48 * s,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusMedium * s,
                      ),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: AppDesignSystem.iconLarge * s,
                    ),
                  ),
                  AppMargin.gapH(context),
                  Expanded(
                    child: Text(
                      'Delete All Audio Data',
                      style: AppTypography.h3(
                        context,
                        weight: AppTypography.bold,
                      ),
                    ),
                  ),
                ],
              ),

              AppMargin.gap(context),

              // Content
              Text(
                'Are you sure you want to delete all audio recordings? This action cannot be undone and will permanently remove all your recitation history.',
                style: AppTypography.body(
                  context,
                  color: AppColors.textSecondary,
                ),
              ),

              AppMargin.gapLarge(context),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppTextButton(
                    text: 'Cancel',
                    onPressed: () {
                      AppHaptics.light();
                      Navigator.pop(context);
                    },
                    color: AppColors.textTertiary,
                  ),
                  AppMargin.gapHSmall(context),
                  AppButton(
                    text: 'Delete',
                    backgroundColor: AppColors.error,
                    textColor: Colors.white,
                    onPressed: () {
                      AppHaptics.heavy();
                      Navigator.pop(context);
                      // TODO: Implement delete audio data
                      ScaffoldMessenger.of(context).showSnackBar(
                        AppComponentStyles.successSnackBar(
                          message: 'Audio data deleted successfully',
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
