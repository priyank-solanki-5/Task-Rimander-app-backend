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

    return await _authApiService.register(
      username: name,
      email: email,
      mobilenumber: mobile,
      password: password,
    );
  }

  /// Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    debugPrint('Attempting login for: $email');

    final result = await _authApiService.login(
      email: email,
      password: password,
    );

    if (result['success'] == true && result.containsKey('user')) {
      _cachedUser = result['user'] as User;
    }

    return result;
  }

  /// Get current logged-in user
  Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    if (_cachedUser != null && !forceRefresh) {
      return _cachedUser;
    }

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
  }

  /// Update user password (for forgot password)
  Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String mobile,
    required String newPassword,
  }) async {
    debugPrint('Attempting password reset for: $email');

    return await _authApiService.changePassword(
      email: email,
      mobilenumber: mobile,
      newPassword: newPassword,
    );
  }

  /// Logout user
  Future<void> logout() async {
    _cachedUser = null;
    await _authApiService.logout();
    debugPrint('User logged out');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _authApiService.isAuthenticated();
  }

  /// Get notification preferences
  Future<NotificationPreferences?> getNotificationPreferences() async {
    return await _authApiService.getNotificationPreferences();
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    return await _authApiService.updateNotificationPreferences(preferences);
  }

  /// Get user settings
  Future<UserSettings?> getUserSettings() async {
    return await _authApiService.getUserSettings();
  }

  /// Update user settings
  Future<bool> updateUserSettings(UserSettings settings) async {
    return await _authApiService.updateUserSettings(settings);
  }

  /// Update user metadata
  Future<bool> updateMetadata(Map<String, dynamic> metadata) async {
    return await _authApiService.updateMetadata(metadata);
  }
}
