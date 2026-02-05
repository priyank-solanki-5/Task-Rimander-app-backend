// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   // Modern Color Palette
//   static const Color primaryLight = Color(0xFF6366F1); // Indigo
//   static const Color secondaryLight = Color(0xFF10B981); // Emerald
//   static const Color tertiaryLight = Color(0xFFF59E0B); // Amber
//   static const Color surfaceLight = Color(0xFFF9FAFB);
//   static const Color backgroundLight = Color(0xFFFFFFFF);
//   static const Color errorLight = Color(0xFFEF4444);

//   static const Color primaryDark = Color(0xFF818CF8); // Light Indigo
//   static const Color secondaryDark = Color(0xFF34D399); // Light Emerald
//   static const Color tertiaryDark = Color(0xFFFCD34D); // Light Amber
//   static const Color surfaceDark = Color(0xFF1F2937); // Dark Gray
//   static const Color backgroundDark = Color(
//     0xFF111827,
//   ); // Very Dark Gray (almost black)
//   static const Color errorDark = Color(0xFFF87171);

//   // Custom Dark Mode Background (Softer than #111827)
//   static const Color scaffoldDark = Color(0xFF0F172A); // Slate 900

//   // Light Theme
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       fontFamily: GoogleFonts.poppins().fontFamily,
//       brightness: Brightness.light,
//       colorScheme: ColorScheme.light(
//         primary: primaryLight,
//         secondary: secondaryLight,
//         tertiary: tertiaryLight,
//         surface: surfaceLight,
//         error: errorLight,
//         onPrimary: Colors.white,
//         onSecondary: Colors.white,
//         onSurface: const Color(0xFF1F2937),
//       ),

//       // AppBar Theme (light: black background, white text/icons)
//       appBarTheme: AppBarTheme(
//         elevation: 0,
//         centerTitle: false,
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.white),
//         surfaceTintColor: Colors.transparent,
//         scrolledUnderElevation: 0,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//         titleTextStyle: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),

//       // Card Theme
//       cardTheme: CardThemeData(
//         elevation: 0,
//         shadowColor: Colors.black.withValues(alpha: 0.05), // Softer shadow
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: Colors.grey.shade200, width: 1),
//         ),
//         color: Colors.white,
//         surfaceTintColor: Colors.transparent,
//       ),

//       // Input Decoration Theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16), // Softer corners
//           borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: primaryLight, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: errorLight, width: 1),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: errorLight, width: 2),
//         ),
//         hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
//         labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
//         floatingLabelStyle: GoogleFonts.poppins(
//           color: primaryLight,
//           fontWeight: FontWeight.w600,
//         ),
//       ),

//       // Elevated Button Theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           backgroundColor: primaryLight,
//           foregroundColor: Colors.white,
//           textStyle: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),

//       // Text Button Theme
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: primaryLight,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           textStyle: GoogleFonts.poppins(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),

//       // Outlined Button Theme
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: primaryLight,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           side: const BorderSide(color: primaryLight, width: 1.5),
//           textStyle: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),

//       // Bottom Navigation Bar Theme
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         elevation: 8,
//         backgroundColor: Colors.white,
//         selectedItemColor: primaryLight,
//         unselectedItemColor: Colors.grey.shade400,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         selectedLabelStyle: GoogleFonts.poppins(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//         unselectedLabelStyle: GoogleFonts.poppins(
//           fontWeight: FontWeight.w500,
//           fontSize: 12,
//         ),
//       ),

//       // Floating Action Button Theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         elevation: 4,
//         backgroundColor: primaryLight,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       ),

//       // Text Theme with Inter
//       textTheme: TextTheme(
//         displayLarge: GoogleFonts.poppins(
//           fontSize: 32,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFF1F2937),
//         ),
//         displayMedium: GoogleFonts.poppins(
//           fontSize: 28,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFF1F2937),
//         ),
//         headlineLarge: GoogleFonts.poppins(
//           fontSize: 24,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFF1F2937),
//         ),
//         headlineMedium: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF1F2937),
//         ),
//         headlineSmall: GoogleFonts.poppins(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF1F2937),
//         ),
//         titleLarge: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF1F2937),
//         ),
//         titleMedium: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: const Color(0xFF374151),
//         ),
//         bodyLarge: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF374151),
//         ),
//         bodyMedium: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF6B7280),
//         ),
//         bodySmall: GoogleFonts.poppins(
//           fontSize: 12,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF9CA3AF),
//         ),
//         labelLarge: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF374151),
//         ),
//       ),

//       // Divider Theme
//       dividerTheme: DividerThemeData(
//         color: Colors.grey.shade200,
//         thickness: 1,
//         space: 1,
//       ),

//       scaffoldBackgroundColor: backgroundLight,
//     );
//   }

//   // Dark Theme
//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       fontFamily: GoogleFonts.poppins().fontFamily,
//       brightness: Brightness.dark,
//       colorScheme: ColorScheme.dark(
//         primary: primaryDark,
//         secondary: secondaryDark,
//         tertiary: tertiaryDark,
//         error: errorDark,
//         onPrimary: Colors.black,
//         onSecondary: Colors.black,
//         onSurface: const Color(0xFFF3F4F6),
//         surface: scaffoldDark, // App background
//       ),

//       // AppBar Theme (dark: soft light background, dark text/icons)
//       appBarTheme: AppBarTheme(
//         elevation: 0,
//         centerTitle: false,
//         backgroundColor: const Color(0xFFF1F5F9),
//         foregroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.black),
//         surfaceTintColor: Colors.transparent,
//         scrolledUnderElevation: 0,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//         titleTextStyle: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//       ),

