import 'package:flutter/material.dart';

class ModernOnboardingScreen extends StatelessWidget {
  const ModernOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark
        ? const Color.fromARGB(255, 255, 167, 38)
        : const Color(0xFFFF7043);
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final descColor = isDark ? Colors.white70 : Colors.black54;
    final ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.transparent; // Show only border when pressed
        }
        return accent; // Filled color before click
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return accent; // Text and border color when pressed
        }
        return Colors.white; // Text color before click
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.pressed)) {
          return BorderSide(color: accent, width: 2);
        }
        return const BorderSide(color: Colors.transparent, width: 2);
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      ),
      elevation: WidgetStateProperty.all(0),
    );
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Back hero image (background)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                isDark
                    ? 'assets/images/page3_dark.png'
                    : 'assets/images/page3.png',
                width: 300,
                height: 390,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            // Auth buttons (centered, with gap and selection style)
            Positioned(
              left: 0,
              right: 0,
              bottom: 370,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/sign-up');
                    },
                    style: buttonStyle,
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/sign-in');
                    },
                    style: buttonStyle,
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Front hero image (in front of Register button)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                isDark
                    ? 'assets/images/page3_dark.png'
                    : 'assets/images/page3.png',
                width: 300,
                height: 390,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            // Headphone image (top right corner, hanging)
            Positioned(
              top: 0,
              right: 16, // move a bit left
              child: Image.asset(
                'assets/images/headphone.png',
                width: 140, // increase size
                height: 140,
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
              ),
            ),
            // Main content (Column)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: textColor.withOpacity(0.85),
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                          splashRadius: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // moved logo/app name up
                    // App logo
                    Image.asset(
                      'assets/logo/logo.png',
                      width: 80,
                      height: 80,
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
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Heading
                    Text(
                      'Ready to Beat Up Your Day?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        decoration: TextDecoration.none,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      'Unleash your favorite tracks with premium sound and a stunning interface.\nSign up now.',
                      style: TextStyle(
                        fontSize: 15,
                        color: descColor,
                        height: 1.5,
                        decoration: TextDecoration.none,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
