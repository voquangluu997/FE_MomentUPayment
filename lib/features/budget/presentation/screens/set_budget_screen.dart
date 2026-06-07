import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';
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
    HapticFeedback.lightImpact();
    final text = _budgetController.text.replaceAll('.', '').trim();
    if (text.isEmpty || text == '0') return;

    String newText = text + zeros;
    _onBudgetChanged(newText);
  }

  void _setQuickBudget(String amountStr) {
    HapticFeedback.selectionClick();
    _onBudgetChanged(amountStr);
  }

  List<Map<String, String>> _getQuickSuggestions(String currency) {
    if (currency == '₫') {
      return [
        {'value': '3000000', 'label': '3M ☕'},
        {'value': '5000000', 'label': '5M 🛍️'},
        {'value': '10000000', 'label': '10M 🛫'},
        {'value': '20000000', 'label': '20M 👑'},
      ];
    } else {
      return [
        {'value': '200', 'label': '200 ☕'},
        {'value': '500', 'label': '500 🛍️'},
        {'value': '1000', 'label': '1K 🛫'},
        {'value': '3000', 'label': '3K 👑'},
      ];
    }
  }

  // 🛠️ THAY THẾ POPUP MENU BẰNG BOTTOM SHEET CHUẨN PREMIUM APP
  void _showCurrencyPicker(BuildContext context, String currentSymbol) {
    HapticFeedback.mediumImpact();
    final appColors = ref.read(appColorsProvider);
    final currencies = [
      {'symbol': '₫', 'name': 'Vietnam Dong (VND)'},
      {'symbol': '\$', 'name': 'US Dollar (USD)'},
      {'symbol': '€', 'name': 'Euro (EUR)'},
      {'symbol': '¥', 'name': 'Yen / Yuan (JPY/CNY)'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: appColors.textMuted.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ...currencies.map((c) {
              final isSelected = c['symbol'] == currentSymbol;
              return ListTile(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(currencyProvider.notifier).setCurrency(c['symbol']!);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? appColors.primary.withOpacity(0.1)
                        : appColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      c['symbol']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? appColors.primary : appColors.text,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  c['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? appColors.primary : appColors.text,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        CupertinoIcons.checkmark_alt_circle_fill,
                        color: appColors.primary,
                      )
                    : null,
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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

    final double initialProgress = _currentAmount > 0
        ? (totalSpent / _currentAmount).clamp(0.0, 1.0)
        : 0.0;

    ref.listen<BudgetState>(budgetProvider, (previous, next) {
      if (next == BudgetState.success) {
        HapticFeedback.mediumImpact();
        AppToast.showSuccess(context, l10n.budgetSuccessMessage, appColors);
        ref.read(homeBudgetProvider.notifier).refreshSummary();
        ref.read(budgetProvider.notifier).resetState();
        Navigator.of(context).pop();
      } else if (next == BudgetState.error) {
        HapticFeedback.heavyImpact();
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
              color: appColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: appColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              child: Icon(
                CupertinoIcons.chevron_back,
                color: appColors.text,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SUBTITLE TRUYỀN CẢM HỨNG
                Text(
                  l10n.budgetHeaderSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: appColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // TIÊU ĐỀ KHU VỰC VÀ PHÍM TẮT THÊM SỐ 0
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.budgetSectionTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: appColors.text.withOpacity(0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Row(
                      children: [
                        _buildShortcutButton(
                          '.000',
                          () => _appendZeros('000'),
                          appColors,
                        ),
                        const SizedBox(width: 6),
                        _buildShortcutButton(
                          '.000.000',
                          () => _appendZeros('000000'),
                          appColors,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🌟 Ô NHẬP TIỀN HOÀN TOÀN MỚI (INTERACTIVE CARD)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appColors.cardBackground,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isBudgetTooLow
                                    ? appColors.error
                                    : appColors.primary)
                                .withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isBudgetTooLow
                          ? appColors.error.withOpacity(0.6)
                          : _currentAmount > 0
                          ? appColors.primary.withOpacity(0.3)
                          : appColors.textMuted.withOpacity(0.15),
                      width: _currentAmount > 0 ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _budgetController,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onChanged: _onBudgetChanged,
                              style: TextStyle(
                                fontSize: _budgetController.text.length > 10
                                    ? 26
                                    : 34,
                                fontWeight: FontWeight.w900,
                                color: isBudgetTooLow
                                    ? appColors.error
                                    : appColors.text,
                                letterSpacing: -0.5,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: appColors.textMuted.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // NÚT CHỌN TIỀN TỆ ĐƯỢC CHUỐT LẠI ĐẸP MẮT
                      InkWell(
                        onTap: () =>
                            _showCurrencyPicker(context, currencySymbol),
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                currencySymbol,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: appColors.primary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.chevron_down,
                                color: appColors.primary,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 🚨 BANNER CẢNH BÁO NẾU NGÂN SÁCH QUÁ THẤP (ANIMATED SIZE)
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: isBudgetTooLow
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: appColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: appColors.error.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_triangle_fill,
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
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // 📊 🌟 THỂ HIỆN PHÂN TÍCH THÔNG MINH SONG SONG (SMART MICRO CARDS)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _currentAmount > 0
                      ? Column(
                          children: [
                            Row(
                              children: [
                                // THẺ 1: HẠN MỨC NGÀY AN TOÀN
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color:
                                          (isBudgetTooLow
                                                  ? appColors.error
                                                  : appColors.success)
                                              .withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            (isBudgetTooLow
                                                    ? appColors.error
                                                    : appColors.success)
                                                .withOpacity(0.12),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.budgetDailySafeLimitTitle,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: appColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatNumber(_dailyAmount.toStringAsFixed(0))} $currencySymbol',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: isBudgetTooLow
                                                ? appColors.error
                                                : appColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // THẺ 2: TRẠNG THÁI KHẢ DỤNG
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color:
                                          (isBudgetTooLow
                                                  ? appColors.error
                                                  : appColors.primary)
                                              .withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            (isBudgetTooLow
                                                    ? appColors.error
                                                    : appColors.primary)
                                                .withOpacity(0.12),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.budgetRemainingLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: appColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isBudgetTooLow
                                              ? l10n.budgetStatusWarning
                                              : l10n.budgetStatusSafe,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: isBudgetTooLow
                                                ? appColors.error
                                                : appColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (totalSpent > 0) ...[
                              const SizedBox(height: 16),
                              // DẢI ĐỒ THỊ TIẾN ĐỘ TINH TẾ (PREMIUM PROGRESS BAR)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: appColors.cardBackground,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${l10n.spentLabel}: ${_formatNumber(totalSpent.toStringAsFixed(0))} $currencySymbol',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: appColors.textMuted,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${(initialProgress * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isBudgetTooLow
                                                ? appColors.error
                                                : appColors.primary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: appColors.textMuted
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                        ),
                                        AnimatedFractionallySizedBox(
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          widthFactor: initialProgress,
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isBudgetTooLow
                                                    ? [
                                                        appColors.error
                                                            .withOpacity(0.6),
                                                        appColors.error,
                                                      ]
                                                    : [
                                                        appColors.primary
                                                            .withOpacity(0.6),
                                                        appColors.primary,
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // KHU VỰC GỢI Ý NHANH (QUICK CHIPS)
                Text(
                  l10n.quickSuggestions,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: appColors.text,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 24),

                // KHU VỰC LỜI KHUYÊN MẸO TIẾT KIỆM (TIPS CARD ĐƯỢC CHUỐT LẠI)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColors.cardBackground,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.lightbulb_fill,
                          color: Colors.amber.shade700,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.budgetTip,
                          style: TextStyle(
                            fontSize: 12,
                            color: appColors.textMuted,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
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
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 24,
            top: 12,
          ),
          decoration: BoxDecoration(
            color: appColors.background,
            boxShadow: [
              BoxShadow(
                color: appColors.background.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: budgetState == BudgetState.loading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CupertinoActivityIndicator()],
                )
              : CupertinoButton(
                  padding: EdgeInsets.zero,
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _currentAmount > 0
                          ? appColors.primary
                          : appColors.textMuted.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _currentAmount > 0
                          ? [
                              BoxShadow(
                                color: appColors.primary.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      l10n.budgetSaveButton.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _currentAmount > 0
                            ? Colors.white
                            : appColors.textMuted,
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
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: appColors.textMuted.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: appColors.text.withOpacity(0.7),
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

    return GestureDetector(
      onTap: () => _setQuickBudget(amountStr),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? appColors.primary : appColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? appColors.primary
                : appColors.textMuted.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: appColors.primary.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? Colors.white : appColors.text,
          ),
        ),
      ),
    );
  }
}
