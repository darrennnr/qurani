// lib/screens/main/home/screens/settings/submenu/reciters_download.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/audio_manager.dart';

/// ==================== RECITERS DOWNLOAD PAGE ====================
/// Halaman untuk memilih dan mendownload audio reciter Quran

class RecitersDownloadPage extends StatefulWidget {
  const RecitersDownloadPage({Key? key}) : super(key: key);

  @override
  State<RecitersDownloadPage> createState() => _RecitersDownloadPageState();
}

class _RecitersDownloadPageState extends State<RecitersDownloadPage> {
  // Dummy list of reciters
  final List<Map<String, String>> _reciters = [
    {
      'name': 'Abdul Basit Abd us-Samad (Mujawwad)',
      'identifier': 'abdul_basit_mujawwad',
    },
    {
      'name': 'Abdul Basit Abd us-Samad (Murattal)',
      'identifier': 'abdul_basit_murattal',
    },
    {
      'name': 'Abdul-Rahman Al-Sudais',
      'identifier': 'abdul_rahman_al_sudais',
    },
    {
      'name': 'Abu Bakr Al-Shatri',
      'identifier': 'abu_bakr_al_shatri',
    },
    {
      'name': 'Ahmad Alnufais',
      'identifier': 'ahmad_alnufais',
    },
    {
      'name': 'Khalifa Al-Tunaiji',
      'identifier': 'khalifa_al_tunaiji',
    },
    {
      'name': 'Maher Al-Muaiqly',
      'identifier': 'maher_al_muaiqly',
    },
    {
      'name': 'Mahmoud Husary (Muallim)',
      'identifier': 'mahmoud_husary_muallim',
    },
    {
      'name': 'Mahmoud Husary (Mujawwad)',
      'identifier': 'mahmoud_husary_mujawwad',
    },
    {
      'name': 'Mahmoud Husary (Murattal)',
      'identifier': 'mahmoud_husary_murattal',
    },
    {
      'name': 'Mishari Al-Afasy',
      'identifier': 'mishari_al_afasy',
    },
    {
      'name': 'Muhammad Siddiq Al Minshaway (Murattal)',
      'identifier': 'muhammad_siddiq_al_minshaway',
    },
    {
      'name': 'Saad Ghamadi',
      'identifier': 'saad_ghamadi',
    },
  ];

  void _openAudioManager(String reciterName, String identifier) {
    AppHaptics.light();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AudioManagerPage(
          reciterName: reciterName,
          reciterIdentifier: identifier,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.03, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
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
  }

  Widget _buildReciterItem({
    required String name,
    required String identifier,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);

    return InkWell(
      onTap: () => _openAudioManager(name, identifier),
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s * 0.9),
      child: Container(
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
                name,
                style: TextStyle(
                  fontSize: 16 * s * 0.9,
                  fontWeight: AppTypography.regular,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24 * s * 0.9,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(
        title: 'Reciters',
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
          children: [
            // Section header
            Text(
              'Available Downloads',
              style: TextStyle(
                fontSize: 14 * s * 0.9,
                fontWeight: AppTypography.medium,
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: AppDesignSystem.space16 * s * 0.9),

            // List of reciters
            ...List.generate(_reciters.length, (index) {
              final reciter = _reciters[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _reciters.length - 1
                      ? AppDesignSystem.space16 * s * 0.9
                      : 0,
                ),
                child: _buildReciterItem(
                  name: reciter['name']!,
                  identifier: reciter['identifier']!,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}