import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/widgets/app_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../l10n/app_localizations.dart';

class MomentGridItem extends ConsumerStatefulWidget {
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
  ConsumerState<MomentGridItem> createState() => _MomentGridItemState();
}

class _MomentGridItemState extends ConsumerState<MomentGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 💡 UX Nâng cao: Hiệu ứng lún xuống khi chạm (Tương tự Instagram/Facebook)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.moment['imageUrl'] ?? '';
    final String note = widget.moment['note'] ?? '';
    final String emoji = widget.moment['emoji'] ?? '✨';
    final bool hasImage = imageUrl.isNotEmpty;

    final currencySymbol = ref.watch(currencyProvider);
    final appColors = ref.watch(appColorsProvider);
    String compactAmount = CurrencyHelper.formatCompactAmount(
      widget.moment['amount'],
      symbol: currencySymbol,
    );
    // Nếu hàm format chưa trả về dấu trừ (cho số dương hiển thị là chi tiêu), ta thêm dấu trừ
    if (!compactAmount.startsWith('-')) {
      compactAmount = '-$compactAmount';
    }

    // 🌟 ĐỔI TỶ LỆ: 0.65 tạo dáng dọc chuẩn Story/Highlight cho lưới 3 cột
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.onTap != null) {
          HapticFeedback.selectionClick(); // Rung nhẹ tạo cảm giác premium
          widget.onTap!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      onLongPress: () {
        HapticFeedback.heavyImpact();
        widget.onLongPress();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: AspectRatio(
            aspectRatio: 0.65,
            child: Container(
              // 💡 THE STORY RING: Vòng sáng Gradient bao quanh như FB Highlight
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appColors.primary.withValues(alpha: 0.8),
                    appColors.primary.withValues(alpha: 0.2),
                    appColors.primary.withValues(alpha: 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: appColors.background,
                  borderRadius: BorderRadius.circular(
                    21.5,
                  ), // Trừ đi padding của viền
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? _buildHighlightImage(
                        imageUrl,
                        compactAmount,
                        note,
                        emoji,
                        appColors,
                      )
                    : _buildHighlightGradient(
                        emoji,
                        compactAmount,
                        note,
                        appColors,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. KHI CÓ ẢNH: Chuẩn phong cách FB/IG Story Cover
  // ===========================================================================
  Widget _buildHighlightImage(
    String imageUrl,
    String compactAmount,
    String note,
    String emoji,
    AppColorTheme appColors,
  ) {
    final String momentId =
        widget.moment['id']?.toString() ??
        widget.moment['_id']?.toString() ??
        '';
    final String heroTag = 'moment-pic-$momentId';
    final String optimizedUrl = CloudinaryHelper.getOptimizedOriginalUrl(
      imageUrl,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Ảnh nền Full Cover
        Hero(
          tag: heroTag,
          child: AppNetworkImage(
            imageUrl: optimizedUrl,
            fit: BoxFit.cover,
            // Truyền toàn bộ logic UI highlight của bạn vào làm widget lỗi
            customErrorWidget: _buildHighlightGradient(
              emoji,
              compactAmount,
              note,
              appColors,
            ),
          ),
        ),

        // Lớp phủ Gradient đen dưới đáy để hiển thị chữ rõ nét (Đẹp hơn viền trắng kính mờ)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85), // Đen sâu ở đáy
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Thẻ Emoji kính mờ (Glassmorphism) siêu nhỏ ở góc trái trên
        Positioned(
          top: 8,
          left: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ),

        // Nội dung rút gọn ở đáy
        Positioned(
          bottom: 12,
          left: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                compactAmount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note.isNotEmpty ? note : widget.l10n.emptyTransactionNote,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. KHI KHÔNG CÓ ẢNH: Nền Gradient mượt mà, rực rỡ
  // ===========================================================================
  Widget _buildHighlightGradient(
    String emoji,
    String compactAmount,
    String note,
    AppColorTheme appColors,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColors.primary.withValues(alpha: 0.15),
            appColors.primary.withValues(
              alpha: 0.35,
            ), // Màu đậm hơn một chút so với trước
          ],
        ),
      ),
      child: Stack(
        children: [
          // Emoji khổng lồ mờ nhạt làm nền
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.1,
              child: Text(emoji, style: const TextStyle(fontSize: 80)),
            ),
          ),

          // Icon Emoji nổi bật ở giữa
          Center(
            child: Text(
              emoji,
              style: const TextStyle(
                fontSize: 36,
                shadows: [
                  Shadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Thông tin góc dưới (Màu tối để tương phản với nền sáng)
          Positioned(
            bottom: 12,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  compactAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: appColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note.isNotEmpty ? note : widget.l10n.emptyTransactionNote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: appColors.primaryDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
