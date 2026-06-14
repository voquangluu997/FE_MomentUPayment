import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/category_helper.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'category_filter_provider.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    // 📋 Đồng bộ danh sách Category với add_transaction_screen.dart
    final categories = CategoryHelper.getFilterCategories(l10n);

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ), // Giữ lề 20 đồng bộ với thẻ Budget
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          final String? categoryId = item['id'];
          final String label = item['name'];
          final String emoji = item['emoji'];

          final bool isActive = selectedCategory == categoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact(); // Rung cơ học chuẩn High-End
                    ref.read(selectedCategoryProvider.notifier).state =
                        categoryId;
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      // Màu Pastel dịu mắt, nhấn màu primary khi Active
                      color: isActive
                          ? appColors.primary.withValues(alpha: 0.85)
                          : appColors.cardBackground,
                      border: Border.all(
                        color: isActive
                            ? appColors.primary
                            : appColors.primaryDark.withValues(alpha: 0.05),
                        width: 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: appColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (emoji.isNotEmpty) ...[
                          Text(emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : appColors.primaryDark.withValues(alpha: 0.6),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
