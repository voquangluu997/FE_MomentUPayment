import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart'; // Import Đa ngôn ngữ

class EditPhotoScreen extends StatefulWidget {
  final String imagePath;
  const EditPhotoScreen({super.key, required this.imagePath});

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final GlobalKey _globalKey = GlobalKey();

  late String _currentImagePath;
  bool _isCapturingRaw = false; // Cờ khóa UI khi đang xử lý Crop thực tế

  int _currentTab = 0;
  int _currentFilterSubTab = 0;

  // 📐 LOGIC CẮT ẢNH TƯƠNG TÁC KÉO THẢ GÓC (Real Crop Box)
  double _cropLeft = 0.0;
  double _cropTop = 0.0;
  double _cropWidth = 0.0;
  double _cropHeight = 0.0;
  final double _minCropSize = 80.0;

  // 💄 Bộ thanh trượt tinh chỉnh da & ánh sáng
  double _glowBrightness = 0.0;
  double _skinSmoothContrast = 1.0;
  double _popSaturation = 1.0;

  // 🏷️ HỆ THỐNG NHÃN DÁN ĐA DẠNG NÂNG CẤP
  Offset _stickerOffset = const Offset(100, 150);
  double _stickerScale = 1.0;
  int _selectedStickerType = 0; // 0: Icon, 1: Text
  int _selectedStickerIndex = 0;

  String _customStickerText = "V I B E S";
  late TextEditingController _textStickerController;

  final List<String> _cuteIcons = [
    "✨",
    "💖",
    "🍓",
    "🍒",
    "🥑",
    "🍑",
    "🍋",
    "🍉",
    "🍕",
    "🥞",
    "🍩",
    "🍦",
    "🍡",
    "☕",
    "🧋",
    "🧸",
    "🐱",
    "🐶",
    "🐰",
    "🦊",
    "🦋",
    "🌸",
    "🌷",
    "🌻",
    "🍀",
    "🍄",
    "🍁",
    "🌙",
    "⭐",
    "☁️",
  ];

  // 🎨 MA TRẬN BỘ LỌC ĐỈNH CAO (Foodie & Portrait)
  int _selectedFilterIndex = 0;

