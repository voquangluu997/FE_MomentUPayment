import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/features/camera/models/editor_models.dart';
import 'package:moment_u_payment/features/camera/widgets/editor_painters.dart';
import 'package:moment_u_payment/features/camera/widgets/sticker_widget.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

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

  // Tabs: 0: Filter, 1: Crop, 2: Beauty, 3: Emojis/Badges, 4: Ghi chú (Draw, Shapes, Text, v.v)
  int _currentTab = 0;
  bool _isPanelVisible = true;
  final double _panelHeight =
      220.0; // Thu gọn Panel lại vì các nút vẽ đã chuyển lên trên

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

  List<DrawingPath> _drawingPaths = [];
  PaintingMode _currentDrawingMode =
      PaintingMode.none; // Khi = none là chế độ chọn/di chuyển
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
      2: ["FILM ORIG", "C-CHROME", "K-GOLD", "VELVIA"],
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
    return Paint()
      ..color = _currentDrawingMode == PaintingMode.eraser
          ? Colors.white
          : (_currentDrawingMode == PaintingMode.blur
                ? Colors.white24
                : _currentPaintColor)
      ..strokeWidth = _currentDrawingMode == PaintingMode.blur
          ? _currentStopWidth * 2
          : _currentStopWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = _currentDrawingMode == PaintingMode.eraser
          ? BlendMode.clear
          : BlendMode.srcOver;
  }

  void _onPanStart(DragStartDetails details) {
    if (_currentTab != 4 || _currentDrawingMode == PaintingMode.none) return;
    HapticFeedback.lightImpact();
    final RenderBox renderBox =
        _paintKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _drawStartPoint = localPosition;

    setState(() {
      _drawingPaths.add(
        DrawingPath(
          points: [localPosition],
          paint: _getCurrentPaint(),
          mode: _currentDrawingMode,
          startPoint: localPosition,
          endPoint: localPosition,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentTab != 4 ||
        _currentDrawingMode == PaintingMode.none ||
        _drawStartPoint == null) {
      return;
    }
    final RenderBox renderBox =
        _paintKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      if (_currentDrawingMode == PaintingMode.free ||
          _currentDrawingMode == PaintingMode.eraser) {
        _drawingPaths.last.points.add(localPosition);
      } else {
        _drawingPaths.last = DrawingPath(
          points: [],
          paint: _drawingPaths.last.paint,
          mode: _currentDrawingMode,
          startPoint: _drawStartPoint,
          endPoint: localPosition,
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
      } else if (_drawingPaths.isNotEmpty) {
        final path = _drawingPaths.removeLast();
        if (path.startPoint != null && path.endPoint != null) {
          final A = path.startPoint!;
          final B = path.endPoint!;
          final length = (B - A).distance;

          if (length > 10) {
            if (_currentDrawingMode == PaintingMode.arrow) {
              final center = Offset((A.dx + B.dx) / 2, (A.dy + B.dy) / 2);
              final size = Size(length, _currentStopWidth * 6);
              final offset = Offset(
                center.dx - size.width / 2,
                center.dy - size.height / 2,
              );
              final angle = math.atan2(B.dy - A.dy, B.dx - A.dx);

              _stickers.add(
                StickerModel(
                  id: DateTime.now().toString(),
                  type: StickerType.arrow,
                  value: "",
                  offset: offset,
                  size: size,
                  rotation: angle,
                  textColor: _currentPaintColor,
                  strokeWidth: _currentStopWidth,
                ),
              );
            } else {
              final rect = Rect.fromPoints(A, B);
              StickerType type = StickerType.rect;
              if (_currentDrawingMode == PaintingMode.circle) {
                type = StickerType.circle;
              }
              if (_currentDrawingMode == PaintingMode.blur) {
                type = StickerType.blur;
              }

              _stickers.add(
                StickerModel(
                  id: DateTime.now().toString(),
                  type: type,
                  value: "",
                  offset: rect.topLeft,
                  size: rect.size,
                  textColor: _currentPaintColor,
                  strokeWidth: _currentStopWidth,
                ),
              );
            }
            _selectedStickerId = _stickers.last.id;
          }
        }
        // ĐÃ XÓA _currentDrawingMode = none Ở ĐÂY ĐỂ GIỮ NGUYÊN CÔNG CỤ VẼ
      }
      _drawStartPoint = null;
    });
    _saveStateToHistory();
  }

  void _openTab(int tabIndex, PaintingMode mode) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentTab = tabIndex;
      _currentDrawingMode = mode;
      _selectedStickerId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const Color studioBg = Color(0xFF050507);
    const Color panelObsidian = Color(0xFF0F0F11);
    const Color champagneAccent = Color(0xFFF3E5D8);

    final List<List<double>> currentFilters = _currentFilterSubTab == 0
        ? _leicaMatrices
        : (_currentFilterSubTab == 1 ? _hasselbladMatrices : _fujifilmMatrices);
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
            // CANVAS
            Positioned(
              top: topPadding + 60,
              left: 0,
              right: 0,
              bottom: bottomPadding + (_isPanelVisible ? _panelHeight : 60),
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

            // TRASH ZONE
            if (_isDraggingSticker) _buildTopTrashZone(l10n, topPadding),

            // ─── TOOLBAR DỌC BÊN PHẢI (CHỈ HIỆN Ở TAB GHI CHÚ) ───
            if (_currentTab == 4 && !_isCapturingRaw)
              Positioned(
                top: topPadding + 80,
                right: 12,
                child: _buildVerticalToolbar(champagneAccent),
              ),

            // ─── CÀI ĐẶT MÀU SẮC & CỌ (CHỈ HIỆN KHI ĐANG CHỌN CÔNG CỤ VẼ) ───
            if (_currentTab == 4 &&
                !_isCapturingRaw &&
                _currentDrawingMode != PaintingMode.none)
              Positioned(
                bottom:
                    bottomPadding + (_isPanelVisible ? _panelHeight + 10 : 80),
                left: 16,
                right: 50, // Tránh đè lên toolbar dọc
                child: _buildDrawingSettings(champagneAccent),
              ),

            // CONTROL PANEL (MỚI - GỌN GÀNG HƠN)
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

            // NÚT ĐÓNG MỞ PANEL
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              bottom:
                  bottomPadding + (_isPanelVisible ? _panelHeight - 16 : 25),
              right: 20,
              child: _buildPanelToggleButton(champagneAccent, panelObsidian),
            ),

            // OVERLAY CHỮ
            if (_isEditingText) _buildStoryEditorOverlay(champagneAccent),
          ],
        ),
      ),
    );
  }

  // ─── THANH CÔNG CỤ DỌC BÊN PHẢI (MỚI) ───
  Widget _buildVerticalToolbar(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVerticalToolBtn(
            CupertinoIcons.hand_draw,
            PaintingMode.none,
            "CHỌN",
            accent,
          ),
          _buildVerticalDivider(),
          _buildVerticalToolBtn(
            CupertinoIcons.pencil,
            PaintingMode.free,
            "VẼ",
            accent,
          ),
          _buildVerticalToolBtn(
            CupertinoIcons.arrow_up_right,
            PaintingMode.arrow,
            "MŨI TÊN",
            accent,
          ),
          _buildVerticalToolBtn(
            CupertinoIcons.square,
            PaintingMode.rect,
            "VUÔNG",
            accent,
          ),
          _buildVerticalToolBtn(
            CupertinoIcons.circle,
            PaintingMode.circle,
            "TRÒN",
            accent,
          ),
          _buildVerticalToolBtn(
            CupertinoIcons.drop_fill,
            PaintingMode.blur,
            "CHE MỜ",
            accent,
          ),
          _buildVerticalDivider(),
          // Các tính năng add liền (Text, Kính Lúp)
          _buildActionToolBtn(CupertinoIcons.textformat, "CHỮ", accent, () {
            setState(
              () => _currentDrawingMode = PaintingMode.none,
            ); // Chuyển về con trỏ
            _openTextEditor();
          }),
          _buildActionToolBtn(
            CupertinoIcons.search_circle,
            "KÍNH LÚP",
            accent,
            () {
              HapticFeedback.selectionClick();
              setState(() {
                _stickers.add(
                  StickerModel(
                    id: DateTime.now().toString(),
                    type: StickerType.magnifier,
                    value: "",
                  ),
                );
                _selectedStickerId = _stickers.last.id;
                _currentDrawingMode =
                    PaintingMode.none; // Trở về con trỏ để di chuyển ngay
              });
            },
          ),
          _buildVerticalDivider(),
          _buildVerticalToolBtn(
            CupertinoIcons.xmark_circle,
            PaintingMode.eraser,
            "TẨY NÉT",
            accent,
          ),
          // Nút Xóa tất cả nét vẽ tự do
          if (_drawingPaths.isNotEmpty) ...[
            _buildVerticalDivider(),
            _buildActionToolBtn(
              CupertinoIcons.trash,
              "XÓA HẾT",
              Colors.redAccent,
              () {
                HapticFeedback.warningNotification();
                setState(() => _drawingPaths.clear());
                _saveStateToHistory();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalToolBtn(
    IconData icon,
    PaintingMode mode,
    String label,
    Color accent,
  ) {
    bool isActive = _currentDrawingMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _currentDrawingMode = mode;
          _selectedStickerId = null;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Icon(icon, color: isActive ? accent : Colors.white54, size: 24),
      ),
    );
  }

  Widget _buildActionToolBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Icon(icon, color: color.withValues(alpha: 0.8), size: 24),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 20,
      height: 1,
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }

  // ─── CÀI ĐẶT CỌ VẼ NỔI Ở ĐÁY ẢNH (MỚI) ───
  Widget _buildDrawingSettings(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slider kích cỡ
          Row(
            children: [
              Icon(CupertinoIcons.circle_fill, color: Colors.white24, size: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    activeTrackColor: accent,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _currentStopWidth,
                    min: 1.0,
                    max: 20.0,
                    onChanged: (v) => setState(() => _currentStopWidth = v),
                  ),
                ),
              ),
              Icon(CupertinoIcons.circle_fill, color: Colors.white24, size: 16),
            ],
          ),
          // Bảng màu (Ẩn đi nếu dùng Tẩy hoặc Che mờ)
          if (_currentDrawingMode != PaintingMode.eraser &&
              _currentDrawingMode != PaintingMode.blur) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 25,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _paintColors.length,
                itemBuilder: (context, idx) {
                  final color = _paintColors[idx];
                  final isSel = _currentPaintColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _currentPaintColor = color),
                    child: Container(
                      width: 25,
                      height: 25,
                      margin: const EdgeInsets.only(right: 10),
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
                                  color: color.withValues(alpha: 0.5),
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
        ],
      ),
    );
  }

  // --- CÁC HÀM XÂY DỰNG UI CÒN LẠI ---

  Widget _buildPremiumHeader(AppLocalizations l10n, Color accent) {
    return Container(
      color: Colors.black.withValues(alpha: 0.2),
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
              ? Colors.redAccent.withValues(alpha: 0.95)
              : Colors.black.withValues(alpha: 0.85),
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
                      if (!_isCapturingRaw && _currentTab != 1)
                        Positioned.fill(
                          child: Stack(
                            children: _stickers.map((stk) {
                              return StickerWidget(
                                sticker: stk,
                                isSelected: stk.id == _selectedStickerId,
                                isDraggingSticker: _isDraggingSticker,
                                currentDrawingMode:
                                    _currentDrawingMode, // GỬI MODE VẼ THAY VÌ TAB
                                onTap: () =>
                                    setState(() => _selectedStickerId = stk.id),
                                onDoubleTap: () =>
                                    _openTextEditor(existingSticker: stk),
                                onScaleStart: (details) {
                                  setState(() {
                                    _selectedStickerId = stk.id;
                                    _isDraggingSticker = true;
                                    _initialStickerScale = stk.scale;
                                    _initialStickerRotation = stk.rotation;
                                    _initialStickerOffset = stk.offset;
                                    _initialFocalPoint = details.focalPoint;
                                  });
                                },
                                onScaleUpdate: (details) {
                                  if (!_isDraggingSticker) return;
                                  setState(() {
                                    stk.offset =
                                        _initialStickerOffset +
                                        (details.focalPoint -
                                            _initialFocalPoint);
                                    if (details.scale != 1.0) {
                                      stk.scale =
                                          (_initialStickerScale * details.scale)
                                              .clamp(0.3, 5.0);
                                    }
                                    if (details.rotation != 0.0) {
                                      stk.rotation =
                                          _initialStickerRotation +
                                          details.rotation;
                                    }
                                  });
                                  final topPadding = MediaQuery.of(
                                    context,
                                  ).padding.top;
                                  bool isInTrashZone =
                                      details.focalPoint.dy < (topPadding + 70);
                                  if (isInTrashZone != _isOverDeleteArea) {
                                    setState(
                                      () => _isOverDeleteArea = isInTrashZone,
                                    );
                                    if (isInTrashZone) HapticFeedback.vibrate();
                                  }
                                },
                                onScaleEnd: (details) {
                                  if (!_isDraggingSticker) return;
                                  setState(() => _isDraggingSticker = false);
                                  if (_isOverDeleteArea) {
                                    HapticFeedback.heavyImpact();
                                    setState(() {
                                      _stickers.removeWhere(
                                        (s) => s.id == stk.id,
                                      );
                                      _selectedStickerId = null;
                                      _isOverDeleteArea = false;
                                    });
                                  }
                                  _saveStateToHistory();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                // LỚP CHẶN SỰ KIỆN VẼ CHỈ HOẠT ĐỘNG KHI ĐÃ CHỌN CÔNG CỤ VẼ
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
        // Khi ở Tab Ghi chú, Nội dung ở Bottom Panel được thu gọn vì đã chuyển lên Toolbar dọc
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Text(
            "HÃY SỬ DỤNG THANH CÔNG CỤ BÊN CẠNH ẢNH",
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // --- FILTER, CROP, BEAUTY TABS ---
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
            const SizedBox(width: 25),
            _buildStudioSubTab(1, "AESTHETIC", accent),
            const SizedBox(width: 25),
            _buildStudioSubTab(2, "FILM GRAIN", accent),
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
    final List<String> badges = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "✓",
      "✗",
      "!",
    ];
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "CHỌN STICKER ĐỂ CHÈN NHANH",
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: badges.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _stickers.add(
                    StickerModel(
                      id: DateTime.now().toString(),
                      type: StickerType.badge,
                      value: badges[index],
                      backgroundColor: accent,
                      textColor: Colors.black,
                    ),
                  );
                });
              },
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badges[index],
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _iconsStorage.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _stickers.add(
                    StickerModel(
                      id: DateTime.now().toString(),
                      type: StickerType.icon,
                      value: _iconsStorage[index],
                    ),
                  );
                  _selectedStickerId = _stickers.last.id;
                });
                _saveStateToHistory();
              },
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

  // --- TIỆN ÍCH DƯỚI ĐÁY TỐI GIẢN CHỈ CÒN CÁC TAB CHÍNH ---
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

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainTabItem(0, "BỘ LỌC", CupertinoIcons.color_filter, accent),
          _buildMainTabItem(1, "CẮT ẢNH", CupertinoIcons.crop, accent),
          _buildMainTabItem(
            2,
            "LÀM ĐẸP",
            CupertinoIcons.slider_horizontal_3,
            accent,
          ),
          _buildMainTabItem(3, "STICKER", CupertinoIcons.smiley, accent),
          _buildMainTabItem(
            4,
            "GHI CHÚ",
            CupertinoIcons.pencil_outline,
            accent,
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabItem(
    int index,
    String label,
    IconData icon,
    Color accent,
  ) {
    bool isSel = _currentTab == index;
    return GestureDetector(
      onTap: () => _openTab(index, PaintingMode.none),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSel ? accent : Colors.white54, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSel ? accent : Colors.white30,
              fontSize: 9,
              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // CÁC HÀM TIỆN ÍCH KHÁC GIỮ NGUYÊN
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
              color: Colors.white.withValues(alpha: 0.04),
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
                inactiveTrackColor: Colors.white.withValues(alpha: 0.03),
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
        if (_editingStickerId != null) {
          _stickers.removeWhere((s) => s.id == _editingStickerId);
        }
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
                                  ..color = _currentTextBgColor.withValues(
                                    alpha: 0.6,
                                  )
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
                            if (_currentTextHasBg) {
                              _currentTextBgColor = color;
                            } else {
                              _currentTextColor = color;
                            }
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
                if (newLeft >= 0 && newLeft + _cropWidth <= maxWidth) {
                  _cropLeft = newLeft;
                }
                if (newTop >= 0 && newTop + _cropHeight <= maxHeight) {
                  _cropTop = newTop;
                }
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
            if (newW >= _minCropSize && _cropLeft + newW <= maxWidth) {
              _cropWidth = newW;
            }
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
            if (newH >= _minCropSize && _cropTop + newH <= maxHeight) {
              _cropHeight = newH;
            }
          },
        ),
        _buildCropCorner(
          _cropLeft + _cropWidth - 10,
          _cropTop + _cropHeight - 10,
          gridAccent,
          (d) {
            double newW = _cropWidth + d.dx;
            double newH = _cropHeight + d.dy;
            if (newW >= _minCropSize && _cropLeft + newW <= maxWidth) {
              _cropWidth = newW;
            }
            if (newH >= _minCropSize && _cropTop + newH <= maxHeight) {
              _cropHeight = newH;
            }
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
      AppLogger.e('e', "Crop error: $e");
    }
  }

  Future<void> _saveFinalImage() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _selectedStickerId = null;
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
      AppLogger.e('e', "Save error: $e");
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
  final List<List<double>> _fujifilmMatrices = [
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    [
      1.1,
      0.1,
      -0.1,
      0,
      10,
      -0.1,
      1.2,
      0.1,
      0,
      5,
      -0.1,
      -0.1,
      1.1,
      0,
      -5,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      1.2,
      0.05,
      -0.05,
      0,
      15,
      0.05,
      1.1,
      -0.05,
      0,
      10,
      -0.05,
      0.05,
      0.9,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      1.0,
      0.2,
      0.0,
      0,
      5,
      0.0,
      1.3,
      0.0,
      0,
      20,
      0.0,
      0.0,
      1.1,
      0,
      5,
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
