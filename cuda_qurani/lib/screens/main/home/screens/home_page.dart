// lib/screens/main/home/screens/home_page.dart

import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/all_session_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/achievement_page.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:cuda_qurani/services/supabase_service.dart'; // ✅ NEW
import 'package:cuda_qurani/services/auth_service.dart'; // ✅ NEW
import 'package:cuda_qurani/screens/main/stt/stt_page.dart'; // ✅ NEW: For navigation
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Stats data - fetched from database
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _versesRecited = 0;
  int _completionPercentage = 0;
  int _memorizedPercentage = 0;
  String _engagementTime = "0:00:00";
  bool _isLoadingStats = true;

  // ✅ NEW: Backend integration
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _latestSession;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _loadLatestSession();
    _loadUserStats(); // ✅ Load real stats from database
  }

  /// ✅ NEW: Load user stats from database (streak, time, ayahs)
  Future<void> _loadUserStats() async {
    final userUuid = _authService.userId;
    if (userUuid == null) {
      if (mounted) setState(() => _isLoadingStats = false);
      return;
    }

    try {
      // Fetch streak and stats in parallel
      final results = await Future.wait([
        _supabaseService.getUserStreak(userUuid),
        _supabaseService.getUserStats(userUuid),
      ]);

      if (!mounted) return; // ✅ FIX: Check mounted before setState

      final streak = results[0] as Map<String, int>;
      final stats = results[1] as Map<String, dynamic>;

      setState(() {
        _currentStreak = streak['current_streak'] ?? 0;
        _longestStreak = streak['longest_streak'] ?? 0;
        _versesRecited = stats['total_ayahs_read'] ?? 0;

        // Format time
        final totalSeconds = stats['total_time_seconds'] ?? 0;
        final hours = totalSeconds ~/ 3600;
        final minutes = (totalSeconds % 3600) ~/ 60;
        final seconds = totalSeconds % 60;
        _engagementTime = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        // Calculate completion (total 6236 ayat dalam Quran)
        _completionPercentage = ((_versesRecited / 6236) * 100).round();

        _isLoadingStats = false;
      });

      print('✅ HOME: Stats loaded - streak: $_currentStreak, time: $_engagementTime, verses: $_versesRecited');
    } catch (e) {
      print('❌ HOME: Error loading stats: $e');
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  /// ✅ NEW: Load latest resumable session from backend
  Future<void> _loadLatestSession() async {
    print('🔄 HOME: Loading latest session...');

    if (!_authService.isAuthenticated) {
      print('⚠️ HOME: User not authenticated');
      if (mounted) setState(() => _isLoadingSession = false);
      return;
    }

    final userUuid = _authService.userId;
    print('👤 HOME: User UUID: $userUuid');

    if (userUuid == null) {
      print('⚠️ HOME: User UUID is null');
      if (mounted) setState(() => _isLoadingSession = false);
      return;
    }

    try {
      print('📡 HOME: Fetching session from database...');
      final session = await _supabaseService.getResumableSession(userUuid);

      if (!mounted) return; // ✅ FIX: Check mounted before setState

      if (session != null) {
        print('✅ HOME: Session found!');
        print('   Session ID: ${session['session_id']}');
        print('   Surah: ${session['surah_id']}, Ayah: ${session['ayah']}');
        print('   Status: ${session['status']}');
      } else {
        print('⚠️ HOME: No resumable session found');
      }

      setState(() {
        _latestSession = session;
        _isLoadingSession = false;
      });
    } catch (e) {
      print('❌ HOME: Error loading latest session: $e');
      if (mounted) setState(() => _isLoadingSession = false);
    }
  }

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
        Text(_getGreeting(), style: AppTypography.caption(context)),
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
    // ✅ Show loading state
    if (_isLoadingSession) {
      return Container(
        padding: AppPadding.card(context),
        decoration: AppComponentStyles.card(
          color: AppColors.surface,
          borderRadius: AppDesignSystem.radiusLarge,
          borderColor: AppColors.borderLight,
          borderWidth: AppDesignSystem.borderNormal,
          shadow: true,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ No session found
    if (_latestSession == null) {
      return Container(
        padding: AppPadding.card(context),
        decoration: AppComponentStyles.card(
          color: AppColors.surface,
          borderRadius: AppDesignSystem.radiusLarge,
          borderColor: AppColors.borderLight,
          borderWidth: AppDesignSystem.borderNormal,
          shadow: true,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.book_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            AppMargin.gapSmall(context),
            Text(
              'No recent session',
              style: AppTypography.body(context, color: AppColors.textTertiary),
            ),
            AppMargin.gapSmall(context),
            Text(
              'Start your first recitation',
              style: AppTypography.caption(context),
            ),
          ],
        ),
      );
    }

    // ✅ Extract session data from backend
    final surahId = _latestSession!['surah_id'] ?? 0;
    final ayah = _latestSession!['ayah'] ?? 0;
    final position = _latestSession!['position'] ?? 0;
    final status = _latestSession!['status'] ?? 'unknown';
    final updatedAt = _latestSession!['updated_at'] ?? '';

    // Calculate time ago
    String timeAgo = 'Just now';
    try {
      final updated = DateTime.parse(updatedAt);
      final diff = DateTime.now().difference(updated);
      if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else {
        timeAgo = '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      // Keep default
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          // Navigate to continue reading
          _resumeSession();
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
                        decoration: BoxDecoration(
                          color: status == 'paused'
                              ? AppColors.warning
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppMargin.gapHSmall(context),
                      Text(
                        status == 'paused'
                            ? 'PAUSED SESSION'
                            : 'LATEST SESSION',
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
                        padding: AppPadding.all(
                          context,
                          AppDesignSystem.space4,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'See All',
                              style: AppTypography.caption(
                                context,
                                weight: AppTypography.semiBold,
                              ),
                            ),
                            AppMargin.customGapH(
                              context,
                              AppDesignSystem.space4,
                            ),
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
                'Surah $surahId',
                style: AppTypography.h2(context, weight: AppTypography.bold),
              ),
              AppMargin.gapSmall(context),
              Text(
                'Ayah $ayah, Word ${position + 1} · $timeAgo',
                style: AppTypography.caption(context),
              ),
              AppMargin.gap(context),
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    AppHaptics.medium();
                    _resumeSession();
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

  /// ✅ NEW: Resume session action
  Future<void> _resumeSession() async {
    if (_latestSession == null) return;

    try {
      final surahId = _latestSession!['surah_id'] as int;
      final ayah = _latestSession!['ayah'] as int?;
      final position = _latestSession!['position'] as int?;
      final sessionId = _latestSession!['session_id'] as String?; // ✅ NEW
      
      // ✅ Extract word_status_map from session data
      Map<String, dynamic>? wordStatusMap;
      if (_latestSession!['data'] != null && _latestSession!['data']['word_status_map'] != null) {
        wordStatusMap = Map<String, dynamic>.from(_latestSession!['data']['word_status_map']);
      }

      print('▶️ Navigating to resume session:');
      print('   Surah: $surahId');
      print('   Ayah: $ayah');
      print('   Position: $position');
      print('   Session ID: $sessionId');
      print('   Word status map: ${wordStatusMap?.keys.length ?? 0} ayahs');

      // ✅ Navigate to STT page with session_id and word_status_map
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SttPage(
            suratId: surahId,
            isFromHistory: true,
            initialWordStatusMap: wordStatusMap,
            resumeSessionId: sessionId, // ✅ NEW: Pass session_id for backend resume
          ),
        ),
      );
    } catch (e) {
      print('❌ Failed to resume session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resume: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
          Text(label, style: AppTypography.caption(context)),
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
              Text(unit, style: AppTypography.caption(context)),
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          AppMargin.gap(context),
          Text(label, style: AppTypography.caption(context)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: AppTypography.titleLarge(
                context,
                weight: AppTypography.bold,
              ),
            ),

            // 👉 NEW: TextButton di sisi kanan
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AchievementPage(),
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
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space8,
                  vertical: AppDesignSystem.space4,
                ),
                minimumSize: Size(0, 0), // biar mepet, tidak melebar
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'More',
                style: AppTypography.caption(
                  context,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
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
      width: AppDesignSystem.scale(context, 90),
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
                style: TextStyle(fontSize: AppDesignSystem.scale(context, 25)),
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
