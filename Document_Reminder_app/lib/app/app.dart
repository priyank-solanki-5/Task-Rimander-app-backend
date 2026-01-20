import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/theme_provider.dart';
import 'routes.dart';
import 'theme.dart';
import 'package:flutter/gestures.dart';

class DocumentReminderApp extends StatelessWidget {
  const DocumentReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Document Reminder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            // Clamp text scaling to keep UI legible across devices
            final currentScale = mq.textScaler.scale(1.0);
            final clampedScale = currentScale.clamp(0.85, 1.25).toDouble();
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(clampedScale)),
              child: ScrollConfiguration(
                behavior: const _AppScrollBehavior(),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
