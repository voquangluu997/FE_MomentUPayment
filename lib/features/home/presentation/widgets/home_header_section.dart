import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class HomeHeaderSection extends ConsumerWidget {
  final VoidCallback onToggleView;
  final VoidCallback onFilterTap;
  final VoidCallback onCalendarTap;
  final VoidCallback onClearFilter;
  final bool isGridView;
  final bool isFiltered;
  final bool isCalendarView;
  final DateTimeRange? selectedDateRange;

  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;

  const HomeHeaderSection({
    super.key,
    required this.onToggleView,
    required this.onFilterTap,
    required this.onCalendarTap,
    required this.onClearFilter,
    required this.isGridView,
    required this.isFiltered,
    required this.isCalendarView,
    required this.onSelectStart,
    required this.onSelectEnd,
    this.selectedDateRange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);
    final DateFormat df = DateFormat('dd MMM, yyyy', l10n.localeName);

    // 🌟 LẤY TOÀN BỘ FONT CHỮ CHUẨN TỪ THEME TOÀN CỤC
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- THANH TIÊU ĐỀ & 3 NÚT CHỨC NĂNG ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // BÊN TRÁI: Tiêu đề dòng chữ chính
              Expanded(
                child: Text(
                  l10n.spendingMomentsTitle,
                  // ⚡ ĐỒNG BỘ: Dùng headlineMedium hoặc titleLarge để lấy letterSpacing âm kiểu Apple
                  style: textTheme.titleLarge?.copyWith(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),

              // BÊN PHẢI: Cụm 3 nút chức năng tinh giản hàng ngang
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: isGridView
                        ? CupertinoIcons.list_bullet
                        : CupertinoIcons.square_grid_2x2,
                    color: isGridView || !isCalendarView
                        ? Colors.white
                        : appColors.primary,
                    backgroundColor: isGridView || !isCalendarView
                        ? appColors.primary
                        : appColors.primary.withValues(alpha: 0.08),
                    onTap: onToggleView,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: CupertinoIcons.calendar,
                    color: isCalendarView ? Colors.white : appColors.primary,
                    backgroundColor: isCalendarView
                        ? appColors.primary
                        : appColors.primary.withValues(alpha: 0.08),
                    onTap: onCalendarTap,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: CupertinoIcons.line_horizontal_3_decrease,
                    color: isFiltered ? Colors.white : appColors.primary,
                    backgroundColor: isFiltered
                        ? appColors.primary
                        : appColors.primary.withValues(alpha: 0.08),
                    onTap: onFilterTap,
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- 🎯 BỘ CHỌN DATE PICKER CAO CẤP TÁI SỬ DỤNG VIBE FINTECH ---
        if (isFiltered && selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: appColors.primary.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Tiêu đề nhỏ kèm nút Xóa bộ lọc nhanh
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.slider_horizontal_3,
                            size: 14,
                            color: appColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (l10n.filterActiveTitle).toUpperCase(),
                            // ⚡ ĐỒNG BỘ: Sử dụng cấu hình chữ label/caption nhỏ nhưng ép đậm sắc nét
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: appColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onClearFilter,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: appColors.errorAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.multiply,
                            size: 12,
                            color: appColors.errorAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Thanh chọn vùng ngày đối xứng cân đối vào chính giữa 🎯
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Vùng TỪ NGÀY bên trái
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onSelectStart();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: appColors.background.withValues(
                                alpha: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  (l10n.fromDate).toUpperCase(),
                                  // ⚡ ĐỒNG BỘ: Chữ phụ dùng bodyMedium có sẵn màu textMuted
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: appColors.textMuted.withValues(
                                      alpha: 0.6,
                                    ),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  df.format(selectedDateRange!.start),
                                  // ⚡ ĐỒNG BỘ: Chữ hiển thị ngày chính dùng titleMedium
                                  style: textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: appColors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Mũi tên kết nối ở trung tâm
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          CupertinoIcons.arrow_right,
                          size: 14,
                          color: appColors.textMuted.withValues(alpha: 0.4),
                        ),
                      ),

                      // Vùng ĐẾN NGÀY bên phải
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onSelectEnd();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: appColors.background.withValues(
                                alpha: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  (l10n.toDate).toUpperCase(),
                                  // ⚡ ĐỒNG BỘ: Chữ phụ đồng nhất với "Từ ngày"
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: appColors.textMuted.withValues(
                                      alpha: 0.6,
                                    ),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  df.format(selectedDateRange!.end),
                                  // ⚡ ĐỒNG BỘ: Ngày chính đồng nhất
                                  style: textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: appColors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(
          10,
        ), // Tăng nhẹ diện tích bấm cho mượt tay hơn
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}
