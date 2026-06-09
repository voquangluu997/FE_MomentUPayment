import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_list_item.dart';

class HomeListGroup extends ConsumerWidget {
  final String dateKey;
  final List<Map<String, dynamic>> txList;
  final AppLocalizations l10n;
  final AppColorTheme appColors;
  final Function(Map<String, dynamic>) onTapItem;
  final Future<bool> Function(Map<String, dynamic>) onConfirmDelete;

  const HomeListGroup({
    super.key,
    required this.dateKey,
    required this.txList,
    required this.l10n,
    required this.appColors,
    required this.onTapItem,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. TÍNH TỔNG TIỀN ĐÃ CHI TRONG NGÀY ĐÓ ĐỂ HIỂN THỊ LÊN HEADER
    final double dailyTotal = txList.fold(0.0, (sum, tx) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      return sum + amount;
    });

    final currencySymbol = ref.watch(currencyProvider);
    final formattedDailyTotal = CurrencyHelper.formatCompactAmount(
      dailyTotal,
      symbol: currencySymbol,
    );

    return SliverMainAxisGroup(
      slivers: [
        // 🌟 HEADER NGÀY THÁNG - PHONG CÁCH "SOCIAL FEED PILL" KÍNH MỜ
        SliverPersistentHeader(
          pinned: true, // Dính lên top khi cuộn
          delegate: _DailyHeaderDelegate(
            dateKey: dateKey,
            formattedTotal: formattedDailyTotal,
            appColors: appColors,
            l10n: l10n,
          ),
        ),

        // 🌟 DANH SÁCH GIAO DỊCH VỚI HIỆU ỨNG BOUNCY ANIMATION
        SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, idx) {
              final tx = txList[idx];

              return AnimationConfiguration.staggeredList(
                position: idx,
                duration: const Duration(milliseconds: 650),
                child: SlideAnimation(
                  verticalOffset: 60.0,
                  curve: Curves.easeOutQuart,
                  child: FadeInAnimation(
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: MomentListItem(
                        transaction: tx,
                        l10n: l10n,
                        appColors: appColors,
                        onTap: () => onTapItem(tx),
                        onConfirmDelete: () async {
                          return await onConfirmDelete(tx);
                        },
                      ),
                    ),
                  ),
                ),
              );
            }, childCount: txList.length),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// 🛠️ CUSTOM DELEGATE CHO STICKY HEADER (TẠO HIỆU ỨNG VIÊN NANG KÍNH MỜ)
// ===========================================================================
class _DailyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String dateKey;
  final String formattedTotal;
  final AppColorTheme appColors;
  final AppLocalizations l10n;

  _DailyHeaderDelegate({
    required this.dateKey,
    required this.formattedTotal,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Khi bị cuộn đè lên, Header sẽ kích hoạt trạng thái "Pinned"
    final bool isPinned = shrinkOffset > 0 || overlapsContent;

    return ClipRRect(
      // Bọc ClipRRect để BackdropFilter không bị tràn ra ngoài
      child: BackdropFilter(
        // Hiệu ứng kính mờ (Chỉ kích hoạt khi cuộn dính lên top để giữ hiệu năng)
        filter: ImageFilter.blur(
          sigmaX: isPinned ? 15.0 : 0.0,
          sigmaY: isPinned ? 15.0 : 0.0,
        ),
        // 🌟 UPDATE 1: AnimatedContainer thay cho Container để mượt khi switch Dark/Light Mode
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // Nền app mờ đi để lộ mờ mờ nội dung cuộn bên dưới
          color: isPinned
              ? appColors.background.withOpacity(0.65)
              : appColors.background,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // ĐỔI MÀU THÔNG MINH:
              // - Pinned: Dùng nền Card (Trắng tinh/Xám đen tĩnh lặng)
              // - Normal: Dùng màu Primary nhạt (Hồng nhạt/Cyan nhạt trong suốt)
              color: isPinned
                  ? appColors.cardBackground
                  : appColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                100,
              ), // Bo tròn thành viên nang (Pill)
              border: Border.all(
                color: isPinned
                    ? appColors.primary.withOpacity(0.15)
                    : Colors.transparent,
                width: 1,
              ),
              boxShadow: isPinned
                  ? [
                      BoxShadow(
                        color: appColors.primaryDark.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON LỊCH TRẺ TRUNG
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  // ĐỔI MÀU THÔNG MINH
                  color: isPinned ? appColors.primary : appColors.text,
                ),
                const SizedBox(width: 6),

                // CỤM CHỮ NGÀY THÁNG
                Text(
                  DateTimeHelper.getFriendlyDateLabel(
                    dateKey,
                    l10n,
                  ).toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    // Pinned thì rực rỡ, bình thường thì sắc nét theo text Mode
                    color: isPinned ? appColors.primary : appColors.text,
                    letterSpacing: 0.5,
                  ),
                ),

                // DẤU CHẤM NGĂN CÁCH TÍNH TẾ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appColors.textMuted.withOpacity(0.4),
                    ),
                  ),
                ),

                // CỤM CHỮ TỔNG TIỀN (Gây ấn tượng về chi phí)
                Text(
                  "-$formattedTotal",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900, // Đậm hơn để nổi bật số tiền
                    // ErrorAccent giữ nguyên màu nổi bật vì đây là báo cáo trừ tiền
                    color: appColors.errorAccent.withOpacity(
                      isPinned ? 1.0 : 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60.0; // Tăng một chút không gian để header thở

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant _DailyHeaderDelegate oldDelegate) {
    // 🌟 UPDATE 2: Chìa khóa báo cho Flutter biết cần vẽ lại Delegate khi Theme thay đổi
    return dateKey != oldDelegate.dateKey ||
        formattedTotal != oldDelegate.formattedTotal ||
        appColors != oldDelegate.appColors ||
        l10n != oldDelegate.l10n;
  }
}
