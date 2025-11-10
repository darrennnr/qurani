import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../utils/constants.dart';

class QuranTopBar extends StatelessWidget {
  const QuranTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final containerHeight = screenHeight * 0.1125; // ✅ ~90px
    final containerPaddingTop = screenHeight * 0.02; // ✅ ~16px
    final containerPaddingRight = screenWidth * 0.04; // ✅ ~16px
    final badgePaddingH = screenWidth * 0.03; // ✅ ~12px
    final badgePaddingV = screenHeight * 0.01; // ✅ ~8px
    final iconSize = screenWidth * 0.04; // ✅ ~16px
    final textSize = screenWidth * 0.03; // ✅ ~12px
    final spacing = screenWidth * 0.015; // ✅ ~6px

    return Container(
      height: containerHeight, // ✅ GANTI dari 90
      padding: EdgeInsets.only(
        top: containerPaddingTop, // ✅ GANTI dari 16
        right: containerPaddingRight, // ✅ GANTI dari 16
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Consumer<SttController>(
            builder: (context, controller, child) {
              return GestureDetector(
                onTap: !controller.isConnected ? () async {
                  await controller.reconnect();
                } : null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: badgePaddingH, // ✅ GANTI dari 12
                    vertical: badgePaddingV, // ✅ GANTI dari 8
                  ),
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
                        size: iconSize, // ✅ GANTI dari 16
                      ),
                      SizedBox(width: spacing), // ✅ GANTI dari 6
                      Text(
                        controller.isConnected ? 'Connected' : 'Tap to reconnect',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: textSize, // ✅ GANTI dari 12
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final containerHeight = screenHeight * 0.1125; // ✅ ~90px
    final buttonSize = screenWidth * 0.1625; // ✅ ~65px
    final iconSize = screenWidth * 0.065; // ✅ ~26px

    return Container(
      height: containerHeight, // ✅ GANTI dari 90
      alignment: Alignment.center,
      child: Consumer<SttController>(
        builder: (context, controller, child) {
          return Container(
            width: buttonSize, // ✅ GANTI dari 65
            height: buttonSize, // ✅ GANTI dari 65
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
                borderRadius: BorderRadius.circular(buttonSize / 2), // ✅ GANTI dari 30
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
                  size: iconSize, // ✅ GANTI dari 26
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}