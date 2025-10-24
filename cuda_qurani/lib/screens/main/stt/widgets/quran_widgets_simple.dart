import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../utils/constants.dart';

class QuranTopBar extends StatelessWidget {
  const QuranTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Connection indicator
          Consumer<SttController>(
            builder: (context, controller, child) {
              return GestureDetector(
                onTap: !controller.isConnected ? () async {
                  await controller.reconnect();
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: controller.isConnected ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isConnected ? Icons.wifi : Icons.wifi_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.isConnected ? 'Connected' : 'Tap to reconnect',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class QuranBottomBar extends StatelessWidget {
  const QuranBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      alignment: Alignment.center,
      child: Consumer<SttController>(
        builder: (context, controller, child) {
          return Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: controller.isRecording ? errorColor : primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (controller.isRecording ? errorColor : primaryColor).withOpacity(0.3),
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
                        const SnackBar(content: Text('Connecting...')),
                      );
                      await controller.reconnect();
                    }
                    await controller.startRecording();
                  }
                },
                child: Icon(
                  controller.isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}