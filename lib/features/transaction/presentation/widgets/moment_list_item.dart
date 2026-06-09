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
  final Future<bool> Function()? onConfirmDelete;

  const MomentListItem({
    super.key,
    required this.transaction,
    required this.l10n,
    required this.appColors,
    required this.onTap,
    this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = _buildPremiumCardContent(ref);

    if (onConfirmDelete == null) {
      return content;
    }

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
        return await onConfirmDelete!();
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4B4B), // Đỏ nguyên bản, mạnh mẽ và dứt khoát
          borderRadius: BorderRadius.circular(
            28,
          ), // Bo góc khớp hoàn toàn với Card mới
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.trash_fill,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.deleteActionLabel ?? "Xóa",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      child: content,
    );
  }

  Widget _buildPremiumCardContent(WidgetRef ref) {
    final String imageUrl = transaction['imageUrl'] ?? '';
    final String note = transaction['note'] ?? '';
    final bool isNoteEmpty = note.isEmpty;
    final String category = transaction['category'] ?? l10n.categoryOther;
    final String emoji = transaction['emoji'] ?? '✨';
    final bool hasImage = imageUrl.isNotEmpty;

    // 🕒 Format Thời gian
    final rawDate = transaction['spentAt'] ?? transaction['createdAt'];
    String timeString = '';
    if (rawDate != null) {
      final date = DateTime.tryParse(rawDate.toString())?.toLocal();
      if (date != null) {
        timeString =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    }

    // 💰 XỬ LÝ SỐ TIỀN VÀ ĐẢM BẢO DẤU TRỪ
    final currencySymbol = ref.watch(currencyProvider);
    final String rawAmount = transaction['amount']?.toString() ?? '0';
    String compactAmount = CurrencyHelper.formatCompactAmount(
      rawAmount,
      symbol: currencySymbol,
    );

    if (!compactAmount.startsWith('-')) {
      compactAmount = '-$compactAmount';
    }

    return Container(
      // Tăng margin để các thẻ có không gian thở (Whitespace), tạo độ sang trọng
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(
          28,
        ), // Bo góc cực đại tạo nét dễ thương, bồng bềnh
        boxShadow: [
          BoxShadow(
            color: appColors.primaryDark.withOpacity(
              0.04,
            ), // Bóng đổ siêu mờ và rộng (Diffuse shadow)
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          highlightColor: appColors.primary.withOpacity(0.05),
          splashColor: appColors.primary.withOpacity(0.1),
          child: Padding(
            // Padding bên trong hào phóng hơn
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // 📸 1. BIG VISUAL: AVATAR KHOẢNH KHẮC CỰC LỚN
                Container(
                  width: 72, // Phóng to diện tích ảnh đập vào mắt người dùng
                  height: 72,
                  decoration: BoxDecoration(
                    color: hasImage
                        ? null
                        : appColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      22,
                    ), // Tỉ lệ bo góc chuẩn Apple
                    border: hasImage
                        ? null
                        : Border.all(
                            color: appColors.primary.withOpacity(0.15),
                            width: 1.5,
                          ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasImage
                      ? Image.network(
                          CloudinaryHelper.getOptimizedOriginalUrl(imageUrl),
                          fit: BoxFit.cover,
                          // Hiệu ứng Fade-in mượt mà khi load xong ảnh
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) return child;
                                return AnimatedOpacity(
                                  opacity: frame == null ? 0 : 1,
                                  duration: const Duration(milliseconds: 300),
                                  child: child,
                                );
                              },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        )
                      : Center(
                          // Nếu không có ảnh, Emoji phóng to làm điểm nhấn rực rỡ
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                ),
                const SizedBox(width: 16),

                // 📝 2. NỘI DUNG STORY & THẺ HASHTAG
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Caption: Gradient nổi bật
                      isNoteEmpty
                          ? Text(
                              l10n.emptyTransactionNote,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: appColors.textMuted.withOpacity(0.5),
                                height: 1.35,
                                letterSpacing: -0.2,
                              ),
                            )
                          : ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) =>
                                  LinearGradient(
                                    colors: [
                                      appColors.primaryDark,
                                      appColors
                                          .primary, // Chuyển màu từ tối sang sáng mượt mà
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      bounds.width,
                                      bounds.height,
                                    ),
                                  ),
                              child: Text(
                                note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight
                                      .w800, // Dùng w800 cho Gradient sẽ rất đẹp
                                  height: 1.35,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                      const SizedBox(height: 8),

                      // Metadata: Hashtag Category & Time
                      Row(
                        children: [
                          // Viên nang Hashtag (Pill)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: appColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.tag_fill,
                                    size: 10,
                                    color: appColors.primary.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      category,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: appColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (timeString.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: appColors.textMuted.withOpacity(0.3),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              timeString,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: appColors.textMuted.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 💰 3. CON SỐ QUYỀN LỰC
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      compactAmount,
                      style: TextStyle(
                        fontSize: 18, // Phóng to cực mạnh
                        fontWeight: FontWeight.w900, // Đậm nhất có thể
                        color: appColors.errorAccent,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
