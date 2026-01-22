import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../utils/api_exception.dart';
import 'api_client.dart';
import 'token_storage.dart';

/// Authentication API Service
///
/// This service handles all authentication and user management operations.
/// It communicates with the backend API for user registration, login, profile management,
/// password changes, and user settings.
///
/// Key Features:
/// - User registration and login
/// - JWT token management (automatic storage)
/// - Profile retrieval and updates
/// - Password change functionality
/// - Notification preferences management
/// - User settings management
/// - Automatic error handling with user-friendly messages
class AuthApiService {
  /// API client instance for making HTTP requests
  final ApiClient _apiClient = ApiClient();

  // ========================================
  // 🔐 AUTHENTICATION METHODS
  // ========================================

  /// Registers a new user account
  ///
  /// Parameters:
  /// - [username]: User's display name
  /// - [email]: User's email address (must be unique)
  /// - [mobilenumber]: User's mobile number for account recovery
  /// - [password]: User's password (will be hashed on backend)
  ///
  /// Returns: Map with 'success' (bool) and 'message' (String)
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.register(
  ///   username: 'John Doe',
  ///   email: 'john@example.com',
  ///   mobilenumber: '+1234567890',
  ///   password: 'securePassword123',
  /// );
  /// if (result['success']) {
  ///   // Registration successful
  /// }
  /// ```
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String mobilenumber,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        data: {
          'username': username,
          'email': email,
          'mobilenumber': mobilenumber,
          'password': password,
        },
      );

