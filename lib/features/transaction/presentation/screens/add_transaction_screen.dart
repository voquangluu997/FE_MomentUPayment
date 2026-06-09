import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/media_service.dart';
import '../transaction_provider.dart';
import '../controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';

// ==========================================
// 🛠️ UTILS LOGIC - ĐÃ NÂNG CẤP HỖ TRỢ THẬP PHÂN & ĐA TIỀN TỆ
// ==========================================
class NumberFormatUtil {
  /// Định dạng số linh hoạt dựa trên loại tiền tệ được chọn
  static String formatByCurrency(String input, String symbol) {
    bool isVnd = symbol == '₫' || symbol == 'đ';

    if (isVnd) {
      // 🇻🇳 Logic Tiền Việt: Chỉ giữ lại số nguyên, không có thập phân
      String digits = input.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return '';

      if (digits.length > 1 && digits.startsWith('0')) {
        digits = digits.replaceFirst(RegExp(r'^0+'), '');
      }
      if (digits.isEmpty) return '0';

      final buffer = StringBuffer();
      for (int i = 0; i < digits.length; i++) {
        if (i > 0 && (digits.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(digits[i]);
      }
      return buffer.toString();
    } else {
      // 🌍 Logic Ngoại tệ (USD, EUR...): Cho phép 1 dấu chấm thập phân và tối đa 2 số sau dấu chấm

      // 🚀 KHẮC PHỤC LỖI BÀN PHÍM TIẾNG VIỆT: Chuẩn hóa dấu phẩy thập phân thành dấu chấm
      String normalizedInput = input;
      if (normalizedInput.endsWith(',')) {
        // Nếu người dùng vừa gõ dấu phẩy ở cuối (ví dụ: "1," -> "1.")
        normalizedInput =
            normalizedInput.substring(0, normalizedInput.length - 1) + '.';
      } else if (!normalizedInput.contains('.') &&
          normalizedInput.contains(',')) {
        // Hỗ trợ trường hợp sao chép (paste) hoặc nhập nhanh chuỗi chứa dấu phẩy thập phân (ví dụ: "1,25")
        // Nếu cụm chữ số sau dấu phẩy cuối cùng ít hơn 3 ký tự, đó chắc chắn là số thập phân chứ không phải hàng nghìn
        int lastComma = normalizedInput.lastIndexOf(',');
        if (lastComma != -1) {
          String afterComma = normalizedInput.substring(lastComma + 1);
          if (afterComma.length < 3) {
            normalizedInput =
                normalizedInput.substring(0, lastComma) + '.' + afterComma;
          }
        }
      }

      // Tiến hành lọc sạch ký tự sau khi đã chuẩn hóa thành dấu chấm '.'
      String clean = normalizedInput.replaceAll(RegExp(r'[^0-9.]'), '');

      // Chặn trường hợp gõ nhiều dấu chấm liên tiếp
      List<String> parts = clean.split('.');
      if (parts.length > 2) {
        clean = '${parts[0]}.${parts[1]}';
        parts = [parts[0], parts[1]];
      }

      String integerPart = parts[0];
      if (integerPart.length > 1 && integerPart.startsWith('0')) {
        integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
        if (integerPart.isEmpty) integerPart = '0';
      }

      String decimalPart = parts.length > 1 ? parts[1] : '';
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(
          0,
          2,
        ); // Giới hạn xu xu (cents) tối đa 2 chữ số
      }

      if (integerPart.isEmpty) integerPart = '0';

      // Thêm dấu phẩy phân tách hàng nghìn cho phần nguyên chuẩn quốc tế
      final buffer = StringBuffer();
      for (int i = 0; i < integerPart.length; i++) {
        if (i > 0 && (integerPart.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(integerPart[i]);
      }

      if (clean.contains('.')) {
        return '${buffer.toString()}.$decimalPart';
      }
      return buffer.toString();
    }
  }

  /// Chuyển đổi chuỗi hiển thị thành dạng số double để lưu vào DB dữ liệu một cách chính xác
  static double parseToDouble(String value, String symbol) {
    if (value.isEmpty) return 0.0;
    bool isVnd = symbol == '₫' || symbol == 'đ';
    String clean = isVnd
        ? value.replaceAll('.', '')
        : value.replaceAll(
            ',',
            '',
          ); // Giữ lại dấu "." thập phân để parse double chuẩn xác
    return double.tryParse(clean) ?? 0.0;
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

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();

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
    HapticFeedback.lightImpact();
    try {
      final photo = await _mediaService.takePhoto();
      if (photo != null) setState(() => _localImagePath = photo.path);
    } catch (e) {
      debugPrint("Lỗi khi mở camera: $e");
    }
  }

  Future<void> _openGallery() async {
    HapticFeedback.lightImpact();
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
    HapticFeedback.lightImpact();
    final currencySymbol = ref.read(currencyProvider);
    String formatted = NumberFormatUtil.formatByCurrency(value, currencySymbol);

    if (formatted.isEmpty) {
      _amountController.text = '';
      return;
    }
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _appendZeros(String zeros) {
    HapticFeedback.lightImpact();
    final currencySymbol = ref.read(currencyProvider);
    bool isVnd = currencySymbol == '₫' || currencySymbol == 'đ';

    String text = _amountController.text;
    if (!isVnd) {
      text = text.replaceAll(',', '');
      if (text.contains('.'))
        return; // Nếu đã có phần thập phân thì không append shortcut nghìn tránh lỗi dữ liệu số
    } else {
      text = text.replaceAll('.', '');
    }

    if (text.isEmpty || text == '0') return;
    _onAmountChanged(text + zeros);
  }

  /// Xử lý logic khi chuyển đổi tiền tệ trực tiếp ngay tại Input
  void _handleCurrencyChanged(String newSymbol) {
    final oldSymbol = ref.read(currencyProvider);
    if (oldSymbol == newSymbol) return;

    final currentText = _amountController.text;
    ref.read(currencyProvider.notifier).setCurrency(newSymbol);

    if (currentText.isNotEmpty) {
      bool wasVnd = oldSymbol == '₫' || oldSymbol == 'đ';
      String cleanDigits = wasVnd
          ? currentText.replaceAll('.', '')
          : currentText.replaceAll(',', '');

      // Nếu chuyển từ ngoại tệ về VND thì tiến hành làm tròn bỏ phần số thập phân
      bool isNewVnd = newSymbol == '₫' || newSymbol == 'đ';
      if (isNewVnd && cleanDigits.contains('.')) {
        double? parsed = double.tryParse(cleanDigits);
        cleanDigits = parsed != null
            ? parsed.round().toString()
            : cleanDigits.split('.')[0];
      }

      String formatted = NumberFormatUtil.formatByCurrency(
        cleanDigits,
        newSymbol,
      );
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _handleSaveTransaction() {
    final currencySymbol = ref.read(currencyProvider);
    final amountValue = NumberFormatUtil.parseToDouble(
      _amountController.text,
      currencySymbol,
    );
    final appColors = ref.read(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    if (amountValue <= 0) {
      HapticFeedback.lightImpact();
      AppToast.showError(context, l10n.invalidAmountMessage, appColors);
      return;
    }

    HapticFeedback.lightImpact();

    String finalCategory = _selectedCategory;
    if (_isCustomCategory) {
      finalCategory = _customCategoryController.text.trim().isNotEmpty
          ? _customCategoryController.text.trim()
          : l10n.categoryOther;
    }

    final finalDateTimeUtc = DateTimeHelper.combineDateWithCurrentTimeUtc(
      _selectedDate,
    );

    ref
        .read(transactionProvider.notifier)
        .addTransaction(
          amount: amountValue,
          category: finalCategory,
          emoji: _selectedEmoji,
          note: _noteController.text.trim(),
          localImagePath: _localImagePath,
          spentAt: finalDateTimeUtc,
        );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final txState = ref.watch(transactionProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (next == TransactionState.success) {
        HapticFeedback.lightImpact();
        AppToast.showSuccess(context, l10n.txSuccessMessage, appColors);
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
        ref.read(notificationProvider.notifier).fetchUnreadCount();
        Navigator.of(context).pop();
      } else if (next == TransactionState.error) {
        HapticFeedback.lightImpact();
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
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
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
                    HapticFeedback.lightImpact();
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
                  onCurrencyChanged: _handleCurrencyChanged,
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
  final ValueChanged<String>
  onCurrencyChanged; // 🚀 KHẮC PHỤC: Thêm dòng khai báo biến này để hết lỗi compiler

  const _AmountInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onAppendZeros,
    required this.onCurrencyChanged,
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                      HapticFeedback.lightImpact();
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

              // 🚀 ĐÃ CẬP NHẬT: Xoá bỏ hàm BottomSheet nội bộ thừa, gọi trực tiếp từ CurrencyPickerUtil dùng chung
              InkWell(
                onTap: () => CurrencyPickerUtil.showCurrencyBottomSheet(
                  context: context,
                  ref: ref,
                  appColors: appColors,
                  currentSymbol: currencySymbol,
                  onCurrencyChanged: onCurrencyChanged,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [appColors.primary, appColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currencySymbol,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        color: Colors.white,
                        size: 11,
                      ),
                    ],
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
