// lib/screens/main/home/screens/activity_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cuda_qurani/screens/main/home/widgets/navigation_bar.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // Global filter (controls all sections by default)
  String _globalFilter = 'day';
  
  // Individual filters (can be overridden by user navigation)
  String _pagesTimeframe = 'day';
  String _engagementTimeframe = 'day';
  String _statisticsTimeframe = 'THIS DAY';

  // Timeframe options
  final List<String> _timeframeOptions = ['day', 'week', 'month'];
  
  // Global filter options for dropdown
  final Map<String, String> _globalFilterOptions = {
    'day': 'Day',
    'week': 'Week',
    'month': 'Month',
  };

  // Dummy data untuk Pages Chart
  final Map<String, List<FlSpot>> _pagesData = {
    'day': [
      FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0),
      FlSpot(4, 0), FlSpot(5, 0), FlSpot(6, 0), FlSpot(7, 0),
    ],
    'week': [
      FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 0), FlSpot(3, 4),
      FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 2),
    ],
    'month': [
      FlSpot(0, 1), FlSpot(1, 2), FlSpot(2, 3), FlSpot(3, 2),
      FlSpot(4, 4), FlSpot(5, 3), FlSpot(6, 5),
    ],
  };

  // Dummy data untuk Engagement Chart
  final Map<String, List<FlSpot>> _engagementData = {
    'day': [
      FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0),
      FlSpot(4, 0), FlSpot(5, 0), FlSpot(6, 15), FlSpot(7, 0),
    ],
    'week': [
      FlSpot(0, 8), FlSpot(1, 12), FlSpot(2, 0), FlSpot(3, 10),
      FlSpot(4, 15), FlSpot(5, 9), FlSpot(6, 6),
    ],
    'month': [
      FlSpot(0, 5), FlSpot(1, 8), FlSpot(2, 12), FlSpot(3, 7),
      FlSpot(4, 14), FlSpot(5, 10), FlSpot(6, 16),
    ],
  };

  // X-axis labels untuk Pages
  final Map<String, List<String>> _pagesXLabels = {
    'day': ['10/30', '10/31', '11/01', '11/02', '11/03', '11/04', '11/06', '11/07'],
    'week': ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6', 'Week 7'],
    'month': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
  };

  // X-axis labels untuk Engagement
  final Map<String, List<String>> _engagementXLabels = {
    'day': ['11/10', '11/11', '11/12', '11/13', '11/14', '11/15', '11/16', '11/17'],
    'week': ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6', 'Week 7'],
    'month': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
  };

  // Max Y values untuk charts
  final Map<String, double> _pagesMaxY = {
    'day': 6,
    'week': 6,
    'month': 6,
  };

  final Map<String, double> _engagementMaxY = {
    'day': 18,
    'week': 18,
    'month': 18,
  };

  // Statistics data
  final Map<String, Map<String, dynamic>> _statisticsData = {
    'DAY': {
      'engagement': '00:15:33',
      'completion': '0.5%',
      'verses': 3,
      'recitation': '00:12',
      'badges': 0,
      'deeds': '1.2K',
      'searches': 2,
      'shared': 0,
    },
    'WEEK': {
      'engagement': '1:22:45',
      'completion': '1.5%',
      'verses': 8,
      'recitation': '01:05',
      'badges': 1,
      'deeds': '8.5K',
      'searches': 5,
      'shared': 1,
    },
    'MONTH': {
      'engagement': '4:12:18',
      'completion': '3%',
      'verses': 25,
      'recitation': '03:45',
      'badges': 3,
      'deeds': '28.3K',
      'searches': 8,
      'shared': 2,
    },
    'YEAR': {
      'engagement': '45:33:22',
      'completion': '18%',
      'verses': 456,
      'recitation': '38:22',
      'badges': 18,
      'deeds': '342K',
      'searches': 89,
      'shared': 15,
    },
    'LIFETIME': {
      'engagement': '1:33:51',
      'completion': '2%',
      'verses': 13,
      'recitation': '02:05',
      'badges': 6,
      'deeds': '131.44K',
      'searches': 12,
      'shared': 2,
    },
  };

  // Mapping label → key sebenarnya untuk statistics
  String _mapTabToKey(String tab) {
    switch (tab) {
      case 'THIS DAY':
        return 'DAY';
      case 'THIS WEEK':
        return 'WEEK';
      case 'THIS MONTH':
        return 'MONTH';
      case 'THIS YEAR':
        return 'YEAR';
      case 'ALL TIME':
        return 'LIFETIME';
      default:
        return 'LIFETIME';
    }
  }

  // Mapping global filter to statistics tab
  String _mapGlobalToStatTab(String global) {
    switch (global) {
      case 'day':
        return 'THIS DAY';
      case 'week':
        return 'THIS WEEK';
      case 'month':
        return 'THIS MONTH';
      default:
        return 'THIS DAY';
    }
  }

  // Format engagement time with suffix (m or h)
  String _formatEngagementWithSuffix(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      // Format: MM:SS
      final minutes = int.parse(parts[0]);
      return '$timeStr (${minutes}m)';
    } else if (parts.length == 3) {
      // Format: HH:MM:SS or H:MM:SS
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      
      if (hours > 0) {
        return '$timeStr (${hours}h ${minutes}m)';
      } else if (minutes >= 60) {
        final h = minutes ~/ 60;
        final m = minutes % 60;
        return '$timeStr (${h}h ${m}m)';
      } else {
        return '$timeStr (${minutes}m)';
      }
    }
    return timeStr;
  }

  // Handle global filter change
  void _onGlobalFilterChanged(String? newValue) {
    if (newValue == null) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _globalFilter = newValue;
      _pagesTimeframe = newValue;
      _engagementTimeframe = newValue;
      _statisticsTimeframe = _mapGlobalToStatTab(newValue);
    });
  }

  void _changeTimeframe(String currentTimeframe, bool isNext, bool isPages) {
    final currentIndex = _timeframeOptions.indexOf(currentTimeframe);
    int newIndex;

    if (isNext) {
      newIndex = (currentIndex + 1) % _timeframeOptions.length;
    } else {
      newIndex = (currentIndex - 1 + _timeframeOptions.length) % _timeframeOptions.length;
    }

    setState(() {
      if (isPages) {
        _pagesTimeframe = _timeframeOptions[newIndex];
      } else {
        _engagementTimeframe = _timeframeOptions[newIndex];
      }
      // Update global filter to match if they were synced
      if (_pagesTimeframe == _engagementTimeframe) {
        _globalFilter = _pagesTimeframe;
        _statisticsTimeframe = _mapGlobalToStatTab(_pagesTimeframe);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 406.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const MenuAppBar(selectedIndex: 4),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 20 * s, 32 * s),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGlobalFilterDropdown(s),
                  SizedBox(height: 24 * s),
                  _buildPagesChart(s),
                  SizedBox(height: 24 * s),
                  _buildEngagementChart(s),
                  SizedBox(height: 24 * s),
                  _buildStatistics(s),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildGlobalFilterDropdown(double s) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8 * s),
      border: Border.all(color: const Color(0xFFE0E0E0), width: 1 * s),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.filter_list_rounded,
          color: Colors.black87,
          size: 16 * s,
        ),
        SizedBox(width: 6 * s),
        Text(
          'Filter Period:',
          style: TextStyle(
            fontSize: 12.5 * s,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 1.5 * s),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6 * s),
          ),
          child: DropdownButton<String>(
            value: _globalFilter,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black87,
              size: 18 * s,
            ),
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8 * s),
            items: _globalFilterOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: _onGlobalFilterChanged,
          ),
        ),
      ],
    ),
  );
}



  Widget _buildPagesChart(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pages',
              style: TextStyle(
                fontSize: 18 * s,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
            _buildTimeframeSelector(_pagesTimeframe, true, s),
          ],
        ),
        SizedBox(height: 16 * s),
        Container(
          padding: EdgeInsets.all(20 * s),
          height: 200 * s,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
          ),
          child: _buildLineChart(
            _pagesData[_pagesTimeframe]!,
            _pagesMaxY[_pagesTimeframe]!,
            _pagesXLabels[_pagesTimeframe]!,
            s,
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementChart(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Engagement',
              style: TextStyle(
                fontSize: 18 * s,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
            _buildTimeframeSelector(_engagementTimeframe, false, s),
          ],
        ),
        SizedBox(height: 16 * s),
        Container(
          padding: EdgeInsets.all(20 * s),
          height: 200 * s,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
          ),
          child: _buildLineChart(
            _engagementData[_engagementTimeframe]!,
            _engagementMaxY[_engagementTimeframe]!,
            _engagementXLabels[_engagementTimeframe]!,
            s,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector(String current, bool isPages, double s) {
    return Row(
      children: [
        _buildSelectorButton(
          Icons.chevron_left,
          () => _changeTimeframe(current, false, isPages),
          s,
        ),
        SizedBox(width: 12 * s),
        Text(
          current.toUpperCase(),
          style: TextStyle(
            fontSize: 14 * s,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 12 * s),
        _buildSelectorButton(
          Icons.chevron_right,
          () => _changeTimeframe(current, true, isPages),
          s,
        ),
      ],
    );
  }

  Widget _buildSelectorButton(IconData icon, VoidCallback onTap, double s) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(6 * s),
      child: Container(
        width: 28 * s,
        height: 28 * s,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6 * s),
        ),
        child: Icon(icon, size: 18 * s, color: Colors.black54),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots, double maxY, List<String> xLabels, double s) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: constants.primaryColor,
            barWidth: 2 * s,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3 * s,
                  color: constants.primaryColor,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: constants.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32 * s,
              interval: maxY / 3,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10 * s,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28 * s,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < xLabels.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8 * s),
                    child: Text(
                      xLabels[index],
                      style: TextStyle(
                        fontSize: 9 * s,
                        color: constants.primaryColor.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 3,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFF0F0F0),
              strokeWidth: 1 * s,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  Widget _buildStatistics(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18 * s,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 16 * s),
        Container(
          padding: EdgeInsets.all(20 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
          ),
          child: Column(
            children: [
              _buildStatisticsTabs(s),
              SizedBox(height: 24 * s),
              _buildStatisticsGrid(s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTabs(double s) {
    final tabs = ['THIS DAY', 'THIS WEEK', 'THIS MONTH', 'THIS YEAR', 'ALL TIME'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab == _statisticsTimeframe;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _statisticsTimeframe = tab);
            },
            child: Container(
              margin: EdgeInsets.only(right: 8 * s),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 8 * s,
              ),
              decoration: BoxDecoration(
                color: isSelected ? constants.primaryColor : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8 * s),
                border: Border.all(
                  color: isSelected ? constants.primaryColor : const Color(0xFFE0E0E0),
                  width: 1 * s,
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatisticsGrid(double s) {
    final mappedKey = _mapTabToKey(_statisticsTimeframe);
    final data = _statisticsData[mappedKey]!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                _formatEngagementWithSuffix(data['engagement']), // MODIFIED: Add suffix
                'Engagement',
                Icons.access_time_rounded,
                constants.primaryColor,
                s,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _buildStatCard(
                data['completion'],
                'Completion',
                Icons.check_circle_outline_rounded,
                constants.correctColor,
                s,
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * s),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                data['verses'].toString(),
                'Verses Recited',
                Icons.menu_book_rounded,
                constants.listeningColor,
                s,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _buildStatCard(
                data['recitation'],
                'Recitation Time',
                Icons.timer_outlined,
                constants.accentColor,
                s,
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * s),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                data['badges'].toString(),
                'Earned Badges',
                Icons.emoji_events_outlined,
                constants.warningColor,
                s,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _buildStatCard(
                data['deeds'],
                'Deeds Estimated',
                Icons.favorite_border_rounded,
                const Color(0xFFE74C3C),
                s,
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * s),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                data['searches'].toString(),
                'Search Queries',
                Icons.search_rounded,
                const Color(0xFF3498DB),
                s,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _buildStatCard(
                data['shared'].toString(),
                'Verses Shared',
                Icons.share_outlined,
                constants.primaryColor,
                s,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    double s,
  ) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32 * s,
                height: 32 * s,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Icon(icon, color: color, size: 18 * s),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Text(
            value,
            style: TextStyle(
              fontSize: 22 * s,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: TextStyle(
              fontSize: 11 * s,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}