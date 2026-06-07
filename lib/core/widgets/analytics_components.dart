import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

// ==========================================
// 1. THANH CHỌN THỜI GIAN NHANH
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
      {'id': '1D', 'label': l10n.todayChip ?? 'Hôm nay ☀️'},
      {'id': '1W', 'label': l10n.pastWeekChip ?? 'Tuần qua 🌷'},
      {'id': '1M', 'label': l10n.pastMonthChip ?? 'Tháng qua 🌙'},
      {'id': '3M', 'label': l10n.threeMonthsChip ?? '3 tháng 🍄'},
      {'id': '6M', 'label': l10n.sixMonthsChip ?? 'Nửa năm 🐢'},
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
              child: GestureDetector(
                onTap: () => onPeriodSelected(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? appColors.primary
                        : appColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? appColors.primary
                          : appColors.textMuted.withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: appColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : appColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ==========================================
// 2A. BỘ CHỌN NGÀY FROM - TO (ĐÃ TRONG TÂM - VÀO GIỮA)
// ==========================================
class DateRangeSelectorCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;
  final AppColorTheme appColors;
  final AppLocalizations l10n;

  const DateRangeSelectorCard({
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
    final int durationInDays = endDate.difference(startDate).inDays;
    final DateFormat df = DateFormat('dd MMM, yyyy', l10n.localeName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: appColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // --- BADGE ĐẾM NGÀY ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: appColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.timer,
                      size: 14,
                      color: appColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      durationInDays == 0
                          ? (l10n.todayOnly)
                          : (l10n.journeyDuration(
                                    durationInDays.toString(),
                                  )),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: appColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- 2 VÙNG CHỌN NGÀY ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cột trái: TỪ NGÀY
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectStart();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (l10n.fromDate).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: appColors.textMuted.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          df.format(startDate),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: appColors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Icon Mũi tên ở giữa phân cách
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.arrow_right,
                  size: 14,
                  color: appColors.textMuted.withOpacity(0.5),
                ),
              ),

              // Cột phải: ĐẾN NGÀY
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectEnd();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (l10n.toDate ?? 'Đến ngày').toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: appColors.textMuted.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          df.format(endDate),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: appColors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2B. BỘ CHỌN THÁNG NĂM CHO PHẦN MONTHLY (🔥 UPDATE ĐỒNG BỘ UI & ĐA NGÔN NGỮ)
// ==========================================
class MonthSelectorCard extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onSelectMonth;
  final AppColorTheme appColors;
  final AppLocalizations l10n;

  const MonthSelectorCard({
    super.key,
    required this.selectedMonth,
    required this.onSelectMonth,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // 🌍 Tự động lấy định dạng cấu hình ngôn ngữ hệ thống qua intl
    final DateFormat mf = DateFormat.yMMMM(l10n.localeName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: appColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // --- BADGE TIÊU ĐỀ KHỐI ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: appColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.calendar_today,
                      size: 14,
                      color: appColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.monthlySummaryTab,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: appColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- VÙNG CHỌN THÁNG NĂM CHÍNH GIỮA (ĐỒNG BỘ TYPOGRAPHY VỚI 2A) ---
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectMonth();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // 🎯 Căn giữa tuyệt đối giống 2A
                      children: [
                        Text(
                          (l10n.selectMonthLabel ?? 'Thời gian tổng kết')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: appColors.textMuted.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mf.format(selectedMonth),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: appColors.text, // Đồng bộ màu sắc 2A
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: appColors.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.chevron_down,
                                size: 12,
                                color: appColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. THẺ TỔNG QUAN XINH XẮN
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
              (l10n.totalLabel ?? "Tổng chi tiêu").toUpperCase(),
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
                    l10n.avgPerDay ?? "Trung bình/ngày",
                    currencyFormatter.format(avgPerDay),
                  ),
                  _buildSubInfo(
                    l10n.repeatCycle ?? "Chu kỳ",
                    "$totalDays ${l10n.days ?? 'ngày'}",
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
                widget.l10n.spendingStructure ?? "Cơ cấu chi tiêu",
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
              l10n.emptyAnalyticsData ?? "Chưa có dữ liệu phân tích nào 🐥",
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
          const Text("🥺🔧", style: TextStyle(fontSize: 40)),
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
