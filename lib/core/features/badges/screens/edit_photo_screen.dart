import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

// ─── MODEL STICKER ───
enum StickerType { icon, text }

class StickerModel {
  final String id;
  final StickerType type;
  String value;
  Offset offset;
  double scale;
  double rotation;

  Color textColor;
  Color backgroundColor;
  bool hasBackground;

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
    );
  }
}

// ─── MODEL DRAWING ───
enum PaintingMode { none, free, circle, rect, eraser }

class DrawingPath {
  final List<Offset?> points;
  final Paint paint;
  final PaintingMode mode;
  final Rect? rect;

  DrawingPath({
    required this.points,
    required this.paint,
    required this.mode,
    this.rect,
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
      rect: rect,
    );
  }
}

// ─── QUẢN LÝ LỊCH SỬ CHỈNH SỬA ───
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

class EditPhotoScreen extends StatefulWidget {
  final String imagePath;
  const EditPhotoScreen({super.key, required this.imagePath});

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final GlobalKey _globalKey = GlobalKey();
  final GlobalKey _paintKey = GlobalKey();

  double _initialStickerScale = 1.0;
  double _initialStickerRotation = 0.0;
  Offset _initialStickerOffset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;

  late String _currentImagePath;
  bool _isCapturingRaw = false;
  bool _isEditingText = false;
  String? _editingStickerId;

  int _currentTab =
      0; // 0: Filter, 1: Transform, 2: Beauty, 3: Sticker, 4: Draw
  bool _isPanelVisible = true;
  final double _panelHeight = 280.0;

  int _rotationTurns = 0;
  double _cropLeft = 0.0;
  double _cropTop = 0.0;
  double _cropWidth = 0.0;
  double _cropHeight = 0.0;
  final double _minCropSize = 70.0;

  double _glowBrightness = 0.0;
  double _skinSmoothContrast = 1.0;
  double _popSaturation = 1.0;

  List<StickerModel> _stickers = [];
  String? _selectedStickerId;
  bool _isDraggingSticker = false;
  bool _isOverDeleteArea = false;

  Color _currentTextColor = Colors.white;
  Color _currentTextBgColor = Colors.black;
  bool _currentTextHasBg = true;
  late TextEditingController _textStickerController;
  final FocusNode _textStickerFocusNode = FocusNode();

  // STATE DRAWING
  List<DrawingPath> _drawingPaths = [];
  PaintingMode _currentDrawingMode = PaintingMode.none;
  Color _currentPaintColor = Colors.redAccent;
  double _currentStopWidth = 5.0;
  Offset? _drawStartPoint;

  List<EditorState> _history = [];
  int _historyIndex = -1;

  int _selectedFilterIndex = 0;
  int _currentFilterSubTab = 0;

  final List<String> _iconsStorage = [
    "✨",
    "🌸",
    "🦋",
    "🧸",
    "📸",
    "🤍",
    "🖤",
    "🔥",
    "🎀",
    "🪐",
    "🥂",
    "🍰",
    "☕",
    "🍕",
    "🥑",
    "🕶️",
    "🛍️",
    "🏷️",
    "📍",
    "🎵",
  ];

