// lib/screens/main/home/screens/settings/submenu/session_start&stop.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';

/// ==================== SESSION START & STOP SETTINGS PAGE ====================
/// Halaman untuk mengatur pengaturan feedback saat sesi dimulai dan dihentikan

class SessionStartStopPage extends StatefulWidget {
  const SessionStartStopPage({Key? key}) : super(key: key);

  @override
  State<SessionStartStopPage> createState() => _SessionStartStopPageState();
}

class _SessionStartStopPageState extends State<SessionStartStopPage> {
  // Default states untuk semua toggle (dummy state)
  bool _playSound = true;
  bool _vibrateDevice = true;

  void _togglePlaySound(bool value) {
    setState(() {
      _playSound = value;
    });
    AppHaptics.selection();

    // TODO: Implement toggle logic
  }

  void _toggleVibrateDevice(bool value) {
    setState(() {
      _vibrateDevice = value;
    });
    AppHaptics.selection();

    // TODO: Implement toggle logic
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(title: 'Session Start & Stop'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sound Section
                Text(
                  'Sound',
                  style: TextStyle(
                    fontSize: 14 * s * 0.9,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Sound Container
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space16 * s * 0.9,
                    vertical: AppDesignSystem.space16 * s * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMedium * s * 0.9,
                    ),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.0 * s * 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 20 * s * 0.9,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                      Expanded(
                        child: Text(
                          'Play a sound',
                          style: TextStyle(
                            fontSize: 16 * s * 0.9,
                            fontWeight: AppTypography.regular,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Switch(
                        value: _playSound,
                        onChanged: _togglePlaySound,
                        activeColor: Color(0xFF4CAF50),
                        inactiveThumbColor: AppColors.borderMedium,
                        inactiveTrackColor: AppColors.borderLight,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Description text
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space4 * s * 0.9,
                  ),
                  child: Text(
                    'Adjust the sound played when a recitation session starts or stops.',
                    style: TextStyle(
                      fontSize: 14 * s * 0.9,
                      fontWeight: AppTypography.regular,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: AppDesignSystem.space24 * s * 0.9),

                // Haptic Section
                Text(
                  'Haptic',
                  style: TextStyle(
                    fontSize: 14 * s * 0.9,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Vibrate Container
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space16 * s * 0.9,
                    vertical: AppDesignSystem.space16 * s * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMedium * s * 0.9,
                    ),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.0 * s * 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.vibration,
                        size: 20 * s * 0.9,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                      Expanded(
                        child: Text(
                          'Vibrate my device',
                          style: TextStyle(
                            fontSize: 16 * s * 0.9,
                            fontWeight: AppTypography.regular,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Switch(
                        value: _vibrateDevice,
                        onChanged: _toggleVibrateDevice,
                        activeColor: Color(0xFF4CAF50),
                        inactiveThumbColor: AppColors.borderMedium,
                        inactiveTrackColor: AppColors.borderLight,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppDesignSystem.space12 * s * 0.9),

                // Description text
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space4 * s * 0.9,
                  ),
                  child: Text(
                    'Adjust the haptic feedback when a recitation session starts or stops.',
                    style: TextStyle(
                      fontSize: 14 * s * 0.9,
                      fontWeight: AppTypography.regular,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}