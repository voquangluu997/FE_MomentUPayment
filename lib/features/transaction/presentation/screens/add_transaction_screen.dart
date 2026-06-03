import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/media_service.dart';
import '../transaction_provider.dart';
import '../controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';

// ==========================================
// 🛠️ UTILS LOGIC
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
// 📱 MÀN HÌNH CHÍNH - SIZE CHUẨN NỀN NÃ
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
      debugPrint("Lỗi khi chọn ảnh: $e");
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

    // 1. Lấy giờ, phút, giây hiện tại của máy user
    final now = DateTime.now();

    // 2. Tạo đối tượng DateTime Local kết hợp giữa ngày được chọn và giờ hiện tại
    final localDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    final finalDateTimeUtc = localDateTime.toUtc();

    ref
        .read(transactionProvider.notifier)
        .addTransaction(
          amount: double.parse(amountText),
          category: finalCategory,
          emoji: _selectedEmoji,
          note: _noteController.text.trim(),
          localImagePath: _localImagePath,
          spentAt: finalDateTimeUtc, // Truyền biến đã fix timezone vào đây
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
        ref.read(notificationProvider.notifier).fetchUnreadCount();
        Navigator.of(context).pop();
      } else if (next == TransactionState.error) {
        AppToast.showError(context, l10n.txErrorMessage, appColors);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.sparkles, color: appColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                l10n.newMomentTitle.toUpperCase(),
                style: TextStyle(
                  color: appColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: appColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.chevron_back,
                color: appColors.primary,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImageSelector(
                  imagePath: _localImagePath,
                  onCameraTap: _openCamera,
                  onGalleryTap: _openGallery,
                ),
                const SizedBox(height: 14),

                _DateSelector(selectedDate: _selectedDate, onTap: _pickDate),
                const SizedBox(height: 14),

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
                const SizedBox(height: 16),

                _AmountInput(
                  controller: _amountController,
                  onChanged: _onAmountChanged,
                  onAppendZeros: _appendZeros,
                ),
                const SizedBox(height: 16),

                _NoteInput(controller: _noteController),
                const SizedBox(height: 22),

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
// 🧩 WIDGETS
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onCameraTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 245,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imagePath != null
                  ? appColors.cardBackground
                  : appColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: imagePath != null
                    ? Colors.transparent
                    : appColors.primary.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(imagePath!), fit: BoxFit.cover),
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
          onTap: onGalleryTap,
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
                  imagePath != null
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
      {'id': 'Transport', 'name': l10n.catTransport, 'emoji': '🛵'},
      {'id': 'Entertainment', 'name': l10n.catEntertainment, 'emoji': '🍿'},
      {'id': 'Custom', 'name': l10n.catCustom, 'emoji': '✨'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("🏷️", style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              l10n.categorySectionTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: appColors.primaryDark.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: GestureDetector(
                  onTap: () =>
                      onSelect(cat['id'], cat['emoji'], cat['id'] == 'Custom'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                appColors.primary,
                                appColors.primaryDark,
                              ],
                            )
                          : null,
                      color: isSelected ? null : appColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : appColors.primary.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat['emoji'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : appColors.text,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
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
      style: TextStyle(
        color: appColors.text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: l10n.customCategoryHint,
        hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
        prefixIcon: Icon(
          CupertinoIcons.pencil_outline,
          color: appColors.primary,
          size: 18,
        ),
        filled: true,
        fillColor: appColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.primary.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.primary, width: 1.2),
        ),
      ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appColors.primary.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                CupertinoIcons.calendar,
                color: appColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat('dd/MM/yyyy').format(selectedDate),
              style: TextStyle(
                color: appColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.calendar_badge_plus,
              color: appColors.textMuted.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("💸", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  l10n.amountSectionTitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: appColors.primaryDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: appColors.primary.withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: appColors.primaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: appColors.primary.withOpacity(0.25),
                      fontSize: 28,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(
                        CupertinoIcons.clear_thick_circled,
                        color: appColors.primary.withOpacity(0.4),
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [appColors.primary, appColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currencySymbol,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
      color: appColors.primary.withOpacity(0.08),
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
        Row(
          children: [
            const Text("📝", style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              l10n.noteSectionTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: appColors.primaryDark.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(
            color: appColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          minLines: 1,
          decoration: InputDecoration(
            hintText: l10n.noteHint,
            hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
            prefixIcon: Icon(
              CupertinoIcons.doc_text,
              color: appColors.primary,
              size: 18,
            ),
            filled: true,
            fillColor: appColors.cardBackground,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
          gradient: LinearGradient(
            colors: [appColors.primary, appColors.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: appColors.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.saveMomentButton.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.paperplane_fill,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