  final List<Color> _paintColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.white,
    Colors.black,
  ];

  late Map<int, List<String>> _filterNames;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _textStickerController = TextEditingController();
    _filterNames = {
      0: ["ORIGINAL", "NOSTALGIA", "PORTRA", "CHROME", "NOIR"],
      1: ["NATURAL", "VIVID", "COZY", "MINIMAL"],
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveStateToHistory());
  }

  @override
  void dispose() {
    _textStickerController.dispose();
    _textStickerFocusNode.dispose();
    super.dispose();
  }

  void _saveStateToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }
    _history.add(
      EditorState(
        imagePath: _currentImagePath,
        rotationTurns: _rotationTurns,
        glow: _glowBrightness,
        smooth: _skinSmoothContrast,
        pop: _popSaturation,
        filterIndex: _selectedFilterIndex,
        filterSubTab: _currentFilterSubTab,
        stickers: _stickers.map((s) => s.copy()).toList(),
        drawingPaths: _drawingPaths.map((p) => p.copy()).toList(),
      ),
    );
    if (_history.length > 30) _history.removeAt(0);
    _historyIndex = _history.length - 1;
    if (mounted) setState(() {});
  }

  void _undo() {
    if (_historyIndex > 0) {
      HapticFeedback.mediumImpact();
      _historyIndex--;
      _loadState(_history[_historyIndex]);
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      HapticFeedback.mediumImpact();
      _historyIndex++;
      _loadState(_history[_historyIndex]);
    }
  }

  void _loadState(EditorState state) {
    setState(() {
      _currentImagePath = state.imagePath;
      _rotationTurns = state.rotationTurns;
      _glowBrightness = state.glow;
      _skinSmoothContrast = state.smooth;
      _popSaturation = state.pop;
      _selectedFilterIndex = state.filterIndex;
      _currentFilterSubTab = state.filterSubTab;
      _stickers = state.stickers.map((s) => s.copy()).toList();
      _drawingPaths = state.drawingPaths.map((p) => p.copy()).toList();
      _selectedStickerId = null;
      _cropWidth = 0;
      if (_currentTab != 4) _currentDrawingMode = PaintingMode.none;
    });
  }

  Paint _getCurrentPaint() {
    final isEraser = _currentDrawingMode == PaintingMode.eraser;
    return Paint()
      ..color = isEraser ? Colors.white : _currentPaintColor
      ..strokeWidth = _currentStopWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = isEraser ? BlendMode.clear : BlendMode.srcOver;
  }

  void _onPanStart(DragStartDetails details) {
    if (_currentTab != 4 || _currentDrawingMode == PaintingMode.none) return;

    HapticFeedback.lightImpact();
    final RenderBox renderBox =
        _paintKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _drawStartPoint = localPosition;

    setState(() {
      if (_currentDrawingMode == PaintingMode.free ||
          _currentDrawingMode == PaintingMode.eraser) {
        _drawingPaths.add(
          DrawingPath(
            points: [localPosition],
            paint: _getCurrentPaint(),
            mode: _currentDrawingMode,
          ),
        );
      } else {
        _drawingPaths.add(
          DrawingPath(
            points: [],
            paint: _getCurrentPaint(),
            mode: _currentDrawingMode,
            rect: Rect.fromPoints(localPosition, localPosition),
          ),
        );
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentTab != 4 ||
        _currentDrawingMode == PaintingMode.none ||
        _drawStartPoint == null)
      return;

    final RenderBox renderBox =
        _paintKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      if (_currentDrawingMode == PaintingMode.free ||
          _currentDrawingMode == PaintingMode.eraser) {
        _drawingPaths.last.points.add(localPosition);
      } else {
        final lastPath = _drawingPaths.last;
        _drawingPaths[_drawingPaths.length - 1] = DrawingPath(
          points: [],
          paint: lastPath.paint,
          mode: lastPath.mode,
          rect: Rect.fromPoints(_drawStartPoint!, localPosition),
        );
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentTab != 4 || _currentDrawingMode == PaintingMode.none) return;

    setState(() {
      if (_currentDrawingMode == PaintingMode.free ||
          _currentDrawingMode == PaintingMode.eraser) {
        _drawingPaths.last.points.add(null);
      }
      _drawStartPoint = null;
    });
    _saveStateToHistory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const Color studioBg = Color(0xFF050507);
    const Color panelObsidian = Color(0xFF0F0F11);
    const Color champagneAccent = Color(0xFFF3E5D8);

    final List<List<double>> currentFilters = _currentFilterSubTab == 0
        ? _leicaMatrices
        : _hasselbladMatrices;
    final List<String> currentNames = _filterNames[_currentFilterSubTab]!;

    final double currentGlow = _isCapturingRaw ? 0.0 : _glowBrightness;
    final double currentContrast = _isCapturingRaw ? 1.0 : _skinSmoothContrast;
    final double currentSat = _isCapturingRaw ? 1.0 : _popSaturation;
    final List<double> currentFilterMatrix = _isCapturingRaw
        ? [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]
        : currentFilters[_selectedFilterIndex];

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double topPadding = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (_selectedStickerId != null && !_isEditingText) {
          setState(() => _selectedStickerId = null);
        }
      },
      child: Scaffold(
        backgroundColor: studioBg,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // CANVAS CHÍNH
            Positioned(
              top: topPadding + 60,
              left: 0,
              right: 0,
              bottom: bottomPadding + (_isPanelVisible ? _panelHeight : 50),
              child: _buildMainCanvasStudio(
                currentGlow,
                currentContrast,
                currentSat,
                currentFilterMatrix,
              ),
            ),

            // PREMIUM HEADER
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              height: 60,
              child: _buildPremiumHeader(l10n, champagneAccent),
            ),

            // THÙNG RÁC THÔNG MINH TOÀN CHIỀU NGANG PHÍA TRÊN ĐẦU
            if (_isDraggingSticker) _buildTopTrashZone(l10n, topPadding),

            // CONTROL PANEL
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              bottom: _isPanelVisible ? 0 : -_panelHeight,
              left: 0,
              right: 0,
              height: _panelHeight + bottomPadding,
              child: _buildObsidianControlPanel(
                panelObsidian,
                l10n,
                champagneAccent,
                currentFilters,
                currentNames,
                bottomPadding,
              ),
            ),

            // NÚT ĐÓNG/MỞ PANEL
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              bottom:
                  bottomPadding + (_isPanelVisible ? _panelHeight - 16 : 15),
              right: 20,
              child: _buildPanelToggleButton(champagneAccent, panelObsidian),
            ),

            if (_isEditingText) _buildStoryEditorOverlay(champagneAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(AppLocalizations l10n, Color accent) {
    return Container(
      color: Colors.black.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: _historyIndex > 0 ? _undo : null,
                child: Icon(
                  CupertinoIcons.arrow_left,
                  color: _historyIndex > 0 ? Colors.white : Colors.white24,
                  size: 20,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _historyIndex < _history.length - 1 ? _redo : null,
                child: Icon(
                  CupertinoIcons.arrow_right,
                  color: _historyIndex < _history.length - 1
                      ? Colors.white
                      : Colors.white24,
                  size: 20,
                ),
              ),
            ],
          ),
          if (!_isDraggingSticker && _drawStartPoint == null)
            GestureDetector(
              onTap: _saveFinalImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.editPhotoDone.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── UI THÙNG RÁC MỚI (CHẮN HOÀN TOÀN TOP BAR - TRÁNH LỖI UX) ───
  Widget _buildTopTrashZone(AppLocalizations l10n, double topPadding) {
    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      height: 60,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isOverDeleteArea
              ? Colors.redAccent.withOpacity(0.95)
              : Colors.black.withOpacity(0.85),
          border: Border(
            bottom: BorderSide(
              color: _isOverDeleteArea ? Colors.white : Colors.white12,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOverDeleteArea
                  ? CupertinoIcons.trash_fill
                  : CupertinoIcons.trash,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              _isOverDeleteArea
                  ? l10n.stickerDeleteDrop
                  : l10n.stickerDeleteDrag,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCanvasStudio(
    double glow,
    double contrast,
    double sat,
    List<double> matrix,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                RepaintBoundary(
                  key: _globalKey,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(
                            _getBrightnessMatrix(glow),
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                              _getContrastMatrix(contrast),
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(
                                _getSaturationMatrix(sat),
                              ),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.matrix(matrix),
                                child: RotatedBox(
                                  quarterTurns: _rotationTurns,
                                  child: Image.file(
                                    File(_currentImagePath),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // LAYER ĐƯỜNG VẼ
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, pConstraints) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: RepaintBoundary(
                                key: _paintKey,
                                child: CustomPaint(
                                  painter: DrawingPainter(paths: _drawingPaths),
                                  size: Size(
                                    pConstraints.maxWidth,
                                    pConstraints.maxHeight,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // LAYER STICKERS
                      if (!_isCapturingRaw && _currentTab != 1)
                        Positioned.fill(
                          child: Stack(
                            children: _stickers
                                .map((stk) => _buildStickerWidget(stk))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // LAYER GESTURE ĐỂ VẼ TRÊN KHU VỰC ẢNH
                if (_currentTab == 4 &&
                    _currentDrawingMode != PaintingMode.none)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                    ),
                  ),

                if (_currentTab == 1)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, cropCtx) {
                        if (_cropWidth == 0 && cropCtx.maxWidth > 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _cropWidth = cropCtx.maxWidth;
                              _cropHeight = cropCtx.maxHeight;
                              _cropLeft = 0;
                              _cropTop = 0;
                            });
                          });
                        }
                        return _buildCleanCropGrid(
                          cropCtx.maxWidth,
                          cropCtx.maxHeight,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStickerWidget(StickerModel sticker) {
    final isSelected = sticker.id == _selectedStickerId;

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
              if (_currentTab == 4) return;
              HapticFeedback.selectionClick();
              setState(() => _selectedStickerId = sticker.id);
            },
            onDoubleTap: () {
              if (_currentTab == 4) return;
              if (sticker.type == StickerType.text)
                _openTextEditor(existingSticker: sticker);
            },
            onScaleStart: (details) {
              if (_currentTab == 4) return;
              setState(() {
                _selectedStickerId = sticker.id;
                _isDraggingSticker = true;
                _initialStickerScale = sticker.scale;
                _initialStickerRotation = sticker.rotation;
                _initialStickerOffset = sticker.offset;
                _initialFocalPoint = details.focalPoint;
              });
            },
            onScaleUpdate: (details) {
              if (!_isDraggingSticker) return;

              setState(() {
                sticker.offset =
                    _initialStickerOffset +
                    (details.focalPoint - _initialFocalPoint);
                if (details.scale != 1.0)
                  sticker.scale = (_initialStickerScale * details.scale).clamp(
                    0.3,
                    5.0,
                  );
                if (details.rotation != 0.0)
                  sticker.rotation = _initialStickerRotation + details.rotation;
              });

              // KIỂM TRA THÙNG RÁC TOP BAR (Nếu kéo sát vùng topPadding + 60px)
              final topPadding = MediaQuery.of(context).padding.top;
              bool isInTrashZone =
                  details.focalPoint.dy < (topPadding + 70); // <--- Lỗi ở đây

              if (isInTrashZone != _isOverDeleteArea) {
                setState(() => _isOverDeleteArea = isInTrashZone);
                if (isInTrashZone) HapticFeedback.vibrate();
              }
            },
            onScaleEnd: (details) {
              if (!_isDraggingSticker) return;
              setState(() => _isDraggingSticker = false);
              if (_isOverDeleteArea) {
                HapticFeedback.heavyImpact();
                setState(() {
                  _stickers.removeWhere((s) => s.id == sticker.id);
                  _selectedStickerId = null;
                  _isOverDeleteArea = false;
                });
              }
              _saveStateToHistory();
            },
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (sticker.type == StickerType.icon)
                      Text(
                        sticker.value,
                        style: const TextStyle(
                          fontSize: 45,
                          decoration: TextDecoration.none,
                        ),
                      )
                    else
                      Stack(
                        children: [
                          if (sticker.hasBackground)
                            Text(
                              sticker.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                background: Paint()
                                  ..color = sticker.backgroundColor.withOpacity(
                                    0.6,
                                  )
                                  ..strokeWidth = 20
                                  ..strokeJoin = StrokeJoin.round
                                  ..strokeCap = StrokeCap.round
                                  ..style = PaintingStyle.stroke,
                                decoration: TextDecoration.none,
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
                      ),

                    if (isSelected &&
                        !_isDraggingSticker &&
                        _currentTab != 4) ...[
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white70, width: 1),
                            borderRadius: BorderRadius.circular(8),
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

  Widget _buildDotHandle() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 2),
        ],
      ),
    );
  }

  Widget _buildObsidianControlPanel(
    Color bg,
    AppLocalizations l10n,
    Color accent,
    List<List<double>> filters,
    List<String> names,
    double bottomPadding,
  ) {
    return Container(
      padding: EdgeInsets.only(top: 12, bottom: bottomPadding + 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentTab == 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_drawingPaths.isEmpty) return;
                      HapticFeedback.warningNotification();
                      setState(() => _drawingPaths.clear());
                      _saveStateToHistory();
                    },
                    child: Text(
                      "XÓA TẤT CẢ",
                      style: TextStyle(
                        color: _drawingPaths.isNotEmpty
                            ? accent
                            : Colors.white24,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: _buildDynamicTabsContent(l10n, accent, filters, names),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          _buildBottomTabBar(l10n, accent),
        ],
      ),
    );
  }

  Widget _buildPanelToggleButton(Color accent, Color bg) {
    return FloatingActionButton.small(
      elevation: 2,
      backgroundColor: _isPanelVisible ? accent : const Color(0xFF202025),
      foregroundColor: _isPanelVisible ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Icon(
        _isPanelVisible
            ? CupertinoIcons.chevron_down
            : CupertinoIcons.slider_horizontal_3,
        size: 18,
      ),
      onPressed: () => setState(() => _isPanelVisible = !_isPanelVisible),
    );
  }

  Widget _buildDynamicTabsContent(
    AppLocalizations l10n,
    Color accent,
    List<List<double>> filters,
    List<String> names,
  ) {
    switch (_currentTab) {
      case 0:
        return _buildFilterTab(accent, filters, names);
      case 1:
        return _buildCropTab(l10n, accent);
      case 2:
        return _buildBeautyTab(accent);
      case 3:
        return _buildStickerTab(accent);
      case 4:
        return _buildDrawTab(accent);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilterTab(
    Color accent,
    List<List<double>> filters,
    List<String> names,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStudioSubTab(0, "PORTRAIT", accent),
            const SizedBox(width: 30),
            _buildStudioSubTab(1, "AESTHETIC", accent),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, idx) {
              final isSel = _selectedFilterIndex == idx;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFilterIndex = idx);
                  _saveStateToHistory();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? accent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(filters[idx]),
                              child: Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        names[idx],
                        style: TextStyle(
                          color: isSel ? accent : Colors.white54,
                          fontSize: 9,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCropTab(AppLocalizations l10n, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStudioCropButton(
                CupertinoIcons.rotate_right,
                "XOAY ẢNH",
                accent,
                () {
                  setState(() {
                    _rotationTurns = (_rotationTurns + 1) % 4;
                    _cropWidth = 0;
                  });
                },
              ),
              const SizedBox(width: 30),
              _buildStudioCropButton(
                CupertinoIcons.refresh,
                "ĐẶT LẠI",
                accent,
                () {
                  setState(() {
                    _rotationTurns = 0;
                    _cropWidth = 0;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            l10n.cropInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautyTab(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMinimalSlider(
            "ĐỘ SÁNG",
            CupertinoIcons.sun_max,
            _glowBrightness,
            -40,
            40,
            accent,
            (v) => setState(() => _glowBrightness = v),
          ),
          _buildMinimalSlider(
            "ĐỘ MỊN",
            CupertinoIcons.drop,
            _skinSmoothContrast,
            0.6,
            1.4,
            accent,
            (v) => setState(() => _skinSmoothContrast = v),
          ),
          _buildMinimalSlider(
            "NỔI BẬT",
            CupertinoIcons.sparkles,
            _popSaturation,
            0.5,
            1.8,
            accent,
            (v) => setState(() => _popSaturation = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerTab(Color accent) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () => _openTextEditor(),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.textformat, color: accent, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    "THÊM VĂN BẢN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _iconsStorage.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _addIconSticker(_iconsStorage[index]),
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                child: Text(
                  _iconsStorage[index],
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── UI DRAW TAB HOÀN CHỈNH ───
  Widget _buildDrawTab(Color accent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDrawToolsBtn(
              PaintingMode.free,
              CupertinoIcons.pencil,
              "CỌ VẼ",
              accent,
            ),
            const SizedBox(width: 15),
            _buildDrawToolsBtn(
              PaintingMode.rect,
              CupertinoIcons.square,
              "KHUNG VUÔNG",
              accent,
            ),
            const SizedBox(width: 15),
            _buildDrawToolsBtn(
              PaintingMode.circle,
              CupertinoIcons.circle,
              "KHANH TRÒN",
              accent,
            ),
            const SizedBox(width: 15),
            _buildDrawToolsBtn(
              PaintingMode.eraser,
              CupertinoIcons.xmark_circle,
              "CỤC TẨY",
              accent,
            ),
          ],
        ),

        const SizedBox(height: 15),

        if (_currentDrawingMode != PaintingMode.none)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.circle_fill,
                      color: Colors.white24,
                      size: _currentStopWidth.clamp(6.0, 20.0),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          activeTrackColor: accent,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7.0,
                          ),
                        ),
                        child: Slider(
                          value: _currentStopWidth,
                          min: 1.0,
                          max: 20.0,
                          onChanged: (v) =>
                              setState(() => _currentStopWidth = v),
                        ),
                      ),
                    ),
                    Text(
                      "${_currentStopWidth.toInt()}px",
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (_currentDrawingMode != PaintingMode.eraser)
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _paintColors.length,
                      itemBuilder: (context, idx) {
                        final color = _paintColors[idx];
                        final isSel = _currentPaintColor == color;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _currentPaintColor = color),
                          child: Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.white24,
                                width: isSel ? 2 : 1,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 5,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "CHỌN CÔNG CỤ ĐỂ BẮT ĐẦU VẼ",
              style: TextStyle(
                color: Colors.white24,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDrawToolsBtn(
    PaintingMode mode,
    IconData icon,
    String label,
    Color accent,
  ) {
    final bool isSel = _currentDrawingMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentDrawingMode = mode);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSel ? accent : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? Colors.white24 : Colors.transparent,
              ),
            ),
            child: Icon(
              icon,
              color: isSel ? Colors.black : Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSel ? accent : Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioSubTab(int index, String title, Color accent) {
    final bool active = _currentFilterSubTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _currentFilterSubTab = index;
        _selectedFilterIndex = 0;
      }),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: active ? accent : Colors.white30,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: active ? 18 : 0,
            color: accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStudioCropButton(
    IconData icon,
    String label,
    Color accent,
    VoidCallback tap,
  ) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalSlider(
    String label,
    IconData icon,
    double val,
    double min,
    double max,
    Color accent,
    ValueChanged<double> onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 14),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 1.5,
                activeTrackColor: accent,
                inactiveTrackColor: Colors.white.withOpacity(0.03),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.0,
                ),
              ),
              child: Slider(
                value: val,
                min: min,
                max: max,
                onChanged: onChange,
                onChangeEnd: (v) => _saveStateToHistory(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTabBar(AppLocalizations l10n, Color accent) {
    if (_currentTab == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _currentTab = 0;
                _cropWidth = 0;
              }),
              child: const Text(
                "HỦY",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            GestureDetector(
              onTap: _applyCrop,
              child: Text(
                "CẮT ẢNH",
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentTab == 4 && _currentDrawingMode != PaintingMode.none) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _currentDrawingMode = PaintingMode.none;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "HOÀN THÀNH VẼ",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainTabItem(0, "BỘ LỌC", accent),
          _buildMainTabItem(1, "CẮT & XOAY", accent),
          _buildMainTabItem(2, "TINH CHỈNH", accent),
          _buildMainTabItem(3, "STICKER", accent),
          _buildMainTabItem(4, "VẼ / NOTES", accent),
        ],
      ),
    );
  }

  Widget _buildMainTabItem(int index, String label, Color accent) {
    final isSel = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _currentTab = index;
        if (index != 3) _selectedStickerId = null;
        if (index != 4) _currentDrawingMode = PaintingMode.none;
      }),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.white : Colors.white30,
                fontSize: 9,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSel ? accent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTextEditor({StickerModel? existingSticker}) {
    HapticFeedback.lightImpact();
    setState(() {
      _isEditingText = true;
      if (existingSticker != null) {
        _editingStickerId = existingSticker.id;
        _textStickerController.text = existingSticker.value;
        _currentTextColor = existingSticker.textColor;
        _currentTextBgColor = existingSticker.backgroundColor;
        _currentTextHasBg = existingSticker.hasBackground;
      } else {
        _editingStickerId = null;
        _textStickerController.clear();
        _currentTextColor = Colors.white;
        _currentTextBgColor = Colors.black;
        _currentTextHasBg = true;
      }
    });
    _textStickerFocusNode.requestFocus();
  }

  void _finishTextEditing() {
    setState(() {
      _isEditingText = false;
      String text = _textStickerController.text.trim();
      if (text.isEmpty) {
        if (_editingStickerId != null)
          _stickers.removeWhere((s) => s.id == _editingStickerId);
      } else {
        if (_editingStickerId != null) {
          final idx = _stickers.indexWhere((s) => s.id == _editingStickerId);
          if (idx != -1) {
            _stickers[idx].value = text;
            _stickers[idx].textColor = _currentTextColor;
            _stickers[idx].backgroundColor = _currentTextBgColor;
            _stickers[idx].hasBackground = _currentTextHasBg;
            _selectedStickerId = _editingStickerId;
          }
        } else {
          _stickers.add(
            StickerModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: StickerType.text,
              value: text,
              textColor: _currentTextColor,
              backgroundColor: _currentTextBgColor,
              hasBackground: _currentTextHasBg,
            ),
          );
          _selectedStickerId = _stickers.last.id;
        }
      }
    });
    _textStickerFocusNode.unfocus();
    _saveStateToHistory();
  }

  Widget _buildStoryEditorOverlay(Color accent) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(
                        () => _currentTextHasBg = !_currentTextHasBg,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _currentTextHasBg
                              ? Colors.white
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          "A",
                          style: TextStyle(
                            color: _currentTextHasBg
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _finishTextEditing,
                      child: Text(
                        "XONG",
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: IntrinsicWidth(
                      child: TextField(
                        focusNode: _textStickerFocusNode,
                        controller: _textStickerController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        cursorColor: accent,
                        maxLines: null,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _currentTextColor,
                          fontSize: 28,
                          height: 1.2,
                          background: _currentTextHasBg
                              ? (Paint()
                                  ..color = _currentTextBgColor.withOpacity(0.6)
                                  ..strokeWidth = 20
                                  ..strokeJoin = StrokeJoin.round
                                  ..strokeCap = StrokeCap.round
                                  ..style = PaintingStyle.stroke)
                              : null,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.stickerTextHint,
                          hintStyle: const TextStyle(color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 45,
                margin: const EdgeInsets.only(bottom: 30),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children:
                      [
                        Colors.white,
                        Colors.black,
                        const Color(0xFFF3E5D8),
                        Colors.redAccent,
                        Colors.orangeAccent,
                        Colors.yellowAccent,
                        Colors.greenAccent,
                        Colors.blueAccent,
                        Colors.purpleAccent,
                      ].map((color) {
                        bool isSel = _currentTextHasBg
                            ? (_currentTextBgColor == color)
                            : (_currentTextColor == color);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (_currentTextHasBg)
                              _currentTextBgColor = color;
                            else
                              _currentTextColor = color;
                          }),
                          child: Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? accent : Colors.white24,
                                width: isSel ? 2 : 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIconSticker(String icon) {
    HapticFeedback.lightImpact();
    setState(() {
      _stickers.add(
        StickerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: StickerType.icon,
          value: icon,
        ),
      );
      _selectedStickerId = _stickers.last.id;
    });
    _saveStateToHistory();
  }

  Widget _buildCleanCropGrid(double maxWidth, double maxHeight) {
    const Color gridAccent = Colors.white;
    return Stack(
      children: [
        CustomPaint(
          size: Size(maxWidth, maxHeight),
          painter: CropOverlayPainter(
            cropRect: Rect.fromLTWH(
              _cropLeft,
              _cropTop,
              _cropWidth,
              _cropHeight,
            ),
          ),
        ),
        Positioned(
          left: _cropLeft,
          top: _cropTop,
          width: _cropWidth,
          height: _cropHeight,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                double newLeft = _cropLeft + details.delta.dx;
                double newTop = _cropTop + details.delta.dy;
                if (newLeft >= 0 && newLeft + _cropWidth <= maxWidth)
                  _cropLeft = newLeft;
                if (newTop >= 0 && newTop + _cropHeight <= maxHeight)
                  _cropTop = newTop;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: gridAccent, width: 1.0),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(width: 0.5, color: Colors.white38),
                      Container(width: 0.5, color: Colors.white38),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(height: 0.5, color: Colors.white38),
                      Container(height: 0.5, color: Colors.white38),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildCropCorner(_cropLeft - 10, _cropTop - 10, gridAccent, (d) {
          double newL = _cropLeft + d.dx;
          double newT = _cropTop + d.dy;
          double newW = _cropWidth - d.dx;
          double newH = _cropHeight - d.dy;
          if (newW >= _minCropSize && newL >= 0) {
            _cropLeft = newL;
            _cropWidth = newW;
          }
          if (newH >= _minCropSize && newT >= 0) {
            _cropTop = newT;
            _cropHeight = newH;
          }
        }),
        _buildCropCorner(
          _cropLeft + _cropWidth - 10,
          _cropTop - 10,
          gridAccent,
          (d) {
            double newT = _cropTop + d.dy;
            double newW = _cropWidth + d.dx;
            double newH = _cropHeight - d.dy;
            if (newW >= _minCropSize && _cropLeft + newW <= maxWidth)
              _cropWidth = newW;
            if (newH >= _minCropSize && newT >= 0) {
              _cropTop = newT;
              _cropHeight = newH;
            }
          },
        ),
        _buildCropCorner(
          _cropLeft - 10,
          _cropTop + _cropHeight - 10,
          gridAccent,
          (d) {
            double newL = _cropLeft + d.dx;
            double newW = _cropWidth - d.dx;
            double newH = _cropHeight + d.dy;
            if (newW >= _minCropSize && newL >= 0) {
              _cropLeft = newL;
              _cropWidth = newW;
            }
            if (newH >= _minCropSize && _cropTop + newH <= maxHeight)
              _cropHeight = newH;
          },
        ),
        _buildCropCorner(
          _cropLeft + _cropWidth - 10,
          _cropTop + _cropHeight - 10,
          gridAccent,
          (d) {
            double newW = _cropWidth + d.dx;
            double newH = _cropHeight + d.dy;
            if (newW >= _minCropSize && _cropLeft + newW <= maxWidth)
              _cropWidth = newW;
            if (newH >= _minCropSize && _cropTop + newH <= maxHeight)
              _cropHeight = newH;
          },
        ),
      ],
    );
  }

  Widget _buildCropCorner(
    double left,
    double top,
    Color accent,
    Function(Offset) onPan,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => onPan(details.delta)),
        child: Container(
          width: 25,
          height: 25,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: accent, width: 3),
                left: BorderSide(color: accent, width: 3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _applyCrop() async {
    HapticFeedback.heavyImpact();
    setState(() => _isCapturingRaw = true);
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image fullImage = await boundary.toImage(pixelRatio: 3.0);

      double scaleX = fullImage.width / boundary.size.width;
      double scaleY = fullImage.height / boundary.size.height;

      Rect cropRectPixel = Rect.fromLTWH(
        _cropLeft * scaleX,
        _cropTop * scaleY,
        _cropWidth * scaleX,
        _cropHeight * scaleY,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..filterQuality = ui.FilterQuality.high;

      canvas.drawImageRect(
        fullImage,
        cropRectPixel,
        Rect.fromLTWH(0, 0, cropRectPixel.width, cropRectPixel.height),
        paint,
      );

      final croppedUiImage = await recorder.endRecording().toImage(
        cropRectPixel.width.toInt(),
        cropRectPixel.height.toInt(),
      );

      ByteData? byteData = await croppedUiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      fullImage.dispose();
      croppedUiImage.dispose();

      setState(() {
        _currentImagePath = file.path;
        _cropWidth = 0;
        _rotationTurns = 0;
        _stickers.clear();
        _drawingPaths.clear();
        _isCapturingRaw = false;
        _currentTab = 0;
      });
      _saveStateToHistory();
    } catch (e) {
      setState(() => _isCapturingRaw = false);
      debugPrint("Crop error: $e");
    }
  }

  Future<void> _saveFinalImage() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _selectedStickerId = null;
      _isCapturingRaw = true;
      _currentDrawingMode = PaintingMode.none;
    });
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/final_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      image.dispose();

      if (mounted) Navigator.pop(context, file.path);
    } catch (e) {
      setState(() => _isCapturingRaw = false);
      debugPrint("Save error: $e");
    }
  }

  final List<List<double>> _leicaMatrices = [
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    [1.1, 0, 0, 0, 5, 0, 1.02, 0, 0, 3, 0, 0, 0.95, 0, -2, 0, 0, 0, 1, 0],
    [
      1.0,
      -0.05,
      0,
      0,
      10,
      0,
      1.0,
      -0.05,
      0,
      10,
      0,
      0,
      1.0,
      0,
      20,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      1.1,
      0.05,
      -0.1,
      0,
      -5,
      0.05,
      1.0,
      0.05,
      0,
      -2,
      -0.1,
      0.05,
      1.2,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      0.21,
      0.71,
      0.07,
      0,
      0,
      0.21,
      0.71,
      0.07,
      0,
      0,
      0.21,
      0.71,
      0.07,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
  ];

  final List<List<double>> _hasselbladMatrices = [
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    [
      1.2,
      0.1,
      -0.1,
      0,
      0,
      0.1,
      1.1,
      0.1,
      0,
      0,
      -0.1,
      0.1,
      1.0,
      0,
      5,
      0,
      0,
      0,
      1,
      0,
    ],
    [1.05, 0, 0, 0, 15, 0, 1.0, 0, 0, 10, 0, 0, 0.85, 0, -10, 0, 0, 0, 1, 0],
    [
      0.9,
      0.1,
      0.2,
      0,
      10,
      0.1,
      1.2,
      0.1,
      0,
      15,
      0.2,
      0.1,
      1.1,
      0,
      10,
      0,
      0,
      0,
      1,
      0,
    ],
  ];

  List<double> _getBrightnessMatrix(double value) => [
    1,
    0,
    0,
    0,
    value,
    0,
    1,
    0,
    0,
    value,
    0,
    0,
    1,
    0,
    value,
    0,
    0,
    0,
    1,
    0,
  ];
  List<double> _getContrastMatrix(double scale) {
    final t = 128.0 * (1.0 - scale);
    return [
      scale,
      0,
      0,
      0,
      t,
      0,
      scale,
      0,
      0,
      t,
      0,
      0,
      scale,
      0,
      t,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  List<double> _getSaturationMatrix(double sat) {
    final inv = 1.0 - sat;
    final r = 0.213 * inv;
    final g = 0.715 * inv;
    final b = 0.072 * inv;
    return [
      r + sat,
      g,
      b,
      0,
      0,
      r,
      g + sat,
      b,
      0,
      0,
      r,
      g,
      b + sat,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

// ─── CUSTOM PAINTERS ───
class DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;
  DrawingPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    // saveLayer giúp tách biệt hiệu ứng tẩy (BlendMode.clear) không ăn ra nền đen của App
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (var path in paths) {
      if (path.mode == PaintingMode.free || path.mode == PaintingMode.eraser) {
        if (path.points.isEmpty) continue;
        final drawPath = Path();
        bool firstPoint = true;

        for (int i = 0; i < path.points.length; i++) {
          final point = path.points[i];
          if (point == null) {
            // Kết thúc nét vẽ
          } else if (firstPoint) {
            drawPath.moveTo(point.dx, point.dy);
            firstPoint = false;
          } else {
            drawPath.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(drawPath, path.paint);
      } else if (path.mode == PaintingMode.rect && path.rect != null) {
        canvas.drawRect(path.rect!, path.paint);
      } else if (path.mode == PaintingMode.circle && path.rect != null) {
        canvas.drawOval(path.rect!, path.paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter old) => true;
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
