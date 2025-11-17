// lib/screens/main/home/screens/home_page.dart

import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentStreak = 1;
  int _longestStreak = 2;
  int _versesRecited = 13;
  int _completionPercentage = 2;
  int _memorizedPercentage = 0;
  String _engagementTime = "1:33:26";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 406.0; // Scale factor

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const MenuAppBar(selectedIndex: 0),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGreetingHeader(s),
                  SizedBox(height: 24 * s),
                  _buildLastRead(s),
                  SizedBox(height: 20 * s),
                  Text(
                    'Streak',
                    style: TextStyle(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 15 * s),
                  _buildStreakSection(s),
                  SizedBox(height: 20 * s),
                  _buildProgressGrid(s),
                  SizedBox(height: 20 * s),
                  _buildTodayGoal(s),
                  SizedBox(height: 20 * s),
                  _buildAchievements(s),
                  SizedBox(height: 32 * s),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(double s) {
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
          style: TextStyle(
            fontSize: 28 * s,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4 * s),
        Text(
          _getGreeting(),
          style: TextStyle(
            fontSize: 14 * s,
            color: Colors.black45,
            fontWeight: FontWeight.w400,
          ),
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

  Widget _buildLastRead(double s) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16 * s),
      child: Container(
        padding: EdgeInsets.all(24 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6 * s,
                  height: 6 * s,
                  decoration: const BoxDecoration(
                    color: constants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8 * s),
                Text(
                  'LATEST SESSION',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20 * s),
            Text(
              'Surah Ya-sin',
              style: TextStyle(
                fontSize: 24 * s,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 6 * s),
            Text(
              '1-45 · 9 min ago',
              style: TextStyle(
                fontSize: 14 * s,
                color: Colors.black45,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20 * s),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 3 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(2 * s),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.65,
                      child: Container(
                        decoration: BoxDecoration(
                          color: constants.primaryColor,
                          borderRadius: BorderRadius.circular(2 * s),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Text(
                  '65%',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                    color: constants.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(double s) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak 🔥',
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8 * s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_currentStreak',
                      style: TextStyle(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    Text(
                      'day',
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Longest Streak🔥',
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8 * s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_longestStreak',
                      style: TextStyle(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    Text(
                      'days',
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressGrid(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            fontSize: 18 * s,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 16 * s),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                'Completion',
                '$_completionPercentage%',
                constants.primaryColor,
                s,
              ),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: _buildProgressCard(
                'Memorized',
                '$_memorizedPercentage%',
                constants.accentColor,
                s,
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                'Time',
                _engagementTime,
                constants.listeningColor,
                s,
              ),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: _buildProgressCard(
                'Verses',
                '$_versesRecited',
                constants.correctColor,
                s,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(String label, String value, Color color, double s) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4 * s,
            height: 4 * s,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(height: 12 * s),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * s,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            value,
            style: TextStyle(
              fontSize: 24 * s,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayGoal(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Goal",
          style: TextStyle(
            fontSize: 18 * s,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 16 * s),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16 * s),
          child: Container(
            padding: EdgeInsets.all(20 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
            ),
            child: Row(
              children: [
                Container(
                  width: 48 * s,
                  height: 48 * s,
                  decoration: BoxDecoration(
                    color: constants.primaryColor,
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 24 * s,
                  ),
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayah a Day',
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        "Al-Waqi'ah 12",
                        style: TextStyle(
                          fontSize: 13 * s,
                          color: Colors.black45,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
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
        ),
      ],
    );
  }

  Widget _buildAchievements(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: TextStyle(
            fontSize: 18 * s,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 16 * s),
        SizedBox(
          height: 100 * s,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildAchievementBadge('🔍', 'Explorer', '10', s),
              _buildAchievementBadge('📱', 'Social', null, s),
              _buildAchievementBadge('🎯', 'Reminder', '1', s),
              _buildAchievementBadge('🧠', 'Memory', null, s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
    String emoji,
    String label,
    String? count,
    double s,
  ) {
    return Container(
      width: 80 * s,
      margin: EdgeInsets.only(right: 12 * s),
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text(emoji, style: TextStyle(fontSize: 32 * s)),
              if (count != null)
                Positioned(
                  top: -4 * s,
                  right: -4 * s,
                  child: Container(
                    padding: EdgeInsets.all(4 * s),
                    decoration: const BoxDecoration(
                      color: constants.warningColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18 * s,
                      minHeight: 18 * s,
                    ),
                    child: Center(
                      child: Text(
                        count,
                        style: TextStyle(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * s,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
