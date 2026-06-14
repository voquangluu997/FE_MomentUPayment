import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/core/widgets/analytics_components.dart'; // Nơi chứa SplurgeInfo và các Widget
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_analytics_controller.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../transaction_provider.dart';

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

  // 🌟 FIX LỖI TRÀN NGÀY CỦA DART
  DateTime _subtractMonths(DateTime date, int months) {
    int newYear = date.year;
    int newMonth = date.month - months;
    while (newMonth <= 0) {
      newYear--;
      newMonth += 12;
    }
    int newDay = date.day;
    int maxDaysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > maxDaysInNewMonth) {
      newDay = maxDaysInNewMonth;
    }
    return DateTime(newYear, newMonth, newDay);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (now.day == 1) {
      _activeFilterType = 'MonthlySummary';
      _currentMonthSummary = DateTime(now.year, now.month - 1);

      _startDate = DateTimeHelper.getLocalStartOfDay(
        DateTime(now.year, now.month - 1, 1),
      );
      _endDate = DateTimeHelper.getLocalEndOfDay(
        DateTime(now.year, now.month, 0),
      );
    } else {
      _activeFilterType = 'Period';

      _endDate = DateTimeHelper.getLocalEndOfDay(now);
      _startDate = DateTimeHelper.getLocalStartOfDay(_subtractMonths(now, 1));
      _currentMonthSummary = DateTime(now.year, now.month);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    ref
        .read(transactionAnalyticsProvider.notifier)
        .updateDateRange(_startDate.toLocal(), _endDate.toLocal());
  }

  void _onPeriodChanged(String period) {
    HapticFeedback.lightImpact();
    setState(() {
      _activeFilterType = 'Period';
      _selectedTimeFrame = period;

      final now = DateTime.now();
      _endDate = DateTimeHelper.getLocalEndOfDay(now);

      switch (period) {
        case '1D':
          _startDate = DateTimeHelper.getLocalStartOfDay(now);
          break;
        case '1W':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            now.subtract(const Duration(days: 6)),
          );
          break;
        case '1M':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            _subtractMonths(now, 1),
          );
          break;
        case '3M':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            _subtractMonths(now, 3),
          );
          break;
        case '6M':
          _startDate = DateTimeHelper.getLocalStartOfDay(
            _subtractMonths(now, 6),
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
    final textTheme = Theme.of(context).textTheme;

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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: appColors.textMuted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isStart
                    ? (l10n.selectStartDate)
                    : (l10n.selectEndDate),
                style: textTheme.titleLarge?.copyWith(
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
                    minimumDate: isStart ? DateTime(2020) : _startDate,
                    maximumDate: DateTimeHelper.getLocalEndOfDay(
                      DateTime.now(),
                    ),
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
                      shadowColor: appColors.primary.withValues(alpha: 0.4),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (isStart) {
                          _startDate = DateTimeHelper.getLocalStartOfDay(
                            tempDate,
                          );
                          if (_startDate.isAfter(_endDate)) {
                            _endDate = DateTimeHelper.getLocalEndOfDay(
                              _startDate,
                            );
                          }
                        } else {
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
                      l10n.applyButtonTitle,
                      style: textTheme.titleMedium?.copyWith(
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
    final textTheme = Theme.of(context).textTheme;

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
                    color: Colors.black.withValues(alpha: 0.12),
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
                        color: appColors.textMuted.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.chooseMonthYear,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: appColors.text,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          l10n.year,
                          style: textTheme.labelSmall?.copyWith(
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
                                    : appColors.textMuted.withValues(
                                        alpha: 0.06,
                                      ),
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
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : appColors.text.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          l10n.month,
                          style: textTheme.labelSmall?.copyWith(
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
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
                                  ? appColors.primary.withValues(alpha: 0.12)
                                  : (isFutureMonth
                                        ? appColors.textMuted.withValues(
                                            alpha: 0.02,
                                          )
                                        : appColors.textMuted.withValues(
                                            alpha: 0.05,
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
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isFutureMonth
                                    ? appColors.textMuted.withValues(
                                        alpha: 0.25,
                                      )
                                    : (isSelected
                                          ? appColors.primary
                                          : appColors.text.withValues(
                                              alpha: 0.85,
                                            )),
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
                          shadowColor: appColors.primary.withValues(alpha: 0.3),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _activeFilterType = 'MonthlySummary';
                            _currentMonthSummary = DateTime(
                              tempYear,
                              tempMonth,
                            );
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
                          l10n.applyButtonTitle,
                          style: textTheme.titleMedium?.copyWith(
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
    final String langCode = Localizations.localeOf(context).languageCode;
    final textTheme = Theme.of(context).textTheme;

    final String monthStr = langCode == 'vi'
        ? DateFormat('MM').format(_currentMonthSummary)
        : DateFormat('MMMM', 'en').format(_currentMonthSummary);
    final String yearStr = DateFormat('yyyy').format(_currentMonthSummary);

    final String displayMonthlyTitle = l10n.analyticsMonthlyHonor(
      monthStr,
      yearStr,
    );

    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (next == TransactionState.success) {
        ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();
      }
    });

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        title: Text(
          l10n.analyticsTitle,
          style: textTheme.headlineSmall?.copyWith(
            color: appColors.text,
            fontWeight: FontWeight.w900,
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
                    color: appColors.textMuted.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildSwitcherTab(
                        title: l10n.analyticsSwitchPeriod,
                        isActive: _activeFilterType == 'Period',
                        onTap: () {
                          if (_activeFilterType != 'Period') {
                            HapticFeedback.lightImpact();
                            _onPeriodChanged('1M');
                          }
                        },
                        appColors: appColors,
                        textTheme: textTheme,
                      ),
                      _buildSwitcherTab(
                        title: l10n.analyticsSwitchMonthly,
                        isActive: _activeFilterType == 'MonthlySummary',
                        onTap: () {
                          if (_activeFilterType != 'MonthlySummary') {
                            _showMonthYearPicker(appColors);
                          }
                        },
                        appColors: appColors,
                        textTheme: textTheme,
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
                              displayMonthlyTitle,
                              style: textTheme.titleLarge?.copyWith(
                                color: appColors.primaryDark,
                                fontWeight: FontWeight.w900,
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
                                  color: appColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
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
                                      style: textTheme.labelLarge?.copyWith(
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

              // 🌟 XỬ LÝ KHỐI BÓC TÁCH DỮ LIỆU MAP MỚI 🌟
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
                data: (Map<String, dynamic> analyticsData) {
                  // 1. Tách danh sách danh mục (categories)
                  final List<Map<String, dynamic>> categories =
                      List<Map<String, dynamic>>.from(
                        analyticsData['categories'] ?? [],
                      );

                  // 2. Tính tổng tiền từ danh mục
                  final double totalSpending = categories.fold(
                    0.0,
                    (sum, item) =>
                        sum +
                        ((item['totalAmount'] as num?)?.toDouble() ?? 0.0),
                  );

                  final currencySymbol = ref.watch(currencyProvider);

                  if (categories.isEmpty) {
                    return EmptyAnalyticsWidget(
                      l10n: l10n,
                      appColors: appColors,
                    );
                  }

                  // 3. Tách danh sách chi tiêu lớn (biggestSplurges)
                  final List<SplurgeInfo> splurges =
                      (analyticsData['biggestSplurges'] as List<dynamic>?)
                          ?.map(
                            (e) => SplurgeInfo.fromJson(
                              Map<String, dynamic>.from(e),
                            ),
                          )
                          .toList() ??
                      [];

                  // 4. Khởi tạo câu Insight động (Dựa trên backend trả về)
                  final insightRaw = analyticsData['diaryInsight'];
                  String? insightText;

                  if (insightRaw != null) {
                    final percent = insightRaw['percent']?.toString() ?? '0';
                    final cat1 = insightRaw['category1']?.toString() ?? '';
                    final cat2 = insightRaw['category2']?.toString();

                    String joinedCats = cat1;
                    if (cat2 != null && cat2.isNotEmpty) {
                      joinedCats += " & $cat2";
                    }

                    // Tùy chỉnh nhẹ theo ngôn ngữ để câu văn tự nhiên
                    if (langCode == 'vi') {
                      insightText =
                          "$percent% ngân sách kỳ này đã được bạn dành cho '$joinedCats'. Đây quả là một sự đầu tư đáng giá cho cảm xúc của bạn 🥰!";
                    } else {
                      insightText =
                          "$percent% of your budget went into '$joinedCats' this period. A beautiful and worthy investment in your happiness 🥰!";
                    }
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
                        currencySymbol: currencySymbol,
                      ),
                      // 5. Truyền toàn bộ tham số mới vào Component
                      AnalyticsContentWidget(
                        analyticsData: categories,
                        totalSpending: totalSpending,
                        appColors: appColors,
                        l10n: l10n,
                        currencySymbol: currencySymbol,
                        diaryInsightText: insightText,
                        biggestSplurges: splurges,
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
    required TextTheme textTheme,
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
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive
                  ? appColors.primary
                  : appColors.text.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
