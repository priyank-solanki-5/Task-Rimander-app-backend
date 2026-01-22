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
import 'core/config/api_config.dart';
import 'core/services/api_client.dart';
import 'core/services/auth_api_service.dart';
import 'core/services/task_api_service.dart';
import 'core/services/category_api_service.dart';

class ApiConnectionTester {
  final ApiClient _apiClient = ApiClient();
  final AuthApiService _authService = AuthApiService();
  final TaskApiService _taskService = TaskApiService();
  final CategoryApiService _categoryService = CategoryApiService();

  /// Run all connection tests
  Future<void> runAllTests() async {
    debugPrint('\n' + '=' * 60);
    debugPrint('🧪 STARTING API CONNECTION TESTS');
    debugPrint('=' * 60);
    debugPrint('📡 Backend URL: ${ApiConfig.baseUrl}');
    debugPrint('=' * 60 + '\n');

    await testHealthCheck();
    await testCategories();
    
    debugPrint('\n' + '=' * 60);
    debugPrint('✅ ALL TESTS COMPLETED');
    debugPrint('=' * 60 + '\n');
  }

  /// Test 1: Health Check
  Future<void> testHealthCheck() async {
    debugPrint('🔍 Test 1: Health Check');
    debugPrint('-' * 60);
    
    try {
      final response = await _apiClient.get(ApiConfig.health);
      
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
      final categories = await _categoryService.getAllCategories();
      
      if (categories.isNotEmpty) {
        debugPrint('✅ PASSED: Categories retrieved successfully');
        debugPrint('   Found ${categories.length} categories');
        for (var category in categories.take(3)) {
          debugPrint('   - ${category.name}');
        }
      } else {
        debugPrint('⚠️  WARNING: No categories found');
        debugPrint('   💡 Tip: Backend should seed predefined categories on startup');
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
      final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      
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
      final result = await _authService.login(
        email: email,
        password: password,
      );
      
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
      final response = await _apiClient.get(ApiConfig.health);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Print connection info
  void printConnectionInfo() {
    debugPrint('\n' + '=' * 60);
    debugPrint('📡 API CONNECTION INFORMATION');
    debugPrint('=' * 60);
    debugPrint('Backend URL:      ${ApiConfig.baseUrl}');
    debugPrint('Connect Timeout:  ${ApiConfig.connectTimeout.inSeconds}s');
    debugPrint('Receive Timeout:  ${ApiConfig.receiveTimeout.inSeconds}s');
    debugPrint('Send Timeout:     ${ApiConfig.sendTimeout.inSeconds}s');
    debugPrint('=' * 60 + '\n');
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
