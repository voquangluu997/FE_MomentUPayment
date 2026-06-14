import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';

class AppToast {
  /// 🥳 [MATCHA LATTE] Toast Thành công - Dải phẳng tràn viền năng động
  static void showSuccess(
    BuildContext context,
    String message,
    AppColorTheme appColors,
  ) {
    _show(
      context: context,
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFFE8F6EF), Color(0xFFC9EEDC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: const Color(0xFF2B8255),
      icon: CupertinoIcons.check_mark_circled_solid,
      badgeEmoji: "✨",
    );
  }

  /// 🍓 [STRAWBERRY MOCHI] Toast Thất bại / Lỗi - Dải phẳng tràn viền ngọt ngào
  static void showError(
    BuildContext context,
    String message,
    AppColorTheme appColors, {
    bool isCritical = false,
  }) {
    _show(
      context: context,
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF0F2), Color(0xFFFFD1D7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: const Color(0xFFE54B64),
      icon: CupertinoIcons.heart_slash_fill,
      badgeEmoji: "🎀",
    );
  }

  /// 🍇 [LILAC CLOUD] Toast Thông tin / Cảnh báo - Dải phẳng tràn viền mơ mộng
  static void showInfo(
    BuildContext context,
    String message,
    AppColorTheme appColors,
  ) {
    _show(
      context: context,
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFDF5F1FF), Color(0xFFE4D4FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: const Color(0xFF7042C9),
      icon: CupertinoIcons.sparkles,
      badgeEmoji: "🔮",
    );
  }

  /// 🎨 Cấu trúc lõi "Full-Width Premium Banner Toast" - Trải dài 100% chiều rộng≈
  static void _show({
    required BuildContext context,
    required String message,
    required LinearGradient gradient,
    required Color accentColor,
    required IconData icon,
    required String badgeEmoji,
  }) {
    // Xóa ngay lập tức các toast cũ đang xếp hàng
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2800),
        // ✨ THAY ĐỔI: Không dùng margin trái/phải nữa để Toast ép sát 100% chiều rộng màn hình
        margin: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(
            context,
          ).bottom, // Ôm sát phần dưới cùng màn hình (hoặc thanh điều hướng)
          left: 0,
          right: 0,
        ),
        padding: EdgeInsets
            .zero, // Xóa bỏ padding mặc định của SnackBar để Container chiếm trọn không gian
        content: Container(
          width: double.infinity, // Ép rộng tối đa 100%
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: gradient,
            // ✨ THAY ĐỔI: Xóa bo góc tròn (để thành hình chữ nhật phẳng tuyệt đối vuông vức với viền máy)
            borderRadius: BorderRadius.zero,
            border: Border(
              top: BorderSide(
                color: accentColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              bottom: BorderSide(
                color: accentColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, -4), // Đổ bóng nhẹ ngược lên trên
              ),
            ],
          ),
          child: Stack(
            children: [
              // Thanh Accent Bar trang trí tinh tế sát rìa trái
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width:
                      8, // Tăng nhẹ độ dày thanh để dải phẳng trông vững chãi hơn
                  color: accentColor,
                ),
              ),

              // Nội dung chính bên trong dải phẳng
              Padding(
                // ✨ CẢI TIẾN: Thêm padding ngang lớn hơn (24px) để nội dung không bị dính sát viền màn hình
                padding: const EdgeInsets.fromLTRB(28, 16, 24, 16),
                child: Row(
                  children: [
                    // Khối Icon bọc tròn "Chubby style"
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 14),

                    // Thông điệp chữ đậm đà cá tính
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF2D3142),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Emoji nhỏ xinh tinh nghịch ở góc phải
                    Text(badgeEmoji, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
