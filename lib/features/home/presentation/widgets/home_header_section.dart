import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class HomeHeaderSection extends ConsumerWidget {
  final VoidCallback onToggleView;
  final VoidCallback onFilterTap;
  final bool isGridView;
  final bool isFiltered;

  const HomeHeaderSection({
    super.key,
    required this.onToggleView,
    required this.onFilterTap,
    required this.isGridView,
    required this.isFiltered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Tiêu đề
          Expanded(
            child: Text(
              l10n.spendingMomentsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColors.primaryDark,
              ),
            ),
          ),

          // Nút Filter
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
          const SizedBox(width: 8),

          // Nút Toggle View
          _buildActionButton(
            icon: isGridView
                ? Icons.format_list_bulleted_rounded
                : Icons.grid_view_rounded,
            color: appColors.primary,
            backgroundColor: appColors.primary.withOpacity(0.06),
            onTap: onToggleView,
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
