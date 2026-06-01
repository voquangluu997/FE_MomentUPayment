import 'package:flutter/material.dart';
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

  const HomeHeaderSection({
    super.key,
    required this.onToggleView,
    required this.onFilterTap,
    required this.onCalendarTap,
    required this.onClearFilter,
    required this.isGridView,
    required this.isFiltered,
    required this.isCalendarView,
    this.selectedDateRange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);
    final f = DateFormat('dd/MM');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BÊN TRÁI: Tiêu đề & Khoảng ngày tháng bộ lọc (Bọc Expanded tránh tràn viền)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.spendingMomentsTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Hiển thị range ngày tháng nhỏ xinh ngay bên dưới tiêu đề nếu đang filter
                if (isFiltered && selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: 11,
                            color: appColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${f.format(selectedDateRange!.start)} - ${f.format(selectedDateRange!.end)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: appColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onClearFilter,
                            child: Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: appColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // BÊN PHẢI: Cụm 3 nút chức năng đứng thẳng hàng ngang với Tiêu đề
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 2. Nút Chế độ hiển thị (List / Grid)
              _buildActionButton(
                icon: isGridView
                    ? Icons.format_list_bulleted_rounded
                    : Icons.grid_view_rounded,
                color: isGridView || !isCalendarView
                    ? Colors.white
                    : appColors.primary,
                backgroundColor: isGridView || !isCalendarView
                    ? appColors.primary
                    : appColors.primary.withOpacity(0.1),
                onTap: onToggleView,
              ),
              const SizedBox(width: 6),

              // 3. Nút Lịch (Calendar)
              _buildActionButton(
                icon: Icons.calendar_month_rounded,
                color: isCalendarView ? Colors.white : appColors.primary,
                backgroundColor: isCalendarView
                    ? appColors.primary
                    : appColors.primary.withOpacity(0.1),
                onTap: onCalendarTap,
              ),
              const SizedBox(width: 6),
              // 1. Nút Lọc (Filter)
              _buildActionButton(
                icon: isFiltered
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_outlined,
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
        child: Icon(
          icon,
          size: 19,
          color: color,
        ), // Kích thước vừa vặn cho thanh công cụ đơn
      ),
    );
  }
}
