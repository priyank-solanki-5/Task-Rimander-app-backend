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
import '../widgets/double_back_to_exit_wrapper.dart';

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
    splash: (context) => const DoubleBackToExitWrapper(child: SplashScreen()),
    login: (context) => const DoubleBackToExitWrapper(child: LoginScreen()),
    register: (context) =>
        const DoubleBackToExitWrapper(child: RegisterScreen()),
    forgotPassword: (context) =>
        const DoubleBackToExitWrapper(child: ForgotPasswordScreen()),
    main: (context) => const DoubleBackToExitWrapper(child: MainScreen()),
    addMember: (context) =>
        const DoubleBackToExitWrapper(child: AddMemberScreen()),
    taskDetail: (context) =>
        const DoubleBackToExitWrapper(child: TaskDetailScreen()),
    uploadDocument: (context) =>
        const DoubleBackToExitWrapper(child: AddDocumentScreen()),
    documentViewer: (context) =>
        const DoubleBackToExitWrapper(child: DocumentViewerScreen()),
    notificationSettings: (context) =>
        const DoubleBackToExitWrapper(child: NotificationSettingsScreen()),
    settings: (context) =>
        const DoubleBackToExitWrapper(child: SettingsScreen()),
  };
}
