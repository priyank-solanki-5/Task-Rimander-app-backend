import 'package:flutter/material.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/documents/screens/document_viewer_screen.dart';
import '../features/documents/screens/add_document_screen.dart';
import '../features/members/screens/add_member_screen.dart';
import '../features/settings/screens/notification_settings_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/tasks/screens/task_detail_screen.dart';
import '../widgets/main_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String addMember = '/add-member';
  static const String taskDetail = '/task-detail';
  static const String uploadDocument = '/upload-document';
  static const String documentViewer = '/document-viewer';
  static const String notificationSettings = '/notification-settings';
  static const String settings = '/settings';

  // Route map
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    main: (context) => const MainScreen(),
    addMember: (context) => const AddMemberScreen(),
    taskDetail: (context) => const TaskDetailScreen(),
    uploadDocument: (context) => const AddDocumentScreen(),
    documentViewer: (context) => const DocumentViewerScreen(),
    notificationSettings: (context) => const NotificationSettingsScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
