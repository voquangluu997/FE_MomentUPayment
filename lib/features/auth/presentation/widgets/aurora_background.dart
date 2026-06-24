import 'dart:ui';
import 'package:flutter/material.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;
  final Color primaryColor;
  final Color backgroundColor;

  const AuroraBackground({
    super.key,
    required this.child,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          // 🌌 LỚP 1: CÁC KHỐI ĐÈN NEON PHÁT SÁNG
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.22),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.15),
              ),
            ),
          ),

          // 🌫️ LỚP 2: BỘ LỌC BLUR TRONG SUỐT
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 📝 LỚP 3: NỘI DUNG CHÍNH (Đã bọc SafeArea)
          SafeArea(child: child),
        ],
      ),
    );
  }
}
