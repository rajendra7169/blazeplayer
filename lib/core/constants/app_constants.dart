/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'BlazePlayer';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserPhoto = 'user_photo';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Please check your internet connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';
}
