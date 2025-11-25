import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/widgets/glass_button.dart';
import '../../theme_mode/screens/theme_mode_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // Use TickerProviderStateMixin for multiple AnimationControllers
  final GlobalKey _buttonKey = GlobalKey();
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;
  bool _showOverlayArrow = false;
  Offset _arrowStart = Offset.zero;
  bool _nextImageReady = false;
  late AnimationController _barsController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache next page image here (safe to use context)
    precacheImage(const AssetImage('assets/images/page2.jpg'), context).then((
      _,
    ) {
      if (mounted) setState(() => _nextImageReady = true);
    });
  }

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), // Much faster
    );
    _arrowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOutCubic),
    );
    // Visualizer bars controller
    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slower and smoother
    )..repeat();
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _barsController.dispose();
    super.dispose();
  }

  void _startArrowAnimation() async {
    // Get the button position
    final RenderBox box =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    // Start arrow closer to the text (about 65% of button width)
    final Offset position = box.localToGlobal(
      Offset(box.size.width * 0.65, box.size.height / 2 - 13),
    );
    setState(() {
      _showOverlayArrow = true;
      _arrowStart = position;
    });
    await _arrowController.forward();
    setState(() => _showOverlayArrow = false);
    _arrowController.reset();
    // Navigate to next page with no animation
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ThemeModeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // Background image with dim effect
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35), // Dim effect
              BlendMode.darken,
            ),
            child: Image.asset('assets/images/page1.jpg', fit: BoxFit.cover),
          ),
        ),
        // Animated visualizer bars (full height)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _barsController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final t = _barsController.value * 2 * math.pi;
                  final phase = index * 0.6;
                  final barFraction =
                      0.25 +
                      0.75 * (0.5 + 0.5 * math.sin(t + phase)); // 0.25 to 1.0
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 28,
                      height: double.infinity,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: barFraction,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        // Glass overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Top Row: Logo and App Name (centered, larger logo, no background)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Larger Logo, no background
                Image.asset(
                  'assets/logo/logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8), // Closer spacing
                // App Name
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFFFFA726),
                        Color(0xFFFF7043),
                      ], // Orange to deep orange, matching logo
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Blaze Player',
                    style: TextStyle(
                      fontSize: 32, // Increased size
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.white, // This will be masked by the gradient
                      letterSpacing: 1.1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 72.0,
            ), // Increased bottom padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Enjoy Listening To Music 🎶',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none, // Remove underline
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 24,
                ), // Increased gap between text and description
                const Text(
                  'Feel every beat come alive as BlazePlayer delivers pure sound, deep connection, and endless music crafted for true lovers.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.4,
                    decoration: TextDecoration.none, // Remove underline
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 56,
                ), // Increased gap between text and button
                GlassButton(
                  key: _buttonKey,
                  text: 'Get started',
                  onPressed: () {},
                  onArrowFly: () {
                    if (_nextImageReady) {
                      _startArrowAnimation();
                    }
                  },
                  isArrowFlying: _showOverlayArrow,
                ),
              ],
            ),
          ),
        ),
        // Overlay arrow animation
        if (_showOverlayArrow)
          AnimatedBuilder(
            animation: _arrowAnimation,
            builder: (context, child) {
              return Positioned(
                left:
                    _arrowStart.dx +
                    (screenWidth - _arrowStart.dx) * _arrowAnimation.value,
                top: _arrowStart.dy,
                child: Opacity(
                  opacity: 1 - _arrowAnimation.value * 0.5,
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
