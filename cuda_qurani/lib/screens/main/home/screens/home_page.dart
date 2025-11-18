// lib/screens/main/home/screens/home_page.dart

import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/all_session_page.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample data - replace with actual data from provider/API
  int _currentStreak = 1;
  int _longestStreak = 2;
  int _versesRecited = 13;
  int _completionPercentage = 2;
  int _memorizedPercentage = 0;
  String _engagementTime = "1:33:26";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const MenuAppBar(selectedIndex: 0),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: AppPadding.section(context),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGreetingHeader(context),
                  AppMargin.gapLarge(context),
                  _buildLatestSession(context),
                  AppMargin.gapXLarge(context),
                  _buildStreakSection(context),
                  AppMargin.gapXLarge(context),
                  _buildProgressSection(context),
                  AppMargin.gapXLarge(context),
                  _buildTodayGoal(context),
                  AppMargin.gapXLarge(context),
                  _buildAchievements(context),
                  AppMargin.customGap(context, AppDesignSystem.space40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== GREETING HEADER ====================
  Widget _buildGreetingHeader(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    String displayName = 'User';
    if (user != null) {
      if (user.fullName != null && user.fullName!.isNotEmpty) {
        displayName = user.fullName!;
      } else {
        displayName = user.email.split('@')[0];
        if (displayName.isNotEmpty) {
          displayName = displayName[0].toUpperCase() + displayName.substring(1);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: AppTypography.h1(context, weight: AppTypography.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        AppMargin.gapSmall(context),
        Text(
          _getGreeting(),
          style: AppTypography.caption(context),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ==================== LATEST SESSION CARD ====================
  Widget _buildLatestSession(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          // Navigate to continue reading
        },
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        splashColor: AppComponentStyles.rippleColor,
        highlightColor: AppComponentStyles.hoverColor,
        child: Container(
          padding: AppPadding.card(context),
          decoration: AppComponentStyles.card(
            color: AppColors.surface,
            borderRadius: AppDesignSystem.radiusLarge,
            borderColor: AppColors.borderLight,
            borderWidth: AppDesignSystem.borderNormal,
            shadow: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppDesignSystem.space6,
                        height: AppDesignSystem.space6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppMargin.gapHSmall(context),
                      Text(
                        'LATEST SESSION',
                        style: AppTypography.overline(context),
                      ),
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        AppHaptics.light();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllSessionPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusSmall,
                      ),
                      child: Padding(
                        padding: AppPadding.all(context, AppDesignSystem.space4),
                        child: Row(
                          children: [
                            Text(
                              'See All',
                              style: AppTypography.caption(
                                context,
                                weight: AppTypography.semiBold,
                              ),
                            ),
                            AppMargin.customGapH(context, AppDesignSystem.space4),
                            Icon(
                              Icons.history_rounded,
                              size: AppDesignSystem.iconSmall,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppMargin.gap(context),
              // Surah Title
              Text(
                'Surah Ya-sin',
                style: AppTypography.h2(context, weight: AppTypography.bold),
              ),
              AppMargin.gapSmall(context),
              Text(
                '1-45 · 9 min ago',
                style: AppTypography.caption(context),
              ),
              AppMargin.gap(context),
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    AppHaptics.medium();
                    // Continue reading action
                  },
                  style: AppComponentStyles.secondaryButton(context).copyWith(
                    side: MaterialStateProperty.all(
                      const BorderSide(
                        color: AppColors.textPrimary,
                        width: AppDesignSystem.borderThick,
                      ),
                    ),
                  ),
                  child: Text(
                    'Continue reading',
                    style: AppTypography.label(
                      context,
                      color: AppColors.textPrimary,
                      weight: AppTypography.semiBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== STREAK SECTION ====================
  Widget _buildStreakSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streak',
          style: AppTypography.titleLarge(context, weight: AppTypography.bold),
        ),
        AppMargin.gap(context),
        Row(
          children: [
            Expanded(
              child: _buildStreakCard(
                context: context,
                label: 'Current Streak 🔥',
                value: _currentStreak,
                unit: 'day',
              ),
            ),
            AppMargin.gapH(context),
            Expanded(
              child: _buildStreakCard(
                context: context,
                label: 'Longest Streak 🔥',
                value: _longestStreak,
                unit: 'days',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakCard({
    required BuildContext context,
    required String label,
    required int value,
    required String unit,
  }) {
    return Container(
      padding: AppPadding.card(context),
      decoration: AppComponentStyles.card(
        color: AppColors.surface,
        borderRadius: AppDesignSystem.radiusLarge,
        borderColor: AppColors.borderLight,
        borderWidth: AppDesignSystem.borderNormal,
        shadow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption(context),
          ),
          AppMargin.gapSmall(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: AppTypography.displaySmall(
                  context,
                  weight: AppTypography.bold,
                ),
              ),
              AppMargin.gapHSmall(context),
              Text(
                unit,
                style: AppTypography.caption(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== PROGRESS SECTION ====================
  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: AppTypography.titleLarge(context, weight: AppTypography.bold),
        ),
        AppMargin.gap(context),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                context: context,
                label: 'Completion',
                value: '$_completionPercentage%',
                color: AppColors.primary,
              ),
            ),
            AppMargin.gapH(context),
            Expanded(
              child: _buildProgressCard(
                context: context,
                label: 'Memorized',
                value: '$_memorizedPercentage%',
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        AppMargin.gap(context),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                context: context,
                label: 'Time',
                value: _engagementTime,
                color: AppColors.info,
              ),
            ),
            AppMargin.gapH(context),
            Expanded(
              child: _buildProgressCard(
                context: context,
                label: 'Verses',
                value: '$_versesRecited',
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: AppPadding.card(context),
      decoration: AppComponentStyles.card(
        color: AppColors.surface,
        borderRadius: AppDesignSystem.radiusLarge,
        borderColor: AppColors.borderLight,
        borderWidth: AppDesignSystem.borderNormal,
        shadow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDesignSystem.space6,
            height: AppDesignSystem.space6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          AppMargin.gap(context),
          Text(
            label,
            style: AppTypography.caption(context),
          ),
          AppMargin.gapSmall(context),
          Text(
            value,
            style: AppTypography.h2(context, weight: AppTypography.bold),
          ),
        ],
      ),
    );
  }

  // ==================== TODAY'S GOAL ====================
  Widget _buildTodayGoal(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Goal",
          style: AppTypography.titleLarge(context, weight: AppTypography.bold),
        ),
        AppMargin.gap(context),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              AppHaptics.light();
              // Navigate to goal
            },
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
            splashColor: AppComponentStyles.rippleColor,
            child: Container(
              padding: AppPadding.card(context),
              decoration: AppComponentStyles.card(
                color: AppColors.surface,
                borderRadius: AppDesignSystem.radiusLarge,
                borderColor: AppColors.borderLight,
                borderWidth: AppDesignSystem.borderNormal,
                shadow: false,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppDesignSystem.iconHuge,
                    height: AppDesignSystem.iconHuge,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.white,
                      size: AppDesignSystem.iconLarge,
                    ),
                  ),
                  AppMargin.gapH(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ayah a Day',
                          style: AppTypography.title(
                            context,
                            weight: AppTypography.semiBold,
                          ),
                        ),
                        AppMargin.gapSmall(context),
                        Text(
                          "Al-Waqi'ah 12",
                          style: AppTypography.caption(context),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppDesignSystem.iconSmall,
                    color: AppColors.textDisabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== ACHIEVEMENTS ====================
  Widget _buildAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: AppTypography.titleLarge(context, weight: AppTypography.bold),
        ),
        AppMargin.gap(context),
        SizedBox(
          height: AppDesignSystem.scale(context, 100),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildAchievementBadge(
                context: context,
                emoji: '🔍',
                label: 'Explorer',
                count: 10,
              ),
              _buildAchievementBadge(
                context: context,
                emoji: '📱',
                label: 'Social',
                count: null,
              ),
              _buildAchievementBadge(
                context: context,
                emoji: '🎯',
                label: 'Reminder',
                count: 1,
              ),
              _buildAchievementBadge(
                context: context,
                emoji: '🧠',
                label: 'Memory',
                count: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge({
    required BuildContext context,
    required String emoji,
    required String label,
    required int? count,
  }) {
    return Container(
      width: AppDesignSystem.scale(context, 85),
      margin: EdgeInsets.only(
        right: AppDesignSystem.scale(context, AppDesignSystem.space12),
      ),
      padding: AppPadding.card(context),
      decoration: AppComponentStyles.card(
        color: AppColors.surface,
        borderRadius: AppDesignSystem.radiusLarge,
        borderColor: AppColors.borderLight,
        borderWidth: AppDesignSystem.borderNormal,
        shadow: false,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: AppDesignSystem.scale(context, 30),
                ),
              ),
              if (count != null)
                Positioned(
                  top: AppDesignSystem.scale(context, -4),
                  right: AppDesignSystem.scale(context, -4),
                  child: Container(
                    padding: AppPadding.all(context, AppDesignSystem.space4),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: AppDesignSystem.scale(context, 18),
                      minHeight: AppDesignSystem.scale(context, 18),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: AppTypography.captionSmall(
                          context,
                          color: Colors.white,
                          weight: AppTypography.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AppMargin.gapSmall(context),
          Text(
            label,
            style: AppTypography.captionSmall(
              context,
              weight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}