// lib/screens/main/home/screens/all_session_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;

class AllSessionPage extends StatefulWidget {
  const AllSessionPage({Key? key}) : super(key: key);

  @override
  State<AllSessionPage> createState() => _AllSessionPageState();
}

class _AllSessionPageState extends State<AllSessionPage> {
  // Optimized data structure with better organization
  final List<Map<String, dynamic>> _sessions = [
    {
      'type': 'Reading',
      'surah': 'Al-Kafirun 1 - Al-Masad 5',
      'duration': '0 min',
      'verses': 14,
      'timestamp': 'TODAY 8:07AM - 9:08AM',
    },
    {
      'type': 'Reading',
      'surah': 'Al-Ikhlas 1 - An-Nas 6',
      'duration': '3 min',
      'verses': 15,
      'timestamp': 'NOVEMBER 12, 2025 4:02PM - 4:12PM',
    },
    {
      'type': 'Reading',
      'surah': 'Al-Furqan 21 - 32',
      'duration': '0 min',
      'verses': 12,
      'timestamp': 'NOVEMBER 12, 2025 12:28PM - 12:29PM',
    },
    {
      'type': 'Reading',
      'surah': 'Al-Ikhlas 1 - An-Nas 6',
      'duration': '3 min',
      'verses': 15,
      'timestamp': 'NOVEMBER 12, 2025 9:34AM - 9:43AM',
    },
    {
      'type': 'Reading',
      'surah': 'Al-Ikhlas 1 - An-Nas 6',
      'duration': '1 min',
      'verses': 15,
      'timestamp': 'NOVEMBER 12, 2025 9:17AM - 9:18AM',
    },
    {
      'type': 'Reading',
      'surah': "Al-'Imran 23 - 29",
      'duration': '2 min',
      'verses': 7,
      'timestamp': 'NOVEMBER 11, 2025 3:45PM - 3:47PM',
    },
    {
      'type': 'Reading',
      'surah': 'Al-Baqarah 145 - 152',
      'duration': '5 min',
      'verses': 8,
      'timestamp': 'NOVEMBER 11, 2025 10:22AM - 10:27AM',
    },
    {
      'type': 'Reading',
      'surah': 'Yunus 38 - 45',
      'duration': '4 min',
      'verses': 8,
      'timestamp': 'NOVEMBER 10, 2025 2:15PM - 2:19PM',
    },
    {
      'type': 'Reading',
      'surah': 'Al-Kahf 1 - 10',
      'duration': '6 min',
      'verses': 10,
      'timestamp': 'NOVEMBER 9, 2025 8:30AM - 8:36AM',
    },
    {
      'type': 'Reading',
      'surah': 'Maryam 16 - 25',
      'duration': '3 min',
      'verses': 10,
      'timestamp': 'NOVEMBER 8, 2025 5:12PM - 5:15PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 406.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const ProfileAppBar(title: 'Session'),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 24 * s),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16 * s),
                        child: _buildSessionHeader(s),
                      );
                    }
                    final sessionIndex = index - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12 * s),
                      child: _buildSessionCard(_sessions[sessionIndex], s),
                    );
                  },
                  childCount: _sessions.length + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHeader(double s) {
    return Text(
      '${_sessions.length} SESSIONS',
      style: TextStyle(
        fontSize: 11 * s,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9E9E9E),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header with type
          Text(
            session['type'],
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF757575),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12 * s),

          // Main content row - optimized layout
          Row(
            children: [
              // Compact icon
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: constants.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10 * s),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: constants.primaryColor,
                  size: 20 * s,
                ),
              ),
              SizedBox(width: 12 * s),

              // Surah info - better hierarchy
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['surah'],
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                        letterSpacing: -0.2,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Row(
                      children: [
                        Text(
                          session['duration'],
                          style: TextStyle(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6 * s),
                          width: 3 * s,
                          height: 3 * s,
                          decoration: const BoxDecoration(
                            color: Color(0xFFBDBDBD),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          '${session['verses']} verses',
                          style: TextStyle(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12 * s),

          // Bottom row - timestamp & CTA
          Row(
            children: [
              // Timestamp
              Expanded(
                child: Text(
                  session['timestamp'],
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9E9E9E),
                    letterSpacing: 0.1,
                  ),
                ),
              ),

              // More prominent Continue button
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to reading page with session data
                },
                borderRadius: BorderRadius.circular(8 * s),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 4 * s),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10 * s,
                        color: constants.primaryColor,
                      ),
                    ],
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}