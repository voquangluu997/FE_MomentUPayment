import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

// Đã loại bỏ các badge nhàm chán, thêm các badge đánh mạnh vào thói quen/tính cách
enum BadgeType {
  ghost, // Chúa Tể Lười Biếng (0 ghi chép)
  shopaholic, // Cơn Lốc Chốt Đơn (> 40 giao dịch)
  whale, // Đại Gia Bạo Chi (> 10tr)
  survivalist, // Chiến Thần Sinh Tồn (< 2tr - Thay cho Thrifty)
  nightOwl, // Cú Đêm Cháy Ví (Giao dịch 0h - 4h)
  paydayFlash, // Máy Xúc Ngày Lương (Tiêu cực mạnh vào ngày 1-5 đầu tháng)
  foodDestroyer, // Thực Thần Càn Quét (Đa số chi cho category Ăn uống)
  weekendStorm, // Bão Táp Cuối Tuần (Chỉ tiêu nhiều vào T7, CN)
  goldfish, // Não Cá Vàng (Chuyên gia tạo giao dịch backdate/ghi bù)
  brokeAF, // Đỗ Nghèo Khỉ (Nhiều giao dịch dưới 10k)
  bigTicket, // Quẹt Thẻ Khét Lẹt (1 giao dịch > 5tr)
  firstBlood, // Khởi Đầu Mới (Giao dịch đầu tiên)
  centurion, // Trăm Trận Trăm Thắng (Đạt 100 giao dịch)
  balanced, // Bậc Thầy Cân Bằng (Chi tiêu hợp lý)
}

class UserBadge {
  final BadgeType type;
  final Color color;
  final List<Color> gradientColors; // 🚀 Dải màu Gradient lấp lánh
  final IconData icon;
  final bool isMonthly;
  final bool isRare; // 🚀 Đánh dấu huy hiệu hiếm để phát sáng

  UserBadge({
    required this.type,
    required this.color,
    required this.gradientColors,
    required this.icon,
    this.isMonthly = true,
    this.isRare = false,
  });

  // Map thẳng từ Enum ra chuỗi đa ngôn ngữ.
  String getLocalizedTitle(AppLocalizations l10n) {
    switch (type) {
      case BadgeType.ghost:
        return l10n.badgeGhostTitle;
      case BadgeType.shopaholic:
        return l10n.badgeShopaholicTitle;
      case BadgeType.whale:
        return l10n.badgeWhaleTitle;
      case BadgeType.survivalist:
        return l10n.badgeSurvivalistTitle;
      case BadgeType.nightOwl:
        return l10n.badgeNightOwlTitle;
      case BadgeType.paydayFlash:
        return l10n.badgePaydayFlashTitle;
      case BadgeType.foodDestroyer:
        return l10n.badgeFoodDestroyerTitle;
      case BadgeType.weekendStorm:
        return l10n.badgeWeekendStormTitle;
      case BadgeType.goldfish:
        return l10n.badgeGoldfishTitle;
      case BadgeType.brokeAF:
        return l10n.badgeBrokeAFTitle;
      case BadgeType.bigTicket:
        return l10n.badgeBigTicketTitle;
      case BadgeType.firstBlood:
        return l10n.badgeFirstBloodTitle;
      case BadgeType.centurion:
        return l10n.badgeCenturionTitle;
      case BadgeType.balanced:
        return l10n.badgeBalancedTitle;
    }
  }

  String getLocalizedDesc(AppLocalizations l10n) {
    switch (type) {
      case BadgeType.ghost:
        return l10n.badgeGhostDesc;
      case BadgeType.shopaholic:
        return l10n.badgeShopaholicDesc;
      case BadgeType.whale:
        return l10n.badgeWhaleDesc;
      case BadgeType.survivalist:
        return l10n.badgeSurvivalistDesc;
      case BadgeType.nightOwl:
        return l10n.badgeNightOwlDesc;
      case BadgeType.paydayFlash:
        return l10n.badgePaydayFlashDesc;
      case BadgeType.foodDestroyer:
        return l10n.badgeFoodDestroyerDesc;
      case BadgeType.weekendStorm:
        return l10n.badgeWeekendStormDesc;
      case BadgeType.goldfish:
        return l10n.badgeGoldfishDesc;
      case BadgeType.brokeAF:
        return l10n.badgeBrokeAFDesc;
      case BadgeType.bigTicket:
        return l10n.badgeBigTicketDesc;
      case BadgeType.firstBlood:
        return l10n.badgeFirstBloodDesc;
      case BadgeType.centurion:
        return l10n.badgeCenturionDesc;
      case BadgeType.balanced:
        return l10n.badgeBalancedDesc;
    }
  }
}

