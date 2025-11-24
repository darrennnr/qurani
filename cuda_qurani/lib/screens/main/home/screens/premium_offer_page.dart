// lib/screens/main/home/screens/premium_offer_page.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';

class PremiumOfferPage extends StatefulWidget {
  const PremiumOfferPage({Key? key}) : super(key: key);

  @override
  State<PremiumOfferPage> createState() => _PremiumOfferPageState();
}

class _PremiumOfferPageState extends State<PremiumOfferPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProfileAppBar(
        title: 'Premium',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildGradientHeader(context),
                  _buildComparisonTable(context),
                  SizedBox(height: AppDesignSystem.space80 * AppDesignSystem.getScaleFactor(context)),
                ],
              ),
            ),
          ),
          _buildSubscribeButton(context),
        ],
      ),
    );
  }

  // ==================== GRADIENT HEADER ====================
  Widget _buildGradientHeader(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D9A7E),
            const Color(0xFF3FCCB8),
            const Color(0xFF52E8D4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDesignSystem.space20 * s,
        AppDesignSystem.space16 * s,
        AppDesignSystem.space20 * s,
        AppDesignSystem.space24 * s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Image.asset(
            'assets/images/qurani-white-text.png',
            height: 28 * s,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
          
          SizedBox(height: AppDesignSystem.space12 * s),
          
          // Title
          Row(
            children: [
              Expanded(
                child: Text(
                  'UPGRADE TO PREMIUM ⭐\nMEMORIZE MORE',
                  style: TextStyle(
                    fontSize: 19 * s,
                    fontWeight: AppTypography.bold,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== COMPARISON TABLE ====================
  Widget _buildComparisonTable(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space16 * s,
        vertical: AppDesignSystem.space16 * s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          _buildTableHeader(context),
          
          // Sections
          _buildSection(
            context,
            title: 'Memorization',
            features: [
              _FeatureRow('Hide Verses', checkFree: true, checkPremium: true),
              _FeatureRow('Mistake Detection', checkFree: false, checkPremium: true),
              _FeatureRow('Tashkeel Mistakes', checkFree: false, checkPremium: true),
              _FeatureRow('Tajweed Mistakes', checkFree: false, checkPremium: true),
              _FeatureRow('Verse Peeking', checkFree: false, checkPremium: true),
              _FeatureRow('Mistake History', checkFree: false, checkPremium: true),
              _FeatureRow('Mistake Frequency', checkFree: false, checkPremium: true),
              _FeatureRow('Mistake Playback', checkFree: false, checkPremium: true),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Recitation',
            features: [
              _FeatureRow('Follow Along', textFree: 'Unlimited', textPremium: 'Unlimited'),
              _FeatureRow('Session Audio', textFree: 'Last Session', textPremium: 'Unlimited'),
              _FeatureRow('Share Audio', textFree: 'Last Session', textPremium: 'Unlimited'),
              _FeatureRow('Session Pausing', checkFree: false, checkPremium: true),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Progress',
            features: [
              _FeatureRow('Streaks', checkFree: true, checkPremium: true),
              _FeatureRow('Session History', textFree: 'Last Session', textPremium: 'Unlimited'),
              _FeatureRow('Analytics', textFree: 'Basic', textPremium: 'Advanced'),
              _FeatureRow('Memorization Progress', textFree: 'Completion', textPremium: 'Mistakes\nOverview'),
              _FeatureRow('Add External Sessions', checkFree: false, checkPremium: true),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Challenges',
            features: [
              _FeatureRow('Goals', textFree: '1', textPremium: 'Unlimited'),
              _FeatureRow('Badges', textFree: 'Earn', textPremium: 'Discover & Earn'),
              _FeatureRow('Notifications', checkFree: false, checkPremium: true),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Audio',
            features: [
              _FeatureRow('Audio Follow Along', textFree: 'Ayah by Ayah', textPremium: 'Word by Word'),
              _FeatureRow('Various Recitations', checkFree: true, checkPremium: true),
              _FeatureRow('Repeat Functionality', checkFree: true, checkPremium: true),
              _FeatureRow('Custom Range', checkFree: true, checkPremium: true),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Search',
            features: [
              _FeatureRow('Voice', checkFree: true, checkPremium: true),
              _FeatureRow('Text', checkFree: true, checkPremium: true),
              _FeatureRow('Recent Search History', textFree: '3', textPremium: '15'),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Mushaf',
            features: [
              _FeatureRow('Indopak / Madani', checkFree: true, checkPremium: true),
              _FeatureRow('Translations /\nTransliteration', checkFree: true, checkPremium: true),
              _FeatureRow('Tafsir', checkFree: true, checkPremium: true),
              _FeatureRow('Bookmarks', checkFree: true, checkPremium: true),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Devices',
            features: [
              _FeatureRow('Devices', textFree: 'Unlimited', textPremium: 'Unlimited'),
              _FeatureRow('Cross Device Syncing', checkFree: true, checkPremium: true),
              _FeatureRow('Language Support', checkFree: true, checkPremium: true),
            ],
          ),
          
          _buildSection(
            context,
            title: 'Advertisement',
            features: [
              _FeatureRow('Advertisement', textFree: 'No ads!', textPremium: 'No ads!'),
            ],
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ==================== TABLE HEADER ====================
  Widget _buildTableHeader(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDesignSystem.space16 * s,
        AppDesignSystem.space16 * s,
        AppDesignSystem.space16 * s,
        AppDesignSystem.space12 * s,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: AppDesignSystem.borderNormal * s,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              'Compare Premium\nFeatures',
              style: TextStyle(
                fontSize: 14 * s,
                fontWeight: AppTypography.medium,
                color: AppColors.textTertiary,
                height: 1.3,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'FREE',
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space12 * s,
                  vertical: AppDesignSystem.space6 * s,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF39C12),
                      const Color(0xFFF5B041),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusRound * s),
                ),
                child: Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontSize: 9 * s,
                    fontWeight: AppTypography.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION BUILDER ====================
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_FeatureRow> features,
    bool isLast = false,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppDesignSystem.space12 * s,
            AppDesignSystem.space12 * s,
            AppDesignSystem.space12 * s,
            AppDesignSystem.space10 * s,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderLight,
                width: AppDesignSystem.borderNormal * s,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14 * s,
              fontWeight: AppTypography.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        
        // Features
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          final isLastFeature = index == features.length - 1;
          
          return _buildFeatureRow(
            context,
            feature: feature,
            showDivider: !isLastFeature || !isLast,
          );
        }).toList(),
      ],
    );
  }

  // ==================== FEATURE ROW ====================
  Widget _buildFeatureRow(
    BuildContext context, {
    required _FeatureRow feature,
    required bool showDivider,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space16 * s,
        vertical: AppDesignSystem.space12 * s,
      ),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderLight,
                  width: AppDesignSystem.borderNormal * s,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          // Feature Name
          Expanded(
            flex: 5,
            child: Text(
              feature.name,
              style: TextStyle(
                fontSize: 14 * s,
                fontWeight: AppTypography.regular,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
          
          // Free Column
          Expanded(
            flex: 2,
            child: Center(
              child: _buildFeatureValue(
                context,
                text: feature.textFree,
                hasCheck: feature.checkFree,
              ),
            ),
          ),
          
          // Premium Column
          Expanded(
            flex: 2,
            child: Center(
              child: _buildFeatureValue(
                context,
                text: feature.textPremium,
                hasCheck: feature.checkPremium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FEATURE VALUE ====================
  Widget _buildFeatureValue(
    BuildContext context, {
    String? text,
    bool hasCheck = false,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    if (hasCheck) {
      return Container(
        width: 24 * s,
        height: 24 * s,
        decoration: BoxDecoration(
          color: const Color(0xFF27AE60).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: const Color(0xFF27AE60),
          size: 16 * s,
        ),
      );
    }
    
    if (text != null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 11 * s,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      );
    }
    
    // Not available - show empty gray circle container only
    return Container(
      width: 24 * s,
      height: 24 * s,
      decoration: BoxDecoration(
        color: AppColors.blackWithOpacity(0.08),
        shape: BoxShape.circle,
      ),
    );
  }

  // ==================== SUBSCRIBE BUTTON ====================
  Widget _buildSubscribeButton(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDesignSystem.space16 * s,
        AppDesignSystem.space10 * s,
        AppDesignSystem.space16 * s,
        AppDesignSystem.space10 * s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: AppDesignSystem.borderNormal * s,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 52 * s,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3FCCB8),
                const Color(0xFF52E8D4),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusXXLarge * s),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3FCCB8).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                AppHaptics.medium();
                _showSubscriptionDialog(context);
              },
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusXXLarge * s),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Center(
                child: Text(
                  'SUBSCRIBE',
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: AppTypography.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SUBSCRIPTION DIALOG ====================
  void _showSubscriptionDialog(BuildContext context) {
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
            children: [
              // Icon
              Container(
                width: 64 * s,
                height: 64 * s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF39C12).withOpacity(0.2),
                      const Color(0xFFF5B041).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  color: const Color(0xFFF39C12),
                  size: 32 * s,
                ),
              ),
              
              AppMargin.gap(context),
              
              // Title
              Text(
                'Subscription Coming Soon',
                style: AppTypography.h3(
                  context,
                  weight: AppTypography.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              AppMargin.gapSmall(context),
              
              // Message
              Text(
                'Premium subscription feature is currently under development. Stay tuned for amazing features!',
                style: AppTypography.body(
                  context,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              AppMargin.gapLarge(context),
              
              // Button
              AppButton(
                text: 'Got it',
                onPressed: () {
                  AppHaptics.light();
                  Navigator.pop(context);
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== FEATURE ROW DATA CLASS ====================
class _FeatureRow {
  final String name;
  final String? textFree;
  final String? textPremium;
  final bool checkFree;
  final bool checkPremium;

  _FeatureRow(
    this.name, {
    this.textFree,
    this.textPremium,
    this.checkFree = false,
    this.checkPremium = false,
  });
}