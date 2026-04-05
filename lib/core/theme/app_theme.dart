import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color primaryGold = Color(0xFFFFD700);
  
  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color secondaryRed = Color(0xFFF44336);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  // Card Colors
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color cardLight = Color(0xFFFAFAFA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryGold, Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryCyan,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      colorScheme: const ColorScheme.light(
        primary: primaryCyan,
        secondary: primaryPurple,
        surface: surfaceLight,
        error: error,
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(fontSize: 16),
        bodyMedium: const TextStyle(fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryCyan,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: primaryPurple,
        surface: surfaceDark,
        error: error,
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        headlineLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: const TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: const TextStyle(fontSize: 14, color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