  final List<List<double>> _portraitFilters = [
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0], // Gốc
    [
      1.05,
      0.1,
      0,
      0,
      10,
      0,
      1.0,
      0.1,
      0,
      5,
      0,
      0,
      0.95,
      0,
      -5,
      0,
      0,
      0,
      1,
      0,
    ], // Mịn Kem
    [
      1.1,
      0,
      0.1,
      0,
      15,
      0,
      0.95,
      0,
      0,
      5,
      0.05,
      0,
      1.05,
      0,
      10,
      0,
      0,
      0,
      1,
      0,
    ], // Hồng Phấn
    [
      0.95,
      0.1,
      0.1,
      0,
      10,
      0.1,
      0.95,
      0,
      0,
      5,
      0,
      0.1,
      0.85,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ], // Film Cổ
    [
      1.15,
      0.05,
      0,
      0,
      20,
      0,
      1.05,
      0.05,
      0,
      10,
      0,
      0,
      0.9,
      0,
      -15,
      0,
      0,
      0,
      1,
      0,
    ], // Nắng Thơ
  ];

  final List<List<double>> _foodFilters = [
    [
      1.2,
      0,
      0,
      0,
      5,
      0,
      1.15,
      0,
      0,
      -5,
      0,
      0,
      0.9,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ], // Tươi Ngon
    [
      1.25,
      0.1,
      0,
      0,
      15,
      0,
      1.1,
      0.1,
      0,
      5,
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
    ], // Mọng Nước
    [
      1.1,
      0.15,
      0,
      0,
      25,
      0.1,
      1.05,
      0,
      0,
      15,
      0,
      0,
      0.95,
      0,
      5,
      0,
      0,
      0,
      1,
      0,
    ], // Bánh Ngọt
    [
      1.3,
      0,
      0,
      0,
      10,
      0,
      1.2,
      0,
      0,
      10,
      0,
      0,
      0.8,
      0,
      -20,
      0,
      0,
      0,
      1,
      0,
    ], // Chroma Gold
    [
      0.95,
      0,
      0,
      0,
      -10,
      0,
      1.25,
      0,
      0,
      15,
      0,
      0,
      1.1,
      0,
      5,
      0,
      0,
      0,
      1,
      0,
    ], // Forest Xanh
  ];

  List<List<double>> get _activeFilters =>
      _currentFilterSubTab == 0 ? _portraitFilters : _foodFilters;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _textStickerController = TextEditingController(text: _customStickerText);
  }

  @override
  void dispose() {
    _textStickerController.dispose();
    super.dispose();
  }

  // Thuật toán màu sắc chuyên sâu
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
    final translate = 128.0 * (1.0 - scale);
    return [
      scale,
      0,
      0,
      0,
      translate,
      0,
      scale,
      0,
      0,
      translate,
      0,
      0,
      scale,
      0,
      translate,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  List<double> _getSaturationMatrix(double sat) {
    final invSat = 1.0 - sat;
    final r = 0.213 * invSat;
    final g = 0.715 * invSat;
    final b = 0.072 * invSat;
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

  // 🚀 THỰC THI LỆNH CẮT ẢNH THẬT TỪ CANVAS
  Future<void> _applyCrop() async {
    HapticFeedback.heavyImpact();

    // Tạm tắt các Filter và Nhãn dán để chụp chính xác ảnh gốc
    setState(() {
      _isCapturingRaw = true;
    });
    await Future.delayed(const Duration(milliseconds: 100)); // Đợi render

    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Tính toán tỷ lệ Crop trên màn hình so với kích thước thật của ảnh
      double scaleX = image.width / boundary.size.width;
      double scaleY = image.height / boundary.size.height;

      Rect cropRect = Rect.fromLTWH(
        _cropLeft * scaleX,
        _cropTop * scaleY,
        _cropWidth * scaleX,
        _cropHeight * scaleY,
      );

      // Vẽ lại ảnh mới bị cắt bằng PictureRecorder
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
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Lưu file tạm và load lại ảnh mới
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      setState(() {
        _currentImagePath = file.path; // Thay thế ảnh cũ bằng ảnh đã cắt
        _cropWidth = 0; // Kích hoạt reset Crop Frame
        _isCapturingRaw = false; // Bật lại Filter & Sticker
        _currentTab = 0; // Thoát chế độ cắt
      });
    } catch (e) {
      debugPrint("Lỗi Crop: $e");
      setState(() {
        _isCapturingRaw = false;
      });
    }
  }

  Future<void> _saveFinalImage() async {
    HapticFeedback.heavyImpact();
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/final_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      if (mounted) Navigator.pop(context, file.path);
    } catch (e) {
      debugPrint("Lỗi lưu ảnh cuối: $e");
    }
  }

  // Hiện Popup sửa chữ khi chạm vào Text Sticker
  void _showEditStickerDialog(AppLocalizations l10n) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.editStickerTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: _textStickerController,
            autofocus: true,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(l10n.save),
            onPressed: () {
              setState(() {
                _customStickerText = _textStickerController.text;
              });
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Khi Crop Raw, ép ma trận màu về GỐC (Trơn) để không lưu đúp bộ lọc
    final double currentGlow = _isCapturingRaw ? 0.0 : _glowBrightness;
    final double currentContrast = _isCapturingRaw ? 1.0 : _skinSmoothContrast;
    final double currentSat = _isCapturingRaw ? 1.0 : _popSaturation;
    final List<double> currentFilterMatrix = _isCapturingRaw
        ? [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]
        : _activeFilters[_selectedFilterIndex];

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF090D1A),
        body: SafeArea(
          child: Column(
            children: [
              // ─── THANH TIÊU ĐỀ ───
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.momentCreatorTitle,
                        style: const TextStyle(
                          color: Color(0xFFFF9A76),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _saveFinalImage,
                      child: Text(
                        l10n.editPhotoDone,
                        style: const TextStyle(
                          color: Color(0xFFFF9A76),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── KHU VỰC TRƯNG BÀY ẢNH & CANVAS CẮT ───
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        // RepaintBoundary bao bọc CỰC SÁT viền ảnh
                        RepaintBoundary(
                          key: _globalKey,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.matrix(
                                  _getBrightnessMatrix(currentGlow),
                                ),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.matrix(
                                    _getContrastMatrix(currentContrast),
                                  ),
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.matrix(
                                      _getSaturationMatrix(currentSat),
                                    ),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix(
                                        currentFilterMatrix,
                                      ),
                                      child: Image.file(
                                        File(_currentImagePath),
                                      ), // Không dùng BoxFit.cover để lấy kích thước thật
                                    ),
                                  ),
                                ),
                              ),

                              // Nhãn dán di động (Ẩn đi khi đang Crop thật)
                              if (!_isCapturingRaw)
                                _buildDraggableStickerLayer(l10n),
                            ],
                          ),
                        ),

                        // TẦNG CẮT ẢNH: Phủ lên trên RepaintBoundary để không bị Capture lại dính nét kẻ
                        if (_currentTab == 1)
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Khởi tạo viền crop vừa khít hình ảnh lần đầu
                                if (_cropWidth == 0 &&
                                    constraints.maxWidth > 0) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _cropWidth = constraints.maxWidth;
                                      _cropHeight = constraints.maxHeight;
                                      _cropLeft = 0;
                                      _cropTop = 0;
                                    });
                                  });
                                }
                                return _buildInteractiveCropOverlay(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── KHU VỰC BẢNG ĐIỀU KHIỂN & BOTTOM MENU ───
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF121829),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildDynamicControlPanel(l10n),
                    ),
                    const Divider(
                      color: Colors.white10,
                      height: 24,
                      thickness: 1,
                    ),

                    // Nếu đang ở Tab Cắt, hiển thị Hủy / Áp Dụng. Ngược lại hiện Menu 4 nút
                    if (_currentTab == 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => setState(() {
                              _currentTab = 0;
                              _cropWidth = 0;
                            }), // Hủy crop
                            child: Text(
                              l10n.editPhotoCancel,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _applyCrop, // Chạy thuật toán Crop
                            child: Text(
                              l10n.editPhotoApply,
                              style: const TextStyle(
                                color: Color(0xFFFF9A76),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMainTabButton(
                            0,
                            CupertinoIcons.color_filter,
                            l10n.editPhotoFilter,
                          ),
                          _buildMainTabButton(
                            1,
                            CupertinoIcons.crop,
                            l10n.editPhotoCrop,
                          ),
                          _buildMainTabButton(
                            2,
                            CupertinoIcons.slider_horizontal_3,
                            l10n.editPhotoBeauty,
                          ),
                          _buildMainTabButton(
                            3,
                            CupertinoIcons.smiley,
                            l10n.editPhotoSticker,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📐 GIAO DIỆN KHUNG KÉO CẮT ẢNH TƯƠNG TÁC
  Widget _buildInteractiveCropOverlay(double maxWidth, double maxHeight) {
    return Stack(
      children: [
        // Vẽ lớp nền tối khoét lỗ sáng ở giữa
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

        // Vùng có thể kéo toàn khối
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
                border: Border.all(color: const Color(0xFFFF9A76), width: 2),
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(width: 1, color: Colors.white54),
                      Container(width: 1, color: Colors.white54),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(height: 1, color: Colors.white54),
                      Container(height: 1, color: Colors.white54),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 4 Nút kéo điều chỉnh 4 góc
        _buildCornerHandle(_cropLeft - 10, _cropTop - 10, (d) {
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
        _buildCornerHandle(_cropLeft + _cropWidth - 14, _cropTop - 10, (d) {
          double newT = _cropTop + d.dy;
          double newW = _cropWidth + d.dx;
          double newH = _cropHeight - d.dy;
          if (newW >= _minCropSize && _cropLeft + newW <= maxWidth)
            _cropWidth = newW;
          if (newH >= _minCropSize && newT >= 0) {
            _cropTop = newT;
            _cropHeight = newH;
          }
        }),
        _buildCornerHandle(_cropLeft - 10, _cropTop + _cropHeight - 14, (d) {
          double newL = _cropLeft + d.dx;
          double newW = _cropWidth - d.dx;
          double newH = _cropHeight + d.dy;
          if (newW >= _minCropSize && newL >= 0) {
            _cropLeft = newL;
            _cropWidth = newW;
          }
          if (newH >= _minCropSize && _cropTop + newH <= maxHeight)
            _cropHeight = newH;
        }),
        _buildCornerHandle(
          _cropLeft + _cropWidth - 14,
          _cropTop + _cropHeight - 14,
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

  Widget _buildCornerHandle(double left, double top, Function(Offset) onPan) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => onPan(details.delta)),
        child: Container(
          width: 28,
          height: 28,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF9A76), width: 2),
            ),
          ),
        ),
      ),
    );
  }

  // 🏷️ TẦNG HIỂN THỊ STICKER (CHẠM ĐỂ SỬA TEXT)
  Widget _buildDraggableStickerLayer(AppLocalizations l10n) {
    if (_selectedStickerType == 1 && _customStickerText.trim().isEmpty)
      return const SizedBox.shrink();

    return Positioned(
      left: _stickerOffset.dx,
      top: _stickerOffset.dy,
      child: GestureDetector(
        onTap: () {
          // CHẠM ĐỂ CHỈNH SỬA TEXT STICKER
          if (_selectedStickerType == 1) _showEditStickerDialog(l10n);
        },
        onPanUpdate: (details) =>
            setState(() => _stickerOffset += details.delta),
        child: Transform.scale(
          scale: _stickerScale,
          child: _selectedStickerType == 0
              ? Text(
                  _cuteIcons[_selectedStickerIndex],
                  style: const TextStyle(
                    fontSize: 42,
                    decoration: TextDecoration.none,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9A76),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "✨ ${_customStickerText.toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDynamicControlPanel(AppLocalizations l10n) {
    final List<String> _portraitFilterNames = [
      l10n.filterOriginal,
      l10n.filterCreamy,
      l10n.filterPink,
      l10n.filterVintage,
      l10n.filterPoetic,
    ];

    final List<String> foodNames = [
      l10n.filterOriginal,
      l10n.filterFoodFresh,
      l10n.filterFoodJuicy,
      l10n.filterFoodSweet,
      l10n.filterFoodGold,
      l10n.filterFoodForest,
    ];
    switch (_currentTab) {
      case 0:
        List<String> names = _currentFilterSubTab == 0
            ? _portraitFilterNames
            : foodNames;
        return Column(
          key: const ValueKey(0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSubTabFilterButton(0, l10n.filterPortrait),
                const SizedBox(width: 16),
                _buildSubTabFilterButton(1, l10n.filterFood),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _activeFilters.length,
                itemBuilder: (context, index) {
                  final isSel = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilterIndex = index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel
                                    ? const Color(0xFFFF9A76)
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.matrix(
                                  _activeFilters[index],
                                ),
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            names[index],
                            style: TextStyle(
                              color: isSel
                                  ? const Color(0xFFFF9A76)
                                  : Colors.white60,
                              fontSize: 11,
                              fontWeight: isSel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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

      case 1:
        return Container(
          key: const ValueKey(1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              const Icon(
                CupertinoIcons.hand_draw,
                color: Color(0xFFFF9A76),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.cropInstruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );

      case 2:
        return Container(
          key: const ValueKey(2),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildBeautySlider(
                l10n.beautyGlow,
                _glowBrightness,
                -40,
                40,
                (v) => setState(() => _glowBrightness = v),
              ),
              _buildBeautySlider(
                l10n.beautySmooth,
                _skinSmoothContrast,
                0.6,
                1.4,
                (v) => setState(() => _skinSmoothContrast = v),
              ),
              _buildBeautySlider(
                l10n.beautyPop,
                _popSaturation,
                0.5,
                1.8,
                (v) => setState(() => _popSaturation = v),
              ),
            ],
          ),
        );

      case 3:
        return Column(
          key: const ValueKey(3),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSubTabStickerButton(0, l10n.stickerCute),
                const SizedBox(width: 16),
                _buildSubTabStickerButton(1, l10n.stickerText),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    l10n.stickerSize,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  Expanded(
                    child: CupertinoSlider(
                      value: _stickerScale,
                      min: 0.5,
                      max: 3.5,
                      activeColor: const Color(0xFFFF9A76),
                      onChanged: (val) => setState(() => _stickerScale = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _selectedStickerType == 0
                ? SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _cuteIcons.length,
                      itemBuilder: (context, index) {
                        final isSel = _selectedStickerIndex == index;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedStickerIndex = index);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFFFF9A76)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel
                                    ? Colors.transparent
                                    : Colors.white10,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _cuteIcons[index],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    child: CupertinoTextField(
                      controller: _textStickerController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      onChanged: (val) =>
                          setState(() => _customStickerText = val),
                    ),
                  ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── HELPER WIDGETS ───
  Widget _buildSubTabFilterButton(int subTabIndex, String title) {
    final active = _currentFilterSubTab == subTabIndex;
    return GestureDetector(
      onTap: () => setState(() {
        _currentFilterSubTab = subTabIndex;
        _selectedFilterIndex = 0;
      }),
      child: Text(
        title,
        style: TextStyle(
          color: active ? const Color(0xFFFF9A76) : Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSubTabStickerButton(int typeIndex, String title) {
    final active = _selectedStickerType == typeIndex;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedStickerType = typeIndex;
        if (typeIndex == 0) FocusManager.instance.primaryFocus?.unfocus();
      }),
      child: Text(
        title,
        style: TextStyle(
          color: active ? const Color(0xFFFF9A76) : Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBeautySlider(
    String label,
    double val,
    double min,
    double max,
    ValueChanged<double> onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: CupertinoSlider(
              value: val,
              min: min,
              max: max,
              activeColor: const Color(0xFFFF9A76),
              thumbColor: Colors.white,
              onChanged: onChange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabButton(int tabIdx, IconData icon, String label) {
    final isSel = _currentTab == tabIdx;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentTab = tabIdx);
        if (tabIdx != 3) FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSel ? const Color(0xFFFF9A76) : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.white : Colors.white38,
                fontSize: 11,
                fontWeight: isSel ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomPainter tạo lỗ thủng sáng cho Khung Crop
class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  CropOverlayPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.65);
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRect(cropRect);
    final path = Path.combine(PathOperation.difference, bgPath, holePath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect;
}
