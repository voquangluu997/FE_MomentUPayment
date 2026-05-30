import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class HomeHeaderSection extends ConsumerWidget {
  final VoidCallback onToggleView;
  final VoidCallback onFilterTap;
  final VoidCallback onCalendarTap;
  final bool isGridView;
  final bool isFiltered;
  final bool isCalendarView;

  const HomeHeaderSection({
    super.key,
    required this.onToggleView,
    required this.onFilterTap,
    required this.onCalendarTap,
    required this.isGridView,
    required this.isFiltered,
    required this.isCalendarView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Căn lề trái
          children: [
            // Tiêu đề
            Text(
              l10n.spendingMomentsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColors.primaryDark,
              ),
            ),
            const SizedBox(width: 12), // Sát hơn với text (trước là 16)
            // 1. Nút View Mode (List/Grid)
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
            const SizedBox(width: 8), // Khoảng cách đều nhau
            // 2. Nút Calendar
            _buildActionButton(
              icon: Icons.calendar_month_rounded,
              color: isCalendarView ? Colors.white : appColors.primary,
              backgroundColor: isCalendarView
                  ? appColors.primary
                  : appColors.primary.withOpacity(0.1),
              onTap: onCalendarTap,
            ),
            const SizedBox(width: 8), // Khoảng cách đều nhau
            // 3. Nút Filter
            _buildActionButton(
              icon: isFiltered
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: isFiltered
                  ? appColors.primary
                  : appColors.primaryDark.withOpacity(0.6),
              backgroundColor: isFiltered
                  ? appColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              onTap: onFilterTap,
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
