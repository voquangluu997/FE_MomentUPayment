import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/cloudinary_helper.dart';

class PhotoCalendarCell extends ConsumerStatefulWidget {
  final DateTime date;
  final Map<String, dynamic>? dayData;
  final VoidCallback onTap;

  const PhotoCalendarCell({
    super.key,
    required this.date,
    this.dayData,
    required this.onTap,
  });

  @override
  ConsumerState<PhotoCalendarCell> createState() => _PhotoCalendarCellState();
}

class _PhotoCalendarCellState extends ConsumerState<PhotoCalendarCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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
    final appColors = ref.watch(appColorsProvider);
    final bool hasData = widget.dayData != null;

    final String imageUrl = widget.dayData?['imageUrl'] ?? '';
    final bool hasImage = imageUrl.isNotEmpty;
    final String emoji = widget.dayData?['emoji'] ?? '✨';

    final isToday = DateUtils.isSameDay(widget.date, DateTime.now());

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: hasData
                ? (hasImage
                      ? Colors.transparent
                      : appColors.primary.withOpacity(0.12))
                : appColors.background,
            borderRadius: BorderRadius.circular(14),
            border: isToday
                ? Border.all(color: appColors.primary, width: 2)
                : (hasData
                      ? null
                      : Border.all(
                          color: appColors.primaryDark.withOpacity(0.05),
                          width: 1,
                        )),
            boxShadow: hasData
                ? [
                    BoxShadow(
                      color: appColors.primary.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 1. LỚP NỀN (ẢNH HOẶC MÀU)
              if (hasImage)
                Positioned.fill(
                  child: Image.network(
                    CloudinaryHelper.getThumbnailUrl(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),

              if (hasImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),

              // Lưới caro nhạt cho ngày trống (vibe sổ tay)
              if (!hasData)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.04,
                    child: GridPaper(
                      color: appColors.primaryDark,
                      divisions: 1,
                      interval: 10,
                    ),
                  ),
                ),

              // 2. SỐ NGÀY (Góc trên trái)
              Positioned(
                top: 4,
                left: 6,
                child: Text(
                  '${widget.date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: hasImage
                        ? Colors.white
                        : (isToday
                              ? appColors.primary
                              : appColors.primaryDark.withOpacity(0.5)),
                  ),
                ),
              ),

              // 3. EMOJI CHI TIÊU (Ở giữa cho ngày có tiêu mà không có ảnh)
              if (hasData && !hasImage)
                Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),

              // 4. CHẤM NHỎ (Chỉ báo có tiêu tiền mà bị ảnh nền che mất)
              if (hasData && hasImage)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: appColors.errorAccent, // Chấm đỏ/hồng cute
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
