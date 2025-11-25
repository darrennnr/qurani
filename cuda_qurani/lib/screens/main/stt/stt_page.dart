// lib\screens\main\stt\stt_page.dart

import 'controllers/stt_controller.dart';
import 'services/quran_service.dart';
import 'utils/constants.dart';
import 'widgets/quran_widgets.dart';
import 'widgets/mushaf_view.dart';
import 'widgets/list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SttPage extends StatelessWidget {
  final int? suratId;
  final int? pageId;
  final int? juzId;
  final Map<String, dynamic>? resumeSession; // ✅ NEW: Resume parameter

  const SttPage({
    Key? key, 
    this.suratId, 
    this.pageId, 
    this.juzId,
    this.resumeSession, // ✅ NEW
  }) : assert(
        // ✅ Allow resumeSession OR one of the navigation params
        resumeSession != null || 
        (suratId != null ? 1 : 0) +
                (pageId != null ? 1 : 0) +
                (juzId != null ? 1 : 0) ==
            1,
        'Provide either resumeSession OR exactly one of suratId, pageId, or juzId',
      ),
      super(key: key);

@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) {
          // ✅ Extract suratId from resumeSession if provided
          int? effectiveSuratId = suratId;
          int? effectivePageId = pageId;
          int? effectiveJuzId = juzId;
          
          if (resumeSession != null) {
            effectiveSuratId = resumeSession!['surah_id'] as int?;
            // Could also get page/juz from session if needed
          }
          
          final controller = SttController(
            suratId: effectiveSuratId,
            pageId: effectivePageId,
            juzId: effectiveJuzId,
          );
          
          // ✅ Initialize app first, then resume if session provided
          Future.microtask(() async {
            await controller.initializeApp();
            
            // ✅ Auto-resume if session provided
            if (resumeSession != null) {
              print('🔄 SttPage: Auto-resuming session...');
              await Future.delayed(const Duration(milliseconds: 500));
              await controller.resumeFromSession(resumeSession!);
            }
          });
          
          return controller;
        },
      ),
      Provider(create: (_) => QuranService()),
    ],
    child: Consumer<SttController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          extendBodyBehindAppBar: true, // ✅ Key: Body extends behind AppBar
          appBar: const QuranAppBar(),
          body: controller.isLoading
              ? const SizedBox.shrink()
              : controller.errorMessage.isNotEmpty
              ? Column(
                  children: [
                    // Error banner below AppBar
                    SizedBox(height: kToolbarHeight * 0.86),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.015,
                      ),
                      color: errorColor.withOpacity(0.9),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Expanded(
                            child: Text(
                              controller.errorMessage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.035,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width * 0.05,
                            ),
                            onPressed: controller.clearError,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.toggleUIVisibility,
                        child: Column(
                          children: [
                            Expanded(child: _buildMainContent()),
                            if (controller.showLogs && controller.isUIVisible)
                              const QuranLogsPanel(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: controller.toggleUIVisibility,
                  child: Column(
                    children: [
                      Expanded(child: _buildMainContent()),
                      if (controller.showLogs && controller.isUIVisible)
                        const QuranLogsPanel(),
                    ],
                  ),
                ),
        );
      },
    ),
  );
}

  Widget _buildMainContent() {
    return Consumer<SttController>(
      builder: (context, controller, child) {
        return Stack(
          children: [
            _buildQuranText(context, controller), // ✅ FIX: pass context
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: QuranBottomBar(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuranText(BuildContext context, SttController controller) {
  final screenWidth = MediaQuery.of(context).size.width;
  final margin = screenWidth * 0.01;

  return Container(
    margin: EdgeInsets.fromLTRB(margin, 0, margin, 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200), // ✅ ADD: Smooth transition
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        // ✅ ADD: Fade transition for smooth mode switch
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: controller.isQuranMode
          ? MushafDisplay(
              key: ValueKey('mushaf_${controller.currentPage}'), // ✅ ADD: Unique key
            )
          : QuranListView(
              key: ValueKey('list_${controller.listViewCurrentPage}'), // ✅ ADD: Unique key
            ),
    ),
  );
}
}
