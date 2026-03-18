import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4E4BC);
  
  // ألوان إضافية
  static const Color cyanAccent = Color(0xFF00BCD4);
  static const Color purpleAccent = Color(0xFFE040FB);
  
  // ألوان الحالة
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  
  // ألوان الخلفية والبطاقات
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFAFAFA);

  // ألوان إضافية مطلوبة في الشاشات
  static const Color darkSlate = Color(0xFF2C3E50);   // رمادي غامق مزرق
  static const Color deepNavy = Color(0xFF0A1929);    // أزرق داكن جداً

  // مرادف لـ darkCard
  static const Color cardDark = darkCard;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: goldColor,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCard,
      cardTheme: const CardThemeData(
        color: lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      fontFamily: 'Cairo',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: cyanAccent,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      cardTheme: const CardThemeData(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      fontFamily: 'Cairo',
    );
  }
}
