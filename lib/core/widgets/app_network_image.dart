import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? customErrorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;

  // 👇 1. BỔ SUNG BIẾN MÀU NỀN TRỰC TIẾP TẠI ĐÂY
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.customErrorWidget,
    this.color,
    this.colorBlendMode,
    // 👇 2. ĐƯA VÀO CONSTRUCTOR
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Tách phần logic tạo lõi hiển thị (Content) ra riêng
    Widget imageContent;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      imageContent = _buildErrorPlaceholder();
    } else {
      imageContent = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }

    // 👇 3. BỌC TOÀN BỘ BẰNG CONTAINER ĐỂ THIẾT LẬP MÀU NỀN CHUẨN
    return Container(
      width: width,
      height: height,
      color: backgroundColor, // 🔥 Màu nền thực sự nằm ở đây
      child: imageContent,
    );
  }

  Widget _buildErrorPlaceholder() {
    if (customErrorWidget != null) {
      // Bọc customErrorWidget vào SizedBox để đảm bảo size đồng bộ nếu có nền
      return SizedBox(width: width, height: height, child: customErrorWidget!);
    }

    return Image.asset(
      'assets/images/default_placeholder.png',
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }
}
