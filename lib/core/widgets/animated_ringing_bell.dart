import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedRingingBell extends StatefulWidget {
  final bool isRinging;
  final Widget child;

  const AnimatedRingingBell({
    super.key,
    required this.isRinging,
    required this.child,
  });

  @override
  State<AnimatedRingingBell> createState() => _AnimatedRingingBellState();
}

class _AnimatedRingingBellState extends State<AnimatedRingingBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 🌸 Tăng tổng thời gian lên 2 giây để tạo một chu kỳ có khoảng nghỉ
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isRinging) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedRingingBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRinging != oldWidget.isRinging) {
      if (widget.isRinging) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        double angle = 0.0;

        // 🌸 Chỉ rung trong 30% thời gian đầu (~0.6 giây), 70% sau đứng im (~1.4 giây)
        if (t < 0.3) {
          // Chuẩn hóa t về khoảng 0.0 -> 1.0 cho riêng phase đang rung
          final double normalizedT = t / 0.3;

          // Hiệu ứng giảm chấn (damping): Lực lắc yếu dần về cuối
          final double damping = 1.0 - normalizedT;

          // Giảm góc lắc tối đa xuống 0.15 rad (~8.5 độ) cho nhẹ nhàng
          // Nhân với pi * 6 để tạo ra 3 nhịp lắc qua lại
          angle = math.sin(normalizedT * math.pi * 6) * 0.15 * damping;
        }

        return Transform.rotate(
          angle: angle,
          alignment:
              Alignment.topCenter, // Vẫn giữ nguyên tâm lắc ở đỉnh chuông
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
