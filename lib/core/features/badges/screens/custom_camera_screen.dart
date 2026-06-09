import 'dart:ui';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart'; // Đảm bảo đường dẫn này đúng với project của bạn

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

  final ImagePicker _picker = ImagePicker();

  // Animation cho nút chụp
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi start camera: $e");
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

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    HapticFeedback.heavyImpact();
    await _animationController.forward();
    await _animationController.reverse();

    try {
      final XFile picture = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, picture.path);
      }
    } catch (e) {
      debugPrint("Lỗi chụp ảnh: $e");
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
    // Gọi appColors từ Provider để đồng bộ toàn app
    final appColors = ref.watch(appColorsProvider);

    return Scaffold(
      backgroundColor: appColors.background, // Dùng màu nền chuẩn của App
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(
                    icon: CupertinoIcons.xmark,
                    onTap: () => Navigator.pop(context),
                    appColors: appColors,
                  ),
                  _buildNavButton(
                    icon: _getFlashIcon(),
                    onTap: _toggleFlash,
                    appColors: appColors,
                  ),
                ],
              ),
            ),

            // 2. KHUNG KÍNH NGẮM (VIEWFINDER) - STYLE POLAROID NHỎ XINH
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: AspectRatio(
                    aspectRatio: 3 / 4, // Tỷ lệ chuẩn ảnh chân dung/Polaroid
                    child: Container(
                      decoration: BoxDecoration(
                        color: appColors.cardBackground,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: appColors.primary.withOpacity(0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Luồng Camera
                          ClipRRect(
                            borderRadius: BorderRadius.circular(36),
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
                                : Container(
                                    color: appColors.textMuted.withOpacity(0.1),
                                    child: const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  ),
                          ),

                          // SIGNATURE "M" ĐẬM CHẤT THƯƠNG HIỆU
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: appColors.primary.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                "M",
                                style: TextStyle(
                                  fontFamily:
                                      'Times New Roman', // Hoặc font Serif tùy chỉnh của bạn
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
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

            // 3. BOTTOM BAR (CÁC NÚT ĐIỀU KHIỂN)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 40.0,
                top: 20.0,
                left: 40,
                right: 40,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nút Chọn Thư Viện
                  _buildNavButton(
                    icon: CupertinoIcons.photo_on_rectangle,
                    onTap: _openGallery,
                    appColors: appColors,
                  ),

                  // Nút Shutter "Khổng Lồ" có hiệu ứng nảy
                  GestureDetector(
                    onTap: _takePicture,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: appColors.primary.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: appColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: appColors.primary.withOpacity(0.4),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Nút Lật Camera
                  _buildNavButton(
                    icon: CupertinoIcons.switch_camera_solid,
                    onTap: _toggleCamera,
                    appColors: appColors,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nút bấm viền tròn tệp với tone màu của App
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColorTheme appColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: appColors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: appColors.text.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: appColors.text, size: 22),
      ),
    );
  }
}
