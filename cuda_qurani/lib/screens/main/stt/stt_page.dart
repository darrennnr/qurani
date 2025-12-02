// lib\screens\main\stt\stt_page.dart

import 'package:cuda_qurani/screens/main/stt/widgets/slider_guide_popup.dart';

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

  const SttPage({
    Key? key,
    this.suratId,
    this.pageId,
    this.juzId,
  }) : assert(
        (suratId != null ? 1 : 0) +
                (pageId != null ? 1 : 0) +
                (juzId != null ? 1 : 0) ==
            1,
        'Exactly one of suratId, pageId, or juzId must be provided',
      ),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final controller = SttController(
              suratId: suratId,
              pageId: pageId,
              juzId: juzId,
            );
            Future.microtask(() => controller.initializeApp());
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
                : (controller.errorMessage?.isNotEmpty ?? false)
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
                                controller.errorMessage ?? 'An error occurred',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
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
          _buildQuranText(context, controller),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: QuranBottomBar(),
          ),
          // ✅ TAMBAHKAN INI - Popup Guide
          const SliderGuidePopup(),
        ],
      );
    },
  );
}

  Widget _buildQuranText(BuildContext context, SttController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.03; // 1% padding to perfectly center the text

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
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
          return FadeTransition(opacity: animation, child: child);
        },
        child: controller.isQuranMode
            ? MushafDisplay(
                key: ValueKey(
                  'mushaf_${controller.currentPage}',
                ), // ✅ ADD: Unique key
              )
            : QuranListView(
                key: ValueKey(
                  'list_${controller.listViewCurrentPage}',
                ), // ✅ ADD: Unique key
              ),
      ),
    );
  }
}
