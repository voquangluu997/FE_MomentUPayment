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

  // ✨ Biến lưu trữ ngày được chọn
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // ✨ Khởi tạo ngày mặc định
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // ✨ Hàm mở DatePicker (Chỉ chọn ngày)
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
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _openCamera() async {
    try {
      final photo = await _mediaService.takePhoto();
      if (photo != null) {
        setState(() {
          _localImagePath = photo.path;
        });
      }
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
      if (photo != null) {
        setState(() {
          _localImagePath = photo.path;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh từ thư viện: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final txState = ref.watch(transactionProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    final List<Map<String, dynamic>> categories = [
      {'id': 'Food', 'name': l10n.catFood, 'emoji': '🍰'},
      {'id': 'Shopping', 'name': l10n.catShopping, 'emoji': '🛍️'},
      {'id': 'Transport', 'name': l10n.catTransport, 'emoji': '🚗'},
      {'id': 'Entertainment', 'name': l10n.catEntertainment, 'emoji': '🎮'},
      {'id': 'Custom', 'name': l10n.catCustom, 'emoji': '📝'},
    ];

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
                // 🌟 1. KHUNG ẢNH CAMERA
                GestureDetector(
                  onTap: _openCamera,
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
                    child: _localImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.file(
                              File(_localImagePath!),
                              fit: BoxFit.cover,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _openGallery,
                      icon: Icon(
                        Icons.photo_library_rounded,
                        color: appColors.primary,
                        size: 16,
                      ),
                      label: Text(
                        _localImagePath != null
                            ? l10n.galleryChangeAction
                            : l10n.galleryPickAction,
                        style: TextStyle(
                          color: appColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                InkWell(
                  onTap: _pickDate, // Chỉ chọn ngày
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: appColors.primary.withOpacity(0.1),
                      ),
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
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
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
                ),
                const SizedBox(height: 18),

                // 🌟 3. DANH MỤC CHI TIÊU
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
                                    color: isSelected
                                        ? Colors.white
                                        : appColors.text,
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

                if (_isCustomCategory) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customCategoryController,
                    style: TextStyle(color: appColors.text),
                    decoration: InputDecoration(
                      hintText: l10n.customCategoryHint,
                      hintStyle: TextStyle(color: appColors.textMuted),
                      prefixIcon: Icon(
                        Icons.edit_note_rounded,
                        color: appColors.primary,
                      ),
                      filled: true,
                      fillColor: appColors.cardBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: appColors.primary.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: appColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // 🌟 4. TIÊU ĐỀ SỐ TIỀN & PHÍM TẮT SỐ 0
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
                        _buildShortcutZeroButton(
                          '.000',
                          () => _appendZeros('000'),
                          appColors,
                        ),
                        const SizedBox(width: 6),
                        _buildShortcutZeroButton(
                          '.000.000',
                          () => _appendZeros('000000'),
                          appColors,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: appColors.primary.withOpacity(0.06),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onChanged: _onAmountChanged,
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
                            isDense: true,
                          ),
                        ),
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
                const SizedBox(height: 18),

                // 📝 Ô NHẬP GHI CHÚ
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
                  controller: _noteController,
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
                const SizedBox(height: 24),

                // 🚀 NÚT BẤM LƯU GIAO DỊCH
                txState == TransactionState.loading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            appColors.primary,
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          final amountText = _amountController.text
                              .replaceAll('.', '')
                              .trim();
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
                            finalCategory =
                                _customCategoryController.text.trim().isNotEmpty
                                ? _customCategoryController.text.trim()
                                : 'Khác';
                          }

                          // ✨ Kết hợp ngày chọn + thời gian hiện tại
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
                        },
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
                      ),
              ],
            ),
          ),
        ),
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
