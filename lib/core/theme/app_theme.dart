import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get cuteTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(
        0xFFFFFDED,
      ), // Màu nền Kem Cream Ivory
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFCAD4), // Pastel Pink chủ đạo
        primary: const Color(0xFFD4A373), // Sắc Nâu sữa ấm áp
        secondary: const Color(0xFFFFCAD4),
      ),
      textTheme:
          GoogleFonts.quicksandTextTheme(), // Font chữ bo tròn siêu dễ thương
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCAD4),
          foregroundColor: Colors.brown[800],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
