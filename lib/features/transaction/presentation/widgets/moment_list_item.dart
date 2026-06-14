import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/category_helper.dart';
import 'package:moment_u_payment/core/utils/cloudinary_helper.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/widgets/app_network_image.dart';
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
          color: const Color(0xFFFF4B4B),
          borderRadius: BorderRadius.circular(28),
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
              l10n.deleteActionLabel,
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
    final String category = CategoryHelper().getLocalizedCategory(
      transaction['category'],
      l10n,
    );
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

    // 💰 Format Số tiền
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: appColors.primaryDark.withValues(alpha: 0.04),
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
          highlightColor: appColors.primary.withValues(alpha: 0.05),
          splashColor: appColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // 📸 1. CREATIVE VISUAL: POLAROID + MINI BEAR PUSHPIN
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 🔹 Lớp 1: Khung nền mờ xoay sang TRÁI
                      Transform.rotate(
                        angle: -0.08,
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: appColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      // 🔹 Lớp 2: Khung ảnh Polaroid xoay sang PHẢI
                      Transform.rotate(
                        angle: 0.06,
                        child: Container(
                          width: 70,
                          height: 70,
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: appColors.primaryDark.withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 12,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: hasImage
                                  ? appColors.background
                                  : appColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: hasImage
                                ? AppNetworkImage(
                                    imageUrl:
                                        CloudinaryHelper.getOptimizedOriginalUrl(
                                          imageUrl,
                                        ),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    customErrorWidget: Center(
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // 🔹 Lớp 3: GHIM HÌNH ĐẦU GẤU (MINI BEAR PUSHPIN) 🐻
                      Positioned(
                        top: -6,
                        right: 5,
                        child: Transform.rotate(
                          angle: 0.15, // Xoay cùng góc với khung ảnh
                          child: SizedBox(
                            width: 18,
                            height: 16, // Kích thước tổng thể rất nhỏ gọn
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Mặt gấu (Jelly bóng)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(
                                          alpha: 0.8,
                                        ), // Điểm bắt sáng
                                        appColors.primary,
                                        appColors.primaryDark,
                                      ],
                                      stops: const [0.0, 0.4, 1.0],
                                      center: const Alignment(-0.3, -0.4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 3,
                                        offset: const Offset(
                                          1,
                                          2,
                                        ), // Đổ bóng nhẹ xuống giấy
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // 📝 2. NỘI DUNG STORY & THẺ HASHTAG
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isNoteEmpty
                          ? Text(
                              l10n.emptyTransactionNote,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: appColors.textMuted.withValues(
                                  alpha: 0.5,
                                ),
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
                                      appColors.primary,
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
                                  fontWeight: FontWeight.w800,
                                  height: 1.35,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                      const SizedBox(height: 8),

                      // Metadata: Hashtag Category & Time
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: appColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.tag_fill,
                                    size: 10,
                                    color: appColors.primary.withValues(
                                      alpha: 0.8,
                                    ),
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
                                  color: appColors.textMuted.withValues(
                                    alpha: 0.3,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              timeString,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: appColors.textMuted.withValues(
                                  alpha: 0.6,
                                ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
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
