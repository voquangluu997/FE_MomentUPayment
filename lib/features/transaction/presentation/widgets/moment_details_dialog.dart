import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/features/camera/screens/full_screen_image_viewer.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/utils/number_format_util.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../transaction_provider.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';

// Đồng bộ danh mục và màn hình camera/edit từ hệ thống
import 'package:moment_u_payment/core/utils/category_helper.dart';
import 'package:moment_u_payment/features/camera/screens/custom_camera_screen.dart';
import 'package:moment_u_payment/features/camera/screens/edit_photo_screen.dart';

class MomentDetailsDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> moment;
  final AppLocalizations l10n;

  const MomentDetailsDialog({
    super.key,
    required this.moment,
    required this.l10n,
  });

  @override
  ConsumerState<MomentDetailsDialog> createState() =>
      _MomentDetailsDialogState();
}

class _MomentDetailsDialogState extends ConsumerState<MomentDetailsDialog> {
  bool _isEditing = false;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _customCategoryController;
  DateTime _selectedDate = DateTime.now();

  late String _selectedCategory;
  String _selectedEmoji = '📝';
  String? _localImagePath;
  late String _currentImageUrl;
  bool _isCustomCategory = false;

  bool _isImageUploading = false;
  String? _tempUploadedUrl;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.moment['imageUrl'] ?? '';
    final originalCategory = widget.moment['category'] ?? '';
    _selectedEmoji = widget.moment['emoji'] ?? '📝';

    final double rawAmount = (widget.moment['amount'] ?? 0).toDouble();
    _amountController = TextEditingController(
      text: NumberFormatUtil.formatNumber(rawAmount.toInt().toString()),
    );
    _noteController = TextEditingController(text: widget.moment['note'] ?? '');

    // Lấy danh sách ID danh mục chuẩn từ CategoryHelper để kiểm tra custom category
    final defaultCats = CategoryHelper.getTransactionCategories(widget.l10n);
    final standardCategoryIds = defaultCats
        .map((c) => c['id'].toString())
        .where((id) => id != 'Custom')
        .toList();

    if (originalCategory.isNotEmpty &&
        !standardCategoryIds.contains(originalCategory)) {
      _isCustomCategory = true;
      _selectedCategory = 'Custom';
      _customCategoryController = TextEditingController(text: originalCategory);
    } else {
      _isCustomCategory = false;
      _selectedCategory = originalCategory.isEmpty ? 'Food' : originalCategory;
      _customCategoryController = TextEditingController();
    }

