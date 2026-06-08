import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/cloudinary_helper.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class MomentListItem extends ConsumerWidget {
  final Map<String, dynamic> transaction;
  final AppLocalizations l10n;
  final AppColorTheme appColors;
  final VoidCallback onTap;
  final Future<bool> Function() onConfirmDelete;

  const MomentListItem({
    super.key,
    required this.transaction,
    required this.l10n,
    required this.appColors,
    required this.onTap,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(transaction['id'].toString()),
      direction: DismissDirection.endToStart,
      onUpdate: (details) {
        if (details.progress > 0.1 && details.progress < 0.15) {
          HapticFeedback.selectionClick();
        }
      },
      confirmDismiss: (direction) async {
        HapticFeedback.heavyImpact();
        return await onConfirmDelete();
      },
      // 🚀 TỐI ƯU UX VUỐT: Chuyển nền đỏ tĩnh thành Gradient, thêm Text cảnh báo
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF4B4B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4B4B).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.deleteActionLabel ?? "Xóa",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.trash_fill,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
      child: _buildCardContent(ref),
    );
  }

  Widget _buildCardContent(WidgetRef ref) {
    final String imageUrl = transaction['imageUrl'] ?? '';
    final String note = transaction['note'] ?? '';
    final String category = transaction['category'] ?? l10n.categoryOther;
    final String emoji = transaction['emoji'] ?? '✨';
    final bool hasImage = imageUrl.isNotEmpty;

    // Format Thời gian
    final rawDate = transaction['spentAt'] ?? transaction['createdAt'];
    String timeString = '';
    if (rawDate != null) {
      final date = DateTime.tryParse(rawDate.toString())?.toLocal();
      if (date != null) {
        timeString =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    }

    // Format Tiền tệ
    final currencySymbol = ref.watch(currencyProvider);
    final String compactAmount =
        '-${CurrencyHelper.formatCompactAmount(transaction['amount'])}$currencySymbol';

    return Container(
      // 🚀 TĂNG CHIỀU CAO NHẸ: Lên 90 để chứa Pill Tag đẹp hơn mà không mất đi performance
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        // 🚀 TỐI ƯU UI: Thêm viền mỏng tạo cảm giác kính (Soft Glassmorphism)
        border: Border.all(
          color: appColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.primaryDark.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: appColors.primary.withOpacity(0.05),
          splashColor: appColors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 🚀 ALBUM COVER PREIUM
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    // 🚀 Nếu là emoji, dùng Gradient để làm nó rực rỡ và có chiều sâu
                    gradient: hasImage
                        ? null
                        : LinearGradient(
                            colors: [
                              appColors.primary.withOpacity(0.15),
                              appColors.primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Bo cong gắt hơn kiểu iOS
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasImage
                      ? Image.network(
                          CloudinaryHelper.getOptimizedOriginalUrl(imageUrl),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                ),
                const SizedBox(width: 16),

                // THÔNG TIN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        note.isNotEmpty ? note : l10n.emptyTransactionNote,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: appColors
                              .text, // 🚀 Dùng text color chuẩn để nổi bật
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8), // Tăng khoảng cách một chút
                      Row(
                        children: [
                          // 🚀 TỐI ƯU UI: Biến Category thành một cái "Pill Tag" dễ thương
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: appColors.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          if (timeString.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.clock,
                              size: 12,
                              color: appColors.textMuted.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeString,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: appColors.textMuted.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // SỐ TIỀN
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        compactAmount,
                        style: TextStyle(
                          fontSize: 17, // 🚀 To hơn chút xíu
                          fontWeight: FontWeight.w900,
                          color: appColors
                              .errorAccent, // Giữ màu đỏ/cam báo hiệu chi tiêu
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
