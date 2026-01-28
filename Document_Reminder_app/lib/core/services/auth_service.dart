import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'auth_api_service.dart';
import 'token_storage.dart';

/// Authentication service that wraps the API service
/// Provides a simplified interface for authentication operations
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final AuthApiService _authApiService = AuthApiService();
  User? _cachedUser;

  /// Register a new user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    debugPrint('Attempting to register user: $email');

    try {
      return await _authApiService.register(
        username: name,
        email: email,
        mobilenumber: mobile,
        password: password,
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Login user with 30-day persistence
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    debugPrint('Attempting login for: $email');

    try {
      final result = await _authApiService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true && result.containsKey('user')) {
        _cachedUser = result['user'] as User;

        // Save login session with 30-day expiry if remember me is enabled
        if (rememberMe && result.containsKey('token')) {
          await _saveLoginSession(result['token']);
        }
      }
      return result;
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Save login session for 30 days
  Future<void> _saveLoginSession(String token) async {
    try {
      await TokenStorage.saveToken(token);
      // Set expiry to 30 days from now
      final expiryTime = DateTime.now().add(const Duration(days: 30));
      await TokenStorage.saveTokenExpiry(expiryTime);
      await TokenStorage.saveLastLogin(DateTime.now());
      debugPrint('Login session saved for 30 days');
    } catch (e) {
      debugPrint('Error saving login session: $e');
    }
  }

  /// Auto-login if session is still valid
  Future<bool> autoLogin() async {
    try {
      debugPrint('Checking for existing session...');

      final isAuth = await TokenStorage.isAuthenticated();
      if (!isAuth) {
        debugPrint('No valid session found');
        return false;
      }

      // Try to refresh token to ensure it's fresh
      final refreshResult = await _authApiService.refreshToken();
      if (refreshResult['success'] == false) {
        // If refresh fails, try to get profile anyway
        final user = await getCurrentUser(forceRefresh: true);
        return user != null;
      }

      debugPrint('Auto-login successful');
      return true;
    } catch (e) {
      debugPrint('Auto-login error: $e');
      return false;
    }
  }

  /// Get current logged-in user
  Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    if (_cachedUser != null && !forceRefresh) {
      return _cachedUser;
    }

    try {
      final isAuth = await TokenStorage.isAuthenticated();
      if (!isAuth) {
        debugPrint('User not authenticated');
        _cachedUser = null;
        return null;
      }

      final user = await _authApiService.getProfile();
      if (user != null) {
        _cachedUser = user;
      }
      return user;
    } catch (e) {
      debugPrint('Get current user error: $e');
      return null;
    }
  }

  /// Update user password (for forgot password)
  Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String mobile,
    required String newPassword,
  }) async {
    debugPrint('Attempting password reset for: $email');

    try {
      return await _authApiService.changePassword(
        email: email,
        mobilenumber: mobile,
        newPassword: newPassword,
      );
    } catch (e) {
      debugPrint('Update password error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Logout user and clear session
  Future<void> logout() async {
    try {
      _cachedUser = null;
      await TokenStorage.clearAll();
      await _authApiService.logout();
      debugPrint('User logged out and session cleared');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      return await _authApiService.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  /// Get notification preferences
  Future<NotificationPreferences?> getNotificationPreferences() async {
    try {
      return await _authApiService.getNotificationPreferences();
    } catch (e) {
      return null;
    }
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      return await _authApiService.updateNotificationPreferences(preferences);
    } catch (e) {
      return false;
    }
  }

  /// Get user settings
  Future<UserSettings?> getUserSettings() async {
    try {
      return await _authApiService.getUserSettings();
    } catch (e) {
      return null;
    }
  }

  /// Update user settings
  Future<bool> updateUserSettings(UserSettings settings) async {
    try {
      return await _authApiService.updateUserSettings(settings);
    } catch (e) {
      return false;
    }
  }

  /// Update user metadata
  Future<bool> updateMetadata(Map<String, dynamic> metadata) async {
    try {
      return await _authApiService.updateMetadata(metadata);
    } catch (e) {
      return false;
    }
  }
}
