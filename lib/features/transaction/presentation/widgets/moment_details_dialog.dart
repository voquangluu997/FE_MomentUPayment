import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/utils/number_format_util.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/services/media_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../transaction_provider.dart';

// ==========================================
// 📱 DIALOG CHÍNH
// ==========================================
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

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.moment['imageUrl'] ?? '';
    _selectedCategory = widget.moment['category'] ?? '';

    final double rawAmount = (widget.moment['amount'] ?? 0).toDouble();
    _amountController = TextEditingController(
      text: NumberFormatUtil.formatNumber(rawAmount.toInt().toString()),
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

  Future<void> _changePhoto(ImageSource source) async {
    try {
      final photo = source == ImageSource.camera
          ? await _mediaService.takePhoto()
          : await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 75,
              maxWidth: 1080,
            );

      if (photo != null) {
        setState(() => _localImagePath = photo.path);
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _localImagePath = null;
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
    final amountText = _amountController.text.replaceAll('.', '').trim();
    final appColors = ref.read(appColorsProvider);

    if (amountText.isEmpty) return;

    String finalCategory = _selectedCategory;
    if (_isCustomCategory) {
      finalCategory = _customCategoryController.text.trim().isNotEmpty
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
          content: const Text('Không tìm thấy ID của khoảnh khắc để cập nhật!'),
          backgroundColor: appColors.errorAccent,
        ),
      );
      return;
    }

    try {
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
            spentAt: spentAtWithCurrentTime,
          );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint("Lỗi cập nhật: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final currencySymbol = ref.watch(currencyProvider);
    final txState = ref.watch(transactionProvider);

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
            _ImageHeader(
              isEditing: _isEditing,
              localImagePath: _localImagePath,
              currentImageUrl: _currentImageUrl,
              selectedCategory: _selectedCategory,
              onCameraTap: () => _changePhoto(ImageSource.camera),
              onGalleryTap: () => _changePhoto(ImageSource.gallery),
              onToggleEdit: _toggleEditMode,
              onCloseTap: () => Navigator.of(context).pop(false),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: !_isEditing
                    ? _ViewModeContent(
                        selectedCategory: _selectedCategory,
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
    );
  }
}

// ==========================================
// 🧩 WIDGETS ĐÃ ĐƯỢC TÁCH RỜI & SỬA LỖI
// ==========================================

class _ImageHeader extends ConsumerWidget {
  final bool isEditing;
  final String? localImagePath;
  final String currentImageUrl;
  final String selectedCategory;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onToggleEdit;
  final VoidCallback onCloseTap;

  const _ImageHeader({
    required this.isEditing,
    this.localImagePath,
    required this.currentImageUrl,
    required this.selectedCategory,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onToggleEdit,
    required this.onCloseTap,
  });

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.help_outline_rounded;
    final catLower = category.toLowerCase();
    if (catLower.contains('food') || catLower.contains('ăn'))
      return Icons.cake_rounded;
    if (catLower.contains('shop')) return Icons.local_mall_rounded;
    if (catLower.contains('transport') || catLower.contains('xe'))
      return Icons.directions_car_rounded;
    if (catLower.contains('entertain') || catLower.contains('game'))
      return Icons.sports_esports_rounded;
    return Icons.edit_note_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          localImagePath != null
              ? Image.file(File(localImagePath!), fit: BoxFit.cover)
              : currentImageUrl.isNotEmpty
              ? Image.network(
                  CloudinaryHelper.getOptimizedOriginalUrl(currentImageUrl),
                  fit: BoxFit.cover,
                )
              : Container(
                  color: appColors.primary.withOpacity(0.04),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(selectedCategory),
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
                    Colors.black.withOpacity(isEditing ? 0.4 : 0.1),
                  ],
                  stops: const [0.0, 0.25, 0.7, 1.0],
                ),
              ),
            ),
          ),
          if (isEditing)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: _editButtonStyle(appColors),
                      onPressed: onCameraTap,
                      icon: const Icon(Icons.camera_alt_rounded, size: 16),
                      label: Text(
                        l10n.cameraPickActionShort,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: _editButtonStyle(appColors),
                      onPressed: onGalleryTap,
                      icon: const Icon(Icons.photo_library_rounded, size: 16),
                      label: Text(
                        l10n.galleryChangeActionShort,
                        style: const TextStyle(
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
                _buildActionButton(
                  icon: isEditing ? Icons.close_rounded : Icons.edit_rounded,
                  onPressed: onToggleEdit,
                ),
                _buildActionButton(
                  icon: Icons.power_settings_new_rounded,
                  onPressed: onCloseTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _editButtonStyle(AppColorTheme appColors) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.9),
      foregroundColor: appColors.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.5),
      radius: 16,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}

class _ViewModeContent extends ConsumerWidget {
  final String selectedCategory;
  final DateTime selectedDate;
  final String compactAmount;
  final String note;

  const _ViewModeContent({
    required this.selectedCategory,
    required this.selectedDate,
    required this.compactAmount,
    required this.note,
  });

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.help_outline_rounded;
    final catLower = category.toLowerCase();
    if (catLower.contains('food') || catLower.contains('ăn'))
      return Icons.cake_rounded;
    if (catLower.contains('shop')) return Icons.local_mall_rounded;
    if (catLower.contains('transport') || catLower.contains('xe'))
      return Icons.directions_car_rounded;
    if (catLower.contains('entertain') || catLower.contains('game'))
      return Icons.sports_esports_rounded;
    return Icons.edit_note_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final formattedDate =
        "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";

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
                          _getCategoryIcon(selectedCategory),
                          size: 14,
                          color: appColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            selectedCategory.isNotEmpty
                                ? selectedCategory
                                : l10n.emptyTransactionNote,
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
          note.isNotEmpty ? note : l10n.emptyTransactionNote,
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
}

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

    final List<Map<String, dynamic>> categories = [
      {'id': 'Food', 'name': l10n.catFood, 'emoji': '🍰'},
      {'id': 'Shopping', 'name': l10n.catShopping, 'emoji': '🛍️'},
      {'id': 'Transport', 'name': l10n.catTransport, 'emoji': '🚗'},
      {'id': 'Entertainment', 'name': l10n.catEntertainment, 'emoji': '🎮'},
      {'id': 'Custom', 'name': l10n.catCustom, 'emoji': '📝'},
    ];

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
              final isSelected = selectedCategory == cat['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: InkWell(
                  onTap: () => onCategorySelect(
                    cat['id']!,
                    cat['emoji']!,
                    cat['id'] == 'Custom',
                  ),
                  borderRadius: BorderRadius.circular(10),
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

        if (isCustomCategory) ...[
          const SizedBox(height: 8),
          TextField(
            controller: customCategoryController,
            style: TextStyle(color: appColors.primaryDark),
            decoration: InputDecoration(
              hintText: l10n.customCategoryHint,
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
                const SizedBox(width: 4),
                _buildShortcutZeroButton(
                  '.000.000',
                  () => onAppendZeros('000000'),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onChanged: onAmountChanged,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true, // Ép sát text field không có padding thừa
                  ),
                ),
              ),
              // 🚀 CÁCH KHẮC PHỤC TRIỆT ĐỂ: Nhấc nút X ra khỏi InputDecoration
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
                        Icons.cancel_rounded,
                        color: appColors.textMuted.withOpacity(0.4),
                        size: 18,
                      ),
                    ),
                  );
                },
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

        _buildSectionTitle("THỜI GIAN GIAO DỊCH", appColors),
        const SizedBox(height: 6),
        InkWell(
          onTap: onDateTap,
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
                  "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
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
        const SizedBox(height: 16),

        _buildSectionTitle(l10n.noteSectionTitle, appColors),
        const SizedBox(height: 6),
        TextField(
          controller: noteController,
          style: TextStyle(fontSize: 13.5, color: appColors.primaryDark),
          decoration: InputDecoration(
            hintText: l10n.noteHint,
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

        isLoading
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
                onPressed: onSaveTap,
                child: const Text(
                  'Cập nhật',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, AppColorTheme appColors) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: appColors.primaryDark.withOpacity(0.5),
        letterSpacing: 0.8,
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
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
