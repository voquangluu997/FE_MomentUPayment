import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/features/camera/screens/custom_camera_screen.dart';
import 'package:moment_u_payment/features/camera/screens/edit_photo_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class TransactionImagePicker extends ConsumerStatefulWidget {
  final String? initialImagePath;
  final ValueChanged<String?> onImageChanged;

  const TransactionImagePicker({
    super.key,
    required this.initialImagePath,
    required this.onImageChanged,
  });

  @override
  ConsumerState<TransactionImagePicker> createState() =>
      _TransactionImagePickerState();
}

class _TransactionImagePickerState
    extends ConsumerState<TransactionImagePicker> {
  /// 📸 LUỒNG CHỤP ẢNH: Chạm vào ảnh để mở lại camera
  Future<void> _openCameraFlow() async {
    HapticFeedback.mediumImpact();

    final String? capturedPath = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const CustomCameraScreen()),
    );

    if (capturedPath != null && mounted) {
      widget.onImageChanged(capturedPath);
    }
  }

  /// 🎨 LUỒNG EDIT CHỦ ĐỘNG: Chạm vào icon nhỏ góc dưới bên phải
  Future<void> _openEditFlow() async {
    if (widget.initialImagePath == null) return;
    HapticFeedback.lightImpact();

    final String? editedPath = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            EditPhotoScreen(imagePath: widget.initialImagePath!),
      ),
    );

    if (editedPath != null && mounted) {
      widget.onImageChanged(editedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        child: AspectRatio(
          aspectRatio: 1.0, // Tỉ lệ khung hình 1:1 thời thượng
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: widget.initialImagePath == null
                  ? _buildEmptyCameraState(appColors, l10n)
                  : _buildPhotoPreviewState(),
            ),
          ),
        ),
      ),
    );
  }

  // 📸 VÙNG CAMERA TRỐNG (CHƯA CHỤP)
  Widget _buildEmptyCameraState(dynamic appColors, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _openCameraFlow,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: appColors.cardBackground,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.02,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: appColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: appColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.camera_fill,
                    color: appColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.tapToCapture.toUpperCase(),
                  style: TextStyle(
                    color: appColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Locket & Instagram Aesthetic",
                  style: TextStyle(
                    color: appColors.textMuted.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🖼️ KHUNG PREVIEW ĐÃ CÓ ẢNH: Siêu tối giản, tập trung 100% vào bức ảnh
  Widget _buildPhotoPreviewState() {
    return Stack(
      children: [
        // ⚡ CHẠM VÀO ẢNH ĐỂ CHỤP LẠI (Vùng cảm ứng toàn màn hình)
        Positioned.fill(
          child: GestureDetector(
            onTap: _openCameraFlow,
            child: Image.file(
              File(widget.initialImagePath!),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 🎨 NÚT EDIT: Biến thành icon kính mờ nhỏ nhắn ở góc phải, cực kỳ sang trọng
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: _openEditFlow,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50), // Hình tròn hoàn toàn
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ), // Kích thước nút được thu nhỏ
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.3,
                    ), // Mờ đen nhẹ nhàng
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ), // Viền trắng mờ để tách biệt với nền ảnh
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: Colors.white,
                    size: 18, // Icon nhỏ gọn không chắn tầm nhìn
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
