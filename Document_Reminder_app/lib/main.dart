import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/document_provider.dart';
import 'core/providers/category_provider.dart';
import 'core/providers/member_provider.dart';
import 'core/providers/theme_provider.dart';
import 'app/app.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, // Default to dark icons (for light background)
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeMode();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const DocumentReminderApp(),
    ),
  );
}
