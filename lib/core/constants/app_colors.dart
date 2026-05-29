import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';

class AppColors {
  // ✨ Hệ màu nền chính (Theme Colors) - LIGHT MODE
  static const Color background = Color(0xFFFAF8F5); // Kem sữa Pastel ngọt ngào
  static const Color primary = Color(
    0xFFD4A373,
  ); // Nâu trà sữa (Milk Tea Brown)
  static const Color primaryDark = Color(0xFF8B5A2B); // Nâu đậm tiêu đề
  static const Color cardBackground =
      Colors.white; // Nền ô nhập liệu / Khung chứa trắng sạch

  // 📝 Màu chữ bổ sung cho Light Mode (Giúp hiển thị rõ ràng trên ô nhập màu trắng)
  static const Color text = Color(
    0xFF2B221E,
  ); // Chữ chính nâu đen đậm (Hợp tone trà sữa, không bị thô như đen tuyền)
  static const Color textMuted = Color(
    0xFF8C7E74,
  ); // Chữ phụ / Hint text màu xám nâu dịu mắt

  // 🍓 Hệ màu trạng thái Pastel
  static const Color success = Color(
    0xFFCCD5AE,
  ); // Xanh Sage tươi mát (Thành công)
  static const Color error = Color(
    0xFFFFCAD4,
  ); // Hồng dâu dịu nhẹ (Thất bại / Lỗi)
  static const Color errorAccent = Color(
    0xFFFF9B9B,
  ); // Hồng đỏ đậm cho các lỗi nổi bật

  // 🌈 Bảng màu rực rỡ cho biểu đồ chi tiêu
  static const List<Color> chartPalette = [
    Color(0xFFFF6B6B), // Đỏ pastel
    Color(0xFF4DABF7), // Xanh biển
    Color(0xFF51CF66), // Xanh lá
    Color(0xFFFCC419), // Vàng hoàng gia
    Color(0xFFFF922B), // Cam
    Color(0xFF845EF7), // Tím
    Color(0xFFE64980), // Hồng cánh sen
    Color(0xFF22B8CF), // Xanh ngọc
  ];

  static Color getCategoryColor(int index) {
    return chartPalette[index % chartPalette.length];
  }

  // --- MÀU DARK MODE (CUTE VIBE) ---
  static const darkPrimary = Color(0xFFFF6090); // Hồng sáng neon
  static const darkPrimaryDark = Color(0xFFFCE4EC); // Chữ màu hồng phấn nhạt
  static const darkBackground = Color(0xFF160D10); // Nền hồng đen đêm
  static const darkCardBackground = Color(0xFF25161A); // Nền Card tím mận

  // 📝 Màu chữ bổ sung cho Dark Mode (Sửa triệt để lỗi chữ bị đen khi gõ)
  static const darkText = Color(
    0xFFFFFFFF,
  ); // Chữ chính màu trắng tinh tương phản cao
  static const darkTextMuted = Color(
    0xFF9E8E93,
  ); // Chữ phụ / Hint text màu xám hồng nhạt dịu
}

// Lớp chứa bộ màu sẽ được dùng trực tiếp ở UI
class AppColorTheme {
  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color cardBackground;
  final Color text; // ✨ Thêm trường màu chữ chính
  final Color textMuted; // ✨ Thêm trường màu chữ phụ / hint
  final Color success;
  final Color error;
  final Color errorAccent;

  AppColorTheme({
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.cardBackground,
    required this.text, // ✨ Yêu cầu trong constructor
    required this.textMuted, // ✨ Yêu cầu trong constructor
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
    text: isDark
        ? AppColors.darkText
        : AppColors.text, // ✨ Tự động map màu chữ theo Theme
    textMuted: isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted, // ✨ Tự động map màu hint theo Theme
    success: AppColors.success,
    error: AppColors.error,
    errorAccent: AppColors.errorAccent,
  );
});
