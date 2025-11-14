// lib/screens/main/home/widgets/app_bars.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;

class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double scaleFactor;

  const QuranAppBar({
    Key? key,
    this.scaleFactor = 1.0,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.0 * scaleFactor + 1.0 * scaleFactor);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.only(left: 8.0 * scaleFactor),
        child: Image.asset(
          'assets/images/qurani-white-text.png',
          height: 26 * scaleFactor,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          color: constants.primaryColor,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0 * scaleFactor),
        child: Container(
          color: const Color(0xFFE8E8E8),
          height: 1.0 * scaleFactor,
        ),
      ),
    );
  }
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Account',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: -0.3,
        ),
      ),
      automaticallyImplyLeading: false,
    );
  }
}