//       // Card Theme
//       cardTheme: CardThemeData(
//         elevation: 0,
//         shadowColor: Colors.black.withValues(
//           alpha: 0.2,
//         ), // Subtle shadow in dark mode
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(
//             color: Colors.grey.shade800,
//             width: 1,
//           ), // Softer border
//         ),
//         color: surfaceDark, // Slightly lighter than background
//         surfaceTintColor: Colors.transparent,
//       ),

//       // Input Decoration Theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: const Color(0xFF1E293B), // Slate 800
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: primaryDark, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: errorDark, width: 1),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: errorDark, width: 2),
//         ),
//         hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
//         labelStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
//         floatingLabelStyle: GoogleFonts.poppins(
//           color: primaryDark,
//           fontWeight: FontWeight.w600,
//         ),
//       ),

//       // Elevated Button Theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           backgroundColor: primaryDark,
//           foregroundColor: Colors.black, // Dark text on light button
//           textStyle: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),

//       // Text Button Theme
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: primaryDark,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           textStyle: GoogleFonts.poppins(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),

//       // Outlined Button Theme
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: primaryDark,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           side: const BorderSide(color: primaryDark, width: 1.5),
//           textStyle: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),

//       // Bottom Navigation Bar Theme
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         elevation: 8,
//         backgroundColor: surfaceDark, // Match card color
//         selectedItemColor: primaryDark,
//         unselectedItemColor: Colors.grey.shade500,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         selectedLabelStyle: GoogleFonts.poppins(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//         unselectedLabelStyle: GoogleFonts.poppins(
//           fontWeight: FontWeight.w500,
//           fontSize: 12,
//         ),
//       ),

//       // Floating Action Button Theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         elevation: 4,
//         backgroundColor: primaryDark,
//         foregroundColor: Colors.black,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       ),

//       // Text Theme
//       textTheme: TextTheme(
//         displayLarge: GoogleFonts.poppins(
//           fontSize: 32,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFFF3F4F6),
//         ),
//         displayMedium: GoogleFonts.poppins(
//           fontSize: 28,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFFF3F4F6),
//         ),
//         headlineLarge: GoogleFonts.poppins(
//           fontSize: 24,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFFF3F4F6),
//         ),
//         headlineMedium: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFFF3F4F6),
//         ),
//         headlineSmall: GoogleFonts.poppins(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFFF3F4F6),
//         ),
//         titleLarge: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFFF3F4F6),
//         ),
//         titleMedium: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: const Color(0xFFD1D5DB),
//         ),
//         bodyLarge: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFFD1D5DB),
//         ),
//         bodyMedium: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF9CA3AF),
//         ),
//         bodySmall: GoogleFonts.poppins(
//           fontSize: 12,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF6B7280),
//         ),
//         labelLarge: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFFD1D5DB),
//         ),
//       ),

//       // Divider Theme
//       dividerTheme: DividerThemeData(
//         color: Colors.grey.shade800,
//         thickness: 1,
//         space: 1,
//       ),

//       scaffoldBackgroundColor: scaffoldDark,
//     );
//   }
// }

// -----------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // OPTION 3: THE ZEN NATURE (Sage & Forest)
  // ---------------------------------------------------------------------------

  // Light Mode Colors
  static const Color primaryLight = Color(0xFF059669); // Emerald Green
  static const Color secondaryLight = Color(0xFF3F6212); // Olive Green
  static const Color tertiaryLight = Color(0xFF84CC16); // Lime Accent
  static const Color surfaceLight = Color(0xFFF1FDF5); // Mint White
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure White
  static const Color errorLight = Color(0xFFEF4444);

  // Dark Mode Colors
  static const Color primaryDark = Color(0xFF34D399); // Soft Emerald
  static const Color secondaryDark = Color(0xFF86EFAC); // Pale Green
  static const Color tertiaryDark = Color(0xFFBEF264); // Soft Lime
  static const Color surfaceDark = Color(
    0xFF064E3B,
  ); // Deep Forest Green (Card)
  static const Color scaffoldDark = Color(0xFF022C22); // Very Dark Green (Bg)
  static const Color errorDark = Color(0xFFF87171);

  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight, // White Background

      colorScheme: ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        tertiary: tertiaryLight,
        surface: surfaceLight,
        error: errorLight,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1F2937),
      ),

      // FIX: Light Mode App Bar -> Green Background, White Text
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryLight, // Green Background
        foregroundColor: Colors.white, // White Text/Icons
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.light, // White icons for Green header
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24, // Slightly larger for modern look
          fontWeight: FontWeight.w700,
          color: primaryLight, // Green Title
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: primaryLight.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.shade100, width: 1),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.green.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.green.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryLight,
        unselectedItemColor:
            Colors.grey.shade700, // High contrast for visibility
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldDark, // Dark Green Background

      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        tertiary: tertiaryDark,
        surface: scaffoldDark,
        onSurface: const Color(0xFFECFDF5),
      ),

      // FIX: Dark Mode App Bar -> Dark Background, White Text
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: scaffoldDark, // Match the page background (Dark Green)
        foregroundColor: Colors.white, // Text is White
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.light, // Light icons for Dark header
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        color: surfaceDark, // Deep Forest Green cards
        surfaceTintColor: Colors.transparent,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: primaryDark,
          foregroundColor: const Color(0xFF022C22),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: const Color(0xFF022C22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryDark,
        unselectedItemColor: Colors.white.withOpacity(
          0.7,
        ), // Better visibility in dark mode
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }
}
