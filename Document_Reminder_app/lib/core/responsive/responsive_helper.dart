import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Enhanced responsive helper with padding, spacing, and sizing utilities
class ResponsiveHelper {
  final BuildContext context;

  const ResponsiveHelper(this.context);

  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;
  double get screenPadding => MediaQuery.of(context).padding.top;

  bool get isMobile => Responsive.isMobile(context);
  bool get isTablet => Responsive.isTablet(context);
  bool get isDesktop => Responsive.isDesktop(context);

  /// Responsive padding based on screen size
  double get horizontalPadding {
    if (isDesktop) return 32;
    if (isTablet) return 24;
    return 16;
  }

  /// Responsive vertical padding
  double get verticalPadding {
    if (isDesktop) return 24;
    if (isTablet) return 20;
    return 16;
  }

  /// Responsive font size
  double fontSize(
    double mobileSize, [
    double? tabletSize,
    double? desktopSize,
  ]) {
    if (isDesktop) return desktopSize ?? mobileSize * 1.2;
    if (isTablet) return tabletSize ?? mobileSize * 1.1;
    return mobileSize;
  }

  /// Responsive icon size
  double iconSize(
    double mobileSize, [
    double? tabletSize,
    double? desktopSize,
  ]) {
    if (isDesktop) return desktopSize ?? mobileSize * 1.3;
    if (isTablet) return tabletSize ?? mobileSize * 1.15;
    return mobileSize;
  }

  /// Responsive width for widgets
  double responsiveWidth(double percentage) {
    return screenWidth * (percentage / 100);
  }

  /// Responsive height for widgets
  double responsiveHeight(double percentage) {
    return screenHeight * (percentage / 100);
  }

  /// Get number of columns based on screen size
  int get crossAxisCount {
    if (isDesktop) return 4;
    if (isTablet) return 2;
    return 1;
  }

  /// Get max width for content cards
  double get maxCardWidth {
    if (isDesktop) return 400;
    if (isTablet) return 350;
    return double.infinity;
  }

  /// Get grid spacing based on screen size
  double get gridSpacing {
    if (isDesktop) return 24;
    if (isTablet) return 16;
    return 12;
  }

  /// Check if keyboard is open
  bool get isKeyboardOpen {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get safe bottom padding (for keyboard)
  double get bottomInset {
    return MediaQuery.of(context).viewInsets.bottom;
  }
}

/// Extension for easier access to responsive helper
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}
