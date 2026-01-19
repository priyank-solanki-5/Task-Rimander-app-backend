import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  // Get all registered users
  Future<List<User>> _getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5));
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null || usersJson.isEmpty) {
        print('No users found in storage');
        return [];
      }

      final List<dynamic> usersList = jsonDecode(usersJson);
      print('Loaded ${usersList.length} users from storage');
      return usersList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  // Save users list
  Future<void> _saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5));
      final usersJson = jsonEncode(users.map((u) => u.toJson()).toList());
      await prefs.setString(_usersKey, usersJson);
      print('Saved ${users.length} users to storage');
    } catch (e) {
      print('Error saving users: $e');
      throw Exception('Failed to save users: $e');
    }
  }

  // Check if user with email exists
  Future<bool> isUserRegistered(String email) async {
    final users = await _getUsers();
    return users.any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final users = await _getUsers();
    try {
      return users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Register new user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      print('Attempting to register user: $email');

      // Check if user already exists
      if (await isUserRegistered(email)) {
        print('Registration failed: Email already registered');
        return {
          'success': false,
          'message': 'An account with this email already exists. Please login.',
        };
      }

      // Create new user
      final newUser = User(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
      );

      // Add to users list
      final users = await _getUsers();
      users.add(newUser);
      await _saveUsers(users);

      print('User registered successfully: $email');
      return {
        'success': true,
        'message': 'Registration successful! Please login.',
      };
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login for: $email');

      // Check if user exists
      final user = await getUserByEmail(email);
      
      if (user == null) {
        print('Login failed: User not found');
        return {
          'success': false,
          'message': 'No account found with this email. Please register first.',
        };
      }

      // Verify password
      if (user.password != password) {
        print('Login failed: Incorrect password');
        return {
          'success': false,
          'message': 'Incorrect password. Please try again.',
        };
      }

      // Save current user
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5));
      await prefs.setString(_currentUserKey, user.toJsonString());

      print('Login successful for: $email');
      return {
        'success': true,
        'message': 'Login successful!',
        'user': user,
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Login failed. Please try again.',
      };
    }
  }

  // Update user password (for forgot password)
  Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String mobile,
    required String newPassword,
  }) async {
    print('Attempting password reset for: $email');

    // Get user
    final user = await getUserByEmail(email);
    
    if (user == null) {
      print('Password reset failed: User not found');
      return {
        'success': false,
        'message': 'No account found with this email.',
      };
    }

    // Verify mobile number
    if (user.mobile != mobile) {
      print('Password reset failed: Mobile number mismatch');
      return {
        'success': false,
        'message': 'Mobile number does not match our records.',
      };
    }

    // Update password
    final users = await _getUsers();
    final updatedUsers = users.map((u) {
      if (u.email.toLowerCase() == email.toLowerCase()) {
        return User(
          name: u.name,
          email: u.email,
          mobile: u.mobile,
          password: newPassword,
        );
      }
      return u;
    }).toList();

    await _saveUsers(updatedUsers);

    print('Password updated successfully for: $email');
    return {
      'success': true,
      'message': 'Password reset successful! Please login with your new password.',
    };
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) {
      return null;
    }

    try {
      return User.fromJsonString(userJson);
    } catch (e) {
      print('Error loading current user: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    print('User logged out');
  }

  // Clear all users (for testing)
  Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
    print('All users cleared');
  }
}
