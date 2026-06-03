import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';

class AppColors {
  // ✨ Hệ màu nền chính (Theme Colors) - LIGHT MODE (Crisp & Vibrant)
  static const Color background = Color(
    0xFFF4F6F8,
  ); // Xám khói cực nhạt, làm nổi bật card trắng
  static const Color primary = Color(
    0xFFFF3366,
  ); // Hồng Coral / Đỏ Neon (Cực cháy, trẻ trung, hút mắt)
  static const Color primaryDark = Color(
    0xFF14171F,
  ); // Đen nhám sâu thẳm (Dành cho tiêu đề bùng nổ)
  static const Color cardBackground =
      Colors.white; // Trắng tinh khiết (Tạo cảm giác sạch sẽ, cao cấp)

  // 📝 Màu chữ bổ sung cho Light Mode
  static const Color text = Color(
    0xFF2D3142,
  ); // Xanh Navy ngả đen (Chữ sắc nét, hiện đại, không bị "quê")
  static const Color textMuted = Color(
    0xFF8A94A6,
  ); // Xám bạc (Dịu mắt, phân cấp thông tin tốt)

  // 🍓 Hệ màu trạng thái (Vivid & Punchy)
  static const Color success = Color(
    0xFF1DD1A1,
  ); // Xanh Mint rực rỡ (Cảm giác positive, năng lượng)
  static const Color error = Color(
    0xFFFF4757,
  ); // Đỏ Watermelon (Báo lỗi nổi bần bật)
  static const Color errorAccent = Color(
    0xFFFF6B81,
  ); // Hồng đỏ rực (Dành cho các lỗi cần highlight)

  // 🌈 Bảng màu rực rỡ cho biểu đồ chi tiêu (Pop-Art Vibe)
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

  // --- MÀU DARK MODE (NIGHT LIFE & NEON VIBE) ---
  static const darkPrimary = Color(
    0xFF00E0FF,
  ); // Cyan Neon (Sáng rực rỡ trong đêm, cực kỳ Cyberpunk/Tech)
  static const darkPrimaryDark = Color(
    0xFFF1F2F6,
  ); // Trắng sáng (Phản quang trên nền tối)
  static const darkBackground = Color(0xFF090A0F); // Đen thẳm (Deep OLED Black)
  static const darkCardBackground = Color(
    0xFF181A20,
  ); // Xám than chì (Tạo khối 3D nịnh mắt cho thẻ)

  // 📝 Màu chữ bổ sung cho Dark Mode
  static const darkText = Color(
    0xFFFFFFFF,
  ); // Trắng tinh khiết (Tương phản tuyệt đối)
  static const darkTextMuted = Color(
    0xFFA4B0BE,
  ); // Xám sáng (Dễ đọc trên nền đen, không mỏi mắt)
}

// Lớp chứa bộ màu sẽ được dùng trực tiếp ở UI
class AppColorTheme {
  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color cardBackground;
  final Color text;
  final Color textMuted;
  final Color success;
  final Color error;
  final Color errorAccent;

  AppColorTheme({
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.cardBackground,
    required this.text,
    required this.textMuted,
    required this.success,
    required this.error,
    required this.errorAccent,
  });
}

// Provider tự động đổi màu theo chế độ hiện tại
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
    text: isDark ? AppColors.darkText : AppColors.text,
    textMuted: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
    success: AppColors.success,
    error: AppColors.error,
    errorAccent: AppColors.errorAccent,
  );
});
