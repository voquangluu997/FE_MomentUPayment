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
    // ✨ GỌI PROVIDER MÀU SẮC HỖ TRỢ DARK MODE
    final appColors = ref.watch(appColorsProvider);

    return budgetAsync.when(
      skipLoadingOnRefresh:
          true, // Giúp giữ UI cũ, không hiện loading spinner khi làm mới
      loading: () => Card(
        margin: const EdgeInsets.all(16),
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(color: appColors.primary),
          ),
        ),
      ),
      error: (err, stack) => Card(
        margin: const EdgeInsets.all(16),
        elevation: 0,
        color: appColors.cardBackground,
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
        // --- 📅 LOGIC TÍNH TOÁN SỐ NGÀY CÒN LẠI TRONG THÁNG ---
        final now = DateTime.now();
        // Ngày 0 của tháng sau chính là ngày cuối cùng của tháng hiện tại
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        final remainingDays = lastDayOfMonth.day - now.day;
        final String daysStr = remainingDays.toString();

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

        // --- 🎨 XỬ LÝ HEADER TIÊU ĐỀ ---
        final String limitStr = CurrencyHelper.formatCompactAmount(limit);
        final String headerText = isNotSet
            ? l10n.budgetThisMonthLabel
            : '${l10n.budgetThisMonthLabel}: $limitStr';

        // --- 🎨 PHÂN PHỐI MÀU SẮC & TRẠNG THÁI TEXT (Dùng appColors) ---
        Color progressColor = appColors.primary;
        Color feedbackColor = appColors.success;
        String feedbackText = l10n.budgetHealthyFeedback;
        String budgetStatusText = '';
        String? dailySuggestionText;

        final String spentStr = CurrencyHelper.formatCompactAmount(spent);

        if (isNotSet) {
          // 🛑 TRƯỜNG HỢP 1: CHƯA ĐẶT NGÂN SÁCH
          progressColor = appColors.primary.withOpacity(0.15);
          feedbackColor = appColors.primaryDark.withOpacity(0.6);
          feedbackText = l10n.budgetNotSetFeedback;
          budgetStatusText = l10n.budgetNotSetStatus;
        } else if (isOvertarget) {
          // 🚨 TRƯỜNG HỢP 2: VƯỢT HẠN MỨC
          progressColor = Colors.red;
          feedbackColor = Colors.red;
          feedbackText = l10n.budgetOverBudgetFeedback;

          final String overspentStr = CurrencyHelper.formatCompactAmount(
            remaining.abs(),
          );

          // Kiểm tra nếu là ngày cuối tháng thì đổi text cho mượt
          budgetStatusText = remainingDays == 0
              ? l10n.budgetOverspentDetailedStatusToday(spentStr, overspentStr)
              : l10n.budgetOverspentDetailedStatus(
                  spentStr,
                  overspentStr,
                  daysStr,
                );
        } else {
          // ✅ TRƯỜNG HỢP 3: CHI TIÊU HỢP LÝ TRONG HẠN MỨC
          final String remainingStr = CurrencyHelper.formatCompactAmount(
            remaining,
          );

          budgetStatusText = remainingDays == 0
              ? l10n.budgetDetailedStatusToday(spentStr, remainingStr)
              : l10n.budgetDetailedStatus(spentStr, remainingStr, daysStr);

          if (isWarning) {
            progressColor = Colors.orange;
            feedbackColor = Colors.orange;
            feedbackText = l10n.budgetWarningFeedback;
          } else if (isHalfSpent) {
            progressColor = Colors.amber;
            feedbackColor = Colors.amber;
            feedbackText = l10n.budgetHalfSpentFeedback;
          }

          if (remaining > 0) {
            // Chia cho (số ngày còn lại + 1 ngày hôm nay)
            final double safeAmount = remaining / (remainingDays + 1);
            final String safeAmountStr = CurrencyHelper.formatCompactAmount(
              safeAmount,
            );

            dailySuggestionText = remainingDays == 0
                ? l10n.budgetSafeToday(safeAmountStr)
                : l10n.budgetSafeDaily(safeAmountStr);
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
                color: appColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: appColors.primary.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- DÒNG HEADER: TIÊU ĐỀ + HẠN MỨC + ICON EDIT ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          headerText,
                          style: TextStyle(
                            color: appColors.primaryDark.withOpacity(
                              isNotSet ? 0.5 : 0.8,
                            ),
                            fontSize: 13,
                            fontWeight: isNotSet
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: appColors.primaryDark.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // --- DÒNG STATUS: ĐÃ TIÊU • CÒN LẠI • SỐ NGÀY ---
                  Text(
                    budgetStatusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: appColors.primaryDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- THANH PROGRESS BAR ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: spentPercentage > 1.0 ? 1.0 : spentPercentage,
                      minHeight: 8,
                      backgroundColor: appColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- LỜI NHẮN NHỦ CẢM XÚC & NÚT ĐIỀU HƯỚNG ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        feedbackText,
                        style: TextStyle(
                          color: feedbackColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // 👇 HIỂN THỊ DÒNG GỢI Ý (CHỈ HIỆN KHI CHƯA ÂM QUỸ)
                      if (dailySuggestionText != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          dailySuggestionText!,
                          style: TextStyle(
                            color: appColors.primaryDark.withOpacity(0.65),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${l10n.analyticsTitle} ➡️',
                          style: TextStyle(
                            color: appColors.primary.withOpacity(0.9),
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
