import 'dart:ui';
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

// ==========================================
// 🛠️ REUSABLE UTILITIES - ĐỒNG NHẤT HÓA TIỀN TỆ
// ==========================================
class CurrencyPickerUtil {
  /// Hiển thị BottomSheet chọn tiền tệ sang xịn mịn chuẩn phong cách Cozy Hàn Quốc
  static void showCurrencyBottomSheet({
    required BuildContext context,
    required WidgetRef ref,
    required AppColorTheme appColors,
    required String currentSymbol,
    required ValueChanged<String> onCurrencyChanged,
  }) {
    HapticFeedback.mediumImpact();
    final textTheme = Theme.of(context).textTheme; // Lấy bộ font hệ thống
    final List<Map<String, String>> currencyList = [
      {'symbol': '₫', 'name': 'Việt Nam Đồng (VND)'},
      {'symbol': '\$', 'name': 'Đô la Mỹ (USD)'},
      {'symbol': '€', 'name': 'Euro (EUR)'},
      {'symbol': '¥', 'name': 'Yên Nhật (JPY)'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: appColors.textMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Đơn vị tiền tệ".toUpperCase(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: appColors.primaryDark.withValues(alpha: 0.6),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: currencyList.map((currency) {
                    final isSelected = currentSymbol == currency['symbol'];
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        onCurrencyChanged(currency['symbol']!);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? appColors.primary.withValues(alpha: 0.06)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? appColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? appColors.primary
                                    : appColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currency['symbol']!,
                                style: textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : appColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              currency['name']!,
                              style: textTheme.bodyLarge?.copyWith(
                                color: appColors.text,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                CupertinoIcons.checkmark_alt_circle_fill,
                                color: appColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 📱 MÀN HÌNH CHÍNH
// ==========================================
class SetBudgetScreen extends ConsumerStatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  ConsumerState<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen>
    with SingleTickerProviderStateMixin {
  final _budgetController = TextEditingController();
  double _currentAmount = 0.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    final currentSummary = ref.read(homeBudgetProvider).valueOrNull;
    if (currentSummary != null && currentSummary.budgetLimit > 0) {
      _currentAmount = currentSummary.budgetLimit;
      _budgetController.text = _formatNumber(_currentAmount.toStringAsFixed(0));
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int get _daysInMonth => DateTimeHelper.getDaysInCurrentMonth();
  double get _dailyAmount => _currentAmount / _daysInMonth;

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

  String _getLifestyleAdvice(
    double daily,
    String symbol,
    AppLocalizations l10n,
  ) {
    if (daily <= 0) return l10n.budgetLifestyleStart;
    if (symbol == '₫' || symbol == 'đ') {
      if (daily < 50000) return l10n.blessingMessage;
      if (daily < 80000) return l10n.budgetLifestyleLow;
      if (daily < 200000) return l10n.budgetLifestyleMedium;
      return l10n.budgetLifestyleHigh;
    }
    return l10n.budgetLifestyleActive;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Lấy bộ font hệ thống
    final appColors = ref.watch(appColorsProvider);
    final budgetState = ref.watch(budgetProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);
    final budgetSummary = ref.watch(homeBudgetProvider).valueOrNull;
    final double totalSpent = budgetSummary?.totalSpent ?? 0.0;
    final bool isBudgetLow = _currentAmount > 0 && _currentAmount < totalSpent;

    ref.listen<BudgetState>(budgetProvider, (previous, next) {
      if (next == BudgetState.success) {
        ref.invalidate(homeBudgetProvider);
        AppToast.showSuccess(context, l10n.budgetUpdateSuccess, appColors);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else if (next == BudgetState.error) {
        AppToast.showError(context, l10n.budgetUpdateError, appColors);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: _buildBlurBlob(
                200,
                appColors.primary.withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: _buildBlurBlob(150, Colors.blue.withValues(alpha: 0.1)),
            ),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      CupertinoIcons.chevron_left_circle_fill,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                    color: appColors.text.withValues(alpha: 0.3),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      l10n.budgetTitle,
                      style: textTheme.titleLarge?.copyWith(
                        color: appColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildCoachEmoji(isBudgetLow, _currentAmount),
                        const SizedBox(height: 8),
                        Text(
                          l10n.budgetHeaderSubtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: appColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: 32),

                        _buildMainInput(
                          currencySymbol,
                          appColors,
                          isBudgetLow,
                          textTheme,
                        ),

                        const SizedBox(height: 24),

                        if (_currentAmount > 0) ...[
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildGlassCard(
                                    l10n.budgetDailySafeLimitTitle,
                                    '${_formatNumber(_dailyAmount.toStringAsFixed(0))} $currencySymbol',
                                    isBudgetLow
                                        ? appColors.error
                                        : appColors.success,
                                    appColors,
                                    textTheme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGlassCard(
                                    l10n.budgetLifestyleTitle,
                                    _getLifestyleAdvice(
                                      _dailyAmount,
                                      currencySymbol,
                                      l10n,
                                    ),
                                    appColors.primary,
                                    appColors,
                                    textTheme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildProgressSection(
                            totalSpent,
                            _currentAmount,
                            currencySymbol,
                            appColors,
                            isBudgetLow,
                            l10n,
                            textTheme,
                          ),
                        ],

                        const SizedBox(height: 32),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.quickSuggestions,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: appColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickChips(currencySymbol, appColors, textTheme),

                        const SizedBox(height: 40),

                        _buildBigSaveButton(
                          budgetState,
                          appColors,
                          l10n,
                          textTheme,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(),
      ),
    );
  }

  Widget _buildCoachEmoji(bool isLow, double amount) {
    String emoji = "🎯";
    if (amount <= 0) {
      emoji = "🤔";
    } else if (isLow)
      // ignore: curly_braces_in_flow_control_structures
      emoji = "😰";
    else if (amount > 10000000)
      // ignore: curly_braces_in_flow_control_structures
      emoji = "👑";
    else
      // ignore: curly_braces_in_flow_control_structures
      emoji = "🤔";

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Text(emoji, style: const TextStyle(fontSize: 50)),
        );
      },
    );
  }

  Widget _buildMainInput(
    String symbol,
    AppColorTheme appColors,
    bool isLow,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildShortcutButton(
              '.000',
              () => _appendZeros('000'),
              appColors,
              textTheme,
            ),
            const SizedBox(width: 6),
            _buildShortcutButton(
              '.000.000',
              () => _appendZeros('000000'),
              appColors,
              textTheme,
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
              color: (isLow ? appColors.error : appColors.primary).withValues(
                alpha: 0.25,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isLow ? appColors.error : appColors.primary).withValues(
                  alpha: 0.15,
                ),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  onChanged: _onBudgetChanged,
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    color: isLow ? appColors.error : appColors.primaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      color: appColors.textMuted.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _budgetController,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _budgetController.clear();
                      _onBudgetChanged('');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(
                        CupertinoIcons.clear_thick_circled,
                        color: appColors.primary.withValues(alpha: 0.4),
                        size: 18,
                      ),
                    ),
                  );
                },
              ),

              InkWell(
                onTap: () => CurrencyPickerUtil.showCurrencyBottomSheet(
                  context: context,
                  ref: ref,
                  appColors: appColors,
                  currentSymbol: symbol,
                  onCurrencyChanged: (newSymbol) {
                    ref.read(currencyProvider.notifier).setCurrency(newSymbol);
                  },
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
                        symbol,
                        style: textTheme.bodyLarge?.copyWith(
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
    TextTheme textTheme,
  ) {
    return Material(
      color: appColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: appColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(
    String label,
    String value,
    Color accent,
    AppColorTheme appColors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.cardBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: appColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    double spent,
    double limit,
    String symbol,
    AppColorTheme appColors,
    bool isLow,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    double progress = (spent / limit).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${l10n.spentLabel}: ${_formatNumber(spent.toStringAsFixed(0))} $symbol",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isLow ? appColors.error : appColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: appColors.textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              AnimatedFractionallySizedBox(
                duration: const Duration(seconds: 1),
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLow
                          ? [
                              appColors.error.withValues(alpha: 0.5),
                              appColors.error,
                            ]
                          : [
                              appColors.primary.withValues(alpha: 0.5),
                              appColors.primary,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChips(
    String symbol,
    AppColorTheme appColors,
    TextTheme textTheme,
  ) {
    final suggestions = symbol == '₫'
        ? ["1000000", "3000000", "5000000", "10000000"]
        : ["100", "500", "1000", "2000"];
    final labels = symbol == '₫'
        ? ["1M ☕", "3M 🛍️", "5M 🛫", "10M 👑"]
        : ["100 ☕", "500 🛍️", "1K 🛫", "2K 👑"];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(suggestions.length, (index) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _onBudgetChanged(suggestions[index]);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _currentAmount.toStringAsFixed(0) == suggestions[index]
                  ? appColors.primary
                  : appColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (_currentAmount.toStringAsFixed(0) == suggestions[index])
                  BoxShadow(
                    color: appColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
              ],
            ),
            child: Text(
              labels[index],
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _currentAmount.toStringAsFixed(0) == suggestions[index]
                    ? Colors.white
                    : appColors.text,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBigSaveButton(
    BudgetState state,
    AppColorTheme appColors,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    bool isEnabled = _currentAmount > 0 && state != BudgetState.loading;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isEnabled
          ? () {
              HapticFeedback.heavyImpact();
              ref
                  .read(budgetProvider.notifier)
                  .updateBudgetLimit(_currentAmount);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isEnabled
              ? LinearGradient(
                  colors: [appColors.primary, appColors.primaryDark],
                )
              : null,
          color: isEnabled ? null : appColors.textMuted.withValues(alpha: 0.1),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: appColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: state == BudgetState.loading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                l10n.budgetSaveButton.toUpperCase(),
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }
}
