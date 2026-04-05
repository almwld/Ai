import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color cyanAccent = Color(0xFF00BCD4);
  static const Color purpleAccent = Color(0xFF9C27B0);
  static const Color goldColor = Color(0xFFFFD700);
  
  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);
  
  // Background Colors
  static const Color deepNavy = Color(0xFF0A1929);
  static const Color darkSlate = Color(0xFF2C3E50);
  static const Color darkCard = Color(0xFF1E1E1E);
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: cyanAccent,
      scaffoldBackgroundColor: deepNavy,
      cardColor: darkCard,
      colorScheme: const ColorScheme.dark(
        primary: cyanAccent,
        secondary: purpleAccent,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
