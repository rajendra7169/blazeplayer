import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Local storage service using SharedPreferences
class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('LocalStorageService initialized');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize LocalStorageService',
        e,
        stackTrace,
      );
    }
  }

  static bool get isInitialized => _prefs != null;

  static Future<bool> setString(String key, String value) async {
    try {
      return await _prefs?.setString(key, value) ?? false;
    } catch (e, stackTrace) {
      AppLogger.error('Error setting string: $key', e, stackTrace);
      return false;
    }
  }

  static String? getString(String key) {
    try {
      return _prefs?.getString(key);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting string: $key', e, stackTrace);
      return null;
    }
  }

  static Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs?.setBool(key, value) ?? false;
    } catch (e, stackTrace) {
      AppLogger.error('Error setting bool: $key', e, stackTrace);
      return false;
    }
  }

  static bool? getBool(String key) {
    try {
      return _prefs?.getBool(key);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting bool: $key', e, stackTrace);
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      return await _prefs?.remove(key) ?? false;
    } catch (e, stackTrace) {
      AppLogger.error('Error removing key: $key', e, stackTrace);
      return false;
    }
  }

  static Future<bool> clear() async {
    try {
      return await _prefs?.clear() ?? false;
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing storage', e, stackTrace);
      return false;
    }
  }
}
