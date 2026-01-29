import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackToExitWrapper extends StatefulWidget {
  final Widget child;
  final String message;

  const DoubleBackToExitWrapper({
    super.key,
    required this.child,
    this.message = 'Press back again to exit',
  });

  @override
  State<DoubleBackToExitWrapper> createState() =>
      _DoubleBackToExitWrapperState();
}

class _DoubleBackToExitWrapperState extends State<DoubleBackToExitWrapper> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If we can pop (navigate back), let's do that immediately.
        // We only want to prevent accidental APP EXIT, not accidental navigation.
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(result);
          return;
        }

        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.message),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: widget.child,
    );
  }
}
