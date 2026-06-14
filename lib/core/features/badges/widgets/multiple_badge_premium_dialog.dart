import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';
// 🚀 THÊM IMPORT ĐỂ ĐI ĐẾN TRANG GALLERY
import 'package:moment_u_payment/core/features/badges/screens/badge_gallery_page.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class BadgeItem extends StatelessWidget {
  final UserBadge badge;
  final dynamic appColors;

  const BadgeItem({super.key, required this.badge, required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: badge.gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: badge.color.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white54, width: 1.5),
          ),
          child: Center(child: Icon(badge.icon, size: 36, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: badge.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: badge.color.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            badge.getLocalizedTitle(AppLocalizations.of(context)!),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: badge.color,
              fontSize: 11,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class MultipleBadgePremiumDialog extends StatelessWidget {
  final List<dynamic> badges;
  final String title;
  final String description;
  final dynamic appColors;
  final VoidCallback onConfirm;

  const MultipleBadgePremiumDialog({
    super.key,
    required this.badges,
    required this.title,
    required this.description,
    required this.appColors,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        // Giới hạn chiều cao tối đa của dialog để không bị tràn viền màn hình (chừa chỗ cho thanh điều hướng/status bar)
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: appColors.primary.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: appColors.primary.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: appColors.primaryDark,
                letterSpacing: -0.5,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: appColors.textMuted,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 32),

            // 🚀 ĐÃ BỌC FLEXIBLE VÀ SINGLECHILDSCROLLVIEW
            Flexible(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(), // Tạo hiệu ứng nảy mượt mà khi cuộn
                child: Wrap(
                  spacing: 16,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: badges
                      .map((b) => BadgeItem(badge: b, appColors: appColors))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // 🎨 CỤM NÚT ĐÃ ĐƯỢC THAY THẾ & ĐỒNG BỘ THEO CHUẨN L10N
            // 1. Nút chính: Khám phá bộ sưu tập
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // Găm sẵn trạng thái Navigator trước khi Context của Dialog bị đóng
                  final navigator = Navigator.of(context);

                  // Gọi hàm onConfirm gốc của bạn (Hàm này chứa lệnh pop() ẩn dialog và clear state)
                  onConfirm();

                  // Tiến hành chuyển hướng sang trang Gallery
                  navigator.push(
                    CupertinoPageRoute(
                      builder: (_) => const BadgeGalleryPage(),
                    ),
                  );
                },
                child: Text(
                  l10n.exploreCollection, // Khám phá bộ sưu tập
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Nút phụ: Để sau
            TextButton(
              onPressed:
                  onConfirm, // Chỉ thực hiện pop() và clear state nhẹ nhàng
              child: Text(
                l10n.later, // Để sau
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appColors.textMuted.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
