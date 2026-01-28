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

  /// Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    debugPrint('Attempting login for: $email');

    try {
      final result = await _authApiService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true && result.containsKey('user')) {
        _cachedUser = result['user'] as User;
      }
      return result;
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': e.toString()};
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

  /// Logout user
  Future<void> logout() async {
    try {
      _cachedUser = null;
      await _authApiService.logout();
      debugPrint('User logged out');
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
