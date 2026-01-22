/// API Configuration Class
/// 
/// This class centralizes all API-related configuration for the Document Reminder App.
/// It contains the backend server URL, timeout settings, and all API endpoint paths.
/// 
/// Key Features:
/// - Centralized endpoint management
/// - Easy backend URL switching for different environments
/// - Type-safe endpoint access through static constants
/// - Helper methods for dynamic endpoint generation
class ApiConfig {
  // ========================================
  // 🔧 BACKEND CONFIGURATION
  // ========================================
  // 
  // INSTRUCTIONS: Update the baseUrl based on your setup:
  //
  // 1. For REMOTE BACKEND (different laptop on same network):
  //    - Find the IP address of the laptop running the backend
  //    - Windows: Open CMD and run: ipconfig (look for IPv4 Address)
  //    - Mac/Linux: Open Terminal and run: ifconfig or ip addr
  //    - Example: static const String baseUrl = 'http://192.168.1.100:3000';
  //
  // 2. For ANDROID EMULATOR (backend on same computer):
  //    - Use: static const String baseUrl = 'http://10.0.2.2:3000';
  //
  // 3. For iOS SIMULATOR (backend on same computer):
  //    - Use: static const String baseUrl = 'http://localhost:3000';
  //
  // 4. For PHYSICAL DEVICE (backend on same computer):
  //    - Use your computer's IP address (same as option 1)
  //
  // ========================================
  
  // 👇 UPDATE THIS LINE WITH YOUR BACKEND SERVER IP ADDRESS
  static const String baseUrl = 'http://192.168.1.100:3000';
  
  // Example configurations (uncomment the one you need):
  // static const String baseUrl = 'http://192.168.1.100:3000';  // Remote laptop
  // static const String baseUrl = 'http://10.0.2.2:3000';       // Android emulator
  // static const String baseUrl = 'http://localhost:3000';      // iOS simulator
  
  // ========================================
  // ⏱️ TIMEOUT CONFIGURATION
  // ========================================
  // These timeouts control how long the app waits for server responses
  // Adjust these values based on your network conditions and server performance
  
  /// Maximum time to wait for establishing connection to the server
  static const Duration connectTimeout = Duration(seconds: 30);
  
  /// Maximum time to wait for receiving data from the server
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  /// Maximum time to wait for sending data to the server
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // ========================================
  // 🌐 API ENDPOINTS
  // ========================================
  // All API endpoints are organized by feature/resource type
  // The apiPrefix is prepended to all endpoint paths
  
  /// Base prefix for all API endpoints
  static const String apiPrefix = '/api';
  
  // ========================================
  // 🔐 AUTHENTICATION & USER ENDPOINTS
  // ========================================
  // Endpoints for user registration, login, profile management, and settings
  static const String register = '$apiPrefix/users/register';
  static const String login = '$apiPrefix/users/login';
  static const String profile = '$apiPrefix/users/profile';
  static const String changePassword = '$apiPrefix/users/change-password';
  static const String notificationPreferences = '$apiPrefix/users/notification-preferences';
  static const String userSettings = '$apiPrefix/users/settings';
  static const String userMetadata = '$apiPrefix/users/metadata';
  
  // ===================================
  // ✅ TASK MANAGEMENT ENDPOINTS (REMOVED - Local Storage)
  // ===================================
  // ...

  // ===================================
  // 🏥 HEALTH CHECK ENDPOINT
  // ===================================
  static const String healthCheck = '$apiPrefix/health';
}

