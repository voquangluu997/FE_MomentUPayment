import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class HomeBudgetCard extends ConsumerWidget {
  const HomeBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(homeBudgetProvider);
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);

    return budgetAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => Container(
        margin: const EdgeInsets.all(16),
        height: 200,
        decoration: BoxDecoration(
          color: appColors.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: CircularProgressIndicator(color: appColors.primary),
        ),
      ),
      error: (err, stack) => Card(
        margin: const EdgeInsets.all(16),
        color: appColors.errorAccent.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Úi, lỗi hệ thống mất tiêu rồi 🥺\n$err',
            style: TextStyle(
              color: appColors.errorAccent,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (summary) {
        // --- 📅 LOGIC NGÀY THÁNG ---
        final now = DateTime.now();
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        final remainingDays = lastDayOfMonth.day - now.day;
        final String daysStr = remainingDays.toString();

        // --- 📊 LOGIC NGÂN SÁCH ---
        final limit = summary.budgetLimit;
        final spent = summary.totalSpent;
        final remaining = limit - spent;

        final bool isNotSet = limit <= 0;
        final bool isOvertarget = !isNotSet && remaining < 0;

        final double spentPercentage = isNotSet ? 0.0 : (spent / limit);
        final double clampedPercentage = spentPercentage > 1.0
            ? 1.0
            : spentPercentage;

        final bool isWarning =
            !isNotSet && !isOvertarget && (remaining / limit) <= 0.15;
        final bool isHalfSpent =
            !isNotSet && !isOvertarget && !isWarning && spentPercentage > 0.5;

        // --- 🎨 XỬ LÝ MÀU SẮC (THEME AWARE) ---
        Color progressColor = appColors.primary;
        Color feedbackColor = appColors.success;
        String feedbackText = l10n.budgetHealthyFeedback;
        String budgetStatusText = '';
        String? dailySuggestionText;

        final String spentStr = CurrencyHelper.formatCompactAmount(spent);
        final String limitStr = CurrencyHelper.formatCompactAmount(limit);

        if (isNotSet) {
          progressColor = appColors.primary.withOpacity(0.2);
          feedbackColor = appColors.primaryDark.withOpacity(0.6);
          feedbackText = l10n.budgetNotSetFeedback;
          budgetStatusText = l10n.budgetNotSetStatus;
        } else if (isOvertarget) {
          progressColor = const Color(0xFFFF4B4B); // Đỏ Neon rực rỡ
          feedbackColor = const Color(0xFFFF4B4B);
          feedbackText = l10n.budgetOverBudgetFeedback;
          final String overspentStr = CurrencyHelper.formatCompactAmount(
            remaining.abs(),
          );
          budgetStatusText = remainingDays == 0
              ? l10n.budgetOverspentDetailedStatusToday(spentStr, overspentStr)
              : l10n.budgetOverspentDetailedStatus(
                  spentStr,
                  overspentStr,
                  daysStr,
                );
        } else {
          final String remainingStr = CurrencyHelper.formatCompactAmount(
            remaining,
          );
          budgetStatusText = remainingDays == 0
              ? l10n.budgetDetailedStatusToday(spentStr, remainingStr)
              : l10n.budgetDetailedStatus(spentStr, remainingStr, daysStr);

          if (isWarning) {
            progressColor = const Color(0xFFFF8A00); // Cam Cảnh Báo
            feedbackColor = const Color(0xFFFF8A00);
            feedbackText = l10n.budgetWarningFeedback;
          } else if (isHalfSpent) {
            progressColor = const Color(0xFFFFC107); // Vàng Hổ Phách
            feedbackColor = const Color(0xFFD6A000);
            feedbackText = l10n.budgetHalfSpentFeedback;
          }

          if (remaining > 0) {
            final double safeAmount = remaining / (remainingDays + 1);
            final String safeAmountStr = CurrencyHelper.formatCompactAmount(
              safeAmount,
            );
            dailySuggestionText = remainingDays == 0
                ? l10n.budgetSafeToday(safeAmountStr)
                : l10n.budgetSafeDaily(safeAmountStr);
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: progressColor.withOpacity(0.06),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: isNotSet
                  ? appColors.primary.withOpacity(0.05)
                  : progressColor.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(32),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🌟 HEADER: TITLE + NGÂN SÁCH + NÚT EDIT (GỘP CHUNG)
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SetBudgetScreen(),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isNotSet
                                  ? appColors.background
                                  : progressColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isNotSet
                                      ? l10n.budgetThisMonthLabel
                                      : '🎯 ${l10n.budgetThisMonthLabel}',
                                  style: TextStyle(
                                    color: isNotSet
                                        ? appColors.primaryDark.withOpacity(0.5)
                                        : appColors.primaryDark.withOpacity(
                                            0.8,
                                          ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (!isNotSet) ...[
                                  Text(
                                    '  •  $limitStr', // 👉 Hiển thị số ngân sách tổng ngay phía sau cực gọn
                                    style: TextStyle(
                                      color: progressColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appColors.background,
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 15,
                              color: appColors.primaryDark.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 💸 HIGHLIGHT TEXT CONTAINER: Thiết kế số ngân sách cực kỳ bắt mắt
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.background.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: progressColor.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              budgetStatusText
                                  .split('•')
                                  .first
                                  .trim(), // Số tiền "đã vung tay"
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: isOvertarget
                                    ? progressColor
                                    : appColors.primaryDark,
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (budgetStatusText.contains('•')) ...[
                            const SizedBox(height: 4),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                budgetStatusText
                                    .split('•')
                                    .last
                                    .trim(), // Trạng thái "để sinh tồn"
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isOvertarget
                                      ? progressColor.withOpacity(0.8)
                                      : progressColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔋 GLOWING PROGRESS BAR (Thanh trạng thái phát sáng)
                    Column(
                      children: [
                        SizedBox(
                          height: 16,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: appColors.background,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: clampedPercentage,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.fastOutSlowIn,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        progressColor.withOpacity(0.7),
                                        progressColor,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      // 👇 Đổ bóng Neon phát sáng dựa theo màu trạng thái ngân sách hiện tại
                                      BoxShadow(
                                        color: progressColor.withOpacity(0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isNotSet
                                  ? ''
                                  : '${(spentPercentage * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: progressColor,
                              ),
                            ),
                            Text(
                              isNotSet ? '' : limitStr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: appColors.primaryDark.withOpacity(0.35),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 💬 FOOTER TINTED BOX (LỜI NHẮN NHỦ)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isNotSet
                            ? appColors.background
                            : progressColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feedbackText,
                            style: TextStyle(
                              color: isNotSet
                                  ? appColors.primaryDark.withOpacity(0.6)
                                  : feedbackColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          if (dailySuggestionText != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              dailySuggestionText!,
                              style: TextStyle(
                                color: appColors.primaryDark.withOpacity(0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
