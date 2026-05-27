import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'Food';
  String _selectedEmoji = '🍰';
  String? _localImagePath;
  bool _isCustomCategory = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () {
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
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🌟 1. KHUNG ẢNH CAMERA PHONG CÁCH AESTHETIC CỰC MỀM MẠI VÀ BẮT MẮT
              GestureDetector(
                onTap: _openCamera,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 245, // Giữ độ cao mềm mại vừa vặn theo ý bạn
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(
                      24,
                    ), // Bo góc lớn thời thượng
                    // 🔑 NÂNG CẤP: Bóng đổ kép tạo độ sâu môi trường (Ambient Shadow) giúp ảnh nổi bật nhẹ nhàng
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    // Đường viền mỏng tinh tế bảo vệ các cạnh ảnh không bị lem màu nền
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.12),
                      width: 1.2,
                    ),
                  ),
                  child: _localImagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Ảnh gốc do người dùng chụp/chọn
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22.0),
                              child: Image.file(
                                File(_localImagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),

                            // 🔑 NÂNG CẤP: Lớp phủ hòa trộn màu (Color Tint Layer) đồng điệu vibe của app
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22.0),
                                  color: AppColors.primary.withOpacity(0.02),
                                ),
                              ),
                            ),

                            // 🔑 NÂNG CẤP: Lớp phủ Gradient Vignette giúp dìm bớt góc chết của ảnh thường và tạo chiều sâu phim ảnh
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22.0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.12),
                                      Colors.transparent,
                                      Colors.transparent,
                                      AppColors.primary.withOpacity(
                                        0.18,
                                      ), // Chuyển mượt về tông màu chính ở đáy ảnh
                                    ],
                                    stops: const [0.0, 0.25, 0.7, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Nút tròn nhỏ tinh tế báo hiệu trạng thái có thể chỉnh sửa/chụp lại
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Thêm vòng tròn nền mờ nhẹ cho Icon khi chưa có ảnh trông xịn sò hơn
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.06),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_enhance_outlined,
                                size: 42,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                l10n.cameraTapInstruction,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.primaryDark.withOpacity(0.5),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 2),

              // 🌟 NÚT CHỌN ẢNH TỪ THƯ VIỆN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _openGallery,
                    icon: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    label: Text(
                      _localImagePath != null
                          ? l10n.galleryChangeAction
                          : l10n.galleryPickAction,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 🌟 2. DANH MỤC CHI TIÊU
              Text(
                l10n.categorySectionTitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark.withOpacity(0.6),
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
                const SizedBox(height: 8),
                TextField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    hintText: l10n.customCategoryHint,
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // 🌟 3. TIÊU ĐỀ SỐ TIỀN & PHÍM TẮT SỐ 0
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l10n.amountSectionTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark.withOpacity(0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Row(
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
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.06),
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
              ),
              const SizedBox(height: 18),

              // 📝 Ô NHẬP GHI CHÚ
              Text(
                l10n.noteSectionTitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark.withOpacity(0.6),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: l10n.noteHint,
                  filled: true,
                  fillColor: AppColors.cardBackground,
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
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
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
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
