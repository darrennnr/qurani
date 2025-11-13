import 'package:cuda_qurani/screens/main/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './main/auth/login/login_page.dart';
import './main/home/surah_list_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // 🔍 DEBUG: Log auth state
        print('🎯 AuthWrapper: Building...');
        print('   - isLoading: ${auth.isLoading}');
        print('   - isAuthenticated: ${auth.isAuthenticated}');
        print('   - currentUser: ${auth.currentUser?.email ?? "null"}');
        
        // ✅ FIXED: Show loading indicator instead of SplashScreen
        // SplashScreen should only show once on app start (handled by InitialSplashScreen)
        if (auth.isLoading) {
          print('   → Showing LOADING screen');
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF247C64)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Memuat...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Authenticated -> Home
        if (auth.isAuthenticated) {
          print('   → Navigating to HOME');
          return const HomePage();
        }

        // Not authenticated -> Login
        print('   → Navigating to LOGIN');
        return const LoginPage();
      },
    );
  }
}