      debugPrint('Register response: ${response.data}');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Registration successful',
      };
    } on ApiException catch (e) {
      debugPrint('Register error: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Register unexpected error: $e');
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  /// Authenticates a user and stores the JWT token
  ///
  /// This method logs in a user with their email and password.
  /// On success, it automatically stores the JWT token and user information
  /// in secure storage for subsequent authenticated requests.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns: Map containing:
  /// - 'success' (bool): Whether login was successful
  /// - 'message' (String): Success or error message
  /// - 'user' (User): User object (only on success)
  /// - 'token' (String): JWT authentication token (only on success)
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.login(
  ///   email: 'john@example.com',
  ///   password: 'securePassword123',
  /// );
  /// if (result['success']) {
  ///   final user = result['user'] as User;
  ///   // Navigate to home screen
  /// }
  /// ```
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      debugPrint('Login response: ${response.data}');

      final token = response.data['token'] as String;
      final userData = response.data['data'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      // Save token and user info
      await TokenStorage.saveToken(token);
      await TokenStorage.saveUserId(user.id!);
      await TokenStorage.saveUserEmail(user.email);

      return {
        'success': true,
        'message': 'Login successful',
        'user': user,
        'token': token,
      };
    } on UnauthorizedException catch (e) {
      debugPrint('Login unauthorized: ${e.message}');
      return {'success': false, 'message': e.message};
    } on ApiException catch (e) {
      debugPrint('Login error: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Login unexpected error: $e');
      return {'success': false, 'message': 'Login failed. Please try again.'};
    }
  }

  // ========================================
  // 👤 PROFILE MANAGEMENT METHODS
  // ========================================

  /// Retrieves the current authenticated user's profile
  ///
  /// This method fetches the user profile from the backend using the stored JWT token.
  /// If the token is invalid or expired (401 Unauthorized), it automatically logs out the user.
  ///
  /// Returns: User object on success, null on error
  ///
  /// Example:
  /// ```dart
  /// final user = await authService.getProfile();
  /// if (user != null) {
  ///   print('Welcome, ${user.username}!');
  /// }
  /// ```
  Future<User?> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.profile);

      debugPrint('Profile response: ${response.data}');

      final userData = response.data['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } on UnauthorizedException catch (e) {
      debugPrint('Get profile unauthorized: ${e.message}');
      await logout(); // Auto logout if unauthorized
      return null;
    } on ApiException catch (e) {
      debugPrint('Get profile error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Get profile unexpected error: $e');
      return null;
    }
  }

  /// Changes the user's password using email and mobile verification
  ///
  /// This method allows users to change their password by verifying their
  /// email and mobile number. This provides a secure password reset mechanism.
  ///
  /// Parameters:
  /// - [email]: User's email address (for verification)
  /// - [mobilenumber]: User's mobile number (for verification)
  /// - [newPassword]: The new password to set
  ///
  /// Returns: Map with 'success' (bool) and 'message' (String)
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.changePassword(
  ///   email: 'john@example.com',
  ///   mobilenumber: '+1234567890',
  ///   newPassword: 'newSecurePassword456',
  /// );
  /// if (result['success']) {
  ///   // Password changed successfully
  /// }
  /// ```
  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String mobilenumber,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.changePassword,
        data: {
          'email': email,
          'mobilenumber': mobilenumber,
          'newPassword': newPassword,
        },
      );

      debugPrint('Change password response: ${response.data}');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Password changed successfully',
      };
    } on ApiException catch (e) {
      debugPrint('Change password error: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Change password unexpected error: $e');
      return {
        'success': false,
        'message': 'Failed to change password. Please try again.',
      };
    }
  }

  // ========================================
  // 🔔 NOTIFICATION PREFERENCES METHODS
  // ========================================

  /// Retrieves the user's notification preferences
  ///
  /// Returns: NotificationPreferences object on success, null on error
  ///
  /// Example:
  /// ```dart
  /// final prefs = await authService.getNotificationPreferences();
  /// if (prefs != null) {
  ///   print('Email notifications: ${prefs.emailEnabled}');
  /// }
  /// ```
  Future<NotificationPreferences?> getNotificationPreferences() async {
    try {
      final response = await _apiClient.get(ApiConfig.notificationPreferences);

      debugPrint('Notification preferences response: ${response.data}');

      final prefsData = response.data['preferences'] as Map<String, dynamic>;
      return NotificationPreferences.fromJson(prefsData);
    } on ApiException catch (e) {
      debugPrint('Get notification preferences error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Get notification preferences unexpected error: $e');
      return null;
    }
  }

  /// Updates the user's notification preferences
  ///
  /// Parameters:
  /// - [preferences]: NotificationPreferences object with updated settings
  ///
  /// Returns: true on success, false on error
  ///
  /// Example:
  /// ```dart
  /// final prefs = NotificationPreferences(
  ///   emailEnabled: true,
  ///   pushEnabled: false,
  /// );
  /// final success = await authService.updateNotificationPreferences(prefs);
  /// ```
  Future<bool> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.notificationPreferences,
        data: preferences.toJson(),
      );

      debugPrint('Update notification preferences response: ${response.data}');
      return true;
    } on ApiException catch (e) {
      debugPrint('Update notification preferences error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Update notification preferences unexpected error: $e');
      return false;
    }
  }

  // ========================================
  // ⚙️ USER SETTINGS METHODS
  // ========================================

  /// Retrieves the user's application settings
  ///
  /// Returns: UserSettings object on success, null on error
  ///
  /// Example:
  /// ```dart
  /// final settings = await authService.getUserSettings();
  /// if (settings != null) {
  ///   print('Theme: ${settings.theme}');
  /// }
  /// ```
  Future<UserSettings?> getUserSettings() async {
    try {
      final response = await _apiClient.get(ApiConfig.userSettings);

      debugPrint('User settings response: ${response.data}');

      final settingsData = response.data['settings'] as Map<String, dynamic>;
      return UserSettings.fromJson(settingsData);
    } on ApiException catch (e) {
      debugPrint('Get user settings error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Get user settings unexpected error: $e');
      return null;
    }
  }

  /// Updates the user's application settings
  ///
  /// Parameters:
  /// - [settings]: UserSettings object with updated settings
  ///
  /// Returns: true on success, false on error
  ///
  /// Example:
  /// ```dart
  /// final settings = UserSettings(
  ///   theme: 'dark',
  ///   language: 'en',
  /// );
  /// final success = await authService.updateUserSettings(settings);
  /// ```
  Future<bool> updateUserSettings(UserSettings settings) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.userSettings,
        data: settings.toJson(),
      );

      debugPrint('Update user settings response: ${response.data}');
      return true;
    } on ApiException catch (e) {
      debugPrint('Update user settings error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Update user settings unexpected error: $e');
      return false;
    }
  }

  /// Updates user metadata (custom key-value data)
  ///
  /// This method allows storing arbitrary metadata associated with the user.
  ///
  /// Parameters:
  /// - [metadata]: Map of key-value pairs to store
  ///
  /// Returns: true on success, false on error
  ///
  /// Example:
  /// ```dart
  /// final success = await authService.updateMetadata({
  ///   'lastLoginDevice': 'Android',
  ///   'appVersion': '1.0.0',
  /// });
  /// ```
  Future<bool> updateMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.userMetadata,
        data: metadata,
      );

      debugPrint('Update metadata response: ${response.data}');
      return true;
    } on ApiException catch (e) {
      debugPrint('Update metadata error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Update metadata unexpected error: $e');
      return false;
    }
  }

  // ========================================
  // 🚪 LOGOUT & SESSION METHODS
  // ========================================

  /// Logs out the current user by clearing all stored authentication data
  ///
  /// This method removes the JWT token, user ID, and email from secure storage.
  /// After logout, the user will need to login again to access protected resources.
  ///
  /// Example:
  /// ```dart
  /// await authService.logout();
  /// // Navigate to login screen
  /// ```
  Future<void> logout() async {
    await TokenStorage.clearAll();
    debugPrint('User logged out');
  }

  /// Checks if a user is currently authenticated
  ///
  /// Returns: true if a valid JWT token exists in storage, false otherwise
  ///
  /// Example:
  /// ```dart
  /// final isLoggedIn = await authService.isAuthenticated();
  /// if (!isLoggedIn) {
  ///   // Redirect to login screen
  /// }
  /// ```
  Future<bool> isAuthenticated() async {
    return await TokenStorage.isAuthenticated();
  }
}
