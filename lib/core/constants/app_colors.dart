import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';

class AppColors {
  // --- ☀️ LIGHT MODE (Cyber Tangerine & Dynamic Energy Vibe) ---
  static const Color background = Color(
    0xFFF8F9FA,
  ); // Trắng ngọc trai siêu sạch, tôn lớp kính mờ đổ bóng
  static const Color primary = Color(
    0xFFFF5A00,
  ); // Cyber Tangerine (Cam Neon Điện Tử) - Cực cháy, ấn tượng mạnh ban ngày
  static const Color primaryDark = Color(
    0xFF0A0E1A,
  ); // Đen cực sâu (Deep Space) cho tiêu đề bùng nổ
  static const Color cardBackground =
      Colors.white; // Trắng tinh khiết làm phôi thẻ cứng cao cấp
  static const Color text = Color(
    0xFF1E2229,
  ); // Chữ chính: Xám đen carbon sắc nét
  static const Color textMuted = Color(
    0xFF6C7A89,
  ); // Chữ phụ: Xám kim loại dịu mắt

  // Hệ màu trạng thái tài chính hệ Light (Punchy Neo-Semantic)
  static const Color success = Color(
    0xFF00D68F,
  ); // Xanh lục bảo Aurora phát sáng (God Mode)
  static const Color warning = Color(
    0xFFFFB300,
  ); // Vàng hổ phách Cyber (Danger)
  static const Color error = Color(
    0xFFFF3838,
  ); // Đỏ Laser nguyên bản (Apocalypse)
  static const Color errorAccent = Color(
    0xFFFF5252,
  ); // Đỏ Neon highlight vùng lỗi
  static const Color slate = Color(0xFF788896); // Xám Titan (Wasted)

  // --- 🌙 DARK MODE (Electric Periwinkle & Luxury Tech Vibe) ---
  static const Color darkBackground = Color(
    0xFF090611,
  ); // Đen Tím Velvet tuyệt đối (Deep Obsidian Plum) - Giữ nguyên nền sâu thẳm cực sang
  static const Color darkPrimary = Color(
    0xFF849FFF,
  ); // Electric Periwinkle (Xanh Lam Ánh Tím) - Dịu mắt, thanh lịch, tạo cảm giác công nghệ cao và hài hòa tuyệt đối với nền tím
  static const Color darkPrimaryDark = Color(
    0xFFE2E7FF,
  ); // Trắng khói ánh xanh phản quang nhẹ cho tiêu đề lớn
  static const Color darkCardBackground = Color(
    0xFF151122,
  ); // Xám Tím Midnight đúc khối, giảm độ tương phản gắt, êm dịu cho mắt
  static const Color darkText = Color(
    0xFFFFFFFF,
  ); // Trắng tinh khôi tương phản rõ nét
  static const Color darkTextMuted = Color(
    0xFF8F9BB3,
  ); // Xám xanh sương mù (Slate Blue Muted), đọc ban đêm cực kỳ dễ chịu, không mỏi mắt

  // Hệ màu trạng thái tài chính hệ Dark (Đã tinh chỉnh để hòa hợp với tông Lam Tím)
  static const Color darkSuccess = Color(
    0xFF2ECC71,
  ); // Xanh Emerald dịu (Mềm mại hơn màu Electric Mint cũ)
  static const Color darkWarning = Color(0xFFF1C40F); // Vàng hướng dương ấm áp
  static const Color darkError = Color(
    0xFFE74C3C,
  ); // Đỏ Alizarin mềm (Không bị chói gắt trong tối)
  static const Color darkSlate = Color(0xFF524B61); // Xám mờ ánh tím tối giản

  // --- 🌈 BẢNG MÀU CHUYÊN NGHIỆP CHO BIỂU ĐỒ (HARMONIOUS PALETTE) ---
  // Thay thế màu hồng chói bằng các tông màu chuyển tiếp mượt mà giữa Cam và Lam Tím
  static const List<Color> chartPalette = [
    Color(0xFF849FFF), // Xanh Lam Ánh Tím (Dark Primary)
    Color(0xFFFF5A00), // Cam Cyber Tangerine (Light Primary)
    Color(0xFF2ECC71), // Xanh Ngọc dịu
    Color(0xFF00D8F6), // Xanh Băng (Ice Blue)
    Color(0xFF9B5DE5), // Tím Thạch Anh (Amethyst)
    Color(0xFFF1C40F), // Vàng Ấm
    Color(0xFFFF6B6B), // Đỏ San Hô mềm
    Color(0xFF34495E), // Xám Xanh Kim Loại
  ];

  static Color getCategoryColor(int index) {
    return chartPalette[index % chartPalette.length];
  }
}

// --- ⚙️ LỚP CHỨA BỘ MÀU ĐƯỢC PHÂN PHÁT CHO TOÀN APP ---
class AppColorTheme {
  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color cardBackground;
  final Color surface; // 👈 ĐÃ THÊM THUỘC TÍNH NÀY

  final Color text;
  final Color textPrimary;
  final Color textMuted;
  final Color textSecondary;

  final Color success;
  final Color warning;
  final Color error;
  final Color errorAccent;
  final Color slate;

  AppColorTheme({
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.cardBackground,
    required this.surface, // 👈 ĐÃ THÊM YÊU CẦU NÀY
    required this.text,
    required this.textPrimary,
    required this.textMuted,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.errorAccent,
    required this.slate,
  });
}

// --- ⚡ PROVIDER TỰ ĐỘNG ĐỔI MÀU THÔNG MINH THEO THEME MODE ---
final appColorsProvider = Provider<AppColorTheme>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final isDark = themeMode == ThemeMode.dark;

  return AppColorTheme(
    primary: isDark ? AppColors.darkPrimary : AppColors.primary,
    primaryDark: isDark ? AppColors.darkPrimaryDark : AppColors.primaryDark,
    background: isDark ? AppColors.darkBackground : AppColors.background,
    cardBackground: isDark
        ? AppColors.darkCardBackground
        : AppColors.cardBackground,

    // 👈 GÁN SURFACE BẰNG CARD BACKGROUND (Chuẩn Material Design)
    surface: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,

    text: isDark ? AppColors.darkText : AppColors.text,
    textPrimary: isDark ? AppColors.darkText : AppColors.text,
    textMuted: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
    textSecondary: isDark ? AppColors.darkTextMuted : AppColors.textMuted,

    success: isDark ? AppColors.darkSuccess : AppColors.success,
    warning: isDark ? AppColors.darkWarning : AppColors.warning,
    error: isDark ? AppColors.darkError : AppColors.error,
    errorAccent: AppColors.errorAccent,
    slate: isDark ? AppColors.darkSlate : AppColors.slate,
  );
});
