// lib/screens/main/home/screens/achievement_page.dart

import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';

// Model for Achievement Data
class AchievementModel {
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final Color color;
  final bool isEarned;
  final bool isLocked;
  final String? earnedDate;
  final int? count;
  final String? badgeType; // e.g., "AI", "Streak", "Social"

  AchievementModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.color,
    this.isEarned = false,
    this.isLocked = true,
    this.earnedDate,
    this.count,
    this.badgeType,
  });
}

class AchievementPage extends StatefulWidget {
  const AchievementPage({Key? key}) : super(key: key);

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  // ==================== DUMMY DATA ====================

  // The "Latest Badge" shown at the top
  final AchievementModel _latestBadge = AchievementModel(
    title: 'Qurani',
    subtitle: 'Start Memorizing',
    badgeType: 'Hafidz',
    description: 'Enable Memorization Mode in the Quran reading experience.',
    emoji: '🧠',
    color: const Color(0xFF00C853), // Specific badge color
    isEarned: true,
    isLocked: false,
    earnedDate: 'NOV 25, 2025',
  );

  final List<AchievementModel> _earnedBadges = [
    AchievementModel(
      title: 'Start Memorizing',
      subtitle: 'Begin journey',
      description: 'Start your first memorization session.',
      emoji: '🧠',
      color: Colors.blue,
      isEarned: true,
      isLocked: false,
    ),
    AchievementModel(
      title: 'Customize',
      subtitle: 'Personalize App',
      description: 'Change the theme or font settings.',
      emoji: '⚙️',
      color: Colors.orange,
      isEarned: true,
      isLocked: false,
    ),
    AchievementModel(
      title: 'Remind Me 1',
      subtitle: 'First Reminder',
      description: 'Set your first prayer or reading reminder.',
      emoji: '🔖',
      color: Colors.redAccent,
      isEarned: true,
      isLocked: false,
      count: 1,
    ),
    AchievementModel(
      title: 'Committed 1',
      subtitle: 'Consistency',
      description: 'Read Quran for 3 consecutive days.',
      emoji: '📖',
      color: Colors.teal,
      isEarned: true,
      isLocked: false,
      count: 1,
    ),
  ];

