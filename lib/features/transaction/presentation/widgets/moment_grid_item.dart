import 'dart:ui'; // ✨ Cần thiết để dùng ImageFilter (làm mờ kính)
import 'package:flutter/material.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MomentGridItem extends ConsumerWidget {
  final Map<String, dynamic> moment;
  final AppLocalizations l10n;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  const MomentGridItem({
    super.key,
    required this.moment,
    required this.l10n,
    required this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String imageUrl = moment['imageUrl'] ?? '';
    final String note = moment['note'] ?? '';
    final String category = moment['category'] ?? l10n.categoryOther;
    final String emoji = moment['emoji'] ?? '✨';
    final bool hasImage = imageUrl.isNotEmpty;

    final currencySymbol = ref.watch(currencyProvider);
    final appColors = ref.watch(appColorsProvider);

    final String compactAmount =
        '-${CurrencyHelper.formatCompactAmount(moment['amount'])}$currencySymbol';

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(
        16,
      ), // Thu nhỏ bo góc một chút cho hợp với size mới
      child: Container(
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: appColors.primary.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? _buildImageContent(
                imageUrl,
                compactAmount,
                note,
                emoji,
                category,
                appColors,
              )
            : _buildCuteMemoPad(emoji, category, appColors, compactAmount),
      ),
    );
  }

  // ===========================================================================
  // 1. UI KHI CÓ ẢNH: Đã thu ngắn chiều dọc (Tỷ lệ 0.88 - Gọn gàng, thanh thoát)
  // ===========================================================================
  Widget _buildImageContent(
    String imageUrl,
    String compactAmount,
    String note,
    String emoji,
    String category,
    AppColorTheme appColors,
  ) {
    return AspectRatio(
      aspectRatio:
          0.88, // ✨ Giảm độ dài, ảnh sẽ vừa vặn và không lo chiếm diện tích màn hình
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              CloudinaryHelper.getOptimizedOriginalUrl(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildCuteMemoPad(emoji, category, appColors, compactAmount),
            ),
          ),
          // Lớp phủ Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.01),
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Khối Kính Mờ Glassmorphism (Thu nhỏ padding nhẹ để text cân đối)
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              note.isNotEmpty
                                  ? note
                                  : l10n.emptyTransactionNote,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        compactAmount,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Băng keo Washi Tape
          Positioned(
            top: -4,
            left: 12,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: appColors.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. UI KHÔNG CÓ ẢNH: Tờ giấy Memo Pad (Tỷ lệ 1.15 - Dẹt nằm ngang siêu gọn)
  // ===========================================================================
  Widget _buildCuteMemoPad(
    String emoji,
    String category,
    AppColorTheme appColors,
    String compactAmount,
  ) {
    return AspectRatio(
      aspectRatio:
          1.15, // ✨ Thay vì vuông 1:1, ô chữ sẽ dẹt nằm ngang giúp tiết kiệm chiều dọc tối đa
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [appColors.background, appColors.primary.withOpacity(0.05)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.02,
                child: GridPaper(
                  color: appColors.primaryDark,
                  divisions: 1,
                  subdivisions: 1,
                  interval: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: appColors.primaryDark.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    moment['note']?.isNotEmpty == true
                        ? moment['note']
                        : l10n.emptyTransactionNote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: appColors.primaryDark.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    compactAmount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: appColors.errorAccent,
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
}
