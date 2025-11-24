// lib/screens/auth/login_page.dart

import 'package:cuda_qurani/screens/main/auth/register/register_page.dart';
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
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
  bool _isLoading = false;
  bool _rememberMe = false;

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
      _isLoading = true;
    });

    print('🔐 LoginPage: Starting login for ${_emailController.text.trim()}');

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    print('🔐 LoginPage: Login result = $success');

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      print('✅ LoginPage: Login SUCCESS! Navigating to HomePage...');

      ScaffoldMessenger.of(context).showSnackBar(
        AppComponentStyles.successSnackBar(
          message: 'Login berhasil!',
          duration: const Duration(seconds: 1),
        ),
      );

      // ✅ FIX: Manual navigation instead of relying on AuthWrapper Consumer
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
                _buildLogoSection(context, s),

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

                AppMargin.customGap(context, AppDesignSystem.space24),

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
  Widget _buildLogoSection(BuildContext context, double s) {
    return Center(
      child: Column(
        children: [
          // Logo container
          Container(
            width: AppDesignSystem.scale(context, 150),
            height: AppDesignSystem.scale(context, 150),
            decoration: BoxDecoration(
              color: Color.fromARGB(0, 36, 124, 100),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge * s),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(0, 36, 124, 100),
                  blurRadius: AppDesignSystem.scale(context, 16),
                  offset: Offset(0, AppDesignSystem.scale(context, 4)),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'ﲐ',
                style: TextStyle(
                  fontFamily: 'surah_names',
                  fontSize: AppDesignSystem.scale(context, 90),
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          
          AppMargin.customGap(context, AppDesignSystem.space20),
          
          // Brand name
          Image.asset(
            'assets/images/qurani-white-text.png',
            height: AppDesignSystem.scale(context, 32),
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'QURANI',
                style: AppTypography.h2(
                  context,
                  color: AppColors.primary,
                  weight: AppTypography.bold,
                ),
              );
            },
          ),
          
          AppMargin.gapSmall(context),
          
          Text(
            'Hafidz',
            style: AppTypography.label(
              context,
              color: AppColors.primary,
              weight: AppTypography.semiBold,
            ).copyWith(
              letterSpacing: AppDesignSystem.scale(context, 2),
            ),
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
          'Selamat Datang',
          style: AppTypography.displaySmall(
            context,
            color: AppColors.textPrimary,
            weight: AppTypography.bold,
          ),
        ),
        AppMargin.gapSmall(context),
        Text(
          'Masuk untuk melanjutkan perjalanan Quran Anda',
          style: AppTypography.body(
            context,
            color: AppColors.textTertiary,
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
    return Container(
      height: AppDesignSystem.scale(context, AppDesignSystem.buttonHeightLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDesignSystem.radiusMedium * AppDesignSystem.getScaleFactor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: AppDesignSystem.scale(context, 12),
            offset: Offset(0, AppDesignSystem.scale(context, 4)),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: AppComponentStyles.primaryButton(context),
        child: _isLoading
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
    return SizedBox(
      height: AppDesignSystem.scale(context, AppDesignSystem.buttonHeightLarge),
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle Google sign in
        },
        style: AppComponentStyles.secondaryButton(context),
        icon: Image.asset(
          'assets/images/google-icon.png',
          height: AppDesignSystem.scale(context, 20),
          width: AppDesignSystem.scale(context, 20),
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.g_mobiledata,
              size: AppDesignSystem.iconLarge * s,
              color: AppColors.textPrimary,
            );
          },
        ),
        label: Text(
          'Masuk dengan Google',
          style: AppTypography.label(
            context,
            color: AppColors.textPrimary,
            weight: AppTypography.semiBold,
          ),
        ),
      ),
    );
  }

  // ==================== REGISTER LINK ====================
  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: AppTypography.body(
            context,
            color: AppColors.textTertiary,
          ),
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