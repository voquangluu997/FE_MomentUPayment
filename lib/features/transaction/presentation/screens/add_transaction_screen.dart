import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/media_service.dart';
import '../transaction_provider.dart';
import '../controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';

// ==========================================
// 🛠️ UTILS LOGIC (Tách logic để tái sử dụng)
// ==========================================
class NumberFormatUtil {
  static String formatNumber(String s) {
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

  static String cleanValue(String value) {
    String clean = value.replaceAll('.', '');
    if (clean.length > 1 && clean.startsWith('0')) {
      clean = clean.replaceFirst(RegExp(r'^0+'), '');
    }
    return clean;
  }
}

// ==========================================
// 📱 MÀN HÌNH CHÍNH
// ==========================================
class AddTransactionScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const AddTransactionScreen({super.key, this.initialDate});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _mediaService = MediaService();
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'Food';
  String _selectedEmoji = '🍰';
  String? _localImagePath;
  bool _isCustomCategory = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // --- LOGIC XỬ LÝ SỰ KIỆN ---

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ref.read(appColorsProvider).primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _openCamera() async {
    try {
      final photo = await _mediaService.takePhoto();
      if (photo != null) setState(() => _localImagePath = photo.path);
    } catch (e) {
      debugPrint("Lỗi khi mở camera: $e");
    }
  }

