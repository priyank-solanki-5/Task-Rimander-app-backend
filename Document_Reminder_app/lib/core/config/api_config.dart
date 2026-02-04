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

  // 👇 PRODUCTION RENDER BACKEND URL
  // Render testing backend
  static const String baseUrl =
      'https://task-rimander-app-backend-1.onrender.com';

  // Example configurations (uncomment the one you need):
  // static const String baseUrl = 'https://reminderbackend.aurickrystal.com/';  // Production
  // static const String baseUrl = 'http://192.168.1.100:3000';  // Local development
  // static const String baseUrl = 'http://10.0.2.2:3000';       // Android emulator
  // static const String baseUrl = 'http://localhost:3000';      // iOS simulator

  // ========================================
  // ⏱️ TIMEOUT CONFIGURATION
  // ========================================
  // These timeouts control how long the app waits for server responses
  // Adjust these values based on your network conditions and server performance
  // Note: Render free tier may have cold starts, so longer timeouts are needed

  /// Maximum time to wait for establishing connection to the server
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Maximum time to wait for receiving data from the server
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Maximum time to wait for sending data to the server
  static const Duration sendTimeout = Duration(seconds: 60);

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
  static const String notificationPreferences =
      '$apiPrefix/users/notification-preferences';
  static const String userSettings = '$apiPrefix/users/settings';
  static const String userMetadata = '$apiPrefix/users/metadata';

  // ===================================
  // ✅ TASK MANAGEMENT ENDPOINTS
  // ===================================
  static const String tasks = '$apiPrefix/tasks';
  static const String taskSearch = '$tasks/search';
  static const String taskFilter = '$tasks/filter';
  static const String taskSearchFilter = '$tasks/search-filter';
  static const String taskOverdue = '$tasks/overdue';
  static const String taskUpcoming = '$tasks/upcoming';
  static const String taskRecurring = '$tasks/recurring';

  /// Stop recurrence for a task: /api/tasks/:id/stop-recurrence
  static String taskStopRecurrence(String taskId) =>
      '$tasks/$taskId/stop-recurrence';

  /// Process recurring tasks: /api/tasks/process-recurring
  static const String taskProcessRecurring = '$tasks/process-recurring';

  // ===================================
  // 👥 MEMBER MANAGEMENT ENDPOINTS
  // ===================================
  static const String members = '$apiPrefix/members';

  // ===================================
  // 📄 DOCUMENT MANAGEMENT ENDPOINTS
  // ===================================
  static const String documents = '$apiPrefix/documents';
  static const String documentsUpload = '$documents/upload';

  /// Get documents for a task: /api/documents/task/:taskId
  static String documentsForTask(String taskId) => '$documents/task/$taskId';

  /// Download document: /api/documents/:id/download
  static String documentDownload(String documentId) =>
      '$documents/$documentId/download';

  /// Get member statistics: /api/members/stats/overview
  static const String memberStats = '$members/stats/overview';

  /// Search members: /api/members/search?q=query
  static const String searchMembers = '$members/search';

  /// Get member by ID: /api/members/:id
  static String memberById(String id) => '$members/$id';

  // ===================================
  // 🏥 HEALTH CHECK ENDPOINT
  // ===================================
  static const String healthCheck = '$apiPrefix/health';
}
