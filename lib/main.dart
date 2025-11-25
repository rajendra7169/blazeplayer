import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/utils/logger.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/screens/modern_onboarding_screen.dart';
import 'features/theme_mode/screens/theme_mode_screen.dart';

// Global theme notifier
final themeNotifier = ThemeNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    AppLogger.info('Firebase initialized successfully');

    // Initialize Local Storage
    await LocalStorageService.init();
    AppLogger.info('Local Storage initialized successfully');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    AppLogger.error('Error initializing app', e, stackTrace);
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'BlazePlayer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/sign-in': (context) => const SignInScreen(),
              '/sign-up': (context) => const SignUpScreen(),
              '/home': (context) => const HomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/theme-mode': (context) => const ThemeModeScreen(),
              '/modern-onboarding': (context) => const ModernOnboardingScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Wrapper to determine initial route based on auth state and onboarding
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Check if user has completed onboarding
    final hasCompletedOnboarding =
        LocalStorageService.getBool('hasCompletedOnboarding') ?? false;

    // If not completed onboarding, show onboarding flow
    if (!hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // Show loading screen while checking auth state
    if (authProvider.currentUser == null) {
      return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 500)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return authProvider.isAuthenticated
                ? const HomeScreen()
                : const ModernOnboardingScreen();
          }
          return const SplashScreen();
        },
      );
    }

    return authProvider.isAuthenticated
        ? const HomeScreen()
        : const ModernOnboardingScreen();
  }
}

/// Splash screen shown during initialization
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'BlazePlayer',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error app shown if initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: AppTheme.errorColor),
                const SizedBox(height: 24),
                Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check your Firebase configuration and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
