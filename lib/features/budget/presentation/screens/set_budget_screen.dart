import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/budget_provider.dart';

class SetBudgetScreen extends ConsumerStatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  ConsumerState<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
  final _budgetController = TextEditingController();
  double _currentAmount = 0.0;

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
    final text = _budgetController.text.replaceAll('.', '').trim();
    if (text.isEmpty || text == '0') return;

    String newText = text + zeros;
    _onBudgetChanged(newText);
  }

  void _setQuickBudget(String amountStr) {
    _onBudgetChanged(amountStr);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final budgetState = ref.watch(budgetProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);

    ref.listen<BudgetState>(budgetProvider, (previous, next) {
      if (next == BudgetState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.budgetSuccessMessage),
            backgroundColor: appColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        ref.read(homeBudgetProvider.notifier).refreshSummary();
        ref.read(budgetProvider.notifier).resetState();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (next == BudgetState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.budgetErrorMessage),
            backgroundColor: appColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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
            icon: Icon(Icons.arrow_back_ios_new, color: appColors.primary),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
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
                // TIÊU ĐỀ NẰM NGANG VỚI PHÍM TẮT SỐ 0 (Cuộn ngang nếu tràn)
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
                              l10n.budgetSectionTitle,
                              style: TextStyle(
                                fontSize: 12,
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
                      color: appColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          onChanged: _onBudgetChanged,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
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
                      PopupMenuButton<String>(
                        initialValue: currencySymbol,
                        position: PopupMenuPosition.under,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: appColors.cardBackground,
                        elevation: 3,
                        onSelected: (newValue) {
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
                                Icons.keyboard_arrow_down_rounded,
                                color: appColors.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (_currentAmount > 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: appColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appColors.success.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: appColors.success,
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
                                  fontSize: 13,
                                  color: appColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '~ ${_formatNumber(_dailyAmount.toStringAsFixed(0))} $currencySymbol / ngày',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: appColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                Text(
                  l10n.quickSuggestions,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildQuickSelectChip('5000000', '5M', appColors),
                    _buildQuickSelectChip('10000000', '10M', appColors),
                    _buildQuickSelectChip('15000000', '15M', appColors),
                    _buildQuickSelectChip('20000000', '20M', appColors),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_circle,
                      color: Colors.amber.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.budgetTip,
                        style: TextStyle(
                          fontSize: 13,
                          color: appColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
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
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appColors.primary,
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _currentAmount > 0
                        ? () {
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
                        0.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _currentAmount > 0 ? 4 : 0,
                      shadowColor: appColors.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      l10n.budgetSaveButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
      color: appColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

    return InkWell(
      onTap: () => _setQuickBudget(amountStr),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? appColors.primary : appColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? appColors.primary
                : appColors.textMuted.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : appColors.textMuted,
          ),
        ),
      ),
    );
  }
}
