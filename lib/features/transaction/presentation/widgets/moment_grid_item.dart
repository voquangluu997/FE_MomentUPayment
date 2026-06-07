import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/screens/full_screen_image_viewer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../l10n/app_localizations.dart';

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

    // 🌟 ĐỒNG NHẤT TỶ LỆ Ở ĐÂY: Tất cả các card đều chung tỷ lệ 0.82 (dáng dọc Polaroid)
    return AspectRatio(
      aspectRatio: 0.82,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: appColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            // Hiệu ứng chạm mềm mại
            splashColor: appColors.primary.withOpacity(0.2),
            highlightColor: appColors.primary.withOpacity(0.1),
            child: hasImage
                ? _buildImageContent(
                    imageUrl,
                    compactAmount,
                    note,
                    emoji,
                    category,
                    appColors,
                    context,
                  )
                : _buildCuteMemoPad(
                    emoji,
                    category,
                    appColors,
                    compactAmount,
                    note,
                  ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. UI KHI CÓ ẢNH: Kính mờ (Glassmorphism) tinh tế hơn
  // ===========================================================================
  Widget _buildImageContent(
    String imageUrl,
    String compactAmount,
    String note,
    String emoji,
    String category,
    AppColorTheme appColors,
    BuildContext
    context, // Bắt buộc thêm BuildContext vào tham số để chuyển trang
  ) {
    // Tạo ID duy nhất cho Hero Animation
    final String momentId =
        moment['id']?.toString() ??
        moment['_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final String heroTag = 'moment-pic-$momentId';

    // Giả sử bạn có CloudinaryHelper để tối ưu URL.
    // Nếu có thể, hãy truyền thêm tham số c_fill,g_auto để lấy trung tâm khuôn mặt.
    final String optimizedUrl = CloudinaryHelper.getOptimizedOriginalUrl(
      imageUrl,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: heroTag,
            child: Image.network(
              optimizedUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildCuteMemoPad(
                emoji,
                category,
                appColors,
                compactAmount,
                note,
              ),
            ),
          ),
        ),

        // Lớp phủ Gradient tối dần về đáy để chữ luôn nổi bật
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.75),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Washi Tape Góc trên trái
        _buildWashiTape(category, appColors),

        // Khối Kính Mờ cao cấp ở góc dưới
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note.isNotEmpty ? note : l10n.emptyTransactionNote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      compactAmount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. UI KHÔNG CÓ ẢNH: Nhật ký / Card Gradient Pastel (Sang trọng & Cute)
  // ===========================================================================
  Widget _buildCuteMemoPad(
    String emoji,
    String category,
    AppColorTheme appColors,
    String compactAmount,
    String note,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColors.background,
            appColors.primary.withOpacity(0.08),
            appColors.primary.withOpacity(0.15),
          ],
        ),
        border: Border.all(color: appColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Stack(
        children: [
          // Lưới nền mờ (Tạo cảm giác sổ tay)
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: GridPaper(
                color: appColors.primaryDark,
                divisions: 1,
                subdivisions: 1,
                interval: 20,
              ),
            ),
          ),

          // Vẫn giữ chiếc Washi Tape để đồng bộ với thẻ có ảnh
          _buildWashiTape(category, appColors),

          // Icon Emoji nổi bật ở giữa thay cho ảnh
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),

          // Thông tin ở góc dưới
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note.isNotEmpty ? note : l10n.emptyTransactionNote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: appColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  compactAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: appColors.errorAccent, // Giữ màu cảnh báo chi tiêu
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Widget dùng chung: Washi Tape
  // ===========================================================================
  Widget _buildWashiTape(String category, AppColorTheme appColors) {
    return Positioned(
      top: 10,
      left: 10,
      child: Transform.rotate(
        angle: -0.06,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: appColors.primary,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