  final List<AchievementModel> _remainingBadges = [
    AchievementModel(
      title: 'Super Reciter 1',
      subtitle: '20 min',
      description: 'Recite for 20 minutes in one session.',
      emoji: '⏱️',
      color: Colors.purple,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Super Reciter 2',
      subtitle: '1 Hour',
      description: 'Recite for 1 hour total.',
      emoji: '⏱️',
      color: Colors.purple,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Super Reciter 3',
      subtitle: '5 Hours',
      description: 'Recite for 5 hours total.',
      emoji: '⏱️',
      color: Colors.purple,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Committed 2',
      subtitle: '7 Days',
      description: 'Read everyday for a week.',
      emoji: '📅',
      color: Colors.teal,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Committed 3',
      subtitle: '30 Days',
      description: 'Read everyday for a month.',
      emoji: '📅',
      color: Colors.teal,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Socially Savvy 1',
      subtitle: 'Share',
      description: 'Share an ayah with a friend.',
      emoji: '🤝',
      color: Colors.blueGrey,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Socially Savvy 2',
      subtitle: 'Invite',
      description: 'Invite 3 friends to the app.',
      emoji: '🤝',
      color: Colors.blueGrey,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Socially Savvy 3',
      subtitle: 'Community',
      description: 'Join a group challenge.',
      emoji: '🤝',
      color: Colors.blueGrey,
      isLocked: true,
    ),
    AchievementModel(
      title: 'People of the Cave',
      subtitle: 'Friday',
      description: 'Read Surah Al-Kahf on Friday.',
      emoji: '⛰️',
      color: Colors.brown,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Healing',
      subtitle: 'Shifa',
      description: 'Complete the verses of healing.',
      emoji: '💊',
      color: Colors.green,
      isLocked: true,
    ),
    AchievementModel(
      title: 'Prophetic Completion',
      subtitle: 'Khatam',
      description: 'Complete the whole Quran.',
      emoji: '🕌',
      color: Colors.indigo,
      isLocked: true,
    ),
    AchievementModel(
      title: 'In the Shade',
      subtitle: 'Reflection',
      description: 'Read Tafsir for 30 ayahs.',
      emoji: '🌴',
      color: Colors.amber,
      isLocked: true,
    ),
    AchievementModel(
      title: 'The Seat',
      subtitle: 'Ayat-ul-kursi',
      description: 'Memorize Ayat-ul-Kursi.',
      emoji: '🪑',
      color: Colors.deepPurple,
      isLocked: true,
    ),
    AchievementModel(
      title: 'The Heart',
      subtitle: 'Yaseen',
      description: 'Read Surah Yaseen.',
      emoji: '❤️',
      color: Colors.red,
      isLocked: true,
    ),
    AchievementModel(
      title: 'The Light',
      subtitle: 'An-Nur',
      description: 'Read Surah An-Nur.',
      emoji: '💡',
      color: Colors.yellow,
      isLocked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Get scaling factor for responsiveness
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ProfileAppBar(title: 'Achievements', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: AppDesignSystem.space40 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLatestBadgeSection(context, s),
              AppMargin.gapXLarge(context),
              _buildEarnedBadgesSection(context, s),
              AppMargin.gapLarge(context),
              _buildInfoBanner(context, s),
              _buildRemainingBadgesSection(context, s),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LATEST BADGE CARD (HERO) ====================
  Widget _buildLatestBadgeSection(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.space20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppDesignSystem.space16 * s),
          Text(
            'Latest Badge',
            style: AppTypography.h3(context, weight: AppTypography.bold),
          ),
          SizedBox(height: AppDesignSystem.space12 * s),

          // Main Hero Card
          Container(
            decoration: AppComponentStyles.card(
              color: AppColors.surface,
              shadow: true,
              borderRadius: AppDesignSystem.radiusLarge * s,
              borderColor: AppColors.borderLight,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  AppHaptics.light();
                  _showBadgeDetails(context, _latestBadge, s);
                },
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusLarge * s,
                ),
                child: Column(
                  children: [
                    // Top Content
                    Padding(
                      padding: EdgeInsets.all(AppDesignSystem.space20 * s),
                      child: Column(
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/qurani-white-text.png',
                                    height: 25 * s,
                                    color: AppColors.primary,
                                    fit: BoxFit.contain,
                                  ),
                                  if (_latestBadge.badgeType != null)
                                    Container(
                                      padding: EdgeInsets.only(left: 4 * s),
                                      child: Text(
                                        _latestBadge.badgeType!,
                                        style: AppTypography.bodyLarge(
                                          context,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Icon(
                                Icons.share_outlined,
                                color: AppColors.textTertiary,
                                size: AppDesignSystem.iconMedium * s,
                              ),
                            ],
                          ),

                          // Central Avatar with Glow
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow Effect
                              Container(
                                width: 180 * s,
                                height: 180 * s,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      _latestBadge.color.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.3, 1.0],
                                  ),
                                ),
                              ),
                              // Circle Avatar
                              Container(
                                width: 125 * s,
                                height: 125 * s,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1 * s,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowLight,
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _latestBadge.emoji,
                                  style: TextStyle(fontSize: 55 * s),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppDesignSystem.space16 * s),

                          // Badge Label Chip
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDesignSystem.space12 * s,
                              vertical: AppDesignSystem.space4 * s,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              border: Border.all(color: AppColors.borderMedium),
                              borderRadius: BorderRadius.circular(
                                AppDesignSystem.radiusSmall * s,
                              ),
                            ),
                            child: Text(
                              _latestBadge.subtitle,
                              style: AppTypography.caption(
                                context,
                                color: AppColors.textPrimary,
                                weight: AppTypography.medium,
                              ),
                            ),
                          ),

                          SizedBox(height: AppDesignSystem.space16 * s),

                          // Description
                          Text(
                            _latestBadge.description,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(
                              context,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Divider(height: 1, color: AppColors.borderLight),

                    // Footer
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignSystem.space20 * s,
                        vertical: AppDesignSystem.space12 * s,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STATUS',
                                style: AppTypography.captionSmall(
                                  context,
                                  weight: AppTypography.bold,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              SizedBox(height: 2 * s),
                              Text(
                                'EARNED ON ${_latestBadge.earnedDate}',
                                style: AppTypography.caption(
                                  context,
                                  weight: AppTypography.bold,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          // Verification Badge
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: 24 * s,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EARNED BADGES SECTION ====================
  Widget _buildEarnedBadgesSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space20 * s,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earned Badges',
                style: AppTypography.h3(context, weight: AppTypography.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space8 * s,
                  vertical: 2 * s,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: BorderRadius.circular(
                    AppDesignSystem.radiusLarge * s,
                  ),
                ),
                child: Text(
                  '${_earnedBadges.length}',
                  style: AppTypography.captionSmall(
                    context,
                    color: AppColors.successDark,
                    weight: AppTypography.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDesignSystem.space16 * s),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space16 * s,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _earnedBadges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.70, // Optimized for spacing
              crossAxisSpacing: AppDesignSystem.space8 * s,
              mainAxisSpacing: AppDesignSystem.space16 * s,
            ),
            itemBuilder: (context, index) {
              return _buildBadgeItem(context, _earnedBadges[index], s);
            },
          ),
        ),
      ],
    );
  }

  // ==================== INFO BANNER ====================
  Widget _buildInfoBanner(BuildContext context, double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppDesignSystem.space12 * s,
        horizontal: AppDesignSystem.space20 * s,
      ),
      margin: EdgeInsets.only(bottom: AppDesignSystem.space24 * s),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 14 * s,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: AppDesignSystem.space8 * s),
          Text(
            'TAP BADGE TO VIEW REQUIREMENTS',
            style: AppTypography.captionSmall(
              context,
              weight: AppTypography.bold,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REMAINING BADGES SECTION ====================
  Widget _buildRemainingBadgesSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space20 * s,
          ),
          child: Text(
            'Remaining Badges',
            style: AppTypography.h3(context, weight: AppTypography.bold),
          ),
        ),
        SizedBox(height: AppDesignSystem.space16 * s),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space16 * s,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _remainingBadges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.70,
              crossAxisSpacing: AppDesignSystem.space8 * s,
              mainAxisSpacing: AppDesignSystem.space16 * s,
            ),
            itemBuilder: (context, index) {
              return _buildBadgeItem(context, _remainingBadges[index], s);
            },
          ),
        ),
      ],
    );
  }

  // ==================== BADGE ITEM WIDGET ====================
  Widget _buildBadgeItem(
    BuildContext context,
    AchievementModel item,
    double s,
  ) {
    return GestureDetector(
      onTap: () {
        AppHaptics.light();
        _showBadgeDetails(context, item, s);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge Icon Container
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Main Circular Shape
              Container(
                width: 72 * s,
                height: 72 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Color logic: if locked, gray. if earned, item color.
                  color: item.isLocked
                      ? AppColors.surfaceContainerHigh
                      : item.color,
                  gradient: !item.isLocked
                      ? LinearGradient(
                          colors: [item.color, item.color.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  boxShadow: !item.isLocked
                      ? [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Emoji
                    Opacity(
                      // Locked: 0.5 opacity (visible but muted). Unlocked: 1.0
                      opacity: item.isLocked ? 0.5 : 1.0,
                      child: Text(
                        item.emoji,
                        style: TextStyle(
                          fontSize: 32 * s,
                          // If locked, apply a grayscale filter effect conceptually by mixing color?
                          // Since it's a string emoji, we just rely on opacity and container background.
                        ),
                      ),
                    ),

                    // Lock Overlay (Small icon in center)
                    if (item.isLocked)
                      Container(
                        padding: EdgeInsets.all(4 * s),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: AppColors.textPrimary,
                          size: 16 * s,
                        ),
                      ),
                  ],
                ),
              ),

              // Count Badge (Notification style)
              if (item.count != null && !item.isLocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4 * s),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 2 * s,
                      ),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 22 * s,
                      minHeight: 22 * s,
                    ),
                    child: Center(
                      child: Text(
                        item.count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * s,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppDesignSystem.space8 * s),

          // Badge Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0 * s),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(
                context,
                weight: AppTypography.semiBold,
                color: item.isLocked
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
          ),

          SizedBox(height: 2 * s),

          // Badge Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0 * s),
            child: Text(
              item.subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionSmall(
                context,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BADGE DETAIL DIALOG ====================
  void _showBadgeDetails(
    BuildContext context,
    AchievementModel item,
    double s,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDesignSystem.radiusLarge * s,
            ),
          ),
          elevation: AppDesignSystem.elevationMedium,
          backgroundColor: AppColors.surface,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppDesignSystem.radiusLarge * s,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Title + Close)
                Padding(
                  padding: EdgeInsets.all(AppDesignSystem.space20 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.titleLarge(
                                context,
                                weight: AppTypography.bold,
                              ),
                            ),
                            Text(
                              item.subtitle,
                              style: AppTypography.body(
                                context,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(4 * s),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20 * s,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: AppColors.borderLight),

                // Content
                Padding(
                  padding: EdgeInsets.all(AppDesignSystem.space24 * s),
                  child: Column(
                    children: [
                      // Center Visual
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Card
                          Container(
                            width: 120 * s,
                            height: 120 * s,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(
                                AppDesignSystem.radiusXXLarge * s,
                              ),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 1 * s,
                              ),
                            ),
                          ),

                          // Status Icon Top Right
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              item.isLocked
                                  ? Icons.lock_rounded
                                  : Icons.check_circle_rounded,
                              size: 28 * s,
                              color: item.isLocked
                                  ? AppColors.textDisabled
                                  : item.color,
                            ),
                          ),

                          // Emoji
                          Opacity(
                            opacity: item.isLocked ? 0.5 : 1.0,
                            child: Text(
                              item.emoji,
                              style: TextStyle(fontSize: 64 * s),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDesignSystem.space24 * s),

                      // Description
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          context,
                          color: AppColors.textSecondary,
                        ).copyWith(height: 1.5),
                      ),

                      if (item.isLocked) ...[
                        SizedBox(height: AppDesignSystem.space16 * s),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDesignSystem.space8 * s,
                            horizontal: AppDesignSystem.space12 * s,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(
                              AppDesignSystem.radiusSmall * s,
                            ),
                          ),
                          child: Text(
                            "Keep going to unlock this badge!",
                            style: AppTypography.caption(
                              context,
                              color: AppColors.textTertiary,
                              weight: AppTypography.medium,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Footer Action
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDesignSystem.space16 * s),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        AppDesignSystem.radiusLarge * s,
                      ),
                      bottomRight: Radius.circular(
                        AppDesignSystem.radiusLarge * s,
                      ),
                    ),
                  ),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignSystem.space2 * s,
                        vertical: 0 * s,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STATUS',
                                style: AppTypography.captionSmall(
                                  context,
                                  weight: AppTypography.bold,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              SizedBox(height: 2 * s),
                              Text(
                                'EARNED ON ${_latestBadge.earnedDate}',
                                style: AppTypography.caption(
                                  context,
                                  weight: AppTypography.bold,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          // Verification Badge
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: 24 * s,
                          ),
                        ],
                      ),
                    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
