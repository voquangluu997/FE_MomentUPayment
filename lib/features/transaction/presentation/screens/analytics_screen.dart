import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/widgets/analytics_components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/transaction_analytics_controller.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedTimeFrame = '1M';
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate.year, _endDate.month - 1, _endDate.day);
  }

  // Cập nhật State khi nhấn Tuần qua, Tháng qua, 3 Tháng, 6 Tháng, Năm qua
  void _onPeriodChanged(String period) {
    setState(() {
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

  // Hàm Date Picker Custom: Chạm là chọn luôn & Ràng buộc logic ngày
  Future<void> _selectSingleDate({
    required bool isStartDate,
    required AppColorTheme appColors,
  }) async {
    // Logic ràng buộc cực kỳ quan trọng:
    // - Ngày bắt đầu (Từ ngày) không được lớn hơn Ngày kết thúc (Đến ngày)
    // - Ngày kết thúc không được nhỏ hơn Ngày bắt đầu, không được lớn hơn hiện tại
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime firstDate = isStartDate ? DateTime(2020) : _startDate;
    final DateTime lastDate = isStartDate ? _endDate : DateTime.now();

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: appColors.cardBackground,
          insetPadding: const EdgeInsets.all(20),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: appColors.primary,
                brightness: isDark ? Brightness.dark : Brightness.light,
                surface: appColors.cardBackground,
                onSurface: appColors.text,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CalendarDatePicker(
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                onDateChanged: (DateTime date) {
                  // ĐÓNG DIALOG VÀ TRẢ VỀ NGÀY NGAY LẬP TỨC ⚡
                  Navigator.pop(dialogContext, date);
                },
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTimeFrame = 'Custom';
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _fetchData();
    }
  }

  void _fetchData() {
    // Gọi API làm mới dữ liệu thông qua controller khi ngày thay đổi
    // ref.read(transactionAnalyticsProvider.notifier).fetchByDateRange(_startDate, _endDate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);
    final analyticsState = ref.watch(transactionAnalyticsProvider);

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        title: Text(
          l10n.analyticsTitle ?? "Thống kê",
          style: TextStyle(
            color: appColors.text,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        backgroundColor: appColors.background,
        elevation: 0,
        centerTitle: true,
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
              QuickPeriodChips(
                selectedTimeFrame: _selectedTimeFrame,
                onPeriodSelected: _onPeriodChanged,
                appColors: appColors,
                l10n: l10n, // Trỏ l10n vào để thay đổi chữ
              ),
              FromToDatePicker(
                startDate: _startDate,
                endDate: _endDate,
                onSelectStart: () =>
                    _selectSingleDate(isStartDate: true, appColors: appColors),
                onSelectEnd: () =>
                    _selectSingleDate(isStartDate: false, appColors: appColors),
                appColors: appColors,
                l10n: l10n,
              ),

              analyticsState.when(
                skipLoadingOnRefresh: true,
                loading: () => SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(color: appColors.primary),
                  ),
                ),
                error: (error, stack) => ErrorAnalyticsWidget(
                  // Widget này có trong file components
                  l10n: l10n,
                  appColors: appColors,
                  onRetry: () => ref
                      .read(transactionAnalyticsProvider.notifier)
                      .refreshAnalytics(),
                ),
                data: (analyticsData) {
                  if (analyticsData.isEmpty) {
                    return EmptyAnalyticsWidget(
                      l10n: l10n,
                      appColors: appColors,
                    );
                  }

                  final double totalSpending = analyticsData.fold(
                    0.0,
                    (sum, item) => sum + (item['totalAmount'] ?? 0.0),
                  );
                  final int totalDays = _endDate
                      .difference(_startDate)
                      .inDays
                      .clamp(1, 365);

                  return Column(
                    children: [
                      CuteOverviewCard(
                        total: totalSpending,
                        totalDays: totalDays,
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
}
