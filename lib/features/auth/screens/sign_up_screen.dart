import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    bool hasError = false;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      hasError = true;
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        _emailError = 'Enter a valid email address';
      });
      hasError = true;
    }

    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username cannot be empty';
      });
      hasError = true;
    } else if (username.length < 3) {
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
      });
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      hasError = true;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      hasError = true;
    }

    if (hasError) {
      setState(() => _isLoading = false);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithEmail(
      email: email,
      password: password,
      displayName: username,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Sign up failed. Please try again.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark
        ? const Color.fromARGB(255, 255, 167, 38)
        : const Color(0xFFFF7043);
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final descColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/logo/logo.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFFFFA726),
                        Color.fromRGBO(255, 112, 67, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Blaze Player',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      decoration: TextDecoration.none,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 8),
                // Email field
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter Email',
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: descColor,
                        ),
                        errorText: _emailError,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _emailError != null
                                ? Colors.red
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Username field
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter Username',
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: descColor,
                        ),
                        errorText: _usernameError,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _usernameError != null
                                ? Colors.red
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password field
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock_outline, color: descColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: descColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        errorText: _passwordError,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _passwordError != null
                                ? Colors.red
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: descColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/sign-in');
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
