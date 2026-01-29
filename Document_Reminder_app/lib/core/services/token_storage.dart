import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class TokenStorage {
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _lastLoginKey = 'last_login';

  // Secure storage instance
  static const _storage = FlutterSecureStorage();

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('Error deleting token: $e');
    }
  }

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      debugPrint('Error saving user ID: $e');
    }
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _userEmailKey, value: email);
    } catch (e) {
      debugPrint('Error saving user email: $e');
    }
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return null;
    }
  }

  /// Save token expiry timestamp
  static Future<void> saveTokenExpiry(DateTime expiryTime) async {
    try {
      await _storage.write(
        key: _tokenExpiryKey,
        value: expiryTime.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving token expiry: $e');
    }
  }

  /// Get token expiry timestamp
  static Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null) return null;
      return DateTime.parse(expiryStr);
    } catch (e) {
      debugPrint('Error getting token expiry: $e');
      return null;
    }
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Save last login timestamp
  static Future<void> saveLastLogin(DateTime loginTime) async {
    try {
      await _storage.write(
        key: _lastLoginKey,
        value: loginTime.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving last login: $e');
    }
  }

  /// Get last login timestamp
  static Future<DateTime?> getLastLogin() async {
    try {
      final loginStr = await _storage.read(key: _lastLoginKey);
      if (loginStr == null) return null;
      return DateTime.parse(loginStr);
    } catch (e) {
      debugPrint('Error getting last login: $e');
      return null;
    }
  }

  /// Check if user is authenticated (has valid token)
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    final isExpired = await isTokenExpired();
    return token != null && token.isNotEmpty && !isExpired;
  }

  /// Clear all stored authentication data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }
}
