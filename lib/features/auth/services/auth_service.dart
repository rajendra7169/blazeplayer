import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../core/utils/logger.dart';
import '../models/user_model.dart';

/// Authentication service handling all auth operations
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Get current user as UserModel
  UserModel? get currentUserModel {
    final user = currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Signing in with email: $email');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        AppLogger.info('Sign in successful: ${userCredential.user!.uid}');
        return UserModel.fromFirebaseUser(userCredential.user!);
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign in failed', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign in', e, stackTrace);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AppLogger.info('Creating account for email: $email');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null && displayName != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      if (userCredential.user != null) {
        AppLogger.info('Account created: ${userCredential.user!.uid}');
        return UserModel.fromFirebaseUser(
          _firebaseAuth.currentUser ?? userCredential.user!,
        );
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign up failed', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign up', e, stackTrace);
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google sign in');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.info('Google sign in cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        AppLogger.info(
          'Google sign in successful: ${userCredential.user!.uid}',
        );
        return UserModel.fromFirebaseUser(userCredential.user!);
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Google sign in failed', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during Google sign in', e, stackTrace);
      rethrow;
    }
  }

  /// Sign in with Facebook
  Future<UserModel?> signInWithFacebook() async {
    try {
      AppLogger.info('Starting Facebook sign in');

      // Trigger the sign-in flow
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        // Sign in to Firebase with the Facebook credential
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );

        if (userCredential.user != null) {
          AppLogger.info(
            'Facebook sign in successful: ${userCredential.user!.uid}',
          );
          return UserModel.fromFirebaseUser(userCredential.user!);
        }
      } else if (result.status == LoginStatus.cancelled) {
        AppLogger.info('Facebook sign in cancelled by user');
        return null;
      } else {
        AppLogger.error('Facebook sign in failed: ${result.message}');
        throw Exception('Facebook sign in failed: ${result.message}');
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Facebook sign in failed', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during Facebook sign in',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out');
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      AppLogger.info('Sign out successful');
    } catch (e, stackTrace) {
      AppLogger.error('Error during sign out', e, stackTrace);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.info('Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent');
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Failed to send password reset email', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error sending password reset email',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
