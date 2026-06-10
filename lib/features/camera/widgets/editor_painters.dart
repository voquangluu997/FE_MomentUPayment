import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/editor_models.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;
  DrawingPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (var path in paths) {
      if (path.mode == PaintingMode.free || path.mode == PaintingMode.eraser) {
        if (path.points.isEmpty) continue;
        final drawPath = Path();
        bool firstPoint = true;

        for (int i = 0; i < path.points.length; i++) {
          final point = path.points[i];
          if (point == null) {
            firstPoint = true;
          } else if (firstPoint) {
            drawPath.moveTo(point.dx, point.dy);
            firstPoint = false;
          } else {
            drawPath.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(drawPath, path.paint);
      }
      // Preview khi kéo tay các hình khối
      else if (path.startPoint != null && path.endPoint != null) {
        if (path.mode == PaintingMode.rect || path.mode == PaintingMode.blur) {
          canvas.drawRect(
            Rect.fromPoints(path.startPoint!, path.endPoint!),
            path.paint,
          );
        } else if (path.mode == PaintingMode.circle) {
          canvas.drawOval(
            Rect.fromPoints(path.startPoint!, path.endPoint!),
            path.paint,
          );
        } else if (path.mode == PaintingMode.arrow) {
          final start = path.startPoint!;
          final end = path.endPoint!;
          canvas.drawLine(start, end, path.paint);

          final double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
          final double arrowLength = path.paint.strokeWidth * 4;

          final Offset p1 = Offset(
            end.dx - arrowLength * math.cos(angle - math.pi / 6),
            end.dy - arrowLength * math.sin(angle - math.pi / 6),
          );
          final Offset p2 = Offset(
            end.dx - arrowLength * math.cos(angle + math.pi / 6),
            end.dy - arrowLength * math.sin(angle + math.pi / 6),
          );

          final Path arrowPath = Path()
            ..moveTo(end.dx, end.dy)
            ..lineTo(p1.dx, p1.dy)
            ..lineTo(p2.dx, p2.dy)
            ..close();
          canvas.drawPath(
            arrowPath,
            Paint()
              ..color = path.paint.color
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter old) => true;
}

// Widget chuyên biệt cho Sticker Mũi tên (Dễ dàng xoay)
class ArrowStickerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  ArrowStickerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final start = Offset(0, size.height / 2);
    final end = Offset(size.width, size.height / 2);

    canvas.drawLine(start, end, paint);

    final double arrowLength = strokeWidth * 4;
    final Path arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowLength * math.cos(math.pi / 6),
        end.dy - arrowLength * math.sin(math.pi / 6),
      )
      ..lineTo(
        end.dx - arrowLength * math.cos(-math.pi / 6),
        end.dy - arrowLength * math.sin(-math.pi / 6),
      )
      ..close();

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  CropOverlayPainter({required this.cropRect});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.8);
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRect(cropRect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, bgPath, holePath),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter old) =>
      old.cropRect != cropRect;
}
