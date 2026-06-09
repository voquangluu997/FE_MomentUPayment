import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';

class AppColors {
  // --- ☀️ LIGHT MODE (Pop-Art & Crisp Modern Vibe) ---
  static const Color background = Color(
    0xFFF4F6F8,
  ); // Xám khói cực nhạt, làm nổi bật lớp kính mờ
  static const Color primary = Color(
    0xFFFF3366,
  ); // Hồng Coral / Đỏ Neon cực cháy, trẻ trung
  static const Color primaryDark = Color(
    0xFF14171F,
  ); // Đen nhám sâu thẳm dành cho tiêu đề bùng nổ
  static const Color cardBackground =
      Colors.white; // Trắng tinh khiết làm nền phôi thẻ cao cấp
  static const Color text = Color(
    0xFF2D3142,
  ); // Chữ chính: Xanh Navy ngả đen sắc nét, hiện đại
  static const Color textMuted = Color(
    0xFF8A94A6,
  ); // Chữ phụ: Xám bạc dịu mắt, phân cấp thông tin tốt

  // Hệ màu trạng thái tài chính hệ Light (Vivid & Punchy)
  static const Color success = Color(
    0xFF1DD1A1,
  ); // Xanh Mint rực rỡ (Trạng thái God Mode)
  static const Color warning = Color(
    0xFFF59E0B,
  ); // Vàng hổ phách (Trạng thái Danger)
  static const Color error = Color(
    0xFFFF4757,
  ); // Đỏ Watermelon (Trạng thái Apocalypse)
  static const Color errorAccent = Color(
    0xFFFF6B81,
  ); // Hồng đỏ rực dành cho các lỗi cần highlight
  static const Color slate = Color(
    0xFF64748B,
  ); // Xám đá Slate (Trạng thái Wasted / Hết tiền)

  // --- 🌙 DARK MODE (Cyberpunk, Night Life & Neon Vibe) ---
  static const Color darkBackground = Color(
    0xFF090A0F,
  ); // Đen thẳm tuyệt đối (Deep OLED Black) tạo độ sâu 3D
  static const Color darkPrimary = Color(
    0xFF00E0FF,
  ); // Cyan Neon phát sáng trong đêm, đậm chất công nghệ
  static const Color darkPrimaryDark = Color(
    0xFFF1F2F6,
  ); // Trắng sáng phản quang trên nền tối cho tiêu đề lớn
  static const Color darkCardBackground = Color(
    0xFF181A20,
  ); // Xám than chì cao cấp tạo khối mờ đổ bóng
  static const Color darkText = Color(
    0xFFFFFFFF,
  ); // Trắng tinh khôi tương phản tuyệt đối
  static const Color darkTextMuted = Color(
    0xFFA4B0BE,
  ); // Xám sáng tinh tế, đọc đêm không mỏi mắt

  // Hệ màu trạng thái tài chính hệ Dark (Phản quang Neon dịu hơn)
  static const Color darkSuccess = Color(
    0xFF34D399,
  ); // Xanh ngọc lục bảo phát sáng nhẹ
  static const Color darkWarning = Color(
    0xFFFBBF24,
  ); // Vàng chanh Neon cảnh báo
  static const Color darkError = Color(0xFFF87171); // Đỏ Cyber táo bạo báo động
  static const Color darkSlate = Color(
    0xFF94A3B8,
  ); // Xám Slate mờ (Xịt keo tối giản)

  // --- 🌈 BẢNG MÀU POP-ART CHO BIỂU ĐỒ CHI TIÊU (CHART PALETTE) ---
  static const List<Color> chartPalette = [
    Color(0xFFFF3366), // Đỏ Neon
    Color(0xFF00D2D3), // Xanh Aqua/Cyan
    Color(0xFF54A0FF), // Xanh Sky Blue
    Color(0xFF1DD1A1), // Xanh Mint
    Color(0xFFFECA57), // Vàng chanh rực rỡ
    Color(0xFF5F27CD), // Tím Electric
    Color(0xFFFF9F43), // Cam sặc sỡ
    Color(0xFFF368E0), // Hồng Magenta
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

  // Hỗ trợ đồng bộ cả 2 cách gọi token chữ (text / textPrimary) để tránh lỗi build
  final Color text;
  final Color textPrimary;
  final Color textMuted;
  final Color textSecondary;

  // Hệ màu semantic trạng thái chuẩn UX ngân sách
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

    // Ánh xạ linh hoạt hệ chữ
    text: isDark ? AppColors.darkText : AppColors.text,
    textPrimary: isDark ? AppColors.darkText : AppColors.text,
    textMuted: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
    textSecondary: isDark ? AppColors.darkTextMuted : AppColors.textMuted,

    // Ánh xạ trạng thái tài chính theo tầng nhận diện
    success: isDark ? AppColors.darkSuccess : AppColors.success,
    warning: isDark ? AppColors.darkWarning : AppColors.warning,
    error: isDark ? AppColors.darkError : AppColors.error,
    errorAccent:
        AppColors.errorAccent, // Giữ nguyên accent tươi sáng cho nút highlight
    slate: isDark ? AppColors.darkSlate : AppColors.slate,
  );
});
