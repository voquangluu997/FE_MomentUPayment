import 'package:flutter/material.dart';

enum StickerType { icon, text, magnifier, badge, rect, circle, arrow, blur }

class StickerModel {
  String id;
  StickerType type;
  String value;
  Offset offset;
  double scale;
  double rotation;
  Color textColor;
  Color backgroundColor;
  bool hasBackground;

  // Dành riêng cho các Object Hình khối / Mũi tên / Che mờ
  Size size;
  double strokeWidth;

  StickerModel({
    required this.id,
    required this.type,
    required this.value,
    this.offset = const Offset(100, 100),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.hasBackground = false,
    this.size = const Size(100, 100),
    this.strokeWidth = 5.0,
  });

  StickerModel copy() {
    return StickerModel(
      id: id,
      type: type,
      value: value,
      offset: offset,
      scale: scale,
      rotation: rotation,
      textColor: textColor,
      backgroundColor: backgroundColor,
      hasBackground: hasBackground,
      size: size,
      strokeWidth: strokeWidth,
    );
  }
}

enum PaintingMode { none, free, circle, rect, eraser, arrow, blur }

class DrawingPath {
  final List<Offset?> points;
  final Paint paint;
  final PaintingMode mode;
  final Offset? startPoint; // Tọa độ bắt đầu (Hỗ trợ định hướng mũi tên)
  final Offset? endPoint; // Tọa độ kết thúc

  DrawingPath({
    required this.points,
    required this.paint,
    required this.mode,
    this.startPoint,
    this.endPoint,
  });

  DrawingPath copy() {
    final newPaint = Paint()
      ..color = paint.color
      ..strokeWidth = paint.strokeWidth
      ..style = paint.style
      ..strokeCap = paint.strokeCap
      ..strokeJoin = paint.strokeJoin
      ..blendMode = paint.blendMode;

    return DrawingPath(
      points: List.from(points),
      paint: newPaint,
      mode: mode,
      startPoint: startPoint,
      endPoint: endPoint,
    );
  }
}

class EditorState {
  final String imagePath;
  final int rotationTurns;
  final double glow;
  final double smooth;
  final double pop;
  final int filterIndex;
  final int filterSubTab;
  final List<StickerModel> stickers;
  final List<DrawingPath> drawingPaths;

  EditorState({
    required this.imagePath,
    required this.rotationTurns,
    required this.glow,
    required this.smooth,
    required this.pop,
    required this.filterIndex,
    required this.filterSubTab,
    required this.stickers,
    required this.drawingPaths,
  });
}
