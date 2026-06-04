import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 📳 Thêm Haptic để đồng bộ trải nghiệm rung với màn hình trước
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart'; // 🚀 IMPORT APPTOAST TẠI ĐÂY
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/budget_provider.dart';
import 'package:flutter/cupertino.dart';

class SetBudgetScreen extends ConsumerStatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  ConsumerState<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
  final _budgetController = TextEditingController();
  double _currentAmount = 0.0;

  @override
  void initState() {
    super.initState();
    final currentSummary = ref.read(homeBudgetProvider).valueOrNull;
    if (currentSummary != null && currentSummary.budgetLimit > 0) {
      _currentAmount = currentSummary.budgetLimit;
      _budgetController.text = _formatNumber(_currentAmount.toStringAsFixed(0));
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  int get _daysInMonth => DateTimeHelper.getDaysInCurrentMonth();
  double get _dailyAmount => _currentAmount / _daysInMonth;

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

  void _onBudgetChanged(String value) {
    String cleanValue = value.replaceAll('.', '');
    if (cleanValue.isEmpty) {
      setState(() {
        _budgetController.text = '';
        _currentAmount = 0.0;
      });
      return;
    }

    if (cleanValue.length > 1 && cleanValue.startsWith('0')) {
      cleanValue = cleanValue.replaceFirst(RegExp(r'^0+'), '');
    }

    String formatted = _formatNumber(cleanValue);

    setState(() {
      _currentAmount = double.tryParse(cleanValue) ?? 0.0;
      _budgetController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  void _appendZeros(String zeros) {
    HapticFeedback.lightImpact(); // 📳 Rung nhẹ phản hồi
    final text = _budgetController.text.replaceAll('.', '').trim();
    if (text.isEmpty || text == '0') return;

    String newText = text + zeros;
    _onBudgetChanged(newText);
  }

  void _setQuickBudget(String amountStr) {
    HapticFeedback.lightImpact(); // 📳 Rung nhẹ phản hồi
    _onBudgetChanged(amountStr);
  }

  /// 💡 Ý TƯỞNG UI: Danh sách gợi ý thay đổi động theo loại Tiền tệ (VND khác USD/EUR)
  List<Map<String, String>> _getQuickSuggestions(String currency) {
    if (currency == '₫') {
      return [
        {'value': '5000000', 'label': '5M'},
        {'value': '10000000', 'label': '10M'},
        {'value': '15000000', 'label': '15M'},
        {'value': '20000000', 'label': '20M'},
      ];
    } else {
      return [
        {'value': '500', 'label': '500'},
        {'value': '1000', 'label': '1K'},
        {'value': '2000', 'label': '2K'},
        {'value': '5000', 'label': '5K'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final budgetState = ref.watch(budgetProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    final budgetSummary = ref.watch(homeBudgetProvider).valueOrNull;
    final double totalSpent = budgetSummary?.totalSpent ?? 0.0;
    final bool isBudgetTooLow =
        _currentAmount > 0 && _currentAmount < totalSpent;

    // Tính toán % tiến độ ngân sách mới đã bị "nuốt" bởi số tiền đã tiêu
    final double initialProgress = _currentAmount > 0
        ? (totalSpent / _currentAmount).clamp(0.0, 1.0)
        : 0.0;

    ref.listen<BudgetState>(budgetProvider, (previous, next) {
      if (next == BudgetState.success) {
        HapticFeedback.mediumImpact(); // 📳 Rung vừa khi lưu thành công
        // 🚀 ĐÃ SỬA: Thay thế bằng AppToast
        AppToast.showSuccess(context, l10n.budgetSuccessMessage, appColors);

        ref.read(homeBudgetProvider.notifier).refreshSummary();
        ref.read(budgetProvider.notifier).resetState();
        Navigator.of(context).pop();
      } else if (next == BudgetState.error) {
        HapticFeedback.heavyImpact(); // 📳 Rung mạnh cảnh báo lỗi
        // 🚀 ĐÃ SỬA: Thay thế bằng AppToast
        AppToast.showError(context, l10n.budgetErrorMessage, appColors);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            l10n.budgetTitle,
            style: TextStyle(
              color: appColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(CupertinoIcons.chevron_back, color: appColors.primary),
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
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              l10n.budgetSectionTitle.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: appColors.primaryDark.withOpacity(0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                _buildShortcutButton(
                                  '.000',
                                  () => _appendZeros('000'),
                                  appColors,
                                ),
                                const SizedBox(width: 8),
                                _buildShortcutButton(
                                  '.000.000',
                                  () => _appendZeros('000000'),
                                  appColors,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Ô NHẬP TIỀN HẠN MỨC & CHỌN ĐƠN VỊ TIỀN TỆ
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.primary.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: isBudgetTooLow
                          ? appColors.error.withOpacity(0.5)
                          : appColors.primary.withOpacity(0.1),
                      width: isBudgetTooLow ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _budgetController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          onChanged: _onBudgetChanged,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: isBudgetTooLow
                                ? appColors.error
                                : appColors.primary,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: appColors.primary.withOpacity(0.2),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            suffixIcon: _budgetController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      color: appColors.textMuted.withOpacity(
                                        0.4,
                                      ),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      _budgetController.clear();
                                      _onBudgetChanged('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        initialValue: currencySymbol,
                        position: PopupMenuPosition.under,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: appColors.cardBackground,
                        elevation: 3,
                        onSelected: (newValue) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(currencyProvider.notifier)
                              .setCurrency(newValue);
                        },
                        itemBuilder: (BuildContext context) {
                          return ['₫', '\$', '€', '¥'].map((String value) {
                            final isSelected = value == currencySymbol;
                            return PopupMenuItem<String>(
                              value: value,
                              height: 40,
                              child: Center(
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? appColors.primary
                                        : appColors.primaryDark,
                                  ),
                                ),
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currencySymbol,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: appColors.primary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.chevron_down,
                                color: appColors.primary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 🛑 ĐA NGÔN NGỮ: HIỂN THỊ CẢNH BÁO NẾU NGÂN SÁCH MỚI < SỐ TIỀN ĐÃ TIÊU
                if (isBudgetTooLow)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: appColors.error.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_shield_fill,
                          color: appColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.budgetWarningLow(
                              '${_formatNumber(totalSpent.toStringAsFixed(0))} $currencySymbol',
                            ),
                            style: TextStyle(
                              color: appColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🌟 Ý TƯỞNG UI: CARD THÔNG TIN TIẾN ĐỘ THÔNG MINH (DÀNH CHO NGÂN SÁCH HỢP LỆ)
                if (_currentAmount > 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          (isBudgetTooLow ? appColors.error : appColors.success)
                              .withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            (isBudgetTooLow
                                    ? appColors.error
                                    : appColors.success)
                                .withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    (isBudgetTooLow
                                            ? appColors.error
                                            : appColors.success)
                                        .withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isBudgetTooLow
                                    ? CupertinoIcons.chart_pie_fill
                                    : CupertinoIcons.calendar_today,
                                size: 18,
                                color: isBudgetTooLow
                                    ? appColors.error
                                    : appColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.dailyAllowance,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: appColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '~ ${_formatNumber(_dailyAmount.toStringAsFixed(0))} $currencySymbol / ${l10n.dayLabel}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isBudgetTooLow
                                          ? appColors.error
                                          : appColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // 📊 Thanh Progress Bar trực quan thể hiện tỉ lệ "Đã tiêu / Ngân sách dự kiến"
                        if (totalSpent > 0) ...[
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: initialProgress,
                              backgroundColor: appColors.textMuted.withOpacity(
                                0.1,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isBudgetTooLow
                                    ? appColors.error
                                    : appColors.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${l10n.spentLabel}: ${_formatNumber(totalSpent.toStringAsFixed(0))} $currencySymbol',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: appColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${(initialProgress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isBudgetTooLow
                                      ? appColors.error
                                      : appColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 28),

                Text(
                  l10n.quickSuggestions,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // 🔄 CHIPS ĐÃ ĐƯỢC THÍCH ỨNG THEO ĐƠN VỊ TIỀN TỆ CỦA USER
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getQuickSuggestions(currencySymbol).map((
                    suggestion,
                  ) {
                    return _buildQuickSelectChip(
                      suggestion['value']!,
                      suggestion['label']!,
                      appColors,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // CARD GỢI Ý (TIP) NỀN NÃ
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: appColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: appColors.primary.withOpacity(0.04),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb_fill,
                        color: Colors.amber.shade600,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.budgetTip,
                          style: TextStyle(
                            fontSize: 13,
                            color: appColors.textMuted,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 24,
              top: 10,
            ),
            child: budgetState == BudgetState.loading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator()],
                  )
                : ElevatedButton(
                    onPressed: _currentAmount > 0
                        ? () {
                            HapticFeedback.mediumImpact();
                            final budgetText = _budgetController.text
                                .replaceAll('.', '')
                                .trim();
                            ref
                                .read(budgetProvider.notifier)
                                .updateBudgetLimit(double.parse(budgetText));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.primary,
                      disabledBackgroundColor: appColors.primary.withOpacity(
                        0.25,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _currentAmount > 0 ? 2 : 0,
                      shadowColor: appColors.primary.withOpacity(0.3),
                    ),
                    child: Text(
                      l10n.budgetSaveButton.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutButton(
    String label,
    VoidCallback onTap,
    AppColorTheme appColors,
  ) {
    return Material(
      color: appColors.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  Widget _buildQuickSelectChip(
    String amountStr,
    String label,
    AppColorTheme appColors,
  ) {
    final isSelected =
        _currentAmount.toString() == amountStr ||
        _currentAmount.toStringAsFixed(0) == amountStr;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? appColors.primary : appColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? appColors.primary
              : appColors.primary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _setQuickBudget(amountStr),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : appColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
