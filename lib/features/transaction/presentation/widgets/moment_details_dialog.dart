import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/services/media_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../transaction_provider.dart';

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

  final _mediaService = MediaService();
  final ImagePicker _picker = ImagePicker();

  late String _selectedCategory;
  String _selectedEmoji = '📝';
  String? _localImagePath;
  late String _currentImageUrl;
  bool _isCustomCategory = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.moment['imageUrl'] ?? '';
    _selectedCategory = widget.moment['category'] ?? '';

    final double rawAmount = (widget.moment['amount'] ?? 0).toDouble();
    _amountController = TextEditingController(
      text: _formatNumber(rawAmount.toInt().toString()),
    );

    _noteController = TextEditingController(text: widget.moment['note'] ?? '');
    _customCategoryController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  String _formatNumber(String s) {
    String digits = s.replaceAll('.', '');
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  void _onAmountChanged(String value) {
    String cleanValue = value.replaceAll('.', '');
    if (cleanValue.isEmpty) {
      _amountController.text = '';
      return;
    }
    if (cleanValue.length > 1 && cleanValue.startsWith('0')) {
      cleanValue = cleanValue.replaceFirst(RegExp(r'^0+'), '');
    }
    String formatted = _formatNumber(cleanValue);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _appendZeros(String zeros) {
    final text = _amountController.text.replaceAll('.', '').trim();
    if (text.isEmpty || text == '0') return;

    String newText = text + zeros;
    String formatted = _formatNumber(newText);

    setState(() {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  Future<void> _changePhotoFromCamera() async {
    try {
      final photo = await _mediaService.takePhoto();
      if (photo != null) {
        setState(() {
          _localImagePath = photo.path;
        });
      }
    } catch (e) {
      debugPrint("Lỗi camera: $e");
    }
  }

  Future<void> _changePhotoFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1080,
      );
      if (photo != null) {
        setState(() {
          _localImagePath = photo.path;
        });
      }
    } catch (e) {
      debugPrint("Lỗi thư viện: $e");
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.help_outline_rounded;
    final catLower = category.toLowerCase();

    if (catLower.contains('food') || catLower.contains('ăn')) {
      return Icons.cake_rounded;
    } else if (catLower.contains('shop')) {
      return Icons.local_mall_rounded;
    } else if (catLower.contains('transport') ||
        catLower.contains('xe') ||
        catLower.contains('di chuyển')) {
      return Icons.directions_car_rounded;
    } else if (catLower.contains('entertain') ||
        catLower.contains('game') ||
        catLower.contains('giải trí')) {
      return Icons.sports_esports_rounded;
    }
    return Icons.edit_note_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencyProvider);
    final txState = ref.watch(transactionProvider);

    final List<Map<String, dynamic>> categories = [
      {'id': 'Food', 'name': widget.l10n.catFood, 'emoji': '🍰'},
      {'id': 'Shopping', 'name': widget.l10n.catShopping, 'emoji': '🛍️'},
      {'id': 'Transport', 'name': widget.l10n.catTransport, 'emoji': '🚗'},
      {
        'id': 'Entertainment',
        'name': widget.l10n.catEntertainment,
        'emoji': '🎮',
      },
      {'id': 'Custom', 'name': widget.l10n.catCustom, 'emoji': '📝'},
    ];

    // ✨ ĐÃ SỬA: Lấy số tiền real-time từ Controller thay vì lấy dữ liệu tĩnh cũ
    final double currentAmount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final String compactAmount =
        '-${CurrencyHelper.formatCompactAmount(currentAmount)}$currencySymbol';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBackground,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _localImagePath != null
                      ? Image.file(File(_localImagePath!), fit: BoxFit.cover)
                      : _currentImageUrl.isNotEmpty
                      ? Image.network(
                          CloudinaryHelper.getOptimizedOriginalUrl(
                            _currentImageUrl,
                          ),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.04),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(_selectedCategory),
                              size: 64,
                              color: AppColors.primary.withOpacity(0.15),
                            ),
                          ),
                        ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(_isEditing ? 0.4 : 0.1),
                          ],
                          stops: const [0.0, 0.25, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  if (_isEditing)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: AppColors.primary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: _changePhotoFromCamera,
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                "Chụp mới",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: AppColors.primary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: _changePhotoFromGallery,
                              icon: const Icon(
                                Icons.photo_library_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                "Thư viện",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          radius: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _isEditing
                                  ? Icons.close_rounded
                                  : Icons.edit_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isEditing) {
                                  _localImagePath = null;
                                  _selectedCategory =
                                      widget.moment['category'] ?? '';
                                  final double rawAmount =
                                      (widget.moment['amount'] ?? 0).toDouble();
                                  _amountController.text = _formatNumber(
                                    rawAmount.toInt().toString(),
                                  );
                                  _noteController.text =
                                      widget.moment['note'] ?? '';
                                }
                                _isEditing = !_isEditing;
                              });
                            },
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          radius: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.power_settings_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: !_isEditing
                    ? _buildViewMode(compactAmount)
                    : _buildEditMode(categories, currencySymbol, txState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode(String compactAmount) {
    return Column(
      key: const ValueKey('ViewMode'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(_selectedCategory),
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _selectedCategory.isNotEmpty
                            ? _selectedCategory
                            : widget.l10n.emptyTransactionNote,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              compactAmount,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.errorAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 0.5),
        const SizedBox(height: 16),
        Text(
          _noteController.text.isNotEmpty
              ? _noteController.text
              : widget.l10n.emptyTransactionNote,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark.withOpacity(0.6),
            letterSpacing: 0.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildEditMode(
    List<Map<String, dynamic>> categories,
    String currencySymbol,
    TransactionState txState,
  ) {
    return Column(
      key: const ValueKey('EditMode'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.l10n.categorySectionTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark.withOpacity(0.5),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['id']!;
                      _selectedEmoji = cat['emoji']!;
                      _isCustomCategory = cat['id'] == 'Custom';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.primary.withOpacity(0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          cat['emoji'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
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

        if (_isCustomCategory) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _customCategoryController,
            decoration: InputDecoration(
              hintText: widget.l10n.customCategoryHint,
              prefixIcon: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.l10n.amountSectionTitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark.withOpacity(0.5),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShortcutZeroButton('.000', () => _appendZeros('000')),
                const SizedBox(width: 4),
                _buildShortcutZeroButton(
                  '.000.000',
                  () => _appendZeros('000000'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: _onAmountChanged,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              Text(
                currencySymbol,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          widget.l10n.noteSectionTitle,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark.withOpacity(0.5),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: widget.l10n.noteHint,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        txState == TransactionState.loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final amountText = _amountController.text
                      .replaceAll('.', '')
                      .trim();
                  if (amountText.isEmpty) return;

                  String finalCategory = _selectedCategory;
                  if (_isCustomCategory) {
                    finalCategory =
                        _customCategoryController.text.trim().isNotEmpty
                        ? _customCategoryController.text.trim()
                        : 'Khác';
                  }

                  // 🔑 ĐÃ SỬA: Ép kiểu an toàn .toString() chống lỗi _TypeError int/String
                  final String momentId =
                      widget.moment['id']?.toString() ??
                      widget.moment['_id']?.toString() ??
                      '';

                  if (momentId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Không tìm thấy ID của khoảnh khắc để cập nhật!',
                        ),
                        backgroundColor: AppColors.errorAccent,
                      ),
                    );
                    return;
                  }

                  try {
                    // 🔥 BẮN API NGAY TẠI ĐÂY VÀ ĐỢI KẾT QUẢ
                    await ref
                        .read(transactionProvider.notifier)
                        .updateTransaction(
                          id: momentId,
                          amount: double.parse(amountText),
                          category: finalCategory,
                          emoji: _selectedEmoji,
                          note: _noteController.text.trim(),
                          localImagePath: _localImagePath,
                        );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật khoảnh khắc thành công! 🎉'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      // 🎯 TỰ ĐỘNG ĐÓNG DIALOG, trả về true báo hiệu cho Timeline reload dữ liệu
                      Navigator.of(context).pop(true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cập nhật thất bại: $e'),
                          backgroundColor: AppColors.errorAccent,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Cập nhật khoảnh khắc ✨",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
      ],
    );
  }

  Widget _buildShortcutZeroButton(String label, VoidCallback onTap) {
    return Material(
      color: AppColors.primary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