  Future<void> _openGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1080,
      );
      if (photo != null) setState(() => _localImagePath = photo.path);
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh từ thư viện: $e");
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

  void _handleSaveTransaction() {
    final amountText = _amountController.text.replaceAll('.', '').trim();
    final appColors = ref.read(appColorsProvider);

    if (amountText.isEmpty) {
      AppToast.showError(
        context,
        'Vui lòng nhập số tiền hợp lệ nha! 💸',
        appColors,
      );
      return;
    }

    String finalCategory = _selectedCategory;
    if (_isCustomCategory) {
      finalCategory = _customCategoryController.text.trim().isNotEmpty
          ? _customCategoryController.text.trim()
          : 'Khác';
    }

    final now = DateTime.now();
    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    ref
        .read(transactionProvider.notifier)
        .addTransaction(
          amount: double.parse(amountText),
          category: finalCategory,
          emoji: _selectedEmoji,
          note: _noteController.text.trim(),
          localImagePath: _localImagePath,
          spentAt: finalDateTime,
        );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final txState = ref.watch(transactionProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (next == TransactionState.success) {
        AppToast.showSuccess(context, l10n.txSuccessMessage, appColors);
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (next == TransactionState.error) {
        AppToast.showError(context, l10n.txErrorMessage, appColors);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        appBar: AppBar(
          title: Text(
            l10n.newMomentTitle,
            style: TextStyle(
              color: appColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: appColors.primary),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Ảnh chụp / Thư viện
                _ImageSelector(
                  imagePath: _localImagePath,
                  onCameraTap: _openCamera,
                  onGalleryTap: _openGallery,
                ),
                const SizedBox(height: 12),

                // 2. Chọn Ngày
                _DateSelector(selectedDate: _selectedDate, onTap: _pickDate),
                const SizedBox(height: 18),

                // 3. Danh mục
                _CategorySelector(
                  selectedCategory: _selectedCategory,
                  onSelect: (id, emoji, isCustom) {
                    setState(() {
                      _selectedCategory = id;
                      _selectedEmoji = emoji;
                      _isCustomCategory = isCustom;
                    });
                  },
                ),

                if (_isCustomCategory) ...[
                  const SizedBox(height: 8),
                  _CustomCategoryInput(controller: _customCategoryController),
                ],
                const SizedBox(height: 18),

                // 4. Nhập số tiền (Đã sửa lỗi phình layout)
                _AmountInput(
                  controller: _amountController,
                  onChanged: _onAmountChanged,
                  onAppendZeros: _appendZeros,
                ),
                const SizedBox(height: 18),

                // 5. Ghi chú
                _NoteInput(controller: _noteController),
                const SizedBox(height: 24),

                // 6. Nút Lưu
                _SaveButton(
                  isLoading: txState == TransactionState.loading,
                  onPressed: _handleSaveTransaction,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🧩 WIDGETS ĐÃ ĐƯỢC TÁCH RỜI & TỐI ƯU
// ==========================================

class _ImageSelector extends ConsumerWidget {
  final String? imagePath;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const _ImageSelector({
    this.imagePath,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onCameraTap,
          child: Container(
            height: 245,
            decoration: BoxDecoration(
              color: appColors.cardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: appColors.primary.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_enhance_outlined,
                        size: 48,
                        color: appColors.primary,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.cameraTapInstruction,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: TextButton.icon(
            onPressed: onGalleryTap,
            icon: Icon(
              Icons.photo_library_rounded,
              color: appColors.primary,
              size: 16,
            ),
            label: Text(
              imagePath != null
                  ? l10n.galleryChangeAction
                  : l10n.galleryPickAction,
              style: TextStyle(
                color: appColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends ConsumerWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const _DateSelector({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: appColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: appColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd/MM/yyyy').format(selectedDate),
              style: TextStyle(
                color: appColors.text,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.edit_calendar_rounded,
              color: appColors.textMuted.withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelector extends ConsumerWidget {
  final String selectedCategory;
  final Function(String id, String emoji, bool isCustom) onSelect;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> categories = [
      {'id': 'Food', 'name': l10n.catFood, 'emoji': '🍰'},
      {'id': 'Shopping', 'name': l10n.catShopping, 'emoji': '🛍️'},
      {'id': 'Transport', 'name': l10n.catTransport, 'emoji': '🚗'},
      {'id': 'Entertainment', 'name': l10n.catEntertainment, 'emoji': '🎮'},
      {'id': 'Custom', 'name': l10n.catCustom, 'emoji': '📝'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categorySectionTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: appColors.primaryDark.withOpacity(0.6),
            letterSpacing: 0.8,
          ),
        ),
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
                  onTap: () =>
                      onSelect(cat['id'], cat['emoji'], cat['id'] == 'Custom'),
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
                            : appColors.primary.withOpacity(0.04),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat['emoji'],
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : appColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
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
      ],
    );
  }
}

class _CustomCategoryInput extends ConsumerWidget {
  final TextEditingController controller;

  const _CustomCategoryInput({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: controller,
      style: TextStyle(color: appColors.text),
      decoration: InputDecoration(
        hintText: l10n.customCategoryHint,
        hintStyle: TextStyle(color: appColors.textMuted),
        prefixIcon: Icon(Icons.edit_note_rounded, color: appColors.primary),
        filled: true,
        fillColor: appColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: appColors.primary.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: appColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ==========================================
// 🚀 NƠI FIX LỖI PHÌNH TO TEXTFIELD
// ==========================================
class _AmountInput extends ConsumerWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onAppendZeros;

  const _AmountInput({
    required this.controller,
    required this.onChanged,
    required this.onAppendZeros,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.amountSectionTitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: appColors.primaryDark.withOpacity(0.6),
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                _buildShortcutButton(
                  '.000',
                  () => onAppendZeros('000'),
                  appColors,
                ),
                const SizedBox(width: 6),
                _buildShortcutButton(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: appColors.primary.withOpacity(0.06),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa trục dọc
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: appColors.primary.withOpacity(0.2),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true, // Ép chặt khoảng cách trống thừa
                  ),
                ),
              ),
              // 💡 GIẢI PHÁP: Nhấc ValueListenableBuilder chứa nút X ra khỏi InputDecoration
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.cancel_rounded,
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
                  color: appColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutButton(
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

class _NoteInput extends ConsumerWidget {
  final TextEditingController controller;

  const _NoteInput({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.noteSectionTitle,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: appColors.primaryDark.withOpacity(0.6),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(color: appColors.text),
          decoration: InputDecoration(
            hintText: l10n.noteHint,
            hintStyle: TextStyle(color: appColors.textMuted),
            filled: true,
            fillColor: appColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends ConsumerWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SaveButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appColors.primary),
        ),
      );
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: appColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          l10n.saveMomentButton,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
