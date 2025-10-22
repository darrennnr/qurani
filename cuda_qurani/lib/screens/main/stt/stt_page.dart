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
  final int suratId;
  const SttPage({Key? key, required this.suratId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final controller = SttController(suratId: suratId);
            // Delay initialization to ensure provider is ready
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
            appBar: const QuranAppBar(),
            body: controller.isLoading
                ? const SizedBox.shrink() // No loading UI - instant load
                : controller.errorMessage.isNotEmpty &&
                      controller.errorMessage.contains('rejected')
                ? Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: errorColor.withOpacity(0.9),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
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
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: _buildQuranText(controller),
                  ),
                ),
              ],
            ),
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

  Widget _buildQuranText(SttController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: controller.isQuranMode
          ? const MushafDisplay()
          : const QuranListView(), // HAPUS SingleChildScrollView wrapper
    );
  }
}
