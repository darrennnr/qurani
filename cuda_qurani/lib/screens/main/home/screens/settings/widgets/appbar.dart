// lib/screens/main/home/screens/settings/widgets/appbar.dart
import 'package:cuda_qurani/screens/main/home/screens/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';

/// ==================== SETTINGS SUBMENU APP BAR ====================
/// AppBar khusus untuk submenu settings dengan design 100% sama seperti ProfileAppBar
/// Digunakan untuk: Theme, Language, Recitation Settings, dll.

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SettingsAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leadingWidth: 56 * s,
      leading: showBackButton
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  AppHaptics.light();
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SettingsPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-0.03, 0.0);
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
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusSmall * s,
                ),
                splashColor: AppComponentStyles.rippleColor,
                child: Container(
                  padding: EdgeInsets.only(left: AppDesignSystem.space12 * s),
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: AppDesignSystem.iconMedium * s,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: AppTypography.titleLarge(
          context,
          weight: AppTypography.semiBold,
        ),
      ),
      actions: actions,
    );
  }
}