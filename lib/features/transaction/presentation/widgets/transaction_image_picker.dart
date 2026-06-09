import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/screens/custom_camera_screen.dart';
import 'package:moment_u_payment/core/features/badges/screens/edit_photo_screen.dart';
import '../../../../l10n/app_localizations.dart';

class TransactionImagePicker extends ConsumerStatefulWidget {
  final String? initialImagePath;
  final ValueChanged<String?>
  onImageChanged; // Callback trả đường dẫn ảnh về cho màn hình chính

  const TransactionImagePicker({
    super.key,
    this.initialImagePath,
    required this.onImageChanged,
  });

  @override
  ConsumerState<TransactionImagePicker> createState() =>
      _TransactionImagePickerState();
}

class _TransactionImagePickerState
    extends ConsumerState<TransactionImagePicker> {
  String? _localImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _localImagePath = widget.initialImagePath;
  }

  // Cập nhật state nội bộ và báo cho màn hình chính biết
  void _updateImage(String? newPath) {
    setState(() {
      _localImagePath = newPath;
    });
    widget.onImageChanged(newPath);
  }

  // 📸 MỞ CAMERA CUSTOM
  Future<void> _openCamera() async {
    HapticFeedback.lightImpact();
    try {
      final String? capturedImagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomCameraScreen(),
          fullscreenDialog: true,
        ),
      );
      if (capturedImagePath != null && mounted) {
        _updateImage(capturedImagePath);
      }
    } catch (e) {
      debugPrint("Lỗi khi mở custom camera: $e");
    }
  }

  // 🖼️ MỞ THƯ VIỆN ẢNH
  Future<void> _openGallery() async {
    HapticFeedback.lightImpact();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        _updateImage(image.path);
      }
    } catch (e) {
      debugPrint("Lỗi khi mở thư viện: $e");
    }
  }

  // ✨ MỞ MÀN HÌNH EDITOR
  Future<void> _openEditor() async {
    if (_localImagePath == null) return;
    HapticFeedback.lightImpact();

    final String? editedPath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPhotoScreen(imagePath: _localImagePath!),
        fullscreenDialog: true,
      ),
    );

    if (editedPath != null && mounted) {
      _updateImage(editedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _localImagePath == null ? _openCamera : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 245,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _localImagePath != null
                  ? appColors.cardBackground
                  : appColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _localImagePath != null
                    ? Colors.transparent
                    : appColors.primary.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: _localImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(_localImagePath!), fit: BoxFit.cover),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.25),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Nút Edit ✨
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: _openEditor,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.wand_stars,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -math.pi / 15,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.camera_fill,
                            size: 32,
                            color: appColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.cameraTapInstruction,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appColors.primaryDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _openGallery,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: appColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: appColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.photo_on_rectangle,
                  color: appColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _localImagePath != null
                      ? l10n.galleryChangeAction
                      : l10n.galleryPickAction,
                  style: TextStyle(
                    color: appColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
