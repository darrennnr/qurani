// lib\screens\main\stt\widgets\quran_widgets.dart
import 'package:cuda_qurani/screens/main/home/screens/surah_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../utils/constants.dart';

class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuranAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final iconSize = screenWidth * 0.060;
    final titleSize = screenWidth * 0.028;
    final subtitleSize = screenWidth * 0.028;
    final badgeSize = screenWidth * 0.028;

    // Determine display name
    String displaySurahName;
    if (controller.suratNameSimple.isNotEmpty) {
      displaySurahName = controller.suratNameSimple;
    } else if (controller.ayatList.isNotEmpty) {
      displaySurahName = 'Surah ${controller.ayatList.first.surah_id}';
    } else {
      displaySurahName = 'Loading...';
    }

    final int currentJuz = controller.currentPageAyats.isNotEmpty
        ? controller.calculateJuz(
            controller.currentPageAyats.first.surah_id,
            controller.currentPageAyats.first.ayah,
          )
        : 1;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: controller.isUIVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !controller.isUIVisible,
        child: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          toolbarHeight: kToolbarHeight * 0.80,
          leading: IconButton(
            icon: Icon(Icons.menu, size: iconSize * 120 / 100),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SurahListPage()),
              );
            },
            tooltip: 'Menu',
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/qurani-white-text.png',
                height: screenHeight * 0.016,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: screenHeight * 0.006),
              // Info Row with structured layout
              Row(
                children: [
                  // Surah Name
                  Flexible(
                    child: Text(
                      displaySurahName,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  // Separator
                  Container(
                    width: 1,
                    height: screenHeight * 0.016,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  // Juz Badge
                  Text(
                    'Juz $currentJuz',
                    style: TextStyle(
                      fontSize: badgeSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.1,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  // Separator
                  Container(
                    width: 1,
                    height: screenHeight * 0.016,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  // Page Number
                  Text(
                    'Hal ${controller.currentPage}',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          titleSpacing: 0,
          actions: [
            // Mode Toggle
// Mode Toggle
IconButton(
  icon: Icon(
    controller.isQuranMode
        ? Icons.vertical_split
        : Icons.auto_stories,
    size: iconSize * 0.9,
  ),
  onPressed: () async {
    // ✅ FIX: Await toggle completion
    await controller.toggleQuranMode();
    
    // ✅ FORCE: Trigger rebuild immediately
    if (context.mounted) {
      // Scroll to correct position after mode change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Trigger any pending navigation
        controller.notifyListeners();
      });
    }
  },
  tooltip: controller.isQuranMode
      ? 'Switch to List Mode'
      : 'Switch to Mushaf Mode',
  splashRadius: iconSize * 1.1,
),
            // Visibility Toggle
            IconButton(
              icon: Icon(
                controller.hideUnreadAyat
                    ? Icons.visibility
                    : Icons.visibility_off,
                size: iconSize * 0.9,
              ),
              onPressed: controller.toggleHideUnread,
              tooltip: controller.hideUnreadAyat
                  ? 'Show All Text'
                  : 'Hide Unread',
              splashRadius: iconSize * 1.1,
            ),
            // More Options Menu
            PopupMenuButton<String>(
              onSelected: (action) =>
                  controller.handleMenuAction(context, action),
              icon: Icon(Icons.settings, size: iconSize * 0.9),
              splashRadius: iconSize * 1.1,
              offset: Offset(0, screenHeight * 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'logs',
                  child: Row(
                    children: [
                      Icon(
                        Icons.bug_report_outlined,
                        size: iconSize * 0.75,
                        color: primaryColor,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text('Debug Logs'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh_outlined,
                        size: iconSize * 0.75,
                        color: primaryColor,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text('Reset Session'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        size: iconSize * 0.75,
                        color: primaryColor,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text('Export Session'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: screenWidth * 0.01),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 0.86);
}

class QuranBottomBar extends StatelessWidget {
  const QuranBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final containerHeight = screenHeight * 0.15; // ✅ ~120px pada 800px height
    final buttonSize = screenWidth * 0.1625; // ✅ ~65px pada 400px width
    final iconSize = screenWidth * 0.065; // ✅ ~26px pada 400px width
    final bottomOffset = screenHeight * 0.030; // ✅ ~40px pada 800px height

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: controller.isUIVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !controller.isUIVisible,
        child: SizedBox(
          height: containerHeight,
          child: Stack(
            children: [
              Positioned(
                bottom: bottomOffset,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          controller.isRecording
                              ? const Color(0xFFD32F2F)  // Red - Stop
                              : (controller.hasResumableSession
                                  ? const Color(0xFFFF9800)  // Orange - Resume
                                  : primaryColor),  // Blue - Start New
                          controller.isRecording
                              ? const Color(0xFFB71C1C)
                              : (controller.hasResumableSession
                                  ? const Color(0xFFF57C00)
                                  : primaryColor.withOpacity(0.8)),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (controller.isRecording
                                  ? const Color(0xFFD32F2F)
                                  : (controller.hasResumableSession
                                      ? const Color(0xFFFF9800)
                                      : primaryColor))
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(buttonSize / 2),
                        onTap: () async {
                          print('🎤 BUTTON: Record button pressed');
                          print('   isRecording: ${controller.isRecording}');
                          print('   hasResumableSession: ${controller.hasResumableSession}');
                          
                          if (controller.isRecording) {
                            // Stop recording
                            print('🛑 BUTTON: Stopping recording...');
                            await controller.stopRecording();
                            print('✅ BUTTON: Recording stopped');
                          } else if (controller.hasResumableSession) {
                            // Resume session
                            print('▶️ BUTTON: Resuming session...');
                            await controller.resumeLastSession();
                            print('✅ BUTTON: Session resumed');
                          } else {
                            // Start new recording
                            print('▶️ BUTTON: Starting new recording...');
                            await controller.startRecording();
                            print('✅ BUTTON: Recording started');
                          }
                        },
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              controller.isRecording
                                  ? Icons.stop
                                  : (controller.hasResumableSession
                                      ? Icons.play_arrow  // Play icon for resume
                                      : Icons.mic),  // Mic icon for new
                              key: ValueKey('${controller.isRecording}_${controller.hasResumableSession}'),
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ),
                        ),
                      ),
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
}

class QuranLoadingWidget extends StatelessWidget {
  final String errorMessage;
  const QuranLoadingWidget({Key? key, required this.errorMessage})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final containerSize = screenWidth * 0.15; // ✅ ~60px pada 400px width
    final titleSize = screenWidth * 0.04; // ✅ ~16px pada 400px width
    final messageSize = screenWidth * 0.03;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            'Initializing App...',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            errorMessage.isNotEmpty ? errorMessage : 'Loading Quran data...',
            style: TextStyle(
              fontSize: messageSize,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QuranErrorWidget extends StatelessWidget {
  const QuranErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SttController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final containerSize = screenWidth * 0.2;
    final iconSize = screenWidth * 0.1;
    final titleSize = screenWidth * 0.045;
    final messageSize = screenWidth * 0.03;
    final buttonTextSize = screenWidth * 0.03;
    final iconButtonSize = screenWidth * 0.04;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: errorColor.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.error_outline,
                size: iconSize,
                color: errorColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'App Initialization Error',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                controller.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: messageSize),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.initializeApp,
                  icon: Icon(Icons.refresh, size: iconButtonSize),
                  label: Text(
                    'Retry',
                    style: TextStyle(fontSize: buttonTextSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.005,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                TextButton.icon(
                  onPressed: controller.toggleLogs,
                  icon: Icon(Icons.bug_report, size: iconButtonSize),
                  label: Text(
                    'View Logs',
                    style: TextStyle(fontSize: buttonTextSize),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuranLogsPanel extends StatelessWidget {
  const QuranLogsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final panelHeight = screenHeight * 0.1875; // ✅ ~150px pada 800px
    final iconSize = screenWidth * 0.04; // ✅ ~16px
    final titleSize = screenWidth * 0.03;
    final logFontSize = screenWidth * 0.02; // ✅ ~8px
    final paddingH = screenWidth * 0.02; // ✅ ~8px
    final paddingV = screenHeight * 0.0075; // ✅ ~6px

    return Container(
      height: panelHeight,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: paddingH,
              vertical: paddingV,
            ),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, color: correctColor, size: iconSize),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  'API Debug Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.white, size: iconSize),
                  onPressed: controller.clearLogs,
                ),
                IconButton(
                  icon: Icon(
                    Icons.save_alt,
                    color: Colors.white,
                    size: iconSize,
                  ),
                  onPressed: () => controller.exportSession(context),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: iconSize),
                  onPressed: controller.toggleLogs,
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: controller.appLogger.logs,
              builder: (context, logs, child) {
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(screenWidth * 0.01),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final logIndex = logs.length - 1 - index;
                    final log = logs[logIndex];
                    Color logColor = Colors.greenAccent;
                    if (log.contains('ERROR') || log.contains('Failed'))
                      logColor = Colors.redAccent;
                    else if (log.contains('WARNING') || log.contains('Warning'))
                      logColor = Colors.orangeAccent;
                    else if (log.contains('API_') || log.contains('WEBSOCKET'))
                      logColor = Colors.cyanAccent;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        log,
                        style: TextStyle(
                          color: logColor,
                          fontSize: logFontSize,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showCompletionDialog(BuildContext context, SttController controller) {
  if (!context.mounted) return;

  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final iconSize = screenWidth * 0.06;
  final titleSize = screenWidth * 0.045;
  final congratsSize = screenWidth * 0.05;
  final messageSize = screenWidth * 0.035;
  final statLabelSize = screenWidth * 0.03;
  final statValueSize = screenWidth * 0.035;

  final sessionDuration = controller.sessionStartTime != null
      ? DateTime.now().difference(controller.sessionStartTime!).inMinutes
      : 0;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: correctColor, size: iconSize),
            SizedBox(width: screenWidth * 0.02),
            Text('Surah Completed!', style: TextStyle(fontSize: titleSize)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: correctColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '🎉 Congratulations! 🎉',
                    style: TextStyle(
                      fontSize: congratsSize,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'You have completed reading ${controller.suratNameSimple}',
                    style: TextStyle(fontSize: messageSize),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Column(
                    children: [
                      _buildStatItem(
                        'Ayat',
                        '${controller.ayatList.length}',
                        statLabelSize,
                        statValueSize,
                      ),
                      _buildStatItem(
                        'Time',
                        '${sessionDuration}min',
                        statLabelSize,
                        statValueSize,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Finish', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

Widget _buildStatItem(
  String label,
  String value,
  double labelSize,
  double valueSize,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: labelSize, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    ),
  );
}

void showSimpleSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
}) {
  if (!ScaffoldMessenger.of(context).mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(fontSize: 12)),
      backgroundColor: backgroundColor ?? primaryColor,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}
