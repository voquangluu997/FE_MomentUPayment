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
        // 1. HEADER CỰC ĐẠI (Ví dụ: Số dư tài khoản lớn, số tiền hiển thị bùng nổ)
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 32,
          fontWeight: FontWeight.w900, // Siêu đậm (Black) tăng độ chất
          letterSpacing: -1.2, // Khít chữ lại theo đúng Apple style
        ),

        // 2. HEADER VỪA (Tiêu đề các mục lớn trên màn hình HomeScreen)
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 24,
          fontWeight: FontWeight.w800, // Rất đậm (Extra Bold)
          letterSpacing: -0.8,
        ),

        // 3. TITLE LỚN (Tiêu đề AppBar, Tiêu đề Card chính)
        titleLarge: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700, // Đậm (Bold) công nghệ
          letterSpacing: -0.5,
        ),

        // 4. TITLE VỪA (Tên các tính năng, tên Card phụ, danh mục chi tiêu)
        titleMedium: GoogleFonts.plusJakartaSans(
          color: appColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w600, // Đậm vừa (Semi Bold) sắc nét
        ),

        // 5. TEXT CHÍNH (Nội dung đọc chính, thông tin chi tiết, text nhập vào)
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: appColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w500, // Mức Medium giúp text không bị thô cứng
        ),

        // 6. TEXT PHỤ / MUTED (Mô tả nhỏ, ngày tháng, sub-title nhạt)
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: appColors.textMuted, // Áp dụng chuẩn màu textMuted dịu mắt
          fontSize: 13,
          fontWeight: FontWeight.w400, // Độ dày bình thường (Regular) dễ nhìn
        ),
      ),

      // 🍏 ĐỒNG BỘ LUÔN CHO TEXT TRÊN APP BAR (THANH TIÊU ĐỀ TRÊN CÙNG)
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: appColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      // Các cấu hình decoration khác giữ nguyên và map theo bộ màu mới
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
