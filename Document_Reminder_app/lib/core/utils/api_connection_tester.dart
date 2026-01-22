// ============================================
// 🧪 API CONNECTION TEST UTILITY
// ============================================
//
// This file helps you test the API connection
// Run this to verify backend connectivity
//
// Usage: Uncomment the test in main.dart or run separately
// ============================================

import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_client.dart';
import '../services/auth_api_service.dart';
import '../services/category_api_service.dart';

class ApiConnectionTester {
  final ApiClient _apiClient = ApiClient();
  final AuthApiService _authService = AuthApiService();
  final CategoryApiService _categoryService = CategoryApiService();

  /// Run all connection tests
  Future<void> runAllTests() async {
    final separator = '=' * 60;
    debugPrint('\n$separator');
    debugPrint('🧪 STARTING API CONNECTION TESTS');
    debugPrint(separator);
    debugPrint('📡 Backend URL: ${ApiConfig.baseUrl}');
    debugPrint('$separator\n');
    debugPrint('ℹ️  This is a utility to test API connectivity');
    debugPrint(
      'ℹ️  Enable debugging by uncommenting testApiConnection() in main.dart\n',
    );

    await testHealthCheck();
    await testCategories();

    debugPrint('\n$separator');
    debugPrint('✅ ALL TESTS COMPLETED');
    debugPrint('$separator\n');
  }

  /// Test 1: Health Check
  Future<void> testHealthCheck() async {
    debugPrint('🔍 Test 1: Health Check');
    debugPrint('-' * 60);

    try {
      final response = await _apiClient.get(ApiConfig.healthCheck);

      if (response.statusCode == 200) {
        debugPrint('✅ PASSED: Backend is reachable');
        debugPrint('   Response: ${response.data}');
      } else {
        debugPrint('❌ FAILED: Unexpected status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ FAILED: $e');
      debugPrint('   💡 Tip: Check if backend server is running');
      debugPrint('   💡 Tip: Verify IP address in api_config.dart');
    }
    debugPrint('');
  }

  /// Test 2: Get Categories (No Auth Required)
  Future<void> testCategories() async {
    debugPrint('🔍 Test 2: Get Categories');
    debugPrint('-' * 60);

    try {
      final result = await _categoryService.getAllCategories();

      if (result['success'] == true) {
        final categories = result['data'] as List? ?? [];
        debugPrint('✅ PASSED: Categories retrieved successfully');
        debugPrint('   Found ${categories.length} categories');
        for (var category in categories.take(3)) {
          debugPrint('   - $category');
        }
      } else {
        debugPrint('⚠️  WARNING: No categories found');
        debugPrint(
          '   💡 Tip: Backend should seed predefined categories on startup',
        );
      }
    } catch (e) {
      debugPrint('❌ FAILED: $e');
      debugPrint('   💡 Tip: Check backend logs for errors');
    }
    debugPrint('');
  }

  /// Test 3: User Registration (Optional - creates test user)
  Future<void> testUserRegistration() async {
    debugPrint('🔍 Test 3: User Registration');
    debugPrint('-' * 60);

    try {
      final testEmail =
          'test_${DateTime.now().millisecondsSinceEpoch}@example.com';

      final result = await _authService.register(
        username: 'Test User',
        email: testEmail,
        mobilenumber: '1234567890',
        password: 'Test@123',
      );

      if (result['success'] == true) {
        debugPrint('✅ PASSED: User registered successfully');
        debugPrint('   Email: $testEmail');
        debugPrint('   Token received: ${result['token'] != null}');
      } else {
        debugPrint('❌ FAILED: ${result['message']}');
      }
    } catch (e) {
      debugPrint('❌ FAILED: $e');
      debugPrint('   💡 Tip: Check if MongoDB is connected');
    }
    debugPrint('');
  }

  /// Test 4: User Login
  Future<void> testUserLogin(String email, String password) async {
    debugPrint('🔍 Test 4: User Login');
    debugPrint('-' * 60);

    try {
      final result = await _authService.login(email: email, password: password);

      if (result['success'] == true) {
        debugPrint('✅ PASSED: User logged in successfully');
        debugPrint('   Token received: ${result['token'] != null}');
      } else {
        debugPrint('❌ FAILED: ${result['message']}');
      }
    } catch (e) {
      debugPrint('❌ FAILED: $e');
    }
    debugPrint('');
  }

  /// Quick connection check (just health endpoint)
  Future<bool> quickCheck() async {
    try {
      final response = await _apiClient.get(ApiConfig.healthCheck);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Print connection info
  void printConnectionInfo() {
    final separator = '=' * 60;
    debugPrint('\n$separator');
    debugPrint('📡 API CONNECTION INFORMATION');
    debugPrint(separator);
    debugPrint('Backend URL:      ${ApiConfig.baseUrl}');
    debugPrint('Connect Timeout:  ${ApiConfig.connectTimeout.inSeconds}s');
    debugPrint('Receive Timeout:  ${ApiConfig.receiveTimeout.inSeconds}s');
    debugPrint('Send Timeout:     ${ApiConfig.sendTimeout.inSeconds}s');
    debugPrint('$separator\n');
  }
}

// ============================================
// HOW TO USE THIS TESTER
// ============================================
//
// Option 1: Add to main.dart (before runApp):
// ```dart
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   
//   // Test API connection
//   final tester = ApiConnectionTester();
//   tester.printConnectionInfo();
//   await tester.runAllTests();
//   
//   runApp(MyApp());
// }
// ```
//
// Option 2: Create a test button in your app:
// ```dart
// ElevatedButton(
//   onPressed: () async {
//     final tester = ApiConnectionTester();
//     await tester.runAllTests();
//   },
//   child: Text('Test API Connection'),
// )
// ```
//
// Option 3: Quick check before login:
// ```dart
// final tester = ApiConnectionTester();
// final isConnected = await tester.quickCheck();
// if (!isConnected) {
//   showDialog(...); // Show error dialog
// }
// ```
// ============================================
