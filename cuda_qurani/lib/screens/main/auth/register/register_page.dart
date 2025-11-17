// lib/screens/auth/register_page.dart

import 'package:cuda_qurani/providers/auth_provider.dart';
import 'package:cuda_qurani/screens/main/home/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;
import 'package:provider/provider.dart';

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
  bool _isLoading = false;
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
    // --- Responsive Scaling ---
    // (diperlukan di sini untuk SnackBar sebelum build selesai)
    // Ambil 's' dari konteks jika ada, jika tidak, hitung dengan cepat.
    // Ini adalah fallback, idealnya 's' didapat dari build.
    // Tapi untuk SnackBar, kita perlu konteks.
    const double designWidth = 406.0;
    final double s = MediaQuery.of(context).size.width / designWidth;
    // --- End Responsive Scaling ---

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Anda harus menyetujui syarat dan ketentuan'),
          backgroundColor: constants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * s),
          ),
          margin: EdgeInsets.all(16 * s),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print(
      '📝 RegisterPage: Starting registration for ${_emailController.text.trim()}',
    );

    // ✅ FIXED: Use real AuthProvider instead of simulation
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
    );

    print('📝 RegisterPage: Registration result = $success');
    print(
      '📝 RegisterPage: isAuthenticated after signup = ${authProvider.isAuthenticated}',
    );

    if (!mounted) return;

    if (success) {
      print('✅ RegisterPage: Registration SUCCESS!');

      // Check if email confirmation is required
      if (authProvider.errorMessage?.contains('email') == true) {
        // Email confirmation required
        print('📧 RegisterPage: Email confirmation required');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registrasi berhasil! Silakan cek email untuk verifikasi'),
            backgroundColor: constants.correctColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * s),
            ),
            margin: EdgeInsets.all(16 * s),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate back to login page
        Navigator.of(context).pop();
      } else {
        // No email confirmation needed, user is logged in
        print('✅ RegisterPage: Navigating to HomePage...');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registrasi berhasil! Selamat datang'),
            backgroundColor: constants.correctColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * s),
            ),
            margin: EdgeInsets.all(16 * s),
          ),
        );

        // ✅ FIX: Manual navigation instead of relying on AuthWrapper Consumer
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
      }
    } else {
      print(
        '❌ RegisterPage: Registration FAILED - ${authProvider.errorMessage}',
      );
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: constants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * s),
          ),
          margin: EdgeInsets.all(16 * s),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Responsive Setup ---
    // Berdasarkan perangkat referensi: 1220px (lebar)
    // Asumsi ~3.0x device pixel ratio: 1220 / 3.0 = 406.6 logical pixels
    // Kita gunakan 406.0 sebagai lebar desain.
    const double designWidth = 406.0;
    final double s = MediaQuery.of(context).size.width / designWidth;
    // --- End Responsive Setup ---

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: const Color.fromARGB(0, 245, 245, 245),
              borderRadius: BorderRadius.circular(10 * s),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 18 * s,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 0),

                // Logo Section
                Center(
                  child: Column(
                    children: [
                      // Logo container
                      Container(
                        width: 137 * s,
                        height: 137 * s,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24 * s),
                          boxShadow: [
                            BoxShadow(
                              color: constants.primaryColor.withOpacity(0.1),
                              blurRadius: 20 * s,
                              offset: Offset(0, 4 * s),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'ﲐ',
                            style: TextStyle(
                              fontFamily: 'surah_names',
                              fontSize: 110 * s,
                              color: constants.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * s),
                      // Brand name
                      Image.asset(
                        'assets/images/qurani-white-text.png',
                        height: 36 * s,
                        color: constants.primaryColor,
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        'Hafidz',
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w600,
                          color: constants.primaryColor,
                          letterSpacing: 2 * s,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40 * s),

                // Welcome Text
                Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 30 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5 * s,
                  ),
                ),
                SizedBox(height: 8 * s),
                Text(
                  'Daftar untuk memulai perjalanan Quran Anda',
                  style: TextStyle(
                    fontSize: 15 * s,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    height: 1.5, // Line height (faktor) biasanya tetap
                  ),
                ),

                SizedBox(height: 32 * s),

                // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontSize: 15 * s,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: EdgeInsets.only(right: 12 * s),
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.grey[600],
                              size: 22 * s,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.primaryColor,
                              width: 2 * s,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: const BorderSide(
                              color: constants.errorColor,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.errorColor,
                              width: 2 * s,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * s,
                            vertical: 18 * s,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          if (value.length < 3) {
                            return 'Nama minimal 3 karakter';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16 * s),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 15 * s,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: EdgeInsets.only(right: 12 * s),
                            child: Icon(
                              Icons.email_outlined,
                              color: Colors.grey[600],
                              size: 22 * s,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.primaryColor,
                              width: 2 * s,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: const BorderSide(
                              color: constants.errorColor,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.errorColor,
                              width: 2 * s,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * s,
                            vertical: 18 * s,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16 * s),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(
                          fontSize: 15 * s,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: EdgeInsets.only(right: 12 * s),
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[600],
                              size: 22 * s,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                              size: 22 * s,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.primaryColor,
                              width: 2 * s,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: const BorderSide(
                              color: constants.errorColor,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.errorColor,
                              width: 2 * s,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * s,
                            vertical: 18 * s,
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

                      SizedBox(height: 16 * s),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        style: TextStyle(
                          fontSize: 15 * s,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: EdgeInsets.only(right: 12 * s),
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[600],
                              size: 22 * s,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                              size: 22 * s,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.primaryColor,
                              width: 2 * s,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: const BorderSide(
                              color: constants.errorColor,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14 * s),
                            borderSide: BorderSide(
                              color: constants.errorColor,
                              width: 2 * s,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * s,
                            vertical: 18 * s,
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
                      ),

                      SizedBox(height: 20 * s),

                      // Terms & Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 22 * s,
                            width: 22 * s,
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: constants.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5 * s),
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 2 * s),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13 * s,
                                    color: Colors.grey[700],
                                    height: 1.5, // Tetap
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Saya menyetujui '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          // Handle terms tap
                                        },
                                        child: Text(
                                          'Syarat dan Ketentuan',
                                          style: TextStyle(
                                            fontSize: 13 * s,
                                            color: constants.primaryColor,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                constants.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' serta '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          // Handle privacy tap
                                        },
                                        child: Text(
                                          'Kebijakan Privasi',
                                          style: TextStyle(
                                            fontSize: 13 * s,
                                            color: constants.primaryColor,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                constants.primaryColor,
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
                      ),

                      SizedBox(height: 28 * s),

                      // Register Button
                      Container(
                        height: 56 * s,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14 * s),
                          boxShadow: [
                            BoxShadow(
                              color: constants.primaryColor.withOpacity(0.3),
                              blurRadius: 12 * s,
                              offset: Offset(0, 6 * s),
                            ),
                          ],
                        ),
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return ElevatedButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: constants.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                disabledBackgroundColor: constants.primaryColor
                                    .withOpacity(0.6),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 26 * s),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1 * s,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20 * s),
                            child: Text(
                              'atau',
                              style: TextStyle(
                                fontSize: 13 * s,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1 * s,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 26 * s),

                      // Google Sign Up Button
                      SizedBox(
                        height: 56 * s,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle Google sign up
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5 * s,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14 * s),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          icon: Image.asset(
                            'assets/images/google-icon.png',
                            height: 24 * s,
                            width: 24 * s,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.g_mobiledata,
                                size: 24 * s,
                                color: Colors.black87,
                              );
                            },
                          ),
                          label: Text(
                            'Daftar dengan Google',
                            style: TextStyle(
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: 0.3 * s,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28 * s),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4 * s,
                          vertical: 8 * s,
                        ),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 14 * s,
                          color: constants.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
