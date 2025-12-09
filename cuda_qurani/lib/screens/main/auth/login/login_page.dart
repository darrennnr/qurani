// lib/screens/auth/login_page.dart

import 'package:cuda_qurani/screens/main/auth/register/register_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/design_system/app_design_system.dart';
import '../../../../core/widgets/app_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isEmailLoginLoading = false; // ✅ Separate loading for email login
  bool _isGoogleLoginLoading = false; // ✅ Separate loading for Google login
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Warm up Google Sign In early to reduce chooser delay
    AuthService().warmUpGoogleSignIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isEmailLoginLoading = true; // ✅ Only email login loading
    });

    print('🔐 LoginPage: Starting login for ${_emailController.text.trim()}');

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    print('🔐 LoginPage: Login result = $success');

    setState(() {
      _isEmailLoginLoading = false; // ✅ Stop email login loading
    });

    if (success && mounted) {
      print('✅ LoginPage: Login SUCCESS! Navigating to HomePage...');

      ScaffoldMessenger.of(context).showSnackBar(
        AppComponentStyles.successSnackBar(
          message: 'Login berhasil!',
          duration: const Duration(seconds: 1),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } else if (!success && mounted) {
      print('❌ LoginPage: Login FAILED - ${authProvider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        AppComponentStyles.errorSnackBar(
          message: authProvider.errorMessage ?? 'Login gagal',
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('🔐 LoginPage: ===== STARTING Google Sign In =====');
    
    setState(() {
      _isGoogleLoginLoading = true; // ✅ Only Google login loading
    });

    print('🔐 LoginPage: Button clicked, calling authProvider.signInWithGoogle()...');

    try {
      print('🔐 LoginPage: Waiting for Google Sign In to complete...');
      final success = await authProvider.signInWithGoogle();
      print('🔐 LoginPage: Google Sign In completed! Result: $success');

      if (!mounted) {
        print('⚠️ LoginPage: Widget not mounted after sign in, skipping navigation');
        return;
      }

      setState(() {
        _isGoogleLoginLoading = false; // ✅ Stop Google login loading
      });

      print('🔐 LoginPage: ===== SIGN IN RESULT =====');
      print('   - Success: $success');
      print('   - Error message: ${authProvider.errorMessage ?? "null"}');
      print('   - Is authenticated: ${authProvider.isAuthenticated}');
      print('   - Current user: ${authProvider.currentUser?.email ?? "null"}');
      print('   - User ID: ${authProvider.userId ?? "null"}');

      if (success) {
        print('✅ LoginPage: Google Sign In SUCCESS! Preparing navigation...');

        // Double check authentication status
        bool isAuth = authProvider.isAuthenticated;
        print('   - Initial isAuthenticated check: $isAuth');
        
        if (!isAuth) {
          print('⚠️ isAuthenticated is false, waiting for state update...');
          // Wait a bit longer for auth state to update
          for (int i = 0; i < 5; i++) {
            await Future.delayed(const Duration(milliseconds: 200));
            isAuth = authProvider.isAuthenticated;
            print('   - Check ${i + 1}/5: isAuthenticated = $isAuth');
            if (isAuth) break;
          }
        }

        if (!mounted) {
          print('⚠️ LoginPage: Widget not mounted before navigation');
          return;
        }

        print('✅ LoginPage: Showing success message...');
        ScaffoldMessenger.of(context).showSnackBar(
          AppComponentStyles.successSnackBar(
            message: 'Login berhasil!',
            duration: const Duration(seconds: 1),
          ),
        );

        print('✅ LoginPage: Navigating to HomePage...');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );

        print('✅ LoginPage: ===== NAVIGATION COMPLETED =====');
      } else {
        print('❌ LoginPage: ===== SIGN IN FAILED =====');
        print('   - Success: $success');
        print('   - Is authenticated: ${authProvider.isAuthenticated}');
        print('   - Error: ${authProvider.errorMessage ?? "No error message"}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          AppComponentStyles.errorSnackBar(
            message: authProvider.errorMessage ?? 'Google Sign In gagal. Silakan coba lagi.',
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ LoginPage: ===== EXCEPTION CAUGHT =====');
      print('   - Error: $e');
      print('   - Type: ${e.runtimeType}');
      print('   - Stack trace: $stackTrace');
      
      if (!mounted) {
        print('⚠️ LoginPage: Widget not mounted in catch block');
        return;
      }
      
      setState(() {
        _isGoogleLoginLoading = false; // ✅ Stop Google login loading
      });
      
      String errorMessage = 'Terjadi kesalahan saat login dengan Google';
      
      // Handle specific errors
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('dibatalkan') || errorString.contains('cancelled')) {
        errorMessage = 'Login dibatalkan';
      } else if (errorString.contains('network') || errorString.contains('connection')) {
        errorMessage = 'Periksa koneksi internet Anda';
      } else if (errorString.contains('id token')) {
        errorMessage = 'Gagal mendapatkan token. Pastikan konfigurasi Google Sign In sudah benar.';
      } else if (errorString.contains('supabase')) {
        errorMessage = 'Gagal menghubungkan ke server. Silakan coba lagi.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        AppComponentStyles.errorSnackBar(
          message: errorMessage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPadding.horizontal(context, AppDesignSystem.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMargin.customGap(context, AppDesignSystem.space40),

                // Logo Section
                _buildLogoSection(s),

                AppMargin.customGap(context, AppDesignSystem.space32),

                // Welcome Text
                _buildWelcomeText(context),

                AppMargin.customGap(context, AppDesignSystem.space32),

                // Form Section
                _buildFormSection(context, s),

                AppMargin.customGap(context, AppDesignSystem.space24),

                // Divider
                _buildDivider(context, s),

                AppMargin.customGap(context, AppDesignSystem.space24),

                // Google Sign In Button
                _buildGoogleButton(context, s),

                AppMargin.gap(context),

                // Register Link
                _buildRegisterLink(context),

                AppMargin.customGap(context, AppDesignSystem.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOGO SECTION ====================
  Widget _buildLogoSection(double s) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 140 * s,
            height: 140 * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge * s),
            ),
            child: Center(
              child: Text(
                'ﲐ',
                style: TextStyle(
                  fontFamily: 'surah_names',
                  fontSize: 90 * s,
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
            ),
          ),
          AppMargin.gap(context),
          Image.asset(
            'assets/images/qurani-white-text.png',
            height: 28 * s,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'Qurani',
                style: AppTypography.h2(context, color: AppColors.primary, weight: AppTypography.bold),
              );
            },
          ),
          SizedBox(height: 4 * s),
          Text(
            'Hafidz',
            style: AppTypography.label(context, color: AppColors.primary, weight: AppTypography.semiBold)
                .copyWith(letterSpacing: 2 * s),
          ),
        ],
      ),
    );
  }

  // ==================== WELCOME TEXT ====================
  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login',
          style: AppTypography.displaySmall(
            context,
            color: AppColors.textPrimary,
            weight: AppTypography.bold,
          ),
        ),
      ],
    );
  }

  // ==================== FORM SECTION ====================
  Widget _buildFormSection(BuildContext context, double s) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTypography.body(
              context,
              color: AppColors.textPrimary,
              weight: AppTypography.medium,
            ),
            decoration: AppComponentStyles.inputDecoration(
              context: context,
              labelText: 'Email',
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  left: AppDesignSystem.space16 * s,
                  right: AppDesignSystem.space12 * s,
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: AppColors.textTertiary,
                  size: AppDesignSystem.iconLarge * s,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),

          AppMargin.gap(context),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: AppTypography.body(
              context,
              color: AppColors.textPrimary,
              weight: AppTypography.medium,
            ),
            decoration: AppComponentStyles.inputDecoration(
              context: context,
              labelText: 'Password',
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  left: AppDesignSystem.space16 * s,
                  right: AppDesignSystem.space12 * s,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppColors.textTertiary,
                  size: AppDesignSystem.iconLarge * s,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                  size: AppDesignSystem.iconLarge * s,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),

          AppMargin.gap(context),

          // Remember Me & Forgot Password
          _buildRememberAndForgot(context, s),

          AppMargin.gapLarge(context),

          // Login Button
          _buildLoginButton(context),
        ],
      ),
    );
  }

  // ==================== REMEMBER & FORGOT ====================
  Widget _buildRememberAndForgot(BuildContext context, double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: AppDesignSystem.scale(context, 20),
              width: AppDesignSystem.scale(context, 20),
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusXSmall * s),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: AppDesignSystem.space8 * s),
            Text(
              'Ingat saya',
              style: AppTypography.body(
                context,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        AppTextButton(
          text: 'Lupa Password?',
          onPressed: () {
            // Handle forgot password
          },
          color: AppColors.primary,
        ),
      ],
    );
  }

  // ==================== LOGIN BUTTON ====================
  Widget _buildLoginButton(BuildContext context) {
    // ✅ Disable only when email login is loading
    final isDisabled = _isEmailLoginLoading;
    
    return Container(
      height: AppDesignSystem.scale(context, AppDesignSystem.buttonHeightLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDesignSystem.radiusMedium * AppDesignSystem.getScaleFactor(context),
        ),
        boxShadow: isDisabled ? [] : [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: AppDesignSystem.scale(context, 12),
            offset: Offset(0, AppDesignSystem.scale(context, 4)),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : _handleLogin,
        style: AppComponentStyles.primaryButton(context),
        child: _isEmailLoginLoading // ✅ Only show loading for email login
            ? SizedBox(
                height: AppDesignSystem.scale(context, 20),
                width: AppDesignSystem.scale(context, 20),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Masuk',
                style: AppTypography.label(
                  context,
                  color: Colors.white,
                  weight: AppTypography.semiBold,
                ),
              ),
      ),
    );
  }

  // ==================== DIVIDER ====================
  Widget _buildDivider(BuildContext context, double s) {
    return Row(
      children: [
        Expanded(
          child: AppDivider(
            color: AppColors.divider,
            thickness: 1 * s,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space16 * s,
          ),
          child: Text(
            'atau',
            style: AppTypography.caption(
              context,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: AppDivider(
            color: AppColors.divider,
            thickness: 1 * s,
          ),
        ),
      ],
    );
  }

  // ==================== GOOGLE BUTTON ====================
  Widget _buildGoogleButton(BuildContext context, double s) {
    final double iconSize = 28 * s;
    // ✅ Disable only when Google login is loading
    final isDisabled = _isGoogleLoginLoading;

    return SizedBox(
      height: AppDesignSystem.scale(context, AppDesignSystem.buttonHeightLarge),
      child: OutlinedButton(
        onPressed: isDisabled ? null : _handleGoogleSignIn,
        style: AppComponentStyles.secondaryButton(context).copyWith(
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: AppDesignSystem.scale(context, 16),
            ),
          ),
        ),
        child: _isGoogleLoginLoading // ✅ Only show loading for Google login
            ? SizedBox(
                height: AppDesignSystem.scale(context, 20),
                width: AppDesignSystem.scale(context, 20),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF247C64)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google-icon.png',
                    height: iconSize,
                    width: iconSize,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.g_mobiledata,
                        size: AppDesignSystem.iconLarge * s,
                        color: AppColors.textPrimary,
                      );
                    },
                  ),
                  SizedBox(width: 12 * s),
                  Text(
                    'Masuk dengan Google',
                    style: AppTypography.label(
                      context,
                      color: AppColors.textPrimary,
                      weight: AppTypography.semiBold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==================== REGISTER LINK ====================
  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Belum punya akun? ',
          style: AppTypography.body(context, color: AppColors.textSecondary),
        ),
        AppTextButton(
          text: 'Daftar Sekarang',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ),
            );
          },
          color: AppColors.primary,
        ),
      ],
    );
  }
}