import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

// ─── MODEL STICKER NÂNG CẤP CHUẨN STUDIO ───
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
    this.offset = const Offset(120, 200),
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

// ─── QUẢN LÝ LỊCH SỬ CHỈNH SỬA (UNDO/REDO) ───
class EditorState {
  final String imagePath;
  final int rotationTurns;
  final double glow;
  final double smooth;
  final double pop;
  final int filterIndex;
  final int filterSubTab;
  final List<StickerModel> stickers;

  EditorState({
    required this.imagePath,
    required this.rotationTurns,
    required this.glow,
    required this.smooth,
    required this.pop,
    required this.filterIndex,
    required this.filterSubTab,
    required this.stickers,
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

  double _initialStickerScale = 1.0;
  double _initialStickerRotation = 0.0;
  Offset _initialStickerOffset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;

  late String _currentImagePath;
  bool _isCapturingRaw = false;
  bool _isEditingText = false;
  String? _editingStickerId;

  int _currentTab = 0;
  bool _isPanelVisible = true;
  final double _panelHeight = 260.0;

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

  late Map<int, List<String>> _filterNames;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _textStickerController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveStateToHistory());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _filterNames = {
      0: ["ORIGINAL", "NOSTALGIA", "PORTRA", "CHROME", "NOIR"],
      1: ["NATURAL", "VIVID", "COZY", "MINIMAL"],
    };
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
      ),
    );
    if (_history.length > 25) _history.removeAt(0);
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
      _selectedStickerId = null;
      _cropWidth = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Bảng màu Minimalist Luxury
    const Color studioBg = Color(0xFF0A0A0C);
    const Color panelObsidian = Color(0xFF121214);
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
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: _buildPremiumHeader(l10n, champagneAccent),
              ),
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                bottom: bottomPadding + (_isPanelVisible ? _panelHeight : 45),
                child: _buildMainCanvasStudio(
                  currentGlow,
                  currentContrast,
                  currentSat,
                  currentFilterMatrix,
                ),
              ),
              if (_isDraggingSticker) _buildFloatingTrashZone(l10n),
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
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                bottom:
                    bottomPadding + (_isPanelVisible ? _panelHeight - 16 : 12),
                right: 20,
                child: _buildPanelToggleButton(champagneAccent, panelObsidian),
              ),
              if (_isEditingText) _buildStoryEditorOverlay(champagneAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(AppLocalizations l10n, Color accent) {
    return Container(
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _historyIndex > 0 ? _undo : null,
                child: Icon(
                  CupertinoIcons.arrow_left,
                  color: _historyIndex > 0 ? Colors.white : Colors.white24,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _historyIndex < _history.length - 1 ? _redo : null,
                child: Icon(
                  CupertinoIcons.arrow_right,
                  color: _historyIndex < _history.length - 1
                      ? Colors.white
                      : Colors.white24,
                  size: 18,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _saveFinalImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.editPhotoDone.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
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

  Widget _buildMainCanvasStudio(
    double glow,
    double contrast,
    double sat,
    List<double> matrix,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                RepaintBoundary(
                  key: _globalKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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
                ),
                if (!_isCapturingRaw && _currentTab != 1)
                  Positioned.fill(
                    child: Stack(
                      children: _stickers
                          .map((stk) => _buildStickerWidget(stk))
                          .toList(),
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

  // ─── THỦ THUẬT RENDER TEXT BACKGROUND CHUẨN FB/IG STORY ───
  Widget _buildStickerWidget(StickerModel sticker) {
    final isSelected = sticker.id == _selectedStickerId;
    const Color handleColor = Color(0xFFF3E5D8);

    return Positioned(
      left: sticker.offset.dx,
      top: sticker.offset.dy,
      child: Transform.rotate(
        angle: sticker.rotation,
        alignment: Alignment.center,
        child: Transform.scale(
          scale: sticker.scale,
          alignment: Alignment.center,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedStickerId = sticker.id);
            },
            onDoubleTap: () {
              if (sticker.type == StickerType.text)
                _openTextEditor(existingSticker: sticker);
            },
            onScaleStart: (details) {
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
              final double screenHeight = MediaQuery.of(context).size.height;
              setState(() {
                sticker.offset =
                    _initialStickerOffset +
                    (details.focalPoint - _initialFocalPoint);
                if (details.scale != 1.0)
                  sticker.scale = (_initialStickerScale * details.scale).clamp(
                    0.4,
                    4.0,
                  );
                if (details.rotation != 0.0)
                  sticker.rotation = _initialStickerRotation + details.rotation;
              });
              final double trashThreshold = screenHeight - _panelHeight - 120;
              bool isOverTrash = (details.focalPoint.dy > trashThreshold);
              if (isOverTrash != _isOverDeleteArea) {
                setState(() => _isOverDeleteArea = isOverTrash);
                if (isOverTrash) HapticFeedback.vibrate();
              }
            },
            onScaleEnd: (details) {
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
                padding: const EdgeInsets.all(12),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (sticker.type == StickerType.icon)
                      Text(
                        sticker.value,
                        style: const TextStyle(
                          fontSize: 50,
                          decoration: TextDecoration.none,
                        ),
                      )
                    else
                      Stack(
                        children: [
                          // HACK: Nền Text bằng Paint ôm sát chữ, bo góc mượt mà
                          if (sticker.hasBackground)
                            Text(
                              sticker.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                                background: Paint()
                                  ..color = sticker.backgroundColor
                                      .withOpacity(0.55) // Màu nhạt trong suốt
                                  ..strokeWidth =
                                      24 // Độ dày viền
                                  ..strokeJoin = StrokeJoin.round
                                  ..strokeCap = StrokeCap.round
                                  ..style = PaintingStyle.stroke,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          // Chữ Text đè lên nền
                          Text(
                            sticker.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                              color: sticker.textColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),

                    if (isSelected) ...[
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Positioned(top: -4, left: -4, child: _buildDotHandle()),
                      Positioned(top: -4, right: -4, child: _buildDotHandle()),
                      Positioned(
                        bottom: -4,
                        left: -4,
                        child: _buildDotHandle(),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
        ],
      ),
    );
  }

  Widget _buildFloatingTrashZone(AppLocalizations l10n) {
    return Positioned(
      left: 60,
      right: 60,
      bottom: _panelHeight + 20,
      height: 50,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isOverDeleteArea
                ? Colors.redAccent.withOpacity(0.9)
                : Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _isOverDeleteArea ? Colors.white : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isOverDeleteArea
                    ? CupertinoIcons.trash_fill
                    : CupertinoIcons.trash,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _isOverDeleteArea
                    ? l10n.stickerDeleteDrop
                    : l10n.stickerDeleteDrag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
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
      padding: EdgeInsets.only(top: 16, bottom: bottomPadding + 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          const SizedBox(height: 10),
          _buildBottomTabBar(l10n, accent),
        ],
      ),
    );
  }

  Widget _buildPanelToggleButton(Color accent, Color bg) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: FloatingActionButton.small(
        elevation: 0,
        backgroundColor: _isPanelVisible ? accent : bg,
        foregroundColor: _isPanelVisible ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Icon(
          _isPanelVisible
              ? CupertinoIcons.chevron_down
              : CupertinoIcons.slider_horizontal_3,
          size: 16,
        ),
        onPressed: () => setState(() => _isPanelVisible = !_isPanelVisible),
      ),
    );
  }

  Widget _buildDynamicTabsContent(
    AppLocalizations l10n,
    Color accent,
    List<List<double>> filters,
    List<String> names,
  ) {
    switch (_currentTab) {
      case 0: // FILTER
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
            const SizedBox(height: 20),
            SizedBox(
              height: 95,
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
                          const SizedBox(height: 8),
                          Text(
                            names[idx],
                            style: TextStyle(
                              color: isSel
                                  ? accent
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
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
      case 1: // CROP
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStudioCropButton(
                    CupertinoIcons.rotate_right,
                    "ROTATE",
                    accent,
                    () {
                      setState(() {
                        _rotationTurns = (_rotationTurns + 1) % 4;
                        _cropWidth = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 24),
                  _buildStudioCropButton(
                    CupertinoIcons.refresh,
                    "RESET",
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
              const SizedBox(height: 20),
              Text(
                l10n.cropInstruction,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
        );
      case 2: // BEAUTY
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              _buildMinimalSlider(
                "LIGHT",
                CupertinoIcons.sun_max,
                _glowBrightness,
                -40,
                40,
                accent,
                (v) => setState(() => _glowBrightness = v),
              ),
              _buildMinimalSlider(
                "SOFT",
                CupertinoIcons.drop,
                _skinSmoothContrast,
                0.6,
                1.4,
                accent,
                (v) => setState(() => _skinSmoothContrast = v),
              ),
              _buildMinimalSlider(
                "POP",
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
      case 3: // STICKER
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => _openTextEditor(),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.textformat, color: accent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "ADD TEXT",
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
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _iconsStorage.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _addIconSticker(_iconsStorage[index]),
                    child: Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _iconsStorage[index],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
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
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: active ? 20 : 0,
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
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 16),
          const SizedBox(width: 14),
          SizedBox(
            width: 50,
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
                inactiveTrackColor: Colors.white.withOpacity(0.05),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.0,
                ),
                overlayColor: accent.withOpacity(0.1),
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

  // UI TAB BAR EDITORIAL SANG TRỌNG
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
                "CANCEL",
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
                "APPLY",
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainTabItem(0, "FILTER", accent),
          _buildMainTabItem(1, "ADJUST", accent),
          _buildMainTabItem(2, "BEAUTY", accent),
          _buildMainTabItem(3, "STICKER", accent),
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
      }),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.white : Colors.white30,
                fontSize: 10,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
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
        color: Colors.black.withOpacity(0.8),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(
                        () => _currentTextHasBg = !_currentTextHasBg,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
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
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _finishTextEditing,
                      child: Text(
                        "DONE",
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          letterSpacing: 0.5,
                          height: 1.3,
                          // Tích hợp viền khi gõ tương tự lúc hiển thị
                          background: _currentTextHasBg
                              ? (Paint()
                                  ..color = _currentTextBgColor.withOpacity(
                                    0.55,
                                  )
                                  ..strokeWidth = 24
                                  ..strokeJoin = StrokeJoin.round
                                  ..strokeCap = StrokeCap.round
                                  ..style = PaintingStyle.stroke)
                              : null,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.stickerTextHint,
                          hintStyle: const TextStyle(color: Colors.white30),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 20),
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
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
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
          width: 20,
          height: 20,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 16,
            height: 16,
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
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      double scaleX = image.width / boundary.size.width;
      double scaleY = image.height / boundary.size.height;
      Rect cropRect = Rect.fromLTWH(
        _cropLeft * scaleX,
        _cropTop * scaleY,
        _cropWidth * scaleX,
        _cropHeight * scaleY,
      );
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImageRect(
        image,
        cropRect,
        Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
        Paint(),
      );
      final croppedImage = await recorder.endRecording().toImage(
        cropRect.width.toInt(),
        cropRect.height.toInt(),
      );
      ByteData? byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(byteData!.buffer.asUint8List());
      setState(() {
        _currentImagePath = file.path;
        _cropWidth = 0;
        _rotationTurns = 0;
        _isCapturingRaw = false;
        _currentTab = 0;
      });
      _saveStateToHistory();
    } catch (e) {
      setState(() => _isCapturingRaw = false);
    }
  }

  Future<void> _saveFinalImage() async {
    HapticFeedback.heavyImpact();
    setState(() => _selectedStickerId = null);
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
      if (mounted) Navigator.pop(context, file.path);
    } catch (e) {}
  }

  final List<List<double>> _leicaMatrices = [
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    [1.1, 0.02, 0, 0, 10, 0, 1.05, 0.02, 0, 5, 0, 0, 1.0, 0, -5, 0, 0, 0, 1, 0],
    [
      1.0,
      -0.02,
      0,
      0,
      5,
      0,
      1.0,
      -0.02,
      0,
      5,
      0,
      0,
      1.05,
      0,
      15,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      1.1,
      0.05,
      -0.05,
      0,
      -10,
      0.05,
      1.0,
      0.05,
      0,
      -5,
      -0.05,
      0.05,
      1.15,
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
      -5,
      0.21,
      0.71,
      0.07,
      0,
      -5,
      0.21,
      0.71,
      0.07,
      0,
      -5,
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
      1.25,
      0.05,
      -0.05,
      0,
      2,
      0.05,
      1.15,
      0.05,
      0,
      2,
      -0.05,
      0.05,
      1.05,
      0,
      5,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      1.08,
      0.05,
      0,
      0,
      15,
      0.05,
      1.0,
      0,
      0,
      5,
      0,
      0,
      0.88,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      0.92,
      0.05,
      0.15,
      0,
      5,
      0.05,
      1.22,
      0.05,
      0,
      15,
      0.15,
      0.05,
      1.05,
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

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  CropOverlayPainter({required this.cropRect});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.85);
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
