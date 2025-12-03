// lib/screens/auth/register_page.dart

import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/core/widgets/app_components.dart';

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
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      if (authProvider.errorMessage?.contains('email') == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppComponentStyles.successSnackBar(
            message: 'Registrasi berhasil! Silakan cek email untuk verifikasi',
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppComponentStyles.successSnackBar(
            message: 'Registrasi berhasil! Selamat datang',
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppComponentStyles.errorSnackBar(
          message: authProvider.errorMessage ?? 'Registrasi gagal',
        ),
      );
    }
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
                _buildLogoSection(s),
                AppMargin.gapXLarge(context),
                _buildWelcomeSection(),
                AppMargin.gapLarge(context),
                _buildForm(s),
                AppMargin.gapLarge(context),
                _buildRegisterButton(),
                AppMargin.gap(context),
                AppMargin.gap(context),
                _buildLoginLink(),
                AppMargin.gapLarge(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buat Akun Baru', style: AppTypography.displaySmall(context)),
        AppMargin.gapSmall(context),
        Text(
          'Daftar untuk memulai perjalanan Quran Anda',
          style: AppTypography.body(context, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildForm(double s) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Username',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Username tidak boleh kosong';
              if (value.length < 3) return 'Username minimal 3 karakter';
              return null;
            },
            s: s,
          ),
          AppMargin.gap(context),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
            s: s,
          ),
          AppMargin.gap(context),
          _buildPasswordField(_passwordController, 'Password', _isPasswordVisible, (val) {
            setState(() => _isPasswordVisible = val);
          }, s),
          AppMargin.gap(context),
          _buildPasswordField(_confirmPasswordController, 'Konfirmasi Password', _isConfirmPasswordVisible, (val) {
            setState(() => _isConfirmPasswordVisible = val);
          }, s, confirmPassword: true),
          AppMargin.gap(context),
          _buildTermsCheckbox(s),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required double s,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: label == 'Username' ? TextCapitalization.words : TextCapitalization.none,
      style: AppTypography.body(context),
      decoration: AppComponentStyles.inputDecoration(
        context: context,
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: AppDesignSystem.space12 * s),
          child: Icon(icon, color: AppColors.textTertiary, size: AppDesignSystem.iconLarge * s),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool isVisible,
    Function(bool) onToggle,
    double s, {
    bool confirmPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: AppTypography.body(context),
      decoration: AppComponentStyles.inputDecoration(
        context: context,
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: AppDesignSystem.space12 * s),
          child: Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: AppDesignSystem.iconLarge * s),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textTertiary,
            size: AppDesignSystem.iconLarge * s,
          ),
          onPressed: () => onToggle(!isVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label tidak boleh kosong';
        if (value.length < 6) return 'Password minimal 6 karakter';
        if (confirmPassword && value != _passwordController.text) return 'Password tidak sama';
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20 * s,
          width: 20 * s,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * s)),
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
                style: AppTypography.bodySmall(context, color: AppColors.textSecondary),
                children: [
                  const TextSpan(text: 'Saya menyetujui '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Syarat dan Ketentuan',
                        style: AppTypography.bodySmall(context, color: AppColors.primary, weight: AppTypography.semiBold)
                            .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.primary),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' serta '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Kebijakan Privasi',
                        style: AppTypography.bodySmall(context, color: AppColors.primary, weight: AppTypography.semiBold)
                            .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.primary),
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

  Widget _buildRegisterButton() {
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sudah punya akun? ', style: AppTypography.body(context, color: AppColors.textSecondary)),
        AppTextButton(
          text: 'Masuk',
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.primary,
        ),
      ],
    );
  }
}