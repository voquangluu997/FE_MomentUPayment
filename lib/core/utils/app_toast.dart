import 'package:flutter/material.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';

class AppToast {
  /// ✨ Toast thành công - Vibe Xanh Sage bình yên, ngọt ngào
  static void showSuccess(
    BuildContext context,
    String message,
    AppColorTheme appColors,
  ) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFE8F5E9), // Xanh Sage pastel sáng
      borderColor: const Color(0xFFC8E6C9),
      icon: Icons.star_rounded,
      iconColor: const Color(0xFF2E7D32),
      iconBgColor: Colors.white,
    );
  }

  /// 🍓 Toast thất bại / lỗi - Vibe Hồng Dâu nhẹ nhàng
  static void showError(
    BuildContext context,
    String message,
    AppColorTheme appColors, {
    bool isCritical = false,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFFFEBEE), // Hồng phấn nhẹ
      borderColor: const Color(0xFFFFCDD2),
      icon: Icons.heart_broken_rounded,
      iconColor: const Color(0xFFD32F2F),
      iconBgColor: Colors.white,
    );
  }

  /// 💜 Toast Thông tin - Vibe Lavender mơ mộng (Mới)
  static void showInfo(
    BuildContext context,
    String message,
    AppColorTheme appColors,
  ) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFF3E5F5), // Lavender pastel
      borderColor: const Color(0xFFE1BEE7),
      icon: Icons.auto_awesome_rounded, // Icon "tỏa sáng" xịn sò
      iconColor: const Color(0xFF7B1FA2),
      iconBgColor: Colors.white,
    );
  }

  /// 🎨 Hàm cốt lõi tạo "Cute Floating Card Toast"
  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(
              0.95,
            ), // Thêm chút độ trong suốt kiểu Glassmorphism
            borderRadius: BorderRadius.circular(
              24,
            ), // Bo góc tròn trịa hơn, cute hơn
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(
                      0xFF4A4A4A,
                    ), // Màu chữ nâu xám sang trọng, dịu mắt
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
