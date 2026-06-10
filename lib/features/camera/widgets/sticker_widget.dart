import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/editor_models.dart';
import 'editor_painters.dart'; // import để dùng ArrowStickerPainter

class StickerWidget extends StatelessWidget {
  final StickerModel sticker;
  final bool isSelected;
  final bool isDraggingSticker;
  final PaintingMode
  currentDrawingMode; // NHẬN BIẾT ĐANG DÙNG CÔNG CỤ VẼ HAY CHỌN
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final Function(ScaleStartDetails) onScaleStart;
  final Function(ScaleUpdateDetails) onScaleUpdate;
  final Function(ScaleEndDetails) onScaleEnd;

  const StickerWidget({
    super.key,
    required this.sticker,
    required this.isSelected,
    required this.isDraggingSticker,
    required this.currentDrawingMode,
    required this.onTap,
    required this.onDoubleTap,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: sticker.offset.dx,
      top: sticker.offset.dy,
      child: Transform.rotate(
        angle: sticker.rotation,
        child: Transform.scale(
          scale: sticker.scale,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // NẾU ĐANG CHỌN CÔNG CỤ VẼ THÌ KHÔNG ĐƯỢC CHỌN STICKER
              if (currentDrawingMode != PaintingMode.none) return;
              HapticFeedback.selectionClick();
              onTap();
            },
            onDoubleTap: () {
              if (currentDrawingMode != PaintingMode.none) return;
              if (sticker.type == StickerType.text) onDoubleTap();
            },
            onScaleStart: (details) {
              if (currentDrawingMode != PaintingMode.none) return;
              onScaleStart(details);
            },
            onScaleUpdate: (details) {
              if (currentDrawingMode != PaintingMode.none) return;
              onScaleUpdate(details);
            },
            onScaleEnd: (details) {
              if (currentDrawingMode != PaintingMode.none) return;
              onScaleEnd(details);
            },
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: Colors.transparent, // Hack để vùng chạm nhạy hơn
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _buildStickerContent(),
                    // KHUNG BAO VÀ CHẤM KHI CHỌN
                    if (isSelected &&
                        !isDraggingSticker &&
                        currentDrawingMode == PaintingMode.none) ...[
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white70,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Positioned(top: -5, left: -5, child: _buildDotHandle()),
                      Positioned(top: -5, right: -5, child: _buildDotHandle()),
                      Positioned(
                        bottom: -5,
                        left: -5,
                        child: _buildDotHandle(),
                      ),
                      Positioned(
                        bottom: -5,
                        right: -5,
                        child: _buildDotHandle(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerContent() {
    switch (sticker.type) {
      case StickerType.magnifier:
        return RawMagnifier(
          size: const Size(120, 120),
          magnificationScale: 2.5,
          decoration: const MagnifierDecoration(
            shape: CircleBorder(
              side: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        );
      case StickerType.badge:
        return Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sticker.backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
          ),
          child: Text(
            sticker.value,
            style: TextStyle(
              color: sticker.textColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
        );
      case StickerType.rect:
        return SizedBox(
          width: sticker.size.width,
          height: sticker.size.height,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: sticker.textColor,
                width: sticker.strokeWidth,
              ),
            ),
          ),
        );
      case StickerType.circle:
        return SizedBox(
          width: sticker.size.width,
          height: sticker.size.height,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: sticker.textColor,
                width: sticker.strokeWidth,
              ),
            ),
          ),
        );
      case StickerType.blur:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: sticker.size.width,
              height: sticker.size.height,
              color: Colors.black.withOpacity(
                0.05,
              ), // Tránh lỗi gesture trên bộ lọc mờ
            ),
          ),
        );
      case StickerType.arrow:
        return SizedBox(
          width: sticker.size.width,
          height: sticker.size.height,
          child: CustomPaint(
            painter: ArrowStickerPainter(
              color: sticker.textColor,
              strokeWidth: sticker.strokeWidth,
            ),
          ),
        );
      case StickerType.icon:
        return Text(
          sticker.value,
          style: const TextStyle(fontSize: 45, decoration: TextDecoration.none),
        );
      case StickerType.text:
      default:
        return Stack(
          children: [
            if (sticker.hasBackground)
              Text(
                sticker.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  decoration: TextDecoration.none,
                  background: Paint()
                    ..color = sticker.backgroundColor.withOpacity(0.6)
                    ..strokeWidth = 20
                    ..strokeJoin = StrokeJoin.round
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.stroke,
                ),
              ),
            Text(
              sticker.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: sticker.textColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildDotHandle() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
        ],
      ),
    );
  }
}
