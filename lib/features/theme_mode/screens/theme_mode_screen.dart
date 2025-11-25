import 'package:flutter/material.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../main.dart';
import '../../onboarding/screens/modern_onboarding_screen.dart';

class ThemeModeScreen extends StatefulWidget {
  const ThemeModeScreen({super.key});

  @override
  State<ThemeModeScreen> createState() => _ThemeModeScreenState();
}

class _ThemeModeScreenState extends State<ThemeModeScreen>
    with SingleTickerProviderStateMixin {
  late bool isDarkMode;
  bool _bgLoaded = false;
  bool _showWeave = false;

  final GlobalKey _buttonKey = GlobalKey();
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;
  bool _showOverlayArrow = false;
  Offset _arrowStart = Offset.zero;

  void _setTheme(bool dark) async {
    setState(() => _showWeave = true);
    await Future.delayed(const Duration(milliseconds: 350));
    setState(() {
      isDarkMode = dark;
      _showWeave = false;
    });
    if (dark) {
      themeNotifier.setDark();
    } else {
      themeNotifier.setLight();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to load the image synchronously if already in cache
    final imageProvider = const AssetImage('assets/images/page2.jpg');
    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((_, __) {
            if (mounted && !_bgLoaded) setState(() => _bgLoaded = true);
          }),
        );
    // Also precache for reliability
    precacheImage(imageProvider, context);
  }

  @override
  void initState() {
    super.initState();
    // Initialize with current theme mode
    isDarkMode = themeNotifier.value == ThemeMode.dark;
    
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _arrowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  void _startArrowAnimation() async {
    final RenderBox box =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
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

    // Mark onboarding as completed
    await LocalStorageService.setBool('hasCompletedOnboarding', true);

    // Navigate to ModernOnboardingScreen with no animation
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ModernOnboardingScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoAsset = isDarkMode
        ? 'assets/logo/logo_white.png' // Use your white logo for dark mode
        : 'assets/logo/logo.png';
    final bgColor = isDarkMode ? Colors.black : Colors.black.withOpacity(0.45);
    final glassButtonColor = isDarkMode
        ? [const Color(0xFFFFA726), const Color(0xFFFFA726)]
        : [const Color(0xFFFFA726), const Color(0xFFFF7043)];
    const textColor = Colors.white;

    return Stack(
      children: [
        // Background image or solid dark background for dark mode
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            layoutBuilder: (currentChild, previousChildren) => Stack(
              fit: StackFit.expand,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            child: _bgLoaded
                ? SizedBox.expand(
                    key: ValueKey(isDarkMode),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(isDarkMode ? 0.7 : 0.45),
                        BlendMode.darken,
                      ),
                      child: Image.asset(
                        'assets/images/page2.jpg',
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('loading'),
                    color: Colors.black,
                  ),
          ),
        ),
        // Glass overlay with animated color
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColor.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            // Minimal smooth wave effect
            foregroundDecoration: _showWeave
                ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        (isDarkMode ? Colors.black : Colors.white).withOpacity(
                          isDarkMode ? 0.12 : 0.08,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  )
                : null,
          ),
        ),
        // Top Row: Logo and App Name
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Image.asset(
                    logoAsset,
                    key: ValueKey(logoAsset),
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: isDarkMode
                      ? const Text(
                          'Blaze Player',
                          key: ValueKey('dark'),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 1.1,
                            decoration: TextDecoration.none,
                          ),
                        )
                      : ShaderMask(
                          key: const ValueKey('light'),
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'Blaze Player',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                              decoration: TextDecoration.none,
                            ),
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Choose mode:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModeToggle(
                      icon: Icons.nightlight_round,
                      label: 'Dark mode',
                      selected: isDarkMode,
                      onTap: () => _setTheme(true),
                    ),
                    const SizedBox(width: 32),
                    _ModeToggle(
                      icon: Icons.wb_sunny_rounded,
                      label: 'Light Mode',
                      selected: !isDarkMode,
                      onTap: () => _setTheme(false),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                GlassButton(
                  key: _buttonKey,
                  text: 'Continue',
                  onPressed: () {},
                  onArrowFly: () {
                    _startArrowAnimation();
                  },
                  isArrowFlying: _showOverlayArrow,
                  gradientColors: glassButtonColor,
                  textStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    decoration: TextDecoration.none,
                    color: Colors.white,
                  ),
                ),
                if (_showWeave)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              (isDarkMode ? Colors.black : Colors.white)
                                  .withOpacity(isDarkMode ? 0.12 : 0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Overlay arrow animation (move out of Column, direct child of Stack)
        if (_showOverlayArrow)
          AnimatedBuilder(
            animation: _arrowAnimation,
            builder: (context, child) {
              final screenWidth = MediaQuery.of(context).size.width;
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

class _ModeToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFA726);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? accent.withOpacity(0.18)
                  : Colors.white.withOpacity(0.05),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: selected ? accent : Colors.white54,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: selected ? accent : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
