// lib/screens/main/home/screens/settings/submenu/reminders.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';

/// ==================== REMINDERS SETTINGS PAGE ====================
/// Halaman untuk mengatur reminder/pengingat aplikasi

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  // Default state untuk streak reminder (dummy state)
  bool _streakReminderEnabled = false;

  void _toggleStreakReminder(bool value) {
    setState(() {
      _streakReminderEnabled = value;
    });
    AppHaptics.selection();
    
    // TODO: Implement reminder toggle logic
    // Example: Save to SharedPreferences or update via Provider
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(
        title: 'Reminders',
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Reminder Option
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space16 * s * 0.9,
                  vertical: AppDesignSystem.space16 * s * 0.9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s * 0.9),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1.0 * s * 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Streak Reminder',
                        style: TextStyle(
                          fontSize: 16 * s * 0.9,
                          fontWeight: AppTypography.regular,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Switch button
                    Switch(
                      value: _streakReminderEnabled,
                      onChanged: _toggleStreakReminder,
                              activeColor: Color(0xFF4CAF50),
                      inactiveThumbColor: AppColors.borderMedium,
                      inactiveTrackColor: AppColors.borderLight,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDesignSystem.space16 * s * 0.9),

              // Info text and Allow button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Please allow notifications in your device settings to receive reminders.',
                      style: TextStyle(
                        fontSize: 14 * s * 0.9,
                        fontWeight: AppTypography.regular,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                  // Allow button
                  ElevatedButton(
                    onPressed: () {
                      AppHaptics.selection();
                      // TODO: Open device notification settings
                      // Example: AppSettings.openNotificationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignSystem.space20 * s * 1.5,
                        vertical: AppDesignSystem.space10 * s * 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s * 1.5),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Allow',
                      style: TextStyle(
                        fontSize: 14 * s * 0.9,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}