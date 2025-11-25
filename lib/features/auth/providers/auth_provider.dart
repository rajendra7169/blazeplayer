import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _init();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize provider
  void _init() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _currentUser = UserModel.fromFirebaseUser(user);
        _saveUserLocally(_currentUser!);
      } else {
        _currentUser = null;
        _clearLocalData();
      }
      notifyListeners();
    });
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        await _saveUserLocally(user);
        AppLogger.info('User signed in: ${user.uid}');
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Sign in error', e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        _currentUser = user;
        await _saveUserLocally(user);
        AppLogger.info('User signed up: ${user.uid}');
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Sign up error', e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        await _saveUserLocally(user);
        AppLogger.info('User signed in with Google: ${user.uid}');
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Google sign in error', e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _authService.signInWithFacebook();

      if (user != null) {
        _currentUser = user;
        await _saveUserLocally(user);
        AppLogger.info('User signed in with Facebook: ${user.uid}');
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Facebook sign in error', e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      await _clearLocalData();
      AppLogger.info('User signed out');
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Sign out error', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Password reset error', e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Save user data locally
  Future<void> _saveUserLocally(UserModel user) async {
    await LocalStorageService.setBool(AppConstants.keyIsLoggedIn, true);
    await LocalStorageService.setString(AppConstants.keyUserId, user.uid);
    if (user.email != null) {
      await LocalStorageService.setString(
        AppConstants.keyUserEmail,
        user.email!,
      );
    }
    if (user.displayName != null) {
      await LocalStorageService.setString(
        AppConstants.keyUserName,
        user.displayName!,
      );
    }
    if (user.photoURL != null) {
      await LocalStorageService.setString(
        AppConstants.keyUserPhoto,
        user.photoURL!,
      );
    }
  }

  /// Clear local user data
  Future<void> _clearLocalData() async {
    await LocalStorageService.remove(AppConstants.keyIsLoggedIn);
    await LocalStorageService.remove(AppConstants.keyUserId);
    await LocalStorageService.remove(AppConstants.keyUserEmail);
    await LocalStorageService.remove(AppConstants.keyUserName);
    await LocalStorageService.remove(AppConstants.keyUserPhoto);
  }
}
