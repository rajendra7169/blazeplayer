import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool hasError = false;

    // Email/username validation
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email/Username cannot be empty';
      });
      hasError = true;
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) &&
        !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(email)) {
      setState(() {
        _emailError = 'Enter a valid email or username';
      });
      hasError = true;
    }

    // Password validation
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
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(email, password);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      _showError(authProvider.errorMessage ?? 'Sign in failed');
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      _showError(authProvider.errorMessage ?? 'Google sign-in failed');
    }
  }

  Future<void> _signInWithFacebook() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithFacebook();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      _showError(authProvider.errorMessage ?? 'Facebook sign-in failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
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
                // App logo
                Image.asset(
                  'assets/logo/logo.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                // App name
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
                // Heading
                Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 8),
                // Support text
                RichText(
                  text: TextSpan(
                    text: 'If you need any support ',
                    style: TextStyle(color: descColor, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Click Here',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Email field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter Username Or Email',
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person_outline, color: descColor),
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
                const SizedBox(height: 8),
                // Recovery password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: accent),
                    child: const Text('Recovery Password'),
                  ),
                ),
                const SizedBox(height: 8),
                // Sign In button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleEmailSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Or divider
                Row(
                  children: [
                    Expanded(child: Divider(color: descColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Or', style: TextStyle(color: descColor)),
                    ),
                    Expanded(child: Divider(color: descColor)),
                  ],
                ),
                const SizedBox(height: 16),
                // Social sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.google,
                        color: isDark ? Colors.white : const Color(0xFF4285F4),
                        size: 32,
                      ),
                      onPressed: _signInWithGoogle,
                      tooltip: 'Sign in with Google',
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.facebook,
                        color: isDark ? Colors.white : const Color(0xFF1877F3),
                        size: 32,
                      ),
                      onPressed: _signInWithFacebook,
                      tooltip: 'Sign in with Facebook',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member? ', style: TextStyle(color: descColor)),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/sign-up');
                      },
                      child: Text(
                        'Register Now',
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
