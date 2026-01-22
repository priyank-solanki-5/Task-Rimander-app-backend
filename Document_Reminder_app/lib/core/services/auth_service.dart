import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'auth_api_service.dart';
import 'token_storage.dart';

/// Authentication service that wraps the API service
/// Provides a simplified interface for authentication operations
class AuthService {
  final AuthApiService _authApiService = AuthApiService();

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

    return await _authApiService.login(
      email: email,
      password: password,
    );
  }

  /// Get current logged-in user
  Future<User?> getCurrentUser() async {
    final isAuth = await TokenStorage.isAuthenticated();
    if (!isAuth) {
      debugPrint('User not authenticated');
      return null;
    }

    return await _authApiService.getProfile();
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
