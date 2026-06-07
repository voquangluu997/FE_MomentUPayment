import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/widgets/analytics_components.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_analytics_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../transaction_provider.dart';
// 🚀 Thêm import DateTimeHelper
import 'package:moment_u_payment/core/utils/datetime_helper.dart';

// ==========================================
// MÀN HÌNH CHÍNH (ANALYTICS SCREEN)
// ==========================================
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _activeFilterType = 'Period';
  String _selectedTimeFrame = '1M';
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _currentMonthSummary;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (now.day == 1) {
      _activeFilterType = 'MonthlySummary';
      _currentMonthSummary = DateTime(now.year, now.month - 1);

      // 🚀 TỐI ƯU: Gọi DateTimeHelper
      _startDate = DateTimeHelper.getLocalStartOfDay(
        DateTime(now.year, now.month - 1, 1),
      );
      _endDate = DateTimeHelper.getLocalEndOfDay(
        DateTime(now.year, now.month, 0),
      );
    } else {
      _activeFilterType = 'Period';

      // 🚀 TỐI ƯU: Gọi DateTimeHelper
      _endDate = DateTimeHelper.getLocalEndOfDay(now);
      _startDate = DateTimeHelper.getLocalStartOfDay(
        DateTime(now.year, now.month - 1, now.day),
      );
      _currentMonthSummary = DateTime(now.year, now.month);
    }
  }

  void _fetchData() {
    ref
        .read(transactionAnalyticsProvider.notifier)
        .updateDateRange(_startDate, _endDate);
  }

  void _onPeriodChanged(String period) {
    HapticFeedback.lightImpact();
    setState(() {
      _activeFilterType = 'Period';
      _selectedTimeFrame = period;

      final now = DateTime.now();
      // 🚀 TỐI ƯU
      _endDate = DateTimeHelper.getLocalEndOfDay(now);

      switch (period) {
        case '1D':
          _startDate = DateTimeHelper.getLocalStartOfDay(now);
          break;
        case '1W':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            _endDate.subtract(const Duration(days: 7)),
          );
          break;
        case '1M':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            DateTime(_endDate.year, _endDate.month - 1, _endDate.day),
          );
          break;
        case '3M':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            DateTime(_endDate.year, _endDate.month - 3, _endDate.day),
          );
          break;
        case '6M':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            DateTime(_endDate.year, _endDate.month - 6, _endDate.day),
          );
          break;
      }
    });
    _fetchData();
  }

  void _pickDatePremium(
    BuildContext context,
    bool isStart,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    HapticFeedback.selectionClick();
    DateTime tempDate = isStart ? _startDate : _endDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 380,
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: appColors.textMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isStart
                    ? (l10n.selectStartDate ?? "Chọn ngày bắt đầu")
                    : (l10n.selectEndDate ?? "Chọn ngày kết thúc"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: appColors.text,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: appColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    minimumDate: DateTime(2020),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      HapticFeedback.selectionClick();
                      tempDate = newDate;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      shadowColor: appColors.primary.withOpacity(0.4),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (isStart) {
                          // 🚀 TỐI ƯU: Đảm bảo giờ phút giây luôn là 00:00:00
                          _startDate = DateTimeHelper.getLocalStartOfDay(
                            tempDate,
                          );
                          if (_startDate.isAfter(_endDate)) {
                            _endDate = DateTimeHelper.getLocalEndOfDay(
                              _startDate,
                            );
                          }
                        } else {
                          // 🚀 TỐI ƯU: Đảm bảo giờ phút giây luôn là 23:59:59
                          _endDate = DateTimeHelper.getLocalEndOfDay(tempDate);
                          if (_endDate.isBefore(_startDate)) {
                            _startDate = DateTimeHelper.getLocalStartOfDay(
                              tempDate,
                            );
                          }
                        }
                        _selectedTimeFrame = 'Custom';
                      });
                      _fetchData();
                      Navigator.pop(context);
                    },
                    child: Text(
                      l10n.applyButtonTitle ?? "Áp dụng",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLocalizedMonthName(int month, String langCode) {
    if (langCode == 'vi') {
      return 'Tháng $month';
    }
    try {
      final date = DateTime(2026, month);
      return DateFormat.MMM(langCode).format(date);
    } catch (_) {
      return DateFormat.MMM().format(DateTime(2026, month));
    }
  }

  void _showMonthYearPicker(AppColorTheme appColors) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        int tempMonth = _currentMonthSummary.month;
        int tempYear = _currentMonthSummary.year;
        final currentYear = DateTime.now().year;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: appColors.cardBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: appColors.textMuted.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.chooseMonthYear ?? "Chọn Tháng & Năm",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: appColors.text,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tiêu đề chọn Năm
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          "NĂM",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: appColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: (currentYear - 2020) + 1,
                        itemBuilder: (context, index) {
                          final year = 2020 + index;
                          final isSelected = year == tempYear;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() => tempYear = year);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? appColors.primary
                                    : appColors.textMuted.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? appColors.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : appColors.text.withOpacity(0.8),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tiêu đề chọn Tháng
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          "THÁNG",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: appColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            3, // Chuyển thành 3 cột để không gian chữ rộng rãi và thoáng hơn
                        childAspectRatio: 2.1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final month = index + 1;
                        final isSelected = month == tempMonth;
                        final isFutureMonth =
                            tempYear == currentYear &&
                            month > DateTime.now().month;

                        final monthLabel = _getLocalizedMonthName(
                          month,
                          langCode,
                        );

                        return GestureDetector(
                          onTap: isFutureMonth
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => tempMonth = month);
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? appColors.primary.withOpacity(0.12)
                                  : (isFutureMonth
                                        ? appColors.textMuted.withOpacity(0.02)
                                        : appColors.textMuted.withOpacity(
                                            0.05,
                                          )),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? appColors.primary
                                    : Colors.transparent,
                                width: 1.8,
                              ),
                            ),
                            child: Text(
                              monthLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isFutureMonth
                                    ? appColors.textMuted.withOpacity(0.25)
                                    : (isSelected
                                          ? appColors.primary
                                          : appColors.text.withOpacity(0.85)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                          shadowColor: appColors.primary.withOpacity(0.3),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _activeFilterType = 'MonthlySummary';
                            _currentMonthSummary = DateTime(
                              tempYear,
                              tempMonth,
                            );
                            // 🚀 TỐI ƯU: Tự tính đầu và cuối tháng thông qua Helper
                            _startDate = DateTimeHelper.getLocalStartOfDay(
                              DateTime(tempYear, tempMonth, 1),
                            );
                            _endDate = DateTimeHelper.getLocalEndOfDay(
                              DateTime(tempYear, tempMonth + 1, 0),
                            );
                          });
                          _fetchData();
                          Navigator.pop(context);
                        },
                        child: Text(
                          l10n.applyButtonTitle ?? "Áp dụng",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);
    final analyticsState = ref.watch(transactionAnalyticsProvider);

    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (next == TransactionState.success) {
        ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();
      }
    });

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        title: Text(
          l10n.analyticsTitle ?? "Thống kê",
          style: TextStyle(
            color: appColors.text,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: appColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: appColors.text),
      ),
      body: RefreshIndicator(
        color: appColors.primary,
        backgroundColor: appColors.cardBackground,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          return ref
              .read(transactionAnalyticsProvider.notifier)
              .refreshAnalytics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: appColors.textMuted.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildSwitcherTab(
                        title: l10n.analyticsSwitchPeriod ?? "Giai đoạn",
                        isActive: _activeFilterType == 'Period',
                        onTap: () {
                          if (_activeFilterType != 'Period') {
                            HapticFeedback.lightImpact();
                            _onPeriodChanged('1M');
                          }
                        },
                        appColors: appColors,
                      ),
                      _buildSwitcherTab(
                        title: l10n.analyticsSwitchMonthly ?? "Từng tháng",
                        isActive: _activeFilterType == 'MonthlySummary',
                        onTap: () {
                          if (_activeFilterType != 'MonthlySummary') {
                            _showMonthYearPicker(appColors);
                          }
                        },
                        appColors: appColors,
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                child: _activeFilterType == 'Period'
                    ? Column(
                        children: [
                          QuickPeriodChips(
                            selectedTimeFrame: _selectedTimeFrame,
                            onPeriodSelected: _onPeriodChanged,
                            appColors: appColors,
                            l10n: l10n,
                          ),
                          DateRangeSelectorCard(
                            startDate: _startDate,
                            endDate: _endDate,
                            onSelectStart: () => _pickDatePremium(
                              context,
                              true,
                              appColors,
                              l10n,
                            ),
                            onSelectEnd: () => _pickDatePremium(
                              context,
                              false,
                              appColors,
                              l10n,
                            ),
                            appColors: appColors,
                            l10n: l10n,
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.analyticsMonthlyHonor != null
                                  ? l10n.analyticsMonthlyHonor(
                                      _currentMonthSummary.month.toString(),
                                    )
                                  : "Tháng ${_currentMonthSummary.month}",
                              style: TextStyle(
                                color: appColors.primaryDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            InkWell(
                              onTap: () => _showMonthYearPicker(appColors),
                              borderRadius: BorderRadius.circular(12),
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
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar,
                                      size: 16,
                                      color: appColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.analyticsLastMonthReview,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: appColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              analyticsState.when(
                skipLoadingOnRefresh: true,
                loading: () => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => ErrorAnalyticsWidget(
                  l10n: l10n,
                  appColors: appColors,
                  onRetry: () => ref
                      .read(transactionAnalyticsProvider.notifier)
                      .refreshAnalytics(),
                ),
                data: (analyticsData) {
                  final double totalSpending = analyticsData.fold(
                    0.0,
                    (sum, item) =>
                        sum +
                        ((item['totalAmount'] as num?)?.toDouble() ?? 0.0),
                  );

                  if (analyticsData.isEmpty) {
                    return EmptyAnalyticsWidget(
                      l10n: l10n,
                      appColors: appColors,
                    );
                  }

                  return Column(
                    children: [
                      CuteOverviewCard(
                        total: totalSpending,
                        totalDays: _endDate
                            .difference(_startDate)
                            .inDays
                            .clamp(1, 365),
                        appColors: appColors,
                        l10n: l10n,
                      ),
                      AnalyticsContentWidget(
                        analyticsData: analyticsData,
                        totalSpending: totalSpending,
                        appColors: appColors,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitcherTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required AppColorTheme appColors,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? appColors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive
                  ? appColors.primary
                  : appColors.text.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