// ============================================================================
// BỘ SƯU TẬP HUY HIỆU ĐƯỢC TẠO SẴN VỚI MÀU SẮC & ICON CHUẨN UX
// ============================================================================
class BadgeRegistry {
  static final Map<BadgeType, UserBadge> badges = {
    BadgeType.ghost: UserBadge(
      type: BadgeType.ghost,
      color: Colors.grey.shade600,
      gradientColors: [Colors.grey.shade400, Colors.grey.shade700],
      icon: CupertinoIcons.wind, // Icon gió thổi hiu quạnh
    ),
    BadgeType.shopaholic: UserBadge(
      type: BadgeType.shopaholic,
      color: const Color(0xFFFF3366),
      gradientColors: [const Color(0xFFFF758C), const Color(0xFFFF7EB3)],
      icon: CupertinoIcons.bag_fill,
      isRare: true,
    ),
    BadgeType.whale: UserBadge(
      type: BadgeType.whale,
      color: const Color(0xFFE5B80B),
      gradientColors: [const Color(0xFFFFD700), const Color(0xFFD4AF37)],
      icon: CupertinoIcons.star_circle_fill, // Đại gia dùng màu Vàng kim loại
      isRare: true,
    ),
    BadgeType.survivalist: UserBadge(
      type: BadgeType.survivalist,
      color: const Color(0xFF2E8B57),
      gradientColors: [const Color(0xFF3CB371), const Color(0xFF2E8B57)],
      icon: CupertinoIcons
          .leaf_arrow_circlepath, // Môi trường, tiết kiệm, sinh tồn
    ),
    BadgeType.nightOwl: UserBadge(
      type: BadgeType.nightOwl,
      color: const Color(0xFF673AB7),
      gradientColors: [const Color(0xFF8A2BE2), const Color(0xFF4B0082)],
      icon: CupertinoIcons.moon_stars_fill,
    ),
    BadgeType.paydayFlash: UserBadge(
      type: BadgeType.paydayFlash,
      color: const Color(0xFFFF5722),
      gradientColors: [const Color(0xFFFF9800), const Color(0xFFF44336)],
      icon: CupertinoIcons.bolt_fill, // Sét đánh bay tiền
    ),
    BadgeType.foodDestroyer: UserBadge(
      type: BadgeType.foodDestroyer,
      color: const Color(0xFFFF9800),
      gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
      icon: Icons.fastfood_rounded, // Hoặc dùng icon cái chảo/nĩa tùy bạn
    ),
    BadgeType.weekendStorm: UserBadge(
      type: BadgeType.weekendStorm,
      color: const Color(0xFF00BCD4),
      gradientColors: [const Color(0xFF4DD0E1), const Color(0xFF0097A7)],
      icon: CupertinoIcons.speaker_3_fill, // Cầm loa quẩy cuối tuần
    ),
    BadgeType.goldfish: UserBadge(
      type: BadgeType.goldfish,
      color: const Color(0xFF9E9E9E),
      gradientColors: [const Color(0xFFBDBDBD), const Color(0xFF757575)],
      icon: CupertinoIcons.arrow_counterclockwise_circle_fill, // Icon back/quên
    ),
    BadgeType.brokeAF: UserBadge(
      type: BadgeType.brokeAF,
      color: const Color(0xFF795548), // Màu đất sét/nghèo khổ xíu
      gradientColors: [const Color(0xFFA1887F), const Color(0xFF5D4037)],
      icon: CupertinoIcons.money_dollar,
    ),
    BadgeType.bigTicket: UserBadge(
      type: BadgeType.bigTicket,
      color: const Color(0xFFE91E63),
      gradientColors: [const Color(0xFFF06292), const Color(0xFFC2185B)],
      icon: CupertinoIcons.flame_fill, // Cháy khét lẹt
      isRare: true,
    ),
    BadgeType.firstBlood: UserBadge(
      type: BadgeType.firstBlood,
      color: Colors.redAccent,
      gradientColors: [Colors.redAccent, Colors.deepOrange],
      icon: CupertinoIcons.drop_fill,
      isMonthly: false, // Thành tựu vĩnh viễn
    ),
    BadgeType.centurion: UserBadge(
      type: BadgeType.centurion,
      color: Colors.amber,
      gradientColors: [Colors.yellow.shade400, Colors.orange.shade700],
      icon: CupertinoIcons.rosette,
      isRare: true,
      isMonthly: false, // Thành tựu vĩnh viễn
    ),
    BadgeType.balanced: UserBadge(
      type: BadgeType.balanced,
      color: Colors.blue,
      gradientColors: [Colors.lightBlueAccent, Colors.blue.shade800],
      icon: CupertinoIcons.slider_horizontal_3,
      isMonthly: true,
    ),
  };
}
