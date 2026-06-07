import 'package:flutter/cupertino.dart'; // 🍏 Đã thêm import CupertinoIcons
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

  // 🔥 ĐĂNG KÝ THÊM 2 SỰ KIỆN CHỌN NGÀY ĐẦU / CUỐI ĐỂ ĐỒNG BỘ ĐỒNG ĐIỆU VỚI ANALYTICS SCREEN
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- THANH TIÊU ĐỀ & 3 NÚT CHỨC NĂNG ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // BÊN TRÁI: Tiêu đề dòng chữ chính
              Expanded(
                child: Text(
                  l10n.spendingMomentsTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryDark,
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
                  // Nút Chế độ hiển thị (List / Grid)
                  _buildActionButton(
                    icon: isGridView
                        ? CupertinoIcons.list_bullet
                        : CupertinoIcons.square_grid_2x2,
                    color: isGridView || !isCalendarView
                        ? Colors.white
                        : appColors.primary,
                    backgroundColor: isGridView || !isCalendarView
                        ? appColors.primary
                        : appColors.primary.withOpacity(0.1),
                    onTap: onToggleView,
                  ),
                  const SizedBox(width: 6),

                  // Nút Lịch (Calendar)
                  _buildActionButton(
                    icon: CupertinoIcons.calendar,
                    color: isCalendarView ? Colors.white : appColors.primary,
                    backgroundColor: isCalendarView
                        ? appColors.primary
                        : appColors.primary.withOpacity(0.1),
                    onTap: onCalendarTap,
                  ),
                  const SizedBox(width: 6),

                  // Nút Lọc (Filter)
                  _buildActionButton(
                    icon: CupertinoIcons.line_horizontal_3_decrease,
                    color: isFiltered ? Colors.white : appColors.primary,
                    backgroundColor: isFiltered
                        ? appColors.primary
                        : appColors.primary.withOpacity(0.1),
                    onTap: onFilterTap,
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- 🎯 BỘ CHỌN DATE PICKER CAO CẤP TÁI SỬ DỤNG GIỐNG MÀN HÌNH ANALYTIC ---
        if (isFiltered && selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: appColors.primary.withOpacity(0.12),
                  width: 1,
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
                          const SizedBox(width: 6),
                          Text(
                            (l10n.filterActiveTitle)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: appColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onClearFilter,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: appColors.errorAccent.withOpacity(0.1),
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
                  const SizedBox(height: 14),

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
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center, // Căn giữa chữ
                              children: [
                                Text(
                                  (l10n.fromDate).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: appColors.textMuted.withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  df.format(selectedDateRange!.start),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
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
                      Icon(
                        CupertinoIcons.arrow_right,
                        size: 13,
                        color: appColors.textMuted.withOpacity(0.4),
                      ),

                      // Vùng ĐẾN NGÀY bên phải
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onSelectEnd();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center, // Căn giữa chữ
                              children: [
                                Text(
                                  (l10n.toDate).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: appColors.textMuted.withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  df.format(selectedDateRange!.end),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}
