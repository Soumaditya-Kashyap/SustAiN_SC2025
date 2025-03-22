import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PrefsService {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNameKey = 'user_name';
  static const String PASSWORD_KEY = 'USER_PASSWORD'; // Key for secure storage

  // For secure passwords
  static final _secureStorage = FlutterSecureStorage();

  // Save user data on login
  static Future<bool> saveUserSession({
    required String userId,
    required String email,
    required String role,
    String? name,
    String? password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userRoleKey, role);
      await prefs.setBool(_isLoggedInKey, true);

      if (name != null) {
        await prefs.setString(_userNameKey, name);
      }

      // Store password securely if provided
      if (password != null) {
        await _secureStorage.write(key: PASSWORD_KEY, value: password);
      }

      print('User session saved: $userId, $email, $role');
      return true;
    } catch (e) {
      print('Error saving user session: $e');
      return false;
    }
  }

  // Clear user data on logout
  static Future<bool> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userNameKey);
      await prefs.setBool(_isLoggedInKey, false);

      // Clear securely stored password
      await _secureStorage.delete(key: PASSWORD_KEY);

      print('User session cleared');
      return true;
    } catch (e) {
      print('Error clearing user session: $e');
      return false;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  // Get user role
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userRoleKey);
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Get complete user session data
  static Future<Map<String, dynamic>> getUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'userId': prefs.getString(_userIdKey),
        'email': prefs.getString(_userEmailKey),
        'role': prefs.getString(_userRoleKey),
        'name': prefs.getString(_userNameKey),
        'isLoggedIn': prefs.getBool(_isLoggedInKey) ?? false,
      };
    } catch (e) {
      print('Error getting user session: $e');
      return {
        'userId': null,
        'email': null,
        'role': null,
        'name': null,
        'isLoggedIn': false,
      };
    }
  }

  // Save theme preference
  static Future<bool> saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themePreference, isDark);
      return true;
    } catch (e) {
      print('Error saving theme preference: $e');
      return false;
    }
  }

  // Get theme preference
  static Future<bool> getThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.themePreference) ?? false;
    } catch (e) {
      print('Error getting theme preference: $e');
      return false;
    }
  }

  // Get saved password (used for auto-login)
  static Future<String?> getSavedPassword() async {
    try {
      return await _secureStorage.read(key: PASSWORD_KEY);
    } catch (e) {
      print('Error retrieving saved password: $e');
      return null;
    }
  }
}
