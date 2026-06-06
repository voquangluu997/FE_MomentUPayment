import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/widgets/analytics_components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/transaction_analytics_controller.dart';

// ==========================================
// 2. MÀN HÌNH CHÍNH (ANALYTICS SCREEN)
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

    // 💡 UX THÔNG MINH: Nếu hôm nay là mùng 1, tự động mở Tổng Kết Tháng Trước
    if (now.day == 1) {
      _activeFilterType = 'MonthlySummary';
      // Lấy tháng trước
      _currentMonthSummary = DateTime(now.year, now.month - 1);
      _startDate = DateTime(now.year, now.month - 1, 1);
      // Ngày cuối cùng của tháng trước
      _endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
    } else {
      _activeFilterType = 'Period';
      _endDate = now;
      _startDate = DateTime(now.year, now.month - 1, now.day);
      _currentMonthSummary = DateTime(now.year, now.month);
    }
  }

  // --- ACTIONS ---
  void _fetchData() {
    ref
        .read(transactionAnalyticsProvider.notifier)
        .updateDateRange(_startDate, _endDate);
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _activeFilterType = 'Period';
      _selectedTimeFrame = period;
      _endDate = DateTime.now();

      switch (period) {
        case '1W':
          _startDate = _endDate.subtract(const Duration(days: 7));
          break;
        case '1M':
          _startDate = DateTime(
            _endDate.year,
            _endDate.month - 1,
            _endDate.day,
          );
          break;
        case '3M':
          _startDate = DateTime(
            _endDate.year,
            _endDate.month - 3,
            _endDate.day,
          );
          break;
        case '6M':
          _startDate = DateTime(
            _endDate.year,
            _endDate.month - 6,
            _endDate.day,
          );
          break;
        case '1Y':
          _startDate = DateTime(
            _endDate.year - 1,
            _endDate.month,
            _endDate.day,
          );
          break;
      }
    });
    _fetchData();
  }

  void _showMonthYearPicker(AppColorTheme appColors) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        int tempMonth = _currentMonthSummary.month;
        int tempYear = _currentMonthSummary.year;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: appColors.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chooseMonthYear,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: appColors.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.minus_circle,
                              color: appColors.primary,
                            ),
                            onPressed: () {
                              if (tempMonth > 1) {
                                setModalState(() => tempMonth--);
                              }
                            },
                          ),
                          Text(
                            "Tháng ${tempMonth.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appColors.text,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.plus_circle,
                              color: appColors.primary,
                            ),
                            onPressed: () {
                              if (tempMonth < 12) {
                                setModalState(() => tempMonth++);
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.minus_circle,
                              color: appColors.primary,
                            ),
                            onPressed: () => setModalState(() => tempYear--),
                          ),
                          Text(
                            "$tempYear",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appColors.text,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.plus_circle,
                              color: appColors.primary,
                            ),
                            onPressed: () {
                              if (tempYear < DateTime.now().year) {
                                setModalState(() => tempYear++);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _activeFilterType = 'MonthlySummary';
                          _currentMonthSummary = DateTime(tempYear, tempMonth);
                          _startDate = DateTime(tempYear, tempMonth, 1);
                          _endDate = DateTime(
                            tempYear,
                            tempMonth + 1,
                            0,
                            23,
                            59,
                            59,
                          );
                        });
                        _fetchData();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Áp dụng",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);
    final analyticsState = ref.watch(transactionAnalyticsProvider);

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        title: Text(
          l10n.analyticsTitle,
          style: TextStyle(
            color: appColors.text,
            fontWeight: FontWeight.w900,
            fontSize: 22,
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
        onRefresh: () =>
            ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SWITCHER TABS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: appColors.textMuted.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildSwitcherTab(
                        title: l10n.analyticsSwitchPeriod,
                        isActive: _activeFilterType == 'Period',
                        onTap: () => _onPeriodChanged('1M'),
                        appColors: appColors,
                      ),
                      _buildSwitcherTab(
                        title: l10n.analyticsSwitchMonthly,
                        isActive: _activeFilterType == 'MonthlySummary',
                        onTap: () => _showMonthYearPicker(appColors),
                        appColors: appColors,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. FILTER UI
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _activeFilterType == 'Period'
                    ? Column(
                        children: [
                          QuickPeriodChips(
                            selectedTimeFrame: _selectedTimeFrame,
                            onPeriodSelected: _onPeriodChanged,
                            appColors: appColors,
                            l10n: l10n,
                          ),
                          FromToDatePicker(
                            startDate: _startDate,
                            endDate: _endDate,
                            onSelectStart: () {},
                            onSelectEnd: () {},
                            appColors: appColors,
                            l10n: l10n,
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.analyticsMonthlyHonor(
                                _currentMonthSummary.month.toString(),
                              ),
                              style: TextStyle(
                                color: appColors.text,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showMonthYearPicker(appColors),
                              icon: Icon(
                                CupertinoIcons.calendar,
                                size: 16,
                                color: appColors.primary,
                              ),
                              label: Text(
                                l10n.analyticsLastMonthReview,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: appColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // 3. MAIN DATA CONTENT
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
                    (sum, item) => sum + (item['totalAmount'] ?? 0.0),
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

  // --- WIDGET HELPER ---
  Widget _buildSwitcherTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required AppColorTheme appColors,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? appColors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
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
