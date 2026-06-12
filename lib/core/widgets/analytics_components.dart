import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

// ==========================================
// DATA MODELS CHO UI
// ==========================================
class SplurgeInfo {
  final String id;
  final String? imageUrl;
  final DateTime date;
  final double amount;
  final String? emoji;

  SplurgeInfo({
    required this.id,
    this.imageUrl,
    required this.date,
    required this.amount,
    this.emoji,
  });

  factory SplurgeInfo.fromJson(Map<String, dynamic> json) {
    return SplurgeInfo(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl'],
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      emoji: json['emoji']?.toString(), 
    );
  }
}

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
    final textTheme = Theme.of(context).textTheme;
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
                    style: textTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : appColors.textMuted,
                      fontWeight: FontWeight.bold,
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
// 2A. BỘ CHỌN NGÀY FROM - TO
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
    final textTheme = Theme.of(context).textTheme;
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
                          : (l10n.journeyDuration(durationInDays.toString())),
                      style: textTheme.labelSmall?.copyWith(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: appColors.textMuted.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          df.format(startDate),
                          style: textTheme.titleSmall?.copyWith(
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
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: appColors.textMuted.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          df.format(endDate),
                          style: textTheme.titleSmall?.copyWith(
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
// 2B. BỘ CHỌN THÁNG NĂM CHO PHẦN MONTHLY
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
    final textTheme = Theme.of(context).textTheme;
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
                      l10n.monthlySummaryTab ?? "Tổng kết tháng",
                      style: textTheme.labelSmall?.copyWith(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (l10n.selectMonthLabel ?? 'Thời gian tổng kết')
                              .toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
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
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: appColors.text,
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
// 3. THỂ TỔNG QUAN XINH XẮN
// ==========================================
class CuteOverviewCard extends StatelessWidget {
  final double total;
  final int totalDays;
  final AppColorTheme appColors;
  final AppLocalizations l10n;
  final String currencySymbol;

  const CuteOverviewCard({
    super.key,
    required this.total,
    required this.totalDays,
    required this.appColors,
    required this.l10n,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String formattedTotal = CurrencyHelper.formatFullAmount(
      total,
      symbol: currencySymbol,
    );

    final double avgPerDay = total / (totalDays == 0 ? 1 : totalDays);
    final String formattedAvg = CurrencyHelper.formatFullAmount(
      avgPerDay,
      symbol: currencySymbol,
    );

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
              style: textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formattedTotal,
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
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
                    formattedAvg,
                    textTheme,
                  ),
                  _buildSubInfo(
                    l10n.repeatCycle ?? "Chu kỳ",
                    "$totalDays ${l10n.days ?? 'ngày'}",
                    textTheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubInfo(String title, String value, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          title,
          style: textTheme.labelSmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 4. KHỐI CHỨA BIỂU ĐỒ TRÒN & DANH SÁCH & INSIGHTS
// ==========================================
class AnalyticsContentWidget extends StatefulWidget {
  final List<Map<String, dynamic>> analyticsData; // Dữ liệu category
  final double totalSpending;
  final AppColorTheme appColors;
  final AppLocalizations l10n;
  final String currencySymbol;

  // Dữ liệu động truyền từ state tổng
  final String? diaryInsightText;
  final List<SplurgeInfo> biggestSplurges;

  const AnalyticsContentWidget({
    super.key,
    required this.analyticsData,
    required this.totalSpending,
    required this.appColors,
    required this.l10n,
    required this.currencySymbol,
    this.diaryInsightText,
    this.biggestSplurges = const [],
  });

  @override
  State<AnalyticsContentWidget> createState() => _AnalyticsContentWidgetState();
}

class _AnalyticsContentWidgetState extends State<AnalyticsContentWidget> {
  int touchedIndex = -1;

  NumberFormat get currencyFormatter {
    final isVnd =
        widget.currencySymbol == '₫' ||
        widget.currencySymbol.toUpperCase() == 'VND';
    return NumberFormat.currency(
      locale: isVnd ? 'vi_VN' : 'en_US',
      symbol: widget.currencySymbol,
      decimalDigits: isVnd ? 0 : 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 220, child: _buildDonutChart(textTheme)),
              const SizedBox(height: 16),
              Text(
                widget.l10n.spendingStructure ?? "Cấu trúc chi tiêu",
                style: textTheme.labelLarge?.copyWith(
                  color: widget.appColors.textMuted,
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
            itemBuilder: (context, index) =>
                _buildCategoryItem(index, textTheme),
          ),
        ),

        // 🌟 HIỂN THỊ DIARY INSIGHT CARD NẾU CÓ TEXT
        if (widget.diaryInsightText != null &&
            widget.diaryInsightText!.isNotEmpty) ...[
          const SizedBox(height: 24),
          DiaryInsightCard(
            appColors: widget.appColors,
            l10n: widget.l10n,
            insightText: widget.diaryInsightText!,
          ),
        ],

        // 🌟 HIỂN THỊ MY BIGGEST SPLURGES NẾU CÓ DỮ LIỆU
        if (widget.biggestSplurges.isNotEmpty) ...[
          const SizedBox(height: 28),
          MyBiggestSplurgesSection(
            appColors: widget.appColors,
            l10n: widget.l10n,
            currencySymbol: widget.currencySymbol,
            splurges: widget.biggestSplurges,
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDonutChart(TextTheme textTheme) {
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
                  : (widget.l10n.totalLabel ?? "Tổng chi tiêu"),
              style: textTheme.labelSmall?.copyWith(
                color: widget.appColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyHelper.formatCompactAmount(
                (activeAmount as num).toDouble(),
                symbol: widget.currencySymbol,
              ),
              style: textTheme.titleLarge?.copyWith(
                color: widget.appColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index, TextTheme textTheme) {
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
                    style: textTheme.bodyLarge?.copyWith(
                      color: widget.appColors.text,
                      fontWeight: FontWeight.w900,
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
                  style: textTheme.bodyLarge?.copyWith(
                    color: widget.appColors.text,
                    fontWeight: FontWeight.w900,
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
                    style: textTheme.labelSmall?.copyWith(
                      color: widget.appColors.text,
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
// 5. DIARY INSIGHT COMPONENT
// ==========================================
class DiaryInsightCard extends StatelessWidget {
  final AppColorTheme appColors;
  final AppLocalizations l10n;
  final String insightText; // Text động được truyền vào

  const DiaryInsightCard({
    super.key,
    required this.appColors,
    required this.l10n,
    required this.insightText,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: appColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.book_solid,
                size: 20,
                color: appColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.diaryInsightTitle ?? "Diary Insight",
                    style: textTheme.titleSmall?.copyWith(
                      color: appColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    insightText,
                    style: textTheme.bodyMedium?.copyWith(
                      color: appColors.textMuted,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ==========================================
// 6. MY BIGGEST SPLURGES COMPONENT
// ==========================================
// Lưu ý: Đảm bảo bạn đã import SplurgeInfo, CurrencyHelper, AppColorTheme, AppLocalizations

class MyBiggestSplurgesSection extends StatelessWidget {
  final AppColorTheme appColors;
  final AppLocalizations l10n;
  final String currencySymbol;
  final List<dynamic>
  splurges; // Đổi thành List<SplurgeInfo> theo model dự án của bạn

  const MyBiggestSplurgesSection({
    super.key,
    required this.appColors,
    required this.l10n,
    required this.currencySymbol,
    required this.splurges,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat dateFormat = DateFormat('MMM dd', l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${l10n.biggestSplurgesTitle ?? 'My Biggest Splurges'} 💖",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: appColors.text,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Bổ sung hành động khi nhấn "See all" nếu cần
                },
                child: Text(
                  l10n.seeAll ?? "See all",
                  style: textTheme.labelLarge?.copyWith(
                    color: appColors.textMuted.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: splurges.length,
            itemBuilder: (context, index) {
              final item = splurges[index];
              final String displayPrice = CurrencyHelper.formatFullAmount(
                item.amount,
                symbol: currencySymbol,
              );

              // Lấy emoji từ item (giả sử SplurgeInfo có thuộc tính emoji)
              // Nếu bạn đang dùng Map thì dùng item['emoji'] ?? '✨'
              final String emoji = item.emoji ?? '✨';

              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần ảnh của Polaroid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              (item.imageUrl != null &&
                                  item.imageUrl!.isNotEmpty)
                              ? Image.network(
                                  item.imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildImagePlaceholder(emoji),
                                )
                              : _buildImagePlaceholder(emoji),
                        ),
                      ),
                    ),
                    // Phần nhãn ghi chú bên dưới ảnh
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(item.date),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayPrice,
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Cập nhật Placeholder thành nền Gradient và Emoji
  Widget _buildImagePlaceholder(String emoji) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColors.primary.withOpacity(0.15),
            appColors.primary.withOpacity(0.35),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Emoji khổng lồ mờ nhạt làm nền
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.1,
              child: Text(emoji, style: const TextStyle(fontSize: 80)),
            ),
          ),
          // Icon Emoji nổi bật ở giữa
          Center(
            child: Text(
              emoji,
              style: const TextStyle(
                fontSize: 36,
                shadows: [
                  Shadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. CÁC TRẠNG THÁI RỖNG / LỖI
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Center(
        child: Column(
          children: [
            const Text("🐥✨☁️", style: TextStyle(fontSize: 36)),
            const SizedBox(height: 16),
            Text(
              l10n.emptyAnalyticsData,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: appColors.textMuted,
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
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Text("🥺🔧", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            l10n.errorLoadData,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: appColors.errorAccent,
              fontWeight: FontWeight.bold,
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
              l10n.retryButton ?? "Thử lại",
              style: textTheme.labelLarge?.copyWith(
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
