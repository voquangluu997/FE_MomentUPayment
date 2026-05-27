import 'package:flutter/material.dart';
import 'package:frontend/core/providers/currency_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../l10n/app_localizations.dart';
import 'moment_details_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🔑 1. Thêm import Riverpod

class MomentGridItem extends ConsumerWidget {
  final Map<String, dynamic> moment;
  final AppLocalizations l10n;
  final VoidCallback onLongPress;

  const MomentGridItem({
    super.key,
    required this.moment,
    required this.l10n,
    required this.onLongPress,
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
    final String imageUrl = moment['imageUrl'] ?? '';
    final String note = moment['note'] ?? '';
    final String category = moment['category'] ?? '';
    final bool hasImage = imageUrl.isNotEmpty;

    final currencySymbol = ref.watch(currencyProvider);

    // 🔑 6. Thay vì hardcode '₫', hãy truyền hoặc nối chuỗi với currencySymbol mới
    // (Nếu hàm formatCompactAmount của bạn đang tự nối đuôi '₫', hãy xóa đuôi '₫' trong file CurrencyHelper đi nhé)
    final String compactAmount =
        '-${CurrencyHelper.formatCompactAmount(moment['amount'])}$currencySymbol';

    final IconData categoryIcon = _getCategoryIcon(category);

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => MomentDetailsDialog(moment: moment, l10n: l10n),
      ),
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImage
                  ? Image.network(
                      CloudinaryHelper.getOptimizedOriginalUrl(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultCenterIcon(categoryIcon),
                    )
                  : _buildDefaultCenterIcon(categoryIcon),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasImage
                          ? Colors.black.withOpacity(0.6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      compactAmount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize:
                            10.5, // Giảm nhẹ 0.5 size để hiển thị chuỗi dài dạng "150.000₫" không bị tràn ô grid 3 cột
                        fontWeight: FontWeight.bold,
                        color: hasImage ? Colors.white : AppColors.errorAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: hasImage
                          ? Colors.black.withOpacity(0.4)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note.isNotEmpty ? note : l10n.emptyTransactionNote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: hasImage
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.primaryDark.withOpacity(0.65),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCenterIcon(IconData icon) {
    return Container(
      color: AppColors.primary.withOpacity(0.04),
      child: Center(
        child: Icon(icon, size: 32, color: AppColors.primary.withOpacity(0.12)),
      ),
    );
  }
}
