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
  DateTime _selectedDate = DateTime.now();

  final _mediaService = MediaService();
  final ImagePicker _picker = ImagePicker();

  late String _selectedCategory;
  String _selectedEmoji = '📝';
  String? _localImagePath;
  late String _currentImageUrl;
  bool _isCustomCategory = false;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
    final appColors = ref.watch(appColorsProvider);

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

    final double currentAmount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final String compactAmount =
        '-${CurrencyHelper.formatCompactAmount(currentAmount)}$currencySymbol';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: appColors.cardBackground,
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
                          color: appColors.primary.withOpacity(0.04),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(_selectedCategory),
                              size: 64,
                              color: appColors.primary.withOpacity(0.15),
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
                                foregroundColor: appColors.primary,
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
                                foregroundColor: appColors.primary,
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
                    ? _buildViewMode(compactAmount, appColors)
                    : _buildEditMode(
                        categories,
                        currencySymbol,
                        txState,
                        appColors,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode(String compactAmount, AppColorTheme appColors) {
    final formattedDate =
        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    return Column(
      key: const ValueKey('ViewMode'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(_selectedCategory),
                          size: 14,
                          color: appColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _selectedCategory.isNotEmpty
                                ? _selectedCategory
                                : widget.l10n.emptyTransactionNote,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: appColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: appColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: appColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              compactAmount,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: appColors.errorAccent,
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
            color: appColors.primaryDark.withOpacity(0.6),
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
    AppColorTheme appColors,
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
            color: appColors.primaryDark.withOpacity(0.5),
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
                          ? appColors.primary
                          : appColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : appColors.primary.withOpacity(0.08),
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
                            color: isSelected
                                ? Colors.white
                                : appColors.primaryDark,
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
            style: TextStyle(color: appColors.primaryDark),
            decoration: InputDecoration(
              hintText: widget.l10n.customCategoryHint,
              hintStyle: TextStyle(
                color: appColors.primaryDark.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.edit_note_rounded,
                color: appColors.primary,
                size: 18,
              ),
              filled: true,
              fillColor: appColors.background,
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
                  color: appColors.primaryDark.withOpacity(0.5),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShortcutZeroButton(
                  '.000',
                  () => _appendZeros('000'),
                  appColors,
                ),
                const SizedBox(width: 4),
                _buildShortcutZeroButton(
                  '.000.000',
                  () => _appendZeros('000000'),
                  appColors,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: appColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appColors.primary.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: _onAmountChanged,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primary,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "THỜI GIAN GIAO DỊCH",
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: appColors.primaryDark.withOpacity(0.5),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: appColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appColors.primary.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: appColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: appColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit_calendar_rounded,
                    size: 16,
                    color: appColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          widget.l10n.noteSectionTitle,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: appColors.primaryDark.withOpacity(0.5),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          style: TextStyle(fontSize: 13.5, color: appColors.primaryDark),
          decoration: InputDecoration(
            hintText: widget.l10n.noteHint,
            hintStyle: TextStyle(color: appColors.primaryDark.withOpacity(0.5)),
            filled: true,
            fillColor: appColors.background,
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
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      appColors.primary,
                    ),
                  ),
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.primary,
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

                  final String momentId =
                      widget.moment['id']?.toString() ??
                      widget.moment['_id']?.toString() ??
                      '';

                  if (momentId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Không tìm thấy ID của khoảnh khắc để cập nhật!',
                        ),
                        backgroundColor: appColors.errorAccent,
                      ),
                    );
                    return;
                  }

                  try {
                    // 🌟 XỬ LÝ GỘP THỜI GIAN: Ngày (từ Date Picker) + Giờ hiện tại (từ DateTime.now())
                    final now = DateTime.now();
                    final spentAtWithCurrentTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      now.hour,
                      now.minute,
                      now.second,
                    );

                    await ref
                        .read(transactionProvider.notifier)
                        .updateTransaction(
                          id: momentId,
                          amount: double.parse(amountText),
                          category: finalCategory,
                          emoji: _selectedEmoji,
                          note: _noteController.text.trim(),
                          localImagePath: _localImagePath,
                          // Gửi chuỗi ISO đã gộp ngày chọn và giờ hiện tại
                          spentAt: spentAtWithCurrentTime,
                        );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Cập nhật khoảnh khắc thành công! 🎉',
                          ),
                          backgroundColor: appColors.success,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cập nhật thất bại: $e'),
                          backgroundColor: appColors.errorAccent,
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

  Widget _buildShortcutZeroButton(
    String label,
    VoidCallback onTap,
    AppColorTheme appColors,
  ) {
    return Material(
      color: appColors.primary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: appColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
