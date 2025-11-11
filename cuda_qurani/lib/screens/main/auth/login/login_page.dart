// lib/screens/auth/login_page.dart

import 'package:cuda_qurani/screens/main/auth/register/register_page.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/screens/main/stt/utils/constants.dart' as constants;
import 'package:cuda_qurani/screens/main/home/surah_list_page.dart';

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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SurahListPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Responsive Setup ---
    const double designWidth = 406.0;
    final double s = MediaQuery.of(context).size.width / designWidth;
    // --- End Responsive Setup ---

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 50 * s),
                
                // Logo Section
                Center(
                  child: Column(
                    children: [
                      // Logo container
                      Container(
                        width: 137 * s,
                        height: 137 * s,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.08),
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
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 32 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5 * s,
                  ),
                ),
                SizedBox(height: 8 * s),
                Text(
                  'Masuk untuk melanjutkan perjalanan Quran Anda',
                  style: TextStyle(
                    fontSize: 15 * s,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    height: 1.5, // Tetap
                  ),
                ),
                
                SizedBox(height: 40 * s),
                
                // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 18 * s),
                      
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
                      
                      SizedBox(height: 18 * s),
                      
                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 22 * s,
                                width: 22 * s,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: constants.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5 * s),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10 * s),
                              Text(
                                'Ingat saya',
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle forgot password
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 8 * s),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Lupa Password?',
                              style: TextStyle(
                                fontSize: 14 * s,
                                color: constants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 32 * s),
                      
                      // Login Button
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
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: constants.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14 * s),
                            ),
                            disabledBackgroundColor:
                                constants.primaryColor.withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 22 * s,
                                  width: 22 * s,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5 * s,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16 * s,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5 * s,
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: 28 * s),
                      
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
                      
                      SizedBox(height: 28 * s),
                      
                      // Google Sign In Button
                      SizedBox(
                        height: 56 * s,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle Google sign in
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!, width: 1.5 * s),
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
                            'Masuk dengan Google',
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
                
                SizedBox(height: 32 * s),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 8 * s),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Daftar Sekarang',
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