    if (widget.moment['spentAt'] != null) {
      _selectedDate =
          DateTime.tryParse(widget.moment['spentAt'].toString())?.toLocal() ??
          DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _cleanupUnsavedImage() async {
    if (!_isSaved && _tempUploadedUrl != null) {
      try {
        debugPrint("🗑 Dọn rác Cloudinary ảnh không lưu: $_tempUploadedUrl");
        await ref
            .read(transactionProvider.notifier)
            .deleteImage(_tempUploadedUrl!);
      } catch (e) {
        debugPrint("Lỗi dọn rác: $e");
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initialDateToShow = _selectedDate;
    if (initialDateToShow.isAfter(now)) {
      initialDateToShow = now;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDateToShow,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        final appColors = ref.read(appColorsProvider);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColors.primary,
              onPrimary: Colors.white,
              surface: appColors.cardBackground,
              onSurface: appColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onAmountChanged(String value) {
    String cleanStr = NumberFormatUtil.cleanValue(value);
    if (cleanStr.isEmpty) {
      _amountController.text = '';
      return;
    }
    String formatted = NumberFormatUtil.formatNumber(cleanStr);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _appendZeros(String zeros) {
    final text = _amountController.text.replaceAll('.', '').trim();
    if (text.isEmpty || text == '0') return;
    _onAmountChanged(text + zeros);
  }

  // Mở Custom Camera (nút chọn gallery đã tích hợp bên trong CustomCameraScreen)
  Future<void> _changePhoto() async {
    try {
      final imagePath = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const CustomCameraScreen()),
      );

      // Khi chụp xong, quay thẳng lại màn hình detail chứ không tự mở màn hình edit ảnh
      if (imagePath != null && mounted) {
        if (_tempUploadedUrl != null) {
          _cleanupUnsavedImage();
          _tempUploadedUrl = null;
        }

        setState(() {
          _localImagePath = imagePath;
          _isImageUploading = true;
        });

        // Tiến hành upload bản gốc lên luôn (mặc định không edit)
        _uploadImageBackground(File(imagePath));
      }
    } catch (e) {
      debugPrint("Lỗi xử lý camera: $e");
    }
  }

  // Hàm xử lý khi người dùng chủ động nhấn nút Edit ở góc của ảnh
  Future<void> _editCurrentPhoto() async {
    if (_localImagePath == null) return;
    try {
      final String? editedPath = await Navigator.push<String?>(
        context,
        MaterialPageRoute(
          builder: (_) => EditPhotoScreen(imagePath: _localImagePath!),
        ),
      );

      if (editedPath != null && mounted) {
        setState(() {
          _localImagePath = editedPath;
          _isImageUploading = true;
        });
        // Upload đè bản ảnh mới đã qua chỉnh sửa lên hệ thống
        _uploadImageBackground(File(editedPath));
      }
    } catch (e) {
      debugPrint("Lỗi khi chỉnh sửa ảnh: $e");
    }
  }

  Future<void> _uploadImageBackground(File file) async {
    try {
      final url = await ref
          .read(transactionProvider.notifier)
          .uploadImageOnly(file.path);
      if (mounted) {
        setState(() {
          if (url != null) {
            _tempUploadedUrl = url;
          }
          _isImageUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImageUploading = false);
        AppToast.showError(
          context,
          "Lỗi tải ảnh lên",
          ref.read(appColorsProvider),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _cleanupUnsavedImage();
        _localImagePath = null;
        _tempUploadedUrl = null;

        _selectedCategory = widget.moment['category'] ?? '';
        final double rawAmount = (widget.moment['amount'] ?? 0).toDouble();
        _amountController.text = NumberFormatUtil.formatNumber(
          rawAmount.toInt().toString(),
        );
        _noteController.text = widget.moment['note'] ?? '';
        if (widget.moment['spentAt'] != null) {
          _selectedDate =
              DateTime.tryParse(
                widget.moment['spentAt'].toString(),
              )?.toLocal() ??
              DateTime.now();
        }
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _handleUpdateTransaction() async {
    final appColors = ref.read(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    if (_isImageUploading) {
      AppToast.showError(
        context,
        "Đang tải ảnh lên, vui lòng đợi trong giây lát!",
        appColors,
      );
      return;
    }

    final amountText = _amountController.text.replaceAll('.', '').trim();
    if (amountText.isEmpty) return;

    String finalCategory = _selectedCategory;
    if (_isCustomCategory) {
      finalCategory = _customCategoryController.text.trim().isNotEmpty
          ? _customCategoryController.text.trim()
          : l10n.categoryOther ?? 'Khác';
    }

    final String momentId =
        widget.moment['id']?.toString() ??
        widget.moment['_id']?.toString() ??
        '';

    if (momentId.isEmpty) {
      AppToast.showError(context, l10n.updateFailed, appColors);
      return;
    }

    try {
      final spentAtWithCurrentTime =
          DateTimeHelper.combineDateWithCurrentTimeUtc(_selectedDate);

      await ref
          .read(transactionProvider.notifier)
          .updateTransaction(
            id: momentId,
            amount: double.parse(amountText),
            category: finalCategory,
            emoji: _selectedEmoji,
            note: _noteController.text.trim(),
            imageUrl: _tempUploadedUrl,
            localImagePath: null,
            spentAt: spentAtWithCurrentTime,
          );

      if (mounted) {
        _isSaved = true;
        AppToast.showSuccess(context, l10n.txSuccessMessage, appColors);
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
        ref.read(notificationProvider.notifier).fetchUnreadCount();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, l10n.txErrorMessage, appColors);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final txState = ref.watch(transactionProvider);

    final double currentAmount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final String compactAmount =
        '-${CurrencyHelper.formatCompactAmount(currentAmount)}';

    return PopScope(
      canPop: !_isImageUploading,
      onPopInvoked: (didPop) {
        if (!didPop && _isImageUploading) {
          AppToast.showError(
            context,
            "Chờ xíu, ảnh đang được tải lên nhé!",
            appColors,
          );
          return;
        }
        if (didPop) _cleanupUnsavedImage();
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: appColors.cardBackground,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImageHeader(
                isEditing: _isEditing,
                localImagePath: _localImagePath,
                currentImageUrl: _currentImageUrl,
                emoji: _selectedEmoji,
                isImageUploading: _isImageUploading,
                moment: widget.moment,
                onCameraTap: _changePhoto,
                onEditPhotoTap: _editCurrentPhoto,
                onToggleEdit: _toggleEditMode,
                onCloseTap: () {
                  if (_isImageUploading) {
                    AppToast.showError(
                      context,
                      "Chờ xíu, ảnh đang được tải lên nhé!",
                      appColors,
                    );
                    return;
                  }
                  _cleanupUnsavedImage();
                  Navigator.of(context).pop(false);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: !_isEditing
                      ? _ViewModeContent(
                          selectedCategory: _selectedCategory,
                          selectedEmoji: _selectedEmoji,
                          selectedDate: _selectedDate,
                          compactAmount: compactAmount,
                          note: _noteController.text,
                        )
                      : _EditModeContent(
                          selectedCategory: _selectedCategory,
                          isCustomCategory: _isCustomCategory,
                          selectedDate: _selectedDate,
                          amountController: _amountController,
                          noteController: _noteController,
                          customCategoryController: _customCategoryController,
                          isLoading: txState == TransactionState.loading,
                          onCategorySelect: (id, emoji, isCustom) {
                            setState(() {
                              _selectedCategory = id;
                              _selectedEmoji = emoji;
                              _isCustomCategory = isCustom;
                            });
                          },
                          onDateTap: _pickDate,
                          onAmountChanged: _onAmountChanged,
                          onAppendZeros: _appendZeros,
                          onSaveTap: () => _handleUpdateTransaction(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HEADER TÍCH HỢP CAMERA HOẶC NÚT EDIT TẠI GÓC ẢNH
// =============================================================================
class _ImageHeader extends ConsumerWidget {
  final bool isEditing;
  final String? localImagePath;
  final String currentImageUrl;
  final String emoji;
  final bool isImageUploading;
  final VoidCallback onCameraTap;
  final VoidCallback onEditPhotoTap;
  final VoidCallback onToggleEdit;
  final VoidCallback onCloseTap;
  final Map<String, dynamic> moment;

  const _ImageHeader({
    required this.isEditing,
    this.localImagePath,
    required this.currentImageUrl,
    required this.emoji,
    this.isImageUploading = false,
    required this.onCameraTap,
    required this.onEditPhotoTap,
    required this.onToggleEdit,
    required this.onCloseTap,
    required this.moment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    final bool hasImage = localImagePath != null || currentImageUrl.isNotEmpty;
    final String momentId =
        moment['id']?.toString() ?? moment['_id']?.toString() ?? 'default_id';
    final String heroTag = 'moment-detail-pic-$momentId';

    return SizedBox(
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            localImagePath != null
                ? Image.file(File(localImagePath!), fit: BoxFit.cover)
                : GestureDetector(
                    onTap: isEditing
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageViewer(
                                  imageUrl:
                                      CloudinaryHelper.getOptimizedOriginalUrl(
                                        currentImageUrl,
                                      ),
                                  heroTag: heroTag,
                                ),
                              ),
                            );
                          },
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        CloudinaryHelper.getOptimizedOriginalUrl(
                          currentImageUrl,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appColors.background,
                    appColors.primary.withOpacity(0.1),
                    appColors.primary.withOpacity(0.2),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: GridPaper(
                        color: appColors.primaryDark,
                        divisions: 1,
                        subdivisions: 1,
                        interval: 24,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: appColors.primary.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 48)),
                    ),
                  ),
                ],
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(isEditing ? 0.4 : 0.05),
                      Colors.transparent,
                      appColors.cardBackground.withOpacity(0.0),
                      appColors.cardBackground,
                    ],
                    stops: const [0.0, 0.3, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Trạng thái Loading khi đang tải ảnh lên hệ thống background
          if (isImageUploading)
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Đang tải lên...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Nút Chỉnh sửa ảnh xuất hiện ở góc dưới bên trái của ảnh để user chủ động chọn
          if (isEditing && localImagePath != null)
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildGlassButtonWithLabel(
                icon: CupertinoIcons.wand_stars,
                label: "Chỉnh sửa ảnh",
                onPressed: isImageUploading ? () {} : onEditPhotoTap,
                appColors: appColors,
              ),
            ),

          // Nút chụp ảnh hoặc thay đổi ảnh chính giữa (Đã bỏ gallery rời rạc)
          if (isEditing)
            Center(
              child: _buildEditBtn(
                icon: CupertinoIcons.camera_fill,
                label: hasImage ? "Thay đổi ảnh" : l10n.cameraPickActionShort,
                onTap: isImageUploading ? () {} : onCameraTap,
                appColors: appColors,
                isDisabled: isImageUploading,
              ),
            ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(
                  icon: isEditing
                      ? CupertinoIcons.xmark
                      : CupertinoIcons.pencil,
                  onPressed: onToggleEdit,
                  appColors: appColors,
                ),
                _buildGlassButton(
                  icon: CupertinoIcons.clear,
                  onPressed: onCloseTap,
                  appColors: appColors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    required AppColorTheme appColors,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButtonWithLabel({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required AppColorTheme appColors,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppColorTheme appColors,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isDisabled ? Colors.grey : appColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.grey : appColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// GIAO DIỆN VIEW (Giữ Nguyên)
// =============================================================================
class _ViewModeContent extends ConsumerWidget {
  final String selectedCategory;
  final String selectedEmoji;
  final DateTime selectedDate;
  final String compactAmount;
  final String note;

  const _ViewModeContent({
    required this.selectedCategory,
    required this.selectedEmoji,
    required this.selectedDate,
    required this.compactAmount,
    required this.note,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final formattedDate =
        "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";

    return Column(
      key: const ValueKey('ViewMode'),
      children: [
        Text(
          compactAmount,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: appColors.errorAccent,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedEmoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    selectedCategory.isNotEmpty
                        ? selectedCategory
                        : l10n.emptyTransactionNote,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: appColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: appColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 14,
                    color: appColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: appColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appColors.primary.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.quote_bubble_fill,
                color: appColors.primary.withOpacity(0.2),
                size: 20,
              ),
              const SizedBox(height: 8),
              Text(
                note.isNotEmpty ? note : l10n.emptyTransactionNote,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: appColors.primaryDark.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// GIAO DIỆN EDIT (Đồng bộ danh mục từ CategoryHelper)
// =============================================================================
class _EditModeContent extends ConsumerWidget {
  final String selectedCategory;
  final bool isCustomCategory;
  final DateTime selectedDate;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final TextEditingController customCategoryController;
  final bool isLoading;

  final Function(String id, String emoji, bool isCustom) onCategorySelect;
  final VoidCallback onDateTap;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onAppendZeros;
  final VoidCallback onSaveTap;

  const _EditModeContent({
    required this.selectedCategory,
    required this.isCustomCategory,
    required this.selectedDate,
    required this.amountController,
    required this.noteController,
    required this.customCategoryController,
    required this.isLoading,
    required this.onCategorySelect,
    required this.onDateTap,
    required this.onAmountChanged,
    required this.onAppendZeros,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    // Đồng bộ danh mục sử dụng CategoryHelper chuẩn của hệ thống giống AddTransactionScreen
    final List<Map<String, dynamic>> categories =
        CategoryHelper.getTransactionCategories(l10n);

    return Column(
      key: const ValueKey('EditMode'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(l10n.categorySectionTitle.toUpperCase(), appColors),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final id = cat['id']?.toString() ?? '';
              final name = cat['name']?.toString() ?? '';
              final emoji = cat['emoji']?.toString() ?? '📝';
              final isSelected = selectedCategory == id;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => onCategorySelect(id, emoji, id == 'Custom'),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? appColors.primary
                          : appColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : appColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : appColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        if (isCustomCategory) ...[
          const SizedBox(height: 12),
          TextField(
            controller: customCategoryController,
            style: TextStyle(
              color: appColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: l10n.customCategoryHint,
              hintStyle: TextStyle(
                color: appColors.primaryDark.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                CupertinoIcons.tag,
                color: appColors.primary,
                size: 18,
              ),
              filled: true,
              fillColor: appColors.background,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildSectionTitle(l10n.amountSectionTitle, appColors),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShortcutZeroButton(
                  '.000',
                  () => onAppendZeros('000'),
                  appColors,
                ),
                const SizedBox(width: 8),
                _buildShortcutZeroButton(
                  '.000.000',
                  () => onAppendZeros('000000'),
                  appColors,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: appColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appColors.primary.withOpacity(0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onChanged: onAmountChanged,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: appColors.errorAccent,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: amountController,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      amountController.clear();
                      onAmountChanged('');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        CupertinoIcons.clear_circled_solid,
                        color: appColors.textMuted.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              Text(
                currencySymbol,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appColors.errorAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionTitle(l10n.transactionTime, appColors),
        const SizedBox(height: 8),
        InkWell(
          onTap: onDateTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: appColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: appColors.primary.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar_today,
                  size: 20,
                  color: appColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: appColors.primaryDark,
                  ),
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.pencil,
                  size: 16,
                  color: appColors.textMuted.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionTitle(l10n.noteSectionTitle, appColors),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          maxLines: 2,
          minLines: 1,
          style: TextStyle(
            fontSize: 14,
            color: appColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: l10n.noteHint,
            hintStyle: TextStyle(color: appColors.primaryDark.withOpacity(0.4)),
            filled: true,
            fillColor: appColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: isLoading ? null : onSaveTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: appColors.primary.withOpacity(0.4),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  l10n.update,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, dynamic appColors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: appColors.textMuted,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildShortcutZeroButton(
    String label,
    VoidCallback onTap,
    dynamic appColors,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: appColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: appColors.primary,
          ),
        ),
      ),
    );
  }
}
