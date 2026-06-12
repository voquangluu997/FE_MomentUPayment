import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import file AppColors của bạn vào đây
import 'package:moment_u_payment/core/constants/app_colors.dart';

class AppTheme {
  // Chuyển thành hàm nhận vào bộ màu động (appColors) và trạng thái Dark Mode
  static ThemeData buildTheme(AppColorTheme appColors, bool isDarkMode) {
    // Tạo base text theme tùy thuộc theo chế độ sáng/tối để Flutter tự tối ưu
    final baseTextTheme = isDarkMode
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: appColors.background,

      // 🎨 HỆ MÀU CHỦ ĐẠO CHO COMPONENT
      colorScheme: ColorScheme.fromSeed(
        seedColor: appColors.primary,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: appColors.primary,
        background: appColors.background,
        surface: appColors.cardBackground,
      ),

      // 🔤 CẬP NHẬT TOÀN BỘ ĐỘ ĐẬM NHẠT, TONE MÀU CỦA TEXT TẠI ĐÂY
      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
        // 1. HEADER CỰC ĐẠI
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5, // Nới lỏng từ -1.2 lên -0.5
        ),

        // 2. HEADER VỪA
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2, // Nới lỏng từ -0.8 lên -0.2
        ),

        // 3. TITLE LỚN
        titleLarge: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.0, // Đưa về 0 để chữ tiêu chuẩn, không dính
        ),

        // 4. TITLE VỪA
        titleMedium: GoogleFonts.plusJakartaSans(
          color: appColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1, // Thêm chút khoảng cách để nét chữ gai góc hơn
        ),

        // 5. TEXT CHÍNH
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: appColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2, // Tăng nhẹ để đoạn văn bản dài dễ đọc hơn
        ),

        // 6. TEXT PHỤ / MUTED
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: appColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2, // Tăng nhẹ để text nhỏ không bị nhòe vào nhau
        ),
      ),

      // 🍏 ĐỒNG BỘ LUÔN CHO TEXT TRÊN APP BAR
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.0, // Đưa về 0 để không bị dính
        ),
      ),

      // Các cấu hình decoration khác giữ nguyên
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.cardBackground,
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
          backgroundColor: appColors.primary,
          foregroundColor: Colors.white,
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
