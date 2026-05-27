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

    return budgetAsync.when(
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
      error: (err, stack) => Card(
        margin: const EdgeInsets.all(16),
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'Úi, lỗi hệ thống mất tiêu rồi: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (summary) {
        // --- 📊 LOGIC PHÂN CHIA KỊCH BẢN CHI TIÊU ---
        final limit = summary.budgetLimit;
        final spent = summary.totalSpent;
        final remaining = limit - spent;

        final bool isNotSet = limit <= 0;
        final bool isOvertarget = !isNotSet && remaining < 0;

        final double spentPercentage = isNotSet ? 0.0 : (spent / limit);
        final double remainingPercentage = isNotSet ? 0.0 : (remaining / limit);

        final bool isWarning =
            !isNotSet && !isOvertarget && remainingPercentage <= 0.15;
        final bool isHalfSpent =
            !isNotSet && !isOvertarget && !isWarning && spentPercentage > 0.5;

        // --- 🎨 PHÂN PHỐI MÀU SẮC & TRẠNG THÁI TEXT ĐA NGÔN NGỮ ---
        Color progressColor = AppColors.primary;
        Color feedbackColor = AppColors.success;
        String feedbackText = l10n.budgetHealthyFeedback;
        String budgetStatusText = '';

        if (isNotSet) {
          // 🛑 TRƯỜNG HỢP 1: CHƯA ĐẶT NGÂN SÁCH (HOẶC HẠN MỨC = 0)
          progressColor = AppColors.primary.withOpacity(0.15);
          feedbackColor = AppColors.primaryDark.withOpacity(0.6);
          feedbackText = l10n.budgetNotSetFeedback;
          budgetStatusText = l10n.budgetNotSetStatus;
        } else if (isOvertarget) {
          // 🚨 TRƯỜNG HỢP 2: VƯỢT HẠN MỨC (LOẠI BỎ DẤU ÂM TỰ NHIÊN HÓA TEXT)
          progressColor = Colors.red;
          feedbackColor = Colors.red;
          feedbackText = l10n.budgetOverBudgetFeedback;

          final String overspentStr = CurrencyHelper.formatCompactAmount(
            remaining.abs(),
          );
          final String limitStr = CurrencyHelper.formatCompactAmount(limit);
          budgetStatusText = l10n.budgetOverspentStatus(overspentStr, limitStr);
        } else {
          // ✅ TRƯỜNG HỢP 3: CHI TIÊU HỢP LÝ TRONG HẠN MỨC CHUYỂN ĐỘNG
          final String spentStr = CurrencyHelper.formatCompactAmount(spent);
          final String limitStr = CurrencyHelper.formatCompactAmount(limit);
          budgetStatusText = l10n.budgetSpentStatus(spentStr, limitStr);

          if (isWarning) {
            progressColor = Colors.orange;
            feedbackColor = Colors.orange;
            feedbackText = l10n.budgetWarningFeedback;
          } else if (isHalfSpent) {
            progressColor = Colors.amber;
            feedbackColor = Colors.amber;
            feedbackText = l10n.budgetHalfSpentFeedback;
          }
        }

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 0,
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.budgetThisMonthLabel,
                        style: TextStyle(
                          color: AppColors.primaryDark.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SetBudgetScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 13,
                            color: AppColors.primaryDark.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    budgetStatusText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: spentPercentage > 1.0 ? 1.0 : spentPercentage,
                      minHeight: 8,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        feedbackText,
                        style: TextStyle(
                          color: feedbackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${l10n.analyticsTitle} ➡️',
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
