import 'package:flutter/material.dart';
import 'core/services/auth_api_service.dart';
import 'core/services/token_storage.dart';

/// Example usage of the API services
/// This file demonstrates basic API service usage
class ApiUsageExample {
  final AuthApiService _authService = AuthApiService();

  /// Example: User authentication flow
  Future<void> exampleAuthFlow() async {
    // Register a new user
    final registerResult = await _authService.register(
      username: 'John Doe',
      email: 'john@example.com',
      mobilenumber: '1234567890',
      password: 'securePassword123',
    );

    if (registerResult['success']) {
      debugPrint('✅ Registration successful');

      // Login with credentials
      final loginResult = await _authService.login(
        email: 'john@example.com',
        password: 'securePassword123',
      );

      if (loginResult['success']) {
        debugPrint('✅ Login successful');
      }
    }
  }

  /// Example: Logout
  Future<void> exampleLogout() async {
    await _authService.logout();
    debugPrint('✅ User logged out');

    final isAuth = await TokenStorage.isAuthenticated();
    debugPrint('Is authenticated: $isAuth');
  }
}

/// Example widget using API services
class ExampleTaskScreen extends StatefulWidget {
  const ExampleTaskScreen({super.key});

  @override
  State<ExampleTaskScreen> createState() => _ExampleTaskScreenState();
}

class _ExampleTaskScreenState extends State<ExampleTaskScreen> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text('Tasks will be loaded from MongoDB via API'),
            ),
    );
  }
}
