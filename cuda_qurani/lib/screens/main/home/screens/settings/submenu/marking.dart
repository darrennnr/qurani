// lib/screens/main/home/screens/settings/submenu/marking.dart
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/tajweed_rules.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';
import 'package:cuda_qurani/providers/premium_provider.dart';
import 'package:cuda_qurani/models/premium_features.dart';
import 'package:cuda_qurani/core/widgets/premium_dialog.dart';

/// ==================== MARKING SETTINGS PAGE ====================
/// Halaman untuk mengatur pengaturan marking/penandaan dalam pembacaan Quran

class MarkingPage extends StatefulWidget {
  const MarkingPage({Key? key}) : super(key: key);

  @override
  State<MarkingPage> createState() => _MarkingPageState();
}

class _MarkingPageState extends State<MarkingPage> {
  // Default states untuk semua toggle (dummy state)
  bool _showTajweedColors = false;
  bool _highlightMistakeHistory = false;
  bool _colorSimilarPhrases = false;

  void _toggleShowTajweedColors(bool value) {
    setState(() {
      _showTajweedColors = value;
    });
    AppHaptics.selection();

    // TODO: Implement toggle logic
  }

  void _toggleHighlightMistakeHistory(bool value) {
    setState(() {
      _highlightMistakeHistory = value;
    });
    AppHaptics.selection();

    // TODO: Implement toggle logic
  }

  void _toggleColorSimilarPhrases(bool value) {
    setState(() {
      _colorSimilarPhrases = value;
    });
    AppHaptics.selection();

    // TODO: Implement toggle logic
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(title: 'Marking'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tajweed Section
                Text(
                  'Tajweed',
                  style: TextStyle(
                    fontSize: 14 * s * 0.9,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Show Tajweed Colors Container
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space16 * s * 0.9,
                    vertical: AppDesignSystem.space16 * s * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMedium * s * 0.9,
                    ),
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
                          Text(
                            'ج',
                            style: TextStyle(
                              fontSize: 20 * s * 0.9,
                              fontWeight: AppTypography.semiBold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                          Expanded(
                            child: Text(
                              'Show Tajweed Colors',
                              style: TextStyle(
                                fontSize: 16 * s * 0.9,
                                fontWeight: AppTypography.regular,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Info icon
                          InkWell(
                            onTap: () {
                              AppHaptics.light();
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const TajweedRulesPage(),
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
                            borderRadius: BorderRadius.circular(
                              100,
                            ), // karena circle
                            child: Container(
                              width: 24 * s * 0.9,
                              height: 24 * s * 0.9,
                              margin: EdgeInsets.only(
                                right: AppDesignSystem.space8 * s * 0.9,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.borderMedium,
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: 14 * s * 0.9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          // 🔒 PREMIUM GATED
                          _buildPremiumSwitch(
                            context,
                            feature: PremiumFeature.tajweedColors,
                            value: _showTajweedColors,
                            onChanged: _toggleShowTajweedColors,
                          ),
                        ],
                      ),
                      SizedBox(height: AppDesignSystem.space8 * s * 0.9),
                      Padding(
                        padding: EdgeInsets.only(left: 32 * s * 0.9),
                        child: Text(
                          'Color letters with distinct colors according to Tajweed rules to make it easier to know which rules to apply while reciting.',
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

                SizedBox(height: AppDesignSystem.space24 * s * 0.9),

                // Mistakes Section
                Text(
                  'Mistakes',
                  style: TextStyle(
                    fontSize: 14 * s * 0.9,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Highlight mistake history Container
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space16 * s * 0.9,
                    vertical: AppDesignSystem.space16 * s * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMedium * s * 0.9,
                    ),
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
                            Icons.edit,
                            size: 20 * s * 0.9,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                          Expanded(
                            child: Text(
                              'Highlight mistake history',
                              style: TextStyle(
                                fontSize: 16 * s * 0.9,
                                fontWeight: AppTypography.regular,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // 🔒 PREMIUM GATED
                          _buildPremiumSwitch(
                            context,
                            feature: PremiumFeature.mistakeHistory,
                            value: _highlightMistakeHistory,
                            onChanged: _toggleHighlightMistakeHistory,
                          ),
                        ],
                      ),
                      SizedBox(height: AppDesignSystem.space8 * s * 0.9),
                      Padding(
                        padding: EdgeInsets.only(left: 32 * s * 0.9),
                        child: Text(
                          'Highlight the mistakes you commonly make according to how often you\'ve been making them.',
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

                SizedBox(height: AppDesignSystem.space24 * s * 0.9),

                // Similar Phrases Section
                Text(
                  'Similar Phrases',
                  style: TextStyle(
                    fontSize: 14 * s * 0.9,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Color similar phrases Container
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space16 * s * 0.9,
                    vertical: AppDesignSystem.space16 * s * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMedium * s * 0.9,
                    ),
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
                            Icons.palette_outlined,
                            size: 20 * s * 0.9,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                          Expanded(
                            child: Text(
                              'Color similar phrases',
                              style: TextStyle(
                                fontSize: 16 * s * 0.9,
                                fontWeight: AppTypography.regular,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Switch(
                            value: _colorSimilarPhrases,
                            onChanged: _toggleColorSimilarPhrases,
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
                          'Color similar phrases (Mutashabihat) with distinct colors to identify patterns and avoid confusing different verses.',
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
        ),
      ),
    );
  }

  /// 🔒 Helper untuk build switch dengan premium gating
  Widget _buildPremiumSwitch(
    BuildContext context, {
    required PremiumFeature feature,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final premium = context.watch<PremiumProvider>();
    final canAccess = premium.canAccess(feature);
    final s = AppDesignSystem.getScaleFactor(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PRO badge jika tidak bisa akses
        if (!canAccess)
          GestureDetector(
            onTap: () => showPremiumFeatureDialog(context, feature),
            child: Container(
              margin: EdgeInsets.only(right: 8 * s),
              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4 * s),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 10 * s, color: const Color(0xFFF39C12)),
                  SizedBox(width: 2 * s),
                  Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 8 * s,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF39C12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Switch
        Switch(
          value: canAccess ? value : false,
          onChanged: canAccess
              ? onChanged
              : (_) => showPremiumFeatureDialog(context, feature),
          activeColor: const Color(0xFF4CAF50),
          inactiveThumbColor: AppColors.borderMedium,
          inactiveTrackColor: AppColors.borderLight,
        ),
      ],
    );
  }
}
