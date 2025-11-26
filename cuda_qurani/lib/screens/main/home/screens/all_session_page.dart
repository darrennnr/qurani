// lib/screens/main/home/screens/all_session_page.dart

import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';
import 'package:cuda_qurani/services/supabase_service.dart';

class AllSessionPage extends StatefulWidget {
  const AllSessionPage({Key? key}) : super(key: key);

  @override
  State<AllSessionPage> createState() => _AllSessionPageState();
}

class _AllSessionPageState extends State<AllSessionPage> {
  // ==================== DATA STRUCTURE ====================
  final SupabaseService _supabaseService = SupabaseService();
  List<SessionData> _sessions = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }
  
  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    
    try {
      final sessions = await _supabaseService.getAllSessions();
      setState(() {
        _sessions = sessions.map((s) => SessionData.fromSupabase(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sessions: $e');
      setState(() => _isLoading = false);
      // Fallback to dummy data if error
      _loadDummyData();
    }
  }
  
  void _loadDummyData() {
    _sessions = [
    SessionData(
      type: SessionType.reading,
      surah: 'Al-Kafirun 1 - Al-Masad 5',
      duration: Duration.zero,
      verses: 14,
      timestamp: DateTime.now(),
      displayDate: 'TODAY',
      displayTime: '8:07AM - 9:08AM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Al-Ikhlas 1 - An-Nas 6',
      duration: const Duration(minutes: 3),
      verses: 15,
      timestamp: DateTime(2025, 11, 12, 16, 2),
      displayDate: 'NOVEMBER 12, 2025',
      displayTime: '4:02PM - 4:12PM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Al-Furqan 21 - 32',
      duration: Duration.zero,
      verses: 12,
      timestamp: DateTime(2025, 11, 12, 12, 28),
      displayDate: 'NOVEMBER 12, 2025',
      displayTime: '12:28PM - 12:29PM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Al-Ikhlas 1 - An-Nas 6',
      duration: const Duration(minutes: 3),
      verses: 15,
      timestamp: DateTime(2025, 11, 12, 9, 34),
      displayDate: 'NOVEMBER 12, 2025',
      displayTime: '9:34AM - 9:43AM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Al-Ikhlas 1 - An-Nas 6',
      duration: const Duration(minutes: 1),
      verses: 15,
      timestamp: DateTime(2025, 11, 12, 9, 17),
      displayDate: 'NOVEMBER 12, 2025',
      displayTime: '9:17AM - 9:18AM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: "Al-'Imran 23 - 29",
      duration: const Duration(minutes: 2),
      verses: 7,
      timestamp: DateTime(2025, 11, 11, 15, 45),
      displayDate: 'NOVEMBER 11, 2025',
      displayTime: '3:45PM - 3:47PM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Al-Baqarah 145 - 152',
      duration: const Duration(minutes: 5),
      verses: 8,
      timestamp: DateTime(2025, 11, 11, 10, 22),
      displayDate: 'NOVEMBER 11, 2025',
      displayTime: '10:22AM - 10:27AM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Yunus 38 - 45',
      duration: const Duration(minutes: 4),
      verses: 8,
      timestamp: DateTime(2025, 11, 10, 14, 15),
      displayDate: 'NOVEMBER 10, 2025',
      displayTime: '2:15PM - 2:19PM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Al-Kahf 1 - 10',
      duration: const Duration(minutes: 6),
      verses: 10,
      timestamp: DateTime(2025, 11, 9, 8, 30),
      displayDate: 'NOVEMBER 9, 2025',
      displayTime: '8:30AM - 8:36AM',
    ),
    SessionData(
      type: SessionType.reading,
      surah: 'Maryam 16 - 25',
      duration: const Duration(minutes: 3),
      verses: 10,
      timestamp: DateTime(2025, 11, 8, 17, 12),
      displayDate: 'NOVEMBER 8, 2025',
      displayTime: '5:12PM - 5:15PM',
    ),
  ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const ProfileAppBar(title: 'Session'),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
      ),
    );
  }

  // ==================== BODY ====================
  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: Padding(
            padding: AppPadding.only(
              context,
              left: AppDesignSystem.space20,
              right: AppDesignSystem.space20,
              top: AppDesignSystem.space12,
              bottom: AppDesignSystem.space8,
            ),
            child: _buildHeader(context),
          ),
        ),

        // Sessions List
        SliverPadding(
          padding: AppPadding.horizontal(context, AppDesignSystem.space20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: AppPadding.only(
                    context,
                    bottom: AppDesignSystem.space8,
                  ),
                  child: _buildSessionCard(context, _sessions[index]),
                );
              },
              childCount: _sessions.length,
            ),
          ),
        ),

        // Bottom Spacing
        SliverToBoxAdapter(
          child: SizedBox(height: AppDesignSystem.space16),
        ),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context) {
    return Text(
      '${_sessions.length} SESSIONS',
      style: AppTypography.overline(
        context,
        color: AppColors.textTertiary,
      ),
    );
  }

  // ==================== SESSION CARD ====================
  Widget _buildSessionCard(BuildContext context, SessionData session) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.medium();
          _navigateToSession(context, session);
        },
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        splashColor: AppComponentStyles.rippleColor,
        highlightColor: AppComponentStyles.hoverColor,
        child: Container(
          padding: EdgeInsets.all(AppDesignSystem.space12 * AppDesignSystem.getScaleFactor(context)),
          decoration: AppComponentStyles.card(
            borderColor: AppColors.borderLight,
            shadow: false,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Type Label (smaller)
              Text(
                session.type.displayName.toUpperCase(),
                style: AppTypography.captionSmall(
                  context,
                  color: AppColors.textDisabled,
                  weight: AppTypography.semiBold,
                ),
              ),
              
              SizedBox(height: AppDesignSystem.space8 * AppDesignSystem.getScaleFactor(context)),
              
              // Main Content Row
              Row(
                children: [
                  // Icon Container (smaller)
                  Container(
                    width: 36 * AppDesignSystem.getScaleFactor(context),
                    height: 36 * AppDesignSystem.getScaleFactor(context),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      _getSessionIcon(session.type),
                      size: AppDesignSystem.iconMedium,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  SizedBox(width: AppDesignSystem.space10 * AppDesignSystem.getScaleFactor(context)),
                  
                  // Surah Info
                  Expanded(
                    child: _buildSurahInfo(context, session),
                  ),
                ],
              ),
              
              SizedBox(height: AppDesignSystem.space8 * AppDesignSystem.getScaleFactor(context)),
              
              // Bottom Row - Timestamp & Action (no divider)
              _buildBottomRow(context, session),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TYPE BADGE ====================
  // REMOVED - Using simple text label instead

  // ==================== SURAH INFO ====================
  Widget _buildSurahInfo(BuildContext context, SessionData session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Surah Name (smaller)
        Text(
          session.surah,
          style: AppTypography.title(
            context,
            weight: AppTypography.semiBold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: AppDesignSystem.space4 * AppDesignSystem.getScaleFactor(context)),
        
        // Duration & Verses (compact)
        Row(
          children: [
            Text(
              _formatDuration(session.duration),
              style: AppTypography.captionSmall(context),
            ),
            
            // Separator Dot
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppDesignSystem.space6 * AppDesignSystem.getScaleFactor(context)),
              width: AppDesignSystem.space2,
              height: AppDesignSystem.space2,
              decoration: const BoxDecoration(
                color: AppColors.borderDark,
                shape: BoxShape.circle,
              ),
            ),
            
            Text(
              '${session.verses} verses',
              style: AppTypography.captionSmall(context),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== BOTTOM ROW ====================
  Widget _buildBottomRow(BuildContext context, SessionData session) {
    return Row(
      children: [
        // Timestamp (compact, no icon)
        Expanded(
          child: Text(
            '${session.displayDate} ${session.displayTime}',
            style: AppTypography.captionSmall(
              context,
              color: AppColors.textDisabled,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        SizedBox(width: AppDesignSystem.space8 * AppDesignSystem.getScaleFactor(context)),
        
        // Continue Button
        _buildContinueButton(context),
      ],
    );
  }

  // ==================== CONTINUE BUTTON ====================
  Widget _buildContinueButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          // TODO: Navigate to reading page
        },
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
        splashColor: AppComponentStyles.rippleColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space6 * AppDesignSystem.getScaleFactor(context),
            vertical: AppDesignSystem.space4 * AppDesignSystem.getScaleFactor(context),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Continue',
                style: AppTypography.captionSmall(
                  context,
                  color: AppColors.primary,
                  weight: AppTypography.semiBold,
                ),
              ),
              SizedBox(width: AppDesignSystem.space2 * AppDesignSystem.getScaleFactor(context)),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppDesignSystem.iconXSmall,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  
  IconData _getSessionIcon(SessionType type) {
    switch (type) {
      case SessionType.reading:
        return Icons.menu_book_rounded;
      case SessionType.memorization:
        return Icons.psychology_rounded;
      case SessionType.revision:
        return Icons.refresh_rounded;
    }
  }

  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.reading:
        return AppColors.primary;
      case SessionType.memorization:
        return AppColors.secondary;
      case SessionType.revision:
        return AppColors.accent;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes == 0) {
      return '< 1 min';
    }
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }

  void _navigateToSession(BuildContext context, SessionData session) {
    // TODO: Navigate to session detail or reading page
    ScaffoldMessenger.of(context).showSnackBar(
      AppComponentStyles.infoSnackBar(
        message: 'Opening ${session.surah}...',
      ),
    );
  }
}

// ==================== SESSION DATA MODEL ====================
enum SessionType {
  reading,
  memorization,
  revision;

  String get displayName {
    switch (this) {
      case SessionType.reading:
        return 'Reading';
      case SessionType.memorization:
        return 'Memorization';
      case SessionType.revision:
        return 'Revision';
    }
  }
}

class SessionData {
  final SessionType type;
  final String surah;
  final Duration duration;
  final int verses;
  final DateTime timestamp;
  final String displayDate;
  final String displayTime;
  final String? sessionId;

  SessionData({
    required this.type,
    required this.surah,
    required this.duration,
    required this.verses,
    required this.timestamp,
    required this.displayDate,
    required this.displayTime,
    this.sessionId,
  });
  
  factory SessionData.fromSupabase(Map<String, dynamic> data) {
    final timestamp = DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String());
    final surahId = data['surah_id'] ?? 1;
    final ayah = data['ayah'] ?? 1;
    
    return SessionData(
      type: SessionType.reading,
      surah: 'Surah $surahId: $ayah',
      duration: Duration(minutes: 0),
      verses: ayah,
      timestamp: timestamp,
      displayDate: _formatDate(timestamp),
      displayTime: _formatTime(timestamp),
      sessionId: data['session_id'],
    );
  }
  
  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'TODAY';
    }
    return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
  }
  
  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour}:${dt.minute.toString().padLeft(2, '0')}$period';
  }
  
  static String _monthName(int month) {
    const months = ['', 'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    return months[month];
  }
}