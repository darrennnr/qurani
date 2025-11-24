// lib/screens/auth/register_page.dart

import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppComponentStyles.errorSnackBar(
          message: 'Anda harus menyetujui syarat dan ketentuan',
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('📝 RegisterPage: Starting registration for ${_emailController.text.trim()}');

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
    );

    print('📝 RegisterPage: Registration result = $success');
    print('📝 RegisterPage: isAuthenticated after signup = ${authProvider.isAuthenticated}');

    if (!mounted) return;

    if (success) {
      print('✅ RegisterPage: Registration SUCCESS!');

      // Check if email confirmation is required
      if (authProvider.errorMessage?.contains('email') == true) {
        print('📧 RegisterPage: Email confirmation required');
        
        ScaffoldMessenger.of(context).showSnackBar(
          AppComponentStyles.successSnackBar(
            message: 'Registrasi berhasil! Silakan cek email untuk verifikasi',
            duration: const Duration(seconds: 3),
          ),
        );
        
        Navigator.of(context).pop();
      } else {
        print('✅ RegisterPage: Navigating to HomePage...');
        
        ScaffoldMessenger.of(context).showSnackBar(
          AppComponentStyles.successSnackBar(
            message: 'Registrasi berhasil! Selamat datang',
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
      }
    } else {
      print('❌ RegisterPage: Registration FAILED - ${authProvider.errorMessage}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        AppComponentStyles.errorSnackBar(
          message: authProvider.errorMessage ?? 'Registrasi gagal',
        ),
      );
    }
  }

  void _handleGoogleSignUp() {
    // TODO: Implement Google Sign Up
    ScaffoldMessenger.of(context).showSnackBar(
      AppComponentStyles.infoSnackBar(
        message: 'Google Sign Up akan segera tersedia',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          iconColor: AppColors.textPrimary,
          size: 40,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: AppPadding.page(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Section
                _buildLogoSection(context, s),
                
                AppMargin.gapXLarge(context),

                // Welcome Text
                _buildWelcomeSection(context),

                AppMargin.gapLarge(context),

                // Form Section
                _buildFormSection(context, s),

                AppMargin.gapLarge(context),

                // Register Button
                _buildRegisterButton(context),

                AppMargin.gap(context),

                // Divider
                _buildDivider(context),

                AppMargin.gap(context),

                // Google Sign Up Button
                _buildGoogleButton(context),

                AppMargin.gap(context),

                // Login Link
                _buildLoginLink(context),

                AppMargin.gapLarge(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, double s) {
    return Center(
      child: Column(
        children: [
          // Logo container
          Container(
            width: 140 * s,
            height: 140 * s,
            decoration: BoxDecoration(
              color: Color.fromARGB(0, 36, 124, 100),
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
          
          // Brand name
          Image.asset(
            'assets/images/qurani-white-text.png',
            height: 28 * s,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'Qurani',
                style: AppTypography.h2(
                  context,
                  color: AppColors.primary,
                  weight: AppTypography.bold,
                ),
              );
            },
          ),
          
          SizedBox(height: 4 * s),
          
          Text(
            'Hafidz',
            style: AppTypography.label(
              context,
              color: AppColors.primary,
              weight: AppTypography.semiBold,
            ).copyWith(
              letterSpacing: 2 * s,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Akun Baru',
          style: AppTypography.displaySmall(context),
        ),
        AppMargin.gapSmall(context),
        Text(
          'Daftar untuk memulai perjalanan Quran Anda',
          style: AppTypography.body(
            context,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context, double s) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          _buildNameField(context, s),
          
          AppMargin.gap(context),

          // Email Field
          _buildEmailField(context, s),

          AppMargin.gap(context),

          // Password Field
          _buildPasswordField(context, s),

          AppMargin.gap(context),

          // Confirm Password Field
          _buildConfirmPasswordField(context, s),

          AppMargin.gap(context),

          // Terms & Conditions
          _buildTermsCheckbox(context, s),
        ],
      ),
    );
  }

  Widget _buildNameField(BuildContext context, double s) {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      style: AppTypography.body(context),
      decoration: AppComponentStyles.inputDecoration(
        context: context,
        labelText: 'Username',
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: AppDesignSystem.space12 * s),
          child: Icon(
            Icons.person_outline_rounded,
            color: AppColors.textTertiary,
            size: AppDesignSystem.iconLarge * s,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Username tidak boleh kosong';
        }
        if (value.length < 3) {
          return 'Username minimal 3 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(BuildContext context, double s) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: AppTypography.body(context),
      decoration: AppComponentStyles.inputDecoration(
        context: context,
        labelText: 'Email',
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: AppDesignSystem.space12 * s),
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
    );
  }

  Widget _buildPasswordField(BuildContext context, double s) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: AppTypography.body(context),
      decoration: AppComponentStyles.inputDecoration(
        context: context,
        labelText: 'Password',
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: AppDesignSystem.space12 * s),
          child: Icon(
            Icons.lock_outline_rounded,
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
    );
  }

  Widget _buildConfirmPasswordField(BuildContext context, double s) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: AppTypography.body(context),
      decoration: AppComponentStyles.inputDecoration(
        context: context,
        labelText: 'Konfirmasi Password',
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: AppDesignSystem.space12 * s),
          child: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textTertiary,
            size: AppDesignSystem.iconLarge * s,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textTertiary,
            size: AppDesignSystem.iconLarge * s,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Konfirmasi password tidak boleh kosong';
        }
        if (value != _passwordController.text) {
          return 'Password tidak sama';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox(BuildContext context, double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20 * s,
          width: 20 * s,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4 * s),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: AppDesignSystem.space12 * s),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1 * s),
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySmall(
                  context,
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Saya menyetujui '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () {
                        // Handle terms tap
                      },
                      child: Text(
                        'Syarat dan Ketentuan',
                        style: AppTypography.bodySmall(
                          context,
                          color: AppColors.primary,
                          weight: AppTypography.semiBold,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' serta '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () {
                        // Handle privacy tap
                      },
                      child: Text(
                        'Kebijakan Privasi',
                        style: AppTypography.bodySmall(
                          context,
                          color: AppColors.primary,
                          weight: AppTypography.semiBold,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return AppButton(
          text: 'Daftar',
          onPressed: auth.isLoading ? null : _handleRegister,
          loading: auth.isLoading,
          fullWidth: true,
        );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: AppDivider()),
        Padding(
          padding: AppPadding.horizontal(context, AppDesignSystem.space16),
          child: Text(
            'atau',
            style: AppTypography.caption(
              context,
              color: AppColors.textDisabled,
            ),
          ),
        ),
        const Expanded(child: AppDivider()),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    
    return SizedBox(
      height: AppDesignSystem.buttonHeightLarge * s,
      child: OutlinedButton(
        onPressed: _handleGoogleSignUp,
        style: AppComponentStyles.secondaryButton(context).copyWith(
          backgroundColor: MaterialStateProperty.all(AppColors.surface),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google-icon.png',
              height: AppDesignSystem.iconLarge * s,
              width: AppDesignSystem.iconLarge * s,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.g_mobiledata_rounded,
                  size: AppDesignSystem.iconXLarge * s,
                  color: AppColors.textPrimary,
                );
              },
            ),
            AppMargin.gapHSmall(context),
            Text(
              'Daftar dengan Google',
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

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: AppTypography.body(
            context,
            color: AppColors.textSecondary,
          ),
        ),
        AppTextButton(
          text: 'Masuk',
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.primary,
        ),
      ],
    );
  }
}