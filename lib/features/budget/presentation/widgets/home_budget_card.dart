import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 130,
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: appColors.primary.withOpacity(0.05)),
        ),
      ),
      error: (err, stack) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4B4B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            l10n.budgetLoadError,
            style: const TextStyle(
              color: Color(0xFFFF4B4B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      data: (summary) {
        // --- 📅 LOGIC NGÀY THÁNG ---
        final now = DateTime.now();
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        final remainingDays = lastDayOfMonth.day - now.day;
        final daysToDivide = remainingDays + 1; // Tính cả ngày hôm nay

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

        // --- 🎨 TÍNH TOÁN LIỀU LƯỢNG TIÊU DÙNG MỖI NGÀY + BADGE ---
        Color progressColor = appColors.primary;
        Color badgeColor = appColors.success;
        String badgeText = l10n.budgetStatusReasonable;
        IconData badgeIcon = CupertinoIcons.check_mark_circled;
        String tipText = '';

        if (isNotSet) {
          progressColor = appColors.primary.withOpacity(0.2);
          badgeColor = appColors.primaryDark.withOpacity(0.4);
          badgeText = l10n.budgetStatusNotSet;
          badgeIcon = CupertinoIcons.add;
          tipText = l10n.budgetDailyNotSet;
        } else if (isOvertarget) {
          progressColor = const Color(0xFFFF4B4B);
          badgeColor = const Color(0xFFFF4B4B);
          badgeText = l10n.budgetStatusOvertarget;
          badgeIcon = CupertinoIcons.exclamationmark_triangle;
          tipText = l10n.budgetDailyOvertarget;
        } else {
          // 🌟 ĐÃ CẬP NHẬT: Thực hiện làm tròn dưới (Floor) để an toàn cho ví tiền của user
          final dailySafeAmount = (remaining / daysToDivide).floorToDouble();
          final dailySafeStr = CurrencyHelper.formatCompactAmount(
            dailySafeAmount,
          );
          tipText = l10n.budgetDailySafeLimit(dailySafeStr);

          if (isWarning) {
            progressColor = const Color(0xFFFF8A00);
            badgeColor = const Color(0xFFFF8A00);
            badgeText = l10n.budgetStatusWarning;
            badgeIcon = CupertinoIcons.exclamationmark_triangle;
          } else if (isHalfSpent) {
            progressColor = const Color(0xFFFFC107);
            badgeColor = const Color(0xFFD6A000);
            badgeText = l10n.budgetStatusHalfSpent;
            badgeIcon = Icons.timelapse;
          }
        }

        final String spentStr = CurrencyHelper.formatCompactAmount(spent);
        final String limitStr = CurrencyHelper.formatCompactAmount(limit);
        final String remainingStr = isOvertarget
            ? CurrencyHelper.formatCompactAmount(remaining.abs())
            : CurrencyHelper.formatCompactAmount(remaining);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: appColors.primaryDark.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: appColors.primary.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => isNotSet
                      ? const SetBudgetScreen()
                      : const AnalyticsScreen(),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DÒNG 1: HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: appColors.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.chart_pie,
                                size: 14,
                                color: appColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.budgetThisMonthLabel,
                              style: TextStyle(
                                color: appColors.primaryDark.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(badgeIcon, size: 12, color: badgeColor),
                              const SizedBox(width: 4),
                              Text(
                                badgeText,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // DÒNG 2: SỐ TIỀN & ICON EDIT
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          spentStr,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: isOvertarget
                                ? progressColor
                                : appColors.primaryDark,
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!isNotSet)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              "/ $limitStr",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: appColors.primaryDark.withOpacity(0.4),
                              ),
                            ),
                          ),
                        const Spacer(),
                        isNotSet
                            ? Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  CupertinoIcons.pencil,
                                  size: 18,
                                  color: appColors.primaryDark.withOpacity(0.3),
                                ),
                              )
                            : InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SetBudgetScreen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    CupertinoIcons.pencil,
                                    size: 18,
                                    color: appColors.primaryDark.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // DÒNG 3: PROGRESS BAR
                    SizedBox(
                      height: 6,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: appColors.primaryDark.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: clampedPercentage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: progressColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // DÒNG 4: THÔNG TIN CHI TIẾT & NHẮC NHỞ NGÀY
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: isOvertarget
                                    ? "${l10n.budgetOverspentLabel}: "
                                    : "${l10n.budgetRemainingLabel}: ",
                                style: TextStyle(
                                  color: appColors.primaryDark.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: remainingStr,
                                style: TextStyle(
                                  color: progressColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isNotSet)
                          Text(
                            remainingDays == 0
                                ? l10n.budgetLastDay
                                : l10n.budgetRemainingDays(remainingDays),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: appColors.primaryDark.withOpacity(0.4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),

                    // DÒNG 5: VIBE LÉM LỈNH NHẮC NHỞ TIÊU XÀI
                    Row(
                      children: [
                        Icon(
                          isOvertarget
                              ? Icons.sentiment_very_dissatisfied
                              : Icons.tips_and_updates,
                          size: 14,
                          color: isOvertarget
                              ? progressColor
                              : appColors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tipText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOvertarget
                                  ? progressColor
                                  : appColors.primaryDark.withOpacity(0.5),
                              fontStyle: isNotSet
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
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