import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/utils/logger.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/player/providers/music_player_provider.dart';
import 'features/player/models/song_model.dart';
import 'features/player/widgets/full_player/in_app_webview_google_image.dart';
import 'features/player/widgets/full_player/cover_preview_sheet.dart';
import 'features/player/widgets/full_player/cover_cropper_screen.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/recovery_password_screen.dart';
import 'features/home/screens/music_home_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/screens/modern_onboarding_screen.dart';
import 'features/theme_mode/screens/theme_mode_screen.dart';
import 'features/splash/screens/splash_screen.dart';

// Global theme notifier
final themeNotifier = ThemeNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance = AndroidWebViewPlatform();
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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MusicPlayerProvider()),
      ],
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
              '/recovery-password': (context) => const RecoveryPasswordScreen(),
              '/music-home': (context) => const MusicHomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/theme-mode': (context) => const ThemeModeScreen(),
              '/modern-onboarding': (context) => const ModernOnboardingScreen(),
              '/changeCover': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args != null && args is Song) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return InAppWebViewGoogleImage(
                    query: args.title + ' Album cover',
                    isDark: isDark,
                    onImageSelected: (imageUrl) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: isDark
                            ? const Color(0xFF232323)
                            : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        builder: (context) {
                          return CoverPreviewSheet(
                            imageUrl: imageUrl,
                            isDark: isDark,
                            onUse: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CoverCropperScreen(
                                    imageUrl: imageUrl,
                                    songId: args.id,
                                    isDark: isDark,
                                    onCropped: (croppedFile) async {
                                      // Save cropped image and update provider
                                      // You may want to refresh the UI after this
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
                return const Scaffold(
                  body: Center(child: Text('No song provided')),
                );
              },
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
                ? const MusicHomeScreen()
                : const ModernOnboardingScreen();
          }
          return const SplashScreen();
        },
      );
    }

    return authProvider.isAuthenticated
        ? const MusicHomeScreen()
        : const ModernOnboardingScreen();
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
