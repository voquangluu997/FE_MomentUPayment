import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart'; // 🔑 THÊM IMPORT CURRENCY HELPER NÈ BỒ TÈO
import 'package:moment_u_payment/l10n/app_localizations.dart';

// ==========================================
// 1. THANH CHỌN THỜI GIAN NHANH (CHIPS)
// ==========================================
class QuickPeriodChips extends StatelessWidget {
  final String selectedTimeFrame;
  final ValueChanged<String> onPeriodSelected;
  final AppColorTheme appColors;
  final AppLocalizations l10n;

  const QuickPeriodChips({
    super.key,
    required this.selectedTimeFrame,
    required this.onPeriodSelected,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      {'id': '1W', 'label': l10n.pastWeek ?? 'Tuần qua 🌷'},
      {'id': '1M', 'label': l10n.pastMonth ?? 'Tháng qua 🌙'},
      {'id': '3M', 'label': l10n.threeMonths ?? '3 tháng 🍄'},
      {'id': '6M', 'label': l10n.sixMonths ?? 'Nửa năm 🐢'},
      {'id': '1Y', 'label': l10n.pastYear ?? 'Năm qua 🌟'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: periods.map((period) {
            final String id = period['id']!;
            final String label = period['label']!;
            final isSelected = selectedTimeFrame == id;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                selectedColor: appColors.primary.withOpacity(0.2),
                backgroundColor: appColors.cardBackground,
                side: BorderSide(
                  color: isSelected ? appColors.primary : Colors.transparent,
                  width: 1.5,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? appColors.primary : appColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (val) {
                  if (val) onPeriodSelected(id);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ==========================================
// 2. BỘ CHỌN NGÀY FROM - TO (CUTE)
// ==========================================
class FromToDatePicker extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;
  final AppColorTheme appColors;
  final AppLocalizations l10n;

  const FromToDatePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onSelectStart,
    required this.onSelectEnd,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat df = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelectStart,
                borderRadius: BorderRadius.circular(18),
                child: _buildDateBox(
                  l10n.fromDate ?? "Từ ngày nào 🐾",
                  df.format(startDate),
                  appColors,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: appColors.primary.withOpacity(0.5),
                size: 18,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onSelectEnd,
                borderRadius: BorderRadius.circular(18),
                child: _buildDateBox(
                  l10n.toDate ?? "Đến ngày nao 🌿",
                  df.format(endDate),
                  appColors,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(String label, String dateStr, AppColorTheme appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: appColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: appColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(
              color: appColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. THẺ TỔNG QUAN XINH XẮN (Giữ nguyên không sửa)
// ==========================================
class CuteOverviewCard extends StatelessWidget {
  final double total;
  final int totalDays;
  final AppColorTheme appColors;
  final AppLocalizations l10n;

  const CuteOverviewCard({
    super.key,
    required this.total,
    required this.totalDays,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final double avgPerDay = total / (totalDays == 0 ? 1 : totalDays);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appColors.primary, appColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: appColors.primary.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              (l10n.totalLabel ?? "Tổng thiệt hại 💸").toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              currencyFormatter.format(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSubInfo(
                    l10n.avgPerDay ?? "Mỗi ngày 'bay' cỡ 🕊️",
                    currencyFormatter.format(avgPerDay),
                  ),
                  _buildSubInfo(
                    l10n.repeatCycle ?? "Vòng lặp ⏳",
                    "$totalDays ${l10n.days ?? "ngày"}",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 4. KHỐI CHỨA BIỂU ĐỒ TRÒN & DANH SÁCH
// ==========================================
class AnalyticsContentWidget extends StatefulWidget {
  final List<Map<String, dynamic>> analyticsData;
  final double totalSpending;
  final AppColorTheme appColors;
  final AppLocalizations l10n;

  const AnalyticsContentWidget({
    super.key,
    required this.analyticsData,
    required this.totalSpending,
    required this.appColors,
    required this.l10n,
  });

  @override
  State<AnalyticsContentWidget> createState() => _AnalyticsContentWidgetState();
}

class _AnalyticsContentWidgetState extends State<AnalyticsContentWidget> {
  int touchedIndex = -1;
  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: widget.appColors.cardBackground,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: widget.appColors.text.withOpacity(0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 220, child: _buildDonutChart()),
              const SizedBox(height: 16),
              Text(
                widget.l10n.spendingStructure ?? "Cơ cấu 'bay màu' của ví 🥧",
                style: TextStyle(
                  color: widget.appColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.appColors.cardBackground,
            borderRadius: BorderRadius.circular(28),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.analyticsData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) => _buildCategoryItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart() {
    // Lấy số tiền hiện tại tùy thuộc vào việc có đang nhấn vào phần nào hay không
    final dynamic activeAmount = touchedIndex != -1
        ? widget.analyticsData[touchedIndex]['totalAmount']
        : widget.totalSpending;

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 4,
            centerSpaceRadius: 65,
            sections: List.generate(widget.analyticsData.length, (i) {
              final isTouched = i == touchedIndex;
              final double radius = isTouched ? 30.0 : 22.0;
              final Color sectionColor = AppColors.getCategoryColor(i);

              return PieChartSectionData(
                color: sectionColor,
                value:
                    (widget.analyticsData[i]['totalAmount'] as num?)
                        ?.toDouble() ??
                    0.0,
                title: '',
                radius: radius,
              );
            }),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              touchedIndex != -1
                  ? widget.analyticsData[touchedIndex]['category']
                  : (widget.l10n.totalLabel ?? "TỔNG"),
              style: TextStyle(
                color: widget.appColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // 🛠️ ĐÃ FIX TRÀN VIỀN: Sử dụng cách hiển thị rút gọn (Compact) từ CurrencyHelper
            Text(
              '${CurrencyHelper.formatCompactAmount(activeAmount)}₫',
              style: TextStyle(
                color: widget.appColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index) {
    final item = widget.analyticsData[index];
    final color = AppColors.getCategoryColor(index);
    final double amount = (item['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final double percentage = widget.totalSpending > 0
        ? (amount / widget.totalSpending) * 100
        : 0.0;
    final bool isSelected = touchedIndex == index;

    return InkWell(
      onTap: () =>
          setState(() => touchedIndex = touchedIndex == index ? -1 : index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                item['emoji'] ?? '📝',
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category'] ?? '',
                    style: TextStyle(
                      color: widget.appColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: widget.appColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(amount),
                  style: TextStyle(
                    color: widget.appColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: widget.appColors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
}

// ==========================================
// 5. CÁC TRẠNG THÁI RỖNG / LỖI
// ==========================================
class EmptyAnalyticsWidget extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColorTheme appColors;

  const EmptyAnalyticsWidget({
    super.key,
    required this.l10n,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Center(
        child: Column(
          children: [
            const Text("🐥✨☁️", style: TextStyle(fontSize: 36)),
            const SizedBox(height: 16),
            Text(
              l10n.emptyAnalyticsData ??
                  "Hộp tiết kiệm đang trống trơn nè~ Chưa tiêu đồng nào luôn á 🐥",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorAnalyticsWidget extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColorTheme appColors;
  final VoidCallback onRetry;

  const ErrorAnalyticsWidget({
    super.key,
    required this.l10n,
    required this.appColors,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text("🥺🔧", style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            l10n.errorLoadData ??
                "Úi, dữ liệu bị vấp cục đá ngã rồi, xu ghê 🥺",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColors.errorAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: appColors.primary.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: onRetry,
            child: Text(
              l10n.retryButton ?? "Lấy đà thử lại nghen 🚀",
              style: TextStyle(
                color: appColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
