import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/features/home/presentation/screens/home_screen.dart';
import 'package:frontend/core/providers/currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/media_service.dart';
import '../transaction_provider.dart';
import '../controllers/transaction_timeline_controller.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _mediaService = MediaService();

  String _selectedCategory = 'Food';
  String _selectedEmoji = '🍰';
  String? _localImagePath;
  bool _isCustomCategory = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _openCamera();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // 🔑 HÀM MỚI: Định dạng số có dấu chấm hàng nghìn
  String _formatNumber(String s) {
    String digits = s.replaceAll('.', '');
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // 🔑 CẬP NHẬT: Xử lý khi gõ vào TextField số tiền
  void _onAmountChanged(String value) {
    String formatted = _formatNumber(value);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // 🔑 CẬP NHẬT: Thêm số 0 nhanh
  void _appendZeros(String zeros) {
    final rawText = _amountController.text.replaceAll('.', '');
    final newText = rawText + zeros;
    final formatted = _formatNumber(newText);

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
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

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    final List<Map<String, dynamic>> categories = [
      {'id': 'Food', 'name': l10n.catFood, 'emoji': '🍰'},
      {'id': 'Shopping', 'name': l10n.catShopping, 'emoji': '🛍️'},
      {'id': 'Transport', 'name': l10n.catTransport, 'emoji': '🚗'},
      {'id': 'Entertainment', 'name': l10n.catEntertainment, 'emoji': '🎮'},
      {'id': 'Custom', 'name': 'Khác...', 'emoji': '📝'},
    ];

    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (next == TransactionState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.txSuccessMessage),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (next == TransactionState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.txErrorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.newMomentTitle,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _openCamera,
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.12),
                      width: 1.5,
                    ),
                  ),
                  child: _localImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            File(_localImagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_enhance_outlined,
                              size: 56,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                l10n.uploadPhotoPlaceholder,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.categorySectionTitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark.withOpacity(0.6),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
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
                                  : AppColors.primary.withOpacity(0.04),
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
                                      : Colors.black87,
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
                const SizedBox(height: 12),
                TextField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên danh mục tự chọn...',
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              Text(
                "SỐ TIỀN CHI TIÊU",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark.withOpacity(0.6),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.06),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            onChanged: _onAmountChanged, // 🔑 Dùng hàm format
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        Text(
                          currencySymbol,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 10,
                      thickness: 0.4,
                      color: Colors.black12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildShortcutZeroButton(
                          '.000',
                          () => _appendZeros('000'),
                        ),
                        const SizedBox(width: 6),
                        _buildShortcutZeroButton(
                          '.000.000',
                          () => _appendZeros('000000'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "GHI CHÚ KHOẢNH KHẮC",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark.withOpacity(0.6),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: l10n.noteHint,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              txState == TransactionState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : InkWell(
                      onTap: () {
                        // 🔑 XÓA DẤU CHẤM TRƯỚC KHI PARSE
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

                        ref
                            .read(transactionProvider.notifier)
                            .addTransaction(
                              amount: double.parse(amountText),
                              category: finalCategory,
                              emoji: _selectedEmoji,
                              note: _noteController.text.trim(),
                              localImagePath: _localImagePath,
                            );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.saveMomentButton,
                          style: const TextStyle(
                            fontSize: 16,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
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
