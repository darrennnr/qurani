// lib\screens\main\stt\widgets\quran_widgets.dart

import 'package:cuda_qurani/screens/main/home/surah_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../utils/constants.dart';

class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuranAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: controller.isUIVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !controller.isUIVisible,
        child: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, size: 24, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SurahListPage()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/qurani-white-text.png',
                        height: 13,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Surat ${controller.suratNameSimple} ${controller.suratId} - ${controller.suratVersesCount} Ayat',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          titleSpacing: 0,
          actions: [
            IconButton(
              icon: Icon(
                controller.isQuranMode ? Icons.list_alt : Icons.auto_stories,
                size: 20,
              ),
              onPressed: controller.toggleQuranMode,
              tooltip: controller.isQuranMode
                  ? 'Switch to List Mode'
                  : 'Switch to Mushaf Mode',
            ),
            IconButton(
              icon: Icon(
                controller.hideUnreadAyat
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: controller.toggleHideUnread,
              tooltip: controller.hideUnreadAyat
                  ? 'Show All Text'
                  : 'Hide Unread',
            ),
            PopupMenuButton<String>(
              onSelected: (action) =>
                  controller.handleMenuAction(context, action),
              iconSize: 20,
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'logs', child: Text('Debug Logs')),
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('Reset Session'),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export Session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class QuranBottomBar extends StatelessWidget {
  const QuranBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: controller.isUIVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !controller.isUIVisible,
        child: Container(
          height: 90,
          child: Stack(
            children: [
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: controller.isRecording ? errorColor : primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (controller.isRecording
                                      ? errorColor
                                      : primaryColor)
                                  .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () async {
                          if (controller.isRecording) {
                            await controller.stopRecording();
                          } else {
                            if (!controller.isConnected) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Connecting to server...'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              await controller.reconnect();
                              if (!controller.isConnected) return;
                            }
                            await controller.startRecording();
                          }
                        },
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              controller.isRecording ? Icons.stop : Icons.mic,
                              key: ValueKey(controller.isRecording),
                              color: Colors.white,
                              size: 26,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
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
          const SizedBox(height: 12),
          const Text(
            'Initializing App...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            errorMessage.isNotEmpty ? errorMessage : 'Loading Quran data...',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: errorColor.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: errorColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'App Initialization Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                controller.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.initializeApp,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: controller.toggleLogs,
                  icon: const Icon(Icons.bug_report, size: 16),
                  label: const Text(
                    'View Logs',
                    style: TextStyle(fontSize: 12),
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

    return Container(
      height: 150,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: correctColor, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'API Debug Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white, size: 16),
                  onPressed: controller.clearLogs,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.save_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () => controller.exportSession(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
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
                  padding: const EdgeInsets.all(4),
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
                          fontSize: 8,
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

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final sessionDuration = controller.sessionStartTime != null
          ? DateTime.now().difference(controller.sessionStartTime!).inMinutes
          : 0;

      return AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.celebration, color: correctColor, size: 24),
            SizedBox(width: 8),
            Text('Surah Completed!', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: correctColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '🎉 Congratulations! 🎉',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have completed reading ${controller.suratNameSimple}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      _buildStatItem('Ayat', '${controller.ayatList.length}'),
                      _buildStatItem('Time', '${sessionDuration}min'),
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

Widget _buildStatItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
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
