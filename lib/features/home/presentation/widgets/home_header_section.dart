import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

// Import để lấy state grid view từ file home_screen
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';

class HomeHeaderSection extends ConsumerWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isGridView = ref.watch(isGridViewProvider);
    final appColors = ref.watch(appColorsProvider); // ✨ Lấy bộ màu động

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 16, top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- BÊN TRÁI: Tiêu đề ---
          Text(
            l10n.spendingMomentsTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appColors.primaryDark, // Thay đổi màu
            ),
          ),

          // --- BÊN PHẢI: Nút View Mode (Cùng hàng) ---
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appColors.primary.withOpacity(0.08), // Mềm mại hóa UI
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: appColors.primary, // Thay đổi màu
                size: 20,
              ),
              onPressed: () {
                // Thêm hiệu ứng rung nhẹ (HapticFeedback) ở đây nếu muốn
                ref.read(isGridViewProvider.notifier).state = !isGridView;
              },
            ),
          ),
        ],
      ),
    );
  }
}
