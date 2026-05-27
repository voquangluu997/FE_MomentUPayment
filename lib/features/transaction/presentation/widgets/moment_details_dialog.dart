import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🔑 Thêm import Riverpod
import 'package:frontend/core/providers/currency_provider.dart';
import 'package:frontend/core/utils/currency_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../l10n/app_localizations.dart';

class MomentDetailsDialog extends ConsumerWidget {
  // 🔑 Đổi từ StatelessWidget thành ConsumerWidget
  final Map<String, dynamic> moment;
  final AppLocalizations l10n;

  const MomentDetailsDialog({
    super.key,
    required this.moment,
    required this.l10n,
  });

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.help_outline_rounded;
    final catLower = category.toLowerCase();

    if (catLower.contains('food') || catLower.contains('ăn')) {
      return Icons.cake_rounded;
    } else if (catLower.contains('shop')) {
      return Icons.local_mall_rounded;
    } else if (catLower.contains('transport') ||
        catLower.contains('xe') ||
        catLower.contains('di chuyển')) {
      return Icons.directions_car_rounded;
    } else if (catLower.contains('entertain') ||
        catLower.contains('game') ||
        catLower.contains('giải trí')) {
      return Icons.sports_esports_rounded;
    }
    return Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔑 Thêm WidgetRef ref vào tham số
    final String imageUrl = moment['imageUrl'] ?? '';
    final String note = moment['note'] ?? '';
    final String category = moment['category'] ?? '';
    final bool hasImage = imageUrl.isNotEmpty;

    // 🔑 Lấy ký hiệu tiền tệ đang được chọn từ Provider toàn cục
    final currencySymbol = ref.watch(currencyProvider);

    // 🔑 Tự động nối ký hiệu tiền tệ động vào sau chuỗi số
    final String compactAmount =
        '-${CurrencyHelper.formatCompactAmount(moment['amount'])}$currencySymbol';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBackground,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasImage
                      ? Image.network(
                          CloudinaryHelper.getOptimizedOriginalUrl(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.04),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(category),
                              size: 64,
                              color: AppColors.primary.withOpacity(0.15),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.isNotEmpty
                                ? category
                                : l10n.emptyTransactionNote,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      compactAmount,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.errorAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 16),
                Text(
                  note.isNotEmpty ? note : l10n.emptyTransactionNote,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark.withOpacity(0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
