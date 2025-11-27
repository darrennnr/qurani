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
    title: 'TARTEEL',
    subtitle: 'Start Memorizing',
    badgeType: 'AI —',
    description: 'Enable Memorization Mode in the Quran reading experience.',
    emoji: '🧠',
    color: const Color(0xFF00C853), // Greenish for the glow
    isEarned: true,
    isLocked: false,
    earnedDate: 'NOV 25, 2025',
  );

  final List<AchievementModel> _earnedBadges = [
    AchievementModel(
      title: 'Start Memorizing',
      subtitle: 'Begin your journey',
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
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      // Using the ProfileAppBar as requested with matching title
      appBar: const ProfileAppBar(title: 'Achievements', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: AppDesignSystem.space40 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLatestBadgeSection(context, s),
              SizedBox(height: AppDesignSystem.space24 * s),
              _buildEarnedBadgesSection(context, s),
              SizedBox(height: AppDesignSystem.space24 * s),
              _buildInfoBanner(context, s),
              _buildRemainingBadgesSection(context, s),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LATEST BADGE CARD ====================
  Widget _buildLatestBadgeSection(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.space20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppDesignSystem.space16 * s),
          Text('Latest Badge', style: AppTypography.body(context)),
          SizedBox(height: AppDesignSystem.space12 * s),

          // Main Card
          Container(
            decoration: AppComponentStyles.card(
              color: AppColors.surface,
              shadow: true,
              borderRadius: AppDesignSystem.radiusLarge * s,
              borderColor: AppColors.borderLight,
              borderWidth: AppDesignSystem.borderThin * s,
            ),
            child: Column(
              children: [
                // Top Part (Content)
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
                              Text(
                                _latestBadge.title,
                                style: AppTypography.titleLarge(
                                  context,
                                  weight: AppTypography.bold,
                                ),
                              ),
                              if (_latestBadge.badgeType != null)
                                Text(
                                  _latestBadge.badgeType!,
                                  style: AppTypography.body(
                                    context,
                                    color: AppColors.textSecondary,
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

                      SizedBox(height: AppDesignSystem.space24 * s),

                      // Central Avatar with Glow
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow Effect
                          Container(
                            width: 140 * s,
                            height: 140 * s,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _latestBadge.color.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                stops: const [0.3, 1.0],
                              ),
                            ),
                          ),
                          // Circle Avatar
                          Container(
                            width: 100 * s,
                            height: 100 * s,
                            decoration: BoxDecoration(
                              color: AppColors
                                  .info, // Blue background like screenshot
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _latestBadge.emoji,
                              style: TextStyle(fontSize: 50 * s),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDesignSystem.space16 * s),

                      // Badge Label
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignSystem.space12 * s,
                          vertical: AppDesignSystem.space4 * s,
                        ),
                        decoration: BoxDecoration(
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

                      SizedBox(height: AppDesignSystem.space24 * s),

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
                    vertical: AppDesignSystem.space16 * s,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dummy',
                            style: AppTypography.captionSmall(
                              context,
                              weight: AppTypography.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppDesignSystem.space2 * s),
                          Text(
                            'EARNED: ${_latestBadge.earnedDate}',
                            style: AppTypography.captionSmall(
                              context,
                              weight: AppTypography.bold,
                              color: AppColors.textTertiary, // Uppercase style
                            ),
                          ),
                        ],
                      ),
                      // The green logo icon in the corner
                      Icon(
                        Icons.verified,
                        color: const Color(0xFF2ECC71), // Bright green
                        size: 24 * s,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EARNED BADGES ====================
  Widget _buildEarnedBadgesSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space20 * s,
          ),
          child: Text(
            'Earned Badges (${_earnedBadges.length})',
            style: AppTypography.titleLarge(
              context,
              weight: AppTypography.bold,
            ),
          ),
        ),
        SizedBox(height: AppDesignSystem.space16 * s),

        // Horizontal Grid/List look
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space12 * s,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _earnedBadges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75, // Adjust for height of text
              crossAxisSpacing: AppDesignSystem.space4 * s,
              mainAxisSpacing: AppDesignSystem.space2 * s,
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
      margin: EdgeInsets.only(bottom: AppDesignSystem.space16 * s),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
      ),
      child: Text(
        'TAP BADGE TO VIEW REQUIREMENTS',
        style: AppTypography.captionSmall(
          context,
          weight: AppTypography.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ==================== REMAINING BADGES ====================
  Widget _buildRemainingBadgesSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space20 * s,
          ),
          child: Text(
            'Remaining Badges (${_remainingBadges.length})',
            style: AppTypography.titleLarge(
              context,
              weight: AppTypography.bold,
            ),
          ),
        ),
        SizedBox(height: AppDesignSystem.space16 * s),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space12 * s,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _remainingBadges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppDesignSystem.space4 * s,
              mainAxisSpacing: AppDesignSystem.space24 * s,
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
                width: 70 * s,
                height: 70 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isLocked ? Colors.transparent : item.color,
                  // Gradient for unlocked (simulated simple color)
                  gradient: !item.isLocked
                      ? LinearGradient(
                          colors: [item.color, item.color.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: item.isLocked
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ghost of the emoji
                          Opacity(
                            opacity: 0.1,
                            child: Text(
                              item.emoji,
                              style: TextStyle(fontSize: 32 * s),
                            ),
                          ),
                          // Lock Icon
                          Icon(
                            Icons.lock_rounded,
                            color: AppColors.textDisabled,
                            size: 28 * s,
                          ),
                        ],
                      )
                    : Text(item.emoji, style: TextStyle(fontSize: 32 * s)),
              ),

              // Notification Badge (Counter)
              if (item.count != null && !item.isLocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4 * s),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20 * s,
                      minHeight: 20 * s,
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

              // Locked State Background (Ghost shape for layout consistency)
              if (item.isLocked)
                Container(
                  width: 70 * s,
                  height: 70 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerMedium.withOpacity(0.5),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppDesignSystem.space8 * s),

          // Badge Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0 * s),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(
                context,
                color: item.isLocked
                    ? AppColors.textTertiary
                    : AppColors.textSecondary,
              ).copyWith(height: 1.2),
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
          elevation: 0,
          backgroundColor: Colors.transparent,
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
              children: [
                // Header (Title + Close)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppDesignSystem.space20 * s,
                    AppDesignSystem.space20 * s,
                    AppDesignSystem.space12 * s,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.title} — ${item.subtitle}',
                          style: AppTypography.title(context),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          size: 24 * s,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: AppColors.borderLight, height: 32 * s),

                // Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space20 * s,
                  ),
                  child: Column(
                    children: [
                      // Badge "TARTEEL AI" dummy text from screenshot
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TARTEEL',
                              style: AppTypography.titleLarge(
                                context,
                                weight: AppTypography.bold,
                              ),
                            ),
                            Text(
                              'AI —',
                              style: AppTypography.body(
                                context,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppDesignSystem.space16 * s),

                      // Center Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background shapes (mimicking the card art)
                          Container(
                            width: 120 * s,
                            height: 100 * s,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(
                                AppDesignSystem.radiusMedium * s,
                              ),
                            ),
                          ),
                          // The Lock or Icon
                          Icon(
                            item.isLocked
                                ? Icons.lock_rounded
                                : Icons.check_circle_rounded,
                            size: 48 * s,
                            color: item.isLocked
                                ? AppColors.textDisabled
                                : item.color,
                          ),
                          // Faded emoji behind
                          Opacity(
                            opacity: 0.1,
                            child: Text(
                              item.emoji,
                              style: TextStyle(fontSize: 80 * s),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDesignSystem.space24 * s),

                      // Badge Name Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignSystem.space12 * s,
                          vertical: AppDesignSystem.space6 * s,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderMedium),
                          borderRadius: BorderRadius.circular(
                            AppDesignSystem.radiusSmall * s,
                          ),
                        ),
                        child: Text(
                          '${item.title} — ${item.subtitle}',
                          style: AppTypography.caption(
                            context,
                            color: AppColors.textPrimary,
                            weight: AppTypography.semiBold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: AppDesignSystem.space24 * s),

                      // Description
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          context,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppDesignSystem.space24 * s),

                // Footer
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dummy',
                            style: AppTypography.captionSmall(
                              context,
                              weight: AppTypography.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2 * s),
                          Text(
                            item.isEarned ? 'EARNED' : 'NOT YET EARNED',
                            style: AppTypography.captionSmall(
                              context,
                              weight: AppTypography.bold,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      // Decorative Icon
                      Icon(
                        Icons.auto_awesome,
                        color: item.isEarned
                            ? AppColors.primary
                            : AppColors.textDisabled,
                        size: 24 * s,
                      ),
                    ],
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
