import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CustomCameraScreen extends ConsumerStatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  ConsumerState<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends ConsumerState<CustomCameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;
  FlashMode _flashMode = FlashMode.off;

  // Tiêu cự thực tế đang chọn
  int _selectedFocalLength = 24;

  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initCamera();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _startCamera(_cameras.first);
      }
    } catch (e) {
      debugPrint("Lỗi khởi tạo camera: $e");
    }
  }

  void _startCamera(CameraDescription cameraDescription) async {
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      // Reset tiêu cự về 24mm (1.0x) khi khởi động camera mới
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _selectedFocalLength = 24;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi start camera: $e");
    }
  }

  // HÀM ĐIỀU CHỈNH TIÊU CỰ THẬT QUA ZOOM CỦA PHẦN CỨNG CAMERA
  Future<void> _changeFocalLength(int mm) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    HapticFeedback.selectionClick();

    // Tính toán Zoom Level dựa trên tiêu cự chuẩn 24mm
    double targetZoom = 1.0;
    if (mm == 35) targetZoom = 1.45;
    if (mm == 50) targetZoom = 2.08;

    try {
      // Lấy giới hạn Zoom phần cứng của thiết bị để tránh crash mạng
      final double minZoom = await _controller!.getMinZoomLevel();
      final double maxZoom = await _controller!.getMaxZoomLevel();

      // Ép mức zoom mục tiêu nằm trong khoảng phần cứng cho phép
      final double safeZoom = targetZoom.clamp(minZoom, maxZoom);

      await _controller!.setZoomLevel(safeZoom);
      setState(() {
        _selectedFocalLength = mm;
      });
    } catch (e) {
      debugPrint("Không thể chỉnh tiêu cự thật: $e");
    }
  }

  void _toggleCamera() {
    HapticFeedback.mediumImpact();
    if (_cameras.length < 2) return;

    setState(() {
      _isCameraInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });

    final newCamera = _isFrontCamera
        ? _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
          )
        : _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
          );

    _startCamera(newCamera);
  }

  void _toggleFlash() async {
    HapticFeedback.lightImpact();
    if (_controller == null) return;

    FlashMode newMode;
    if (_flashMode == FlashMode.off) {
      newMode = FlashMode.always;
    } else if (_flashMode == FlashMode.always) {
      newMode = FlashMode.auto;
    } else {
      newMode = FlashMode.off;
    }

    await _controller!.setFlashMode(newMode);
    setState(() {
      _flashMode = newMode;
    });
  }

  // 3. CẬP NHẬT LẠI HÀM _TAKEPICTURE KHỚP VỚI HÀM CẮT ẢNH TRÊN
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    HapticFeedback.heavyImpact();
    await _animationController.forward();
    await _animationController.reverse();

    try {
      // Chụp ảnh gốc từ phần cứng
      final XFile picture = await _controller!.takePicture();

      // Hiển thị trạng thái loading nhẹ trong lúc xử lý cắt ảnh (nếu cần)
      // Tiến hành cắt ảnh về chuẩn 4:5 thời trang
      final File croppedFile = await _cropImageTo45(picture.path);

      if (mounted) {
        // Trả về đường dẫn ảnh ĐÃ ĐƯỢC CẮT ĐÚNG TỶ LỆ khung app
        Navigator.pop(context, croppedFile.path);
      }
    } catch (e) {
      debugPrint("Lỗi khi chụp hoặc crop ảnh: $e");
    }
  }

  Future<void> _openGallery() async {
    HapticFeedback.lightImpact();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      debugPrint("Lỗi khi mở thư viện: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  IconData _getFlashIcon() {
    if (_flashMode == FlashMode.always) return CupertinoIcons.bolt_fill;
    if (_flashMode == FlashMode.auto) return CupertinoIcons.bolt_badge_a_fill;
    return CupertinoIcons.bolt_slash_fill;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Matte Black Zinc 950
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderButton(
                    icon: CupertinoIcons.xmark,
                    onTap: () => Navigator.pop(context),
                  ),
                  Text(
                    "RAW  •  4:5  •  16-BIT",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                  _buildHeaderButton(
                    icon: _getFlashIcon(),
                    onTap: _toggleFlash,
                  ),
                ],
              ),
            ),

            // 2. VIEW_FINDER FRAME (Tỷ lệ 4:5 thời trang cao cấp)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Luồng camera preview thực tế
                          ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: _isCameraInitialized && _controller != null
                                ? FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _controller!
                                          .value
                                          .previewSize!
                                          .height,
                                      height:
                                          _controller!.value.previewSize!.width,
                                      child: CameraPreview(_controller!),
                                    ),
                                  )
                                : const Center(
                                    child: CupertinoActivityIndicator(
                                      color: Colors.white24,
                                    ),
                                  ),
                          ),

                          // Bốn góc khung ngắm cơ khí hoài cổ
                          _buildFrameCorners(),

                          // CHỮ "MOMENT U PAYMENT" SIÊU TINH TẾ - KHÔNG CHIẾM DIỆN TÍCH
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                "MOMENT U PAYMENT",
                                style: TextStyle(
                                  fontFamily:
                                      'Georgia', // Font Serif thanh lịch
                                  fontSize: 9, // Kích thước Micro cực nhỏ gọn
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing:
                                      4.5, // Giãn khoảng cách tạo cảm giác tối giản kiểu tạp chí thời trang
                                  color: Colors.white.withOpacity(
                                    0.3,
                                  ), // Trong suốt, tiệp vào khung hình
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. THANH ĐIỀU CHỈNH TIÊU CỰ THẬT (24mm, 35mm, 50mm)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [24, 35, 50].map((mm) {
                  final isSelected = _selectedFocalLength == mm;
                  return GestureDetector(
                    onTap: () =>
                        _changeFocalLength(mm), // Gọi hàm zoom phần cứng thật
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${mm}mm",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : Colors.white.withOpacity(0.4),
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // 4. BOTTOM CONTROLS BAR (Trong suốt quanh nút bấm)
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0, left: 40, right: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBottomActionOverlayButton(
                    icon: CupertinoIcons.photo_on_rectangle,
                    onTap: _openGallery,
                  ),

                  // NÚT CHỤP SANG TRỌNG PURE CAMERA
                  GestureDetector(
                    onTap: _takePicture,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _buildBottomActionOverlayButton(
                    icon: CupertinoIcons.arrow_2_circlepath,
                    onTap: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameCorners() {
    const double cornerSize = 14.0;
    const double strokeWidth = 1.2;
    final color = Colors.white.withOpacity(0.25);

    return Stack(
      children: [
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: strokeWidth),
                left: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: strokeWidth),
                right: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: strokeWidth),
                left: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: strokeWidth),
                right: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
      ),
    );
  }

  Widget _buildBottomActionOverlayButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          ),
        ),
      ),
    );
  }

  Future<File> _cropImageTo45(String path) async {
    // Đọc bytes từ file ảnh vừa chụp
    final bytes = await File(path).readAsBytes();

    // Giải mã ảnh (Thư viện tự động xử lý xoay ảnh theo EXIF)
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return File(path);

    int width = originalImage.width;
    int height = originalImage.height;

    int targetWidth, targetHeight;

    // Tính toán kích thước cắt theo tỷ lệ chân dung 4:5 (0.8)
    if (width / height > 4 / 5) {
      // Nếu ảnh gốc quá rộng (ví dụ tỷ lệ 4:3), giữ nguyên chiều cao, cắt bớt chiều rộng
      targetHeight = height;
      targetWidth = (height * 4) ~/ 5;
    } else {
      // Nếu ảnh gốc quá dài, giữ nguyên chiều rộng, cắt bớt chiều cao
      targetWidth = width;
      targetHeight = (width * 5) ~/ 4;
    }

    // Xác định tọa độ X, Y tại tâm để bắt đầu cắt
    int x = (width - targetWidth) ~/ 2;
    int y = (height - targetHeight) ~/ 2;

    // Tiến hành crop ảnh từ vị trí tâm
    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: targetWidth,
      height: targetHeight,
    );

    // Ghi đè file ảnh đã cắt với chất lượng cao (90%)
    final croppedFile = File(path);
    await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

    return croppedFile;
  }
}
