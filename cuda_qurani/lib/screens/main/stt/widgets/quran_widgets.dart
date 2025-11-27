// lib\screens\main\stt\widgets\quran_widgets.dart
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/models/playback_settings_model.dart';
import 'package:cuda_qurani/screens/main/home/screens/surah_list_page.dart';
import 'package:cuda_qurani/screens/main/stt/widgets/playback_settings.dart';
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
              Navigator.pop(
                context
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

class QuranBottomBar extends StatefulWidget {
  const QuranBottomBar({Key? key}) : super(key: key);

  @override
  State<QuranBottomBar> createState() => _QuranBottomBarState();
}

class _QuranBottomBarState extends State<QuranBottomBar>
    with SingleTickerProviderStateMixin {
  bool _isMenuExpanded = false;
  String _selectedMode = 'recite';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final containerHeight = screenHeight * 0.15;
    final buttonSize = screenWidth * 0.165;
    final iconSize = screenWidth * 0.07;
    final bottomOffset = screenHeight * 0.030;

    final activeColor = controller.isRecording || controller.isListeningMode
        ? errorColor
        : primaryColor;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: controller.isUIVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !controller.isUIVisible,
        child: SizedBox(
          height: _isMenuExpanded ? containerHeight * 2.2 : containerHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Backdrop untuk menutup menu
              if (_isMenuExpanded)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isMenuExpanded = false),
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),

              // Menu Expanded (2 Container Terpisah)
              if (_isMenuExpanded)
                Positioned(
                  bottom: bottomOffset,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _isMenuExpanded ? 1.0 : 0.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      scale: _isMenuExpanded ? 1.0 : 0.8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Container 1: Label Container (Kiri)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildLabelItem(
                                label: "Listen",
                                isActive: _selectedMode == 'listen',
                                onTap: () =>
                                    _handleModeSelect(controller, 'listen'),
                              ),
                              SizedBox(height: buttonSize * 0.25),
                              _buildLabelItem(
                                label: "Recite",
                                isActive: _selectedMode == 'recite',
                                onTap: () =>
                                    _handleModeSelect(controller, 'recite'),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          // Container 2: Icon Button Container (Kanan)
                          Container(
                            width: buttonSize,
                            height: buttonSize * 1.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                buttonSize / 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildIconButton(
                                  icon: Icons.play_arrow_rounded,
                                  isActive: _selectedMode == 'listen',
                                  iconSize: iconSize,
                                  onTap: () =>
                                      _handleModeSelect(controller, 'listen'),
                                ),
                                // ✅ FIX: Add STOP button for listening mode
                                if (controller.isListeningMode)
                                  _buildIconButton(
                                    icon: Icons.stop_rounded,
                                    isActive: false,
                                    iconSize: iconSize,
                                    onTap: () async {
                                      await controller.stopListening();
                                      setState(() {
                                        _isMenuExpanded = false;
                                      });
                                    },
                                  )
                                else
                                  _buildIconButton(
                                    icon: Icons.mic_none_rounded,
                                    isActive: _selectedMode == 'recite',
                                    iconSize: iconSize,
                                    onTap: () =>
                                        _handleModeSelect(controller, 'recite'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Main Button (Collapsed State)
              if (!_isMenuExpanded)
                Positioned(
                  bottom: bottomOffset,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(buttonSize / 2),
                      onTap: () async {
                        // ✅ FIX: Haptic feedback immediately
                        AppHaptics.light();

                        if (_selectedMode == 'listen') {
                          // ====== LISTENING MODE ======
                          if (controller.isListeningMode) {
                            // Already listening
                            final audioService =
                                controller.listeningAudioService;
                            if (audioService != null) {
                              if (audioService.isPaused) {
                                // Resume playback
                                await controller.resumeListening();
                              } else {
                                // Pause playback
                                await controller.pauseListening();
                              }
                            }
                          } else {
                            // Not listening, show settings
                            print(
                              '🎵 LISTEN BUTTON: Opening playback settings',
                            );

                            final settings =
                                await Navigator.push<PlaybackSettings>(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const PlaybackSettingsPage(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          const begin = Offset(0.0, 0.3);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;
                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));
                                          var offsetAnimation = animation.drive(
                                            tween,
                                          );
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
                                    transitionDuration:
                                        AppDesignSystem.durationNormal,
                                  ),
                                );

                            if (settings != null) {
                              print('✅ Playback settings received: $settings');

                              // ✅ FIX: Try-catch untuk handle empty playlist
                              try {
                                await controller.startListening(settings);
                              } catch (e) {
                                print('❌ Failed to start listening: $e');

                                // Show error to user
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$e'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 5),
                                    ),
                                  );
                                }
                              }
                            } else {
                              print('⚠️ No settings selected, cancelled');
                            }
                          }
                        } else {
                          // ====== RECITE MODE (EXISTING LOGIC) ======
                          if (controller.isRecording) {
                            await controller.stopRecording();
                          } else {
                            await controller.startRecording();
                          }
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          _isMenuExpanded = true;
                        });
                        Feedback.forLongPress(context);
                      },
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _getIconForCurrentState(controller),
                              key: ValueKey(
                                '${_selectedMode}_${controller.isRecording}',
                              ),
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Small Arrow Button (Only visible when in Listen mode and not expanded)
              if (!_isMenuExpanded && _selectedMode == 'listen')
                Positioned(
                  bottom: bottomOffset + (buttonSize * 0.1),
                  right:
                      (MediaQuery.of(context).size.width / 2) -
                      (buttonSize * 1.15),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        (buttonSize * 0.4) / 2,
                      ),
                      onTap: () {
                        AppHaptics.light();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const PlaybackSettingsPage(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(0.0, 0.3);
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
                      // child: Container(
                      //   width: buttonSize * 0.5,
                      //   height: buttonSize * 0.5,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     shape: BoxShape.circle,
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: primaryColor.withOpacity(0.25),
                      //         blurRadius: 6,
                      //         offset: const Offset(0, 2),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Center(
                      //     child: Icon(
                      //       Icons.keyboard_arrow_up,
                      //       color: primaryColor,
                      //       size: iconSize * 1.1,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelItem({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(220, 0, 0, 0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isActive,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFEEEEEE) : Colors.transparent,
          ),
          child: Icon(icon, size: iconSize, color: Colors.black87),
        ),
      ),
    );
  }

  IconData _getIconForCurrentState(SttController controller) {
    if (_selectedMode == 'recite') {
      return controller.isRecording ? Icons.stop : Icons.mic;
    } else {
      // Listening mode
      if (controller.isListeningMode) {
        final audioService = controller.listeningAudioService;
        if (audioService != null && audioService.isPaused) {
          return Icons.play_arrow; // Show play when paused
        }
        return Icons.pause; // ✅ FIX: Show PAUSE (not stop) when playing
      }
      return Icons.play_arrow; // Default: show play
    }
  }

  Future<void> _handleModeSelect(SttController controller, String mode) async {
    if (controller.isRecording && mode != 'recite') {
      await controller.stopRecording();
    }

    setState(() {
      _selectedMode = mode;
      _isMenuExpanded = false;
    });
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
                controller.errorMessage ?? 'Unknown error occurred',
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
