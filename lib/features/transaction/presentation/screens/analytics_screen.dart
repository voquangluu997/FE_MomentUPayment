import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/transaction_analytics_controller.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int touchedIndex = -1; // Lưu vị trí danh mục người dùng đang nhấn vào biểu đồ

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analyticsState = ref.watch(transactionAnalyticsProvider);
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.analyticsTitle ?? 'Phân Tích Chi Tiêu',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics(),
        child: analyticsState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  l10n.errorLoadData,
                  style: const TextStyle(color: AppColors.errorAccent),
                ),
                TextButton(
                  onPressed: () => ref
                      .read(transactionAnalyticsProvider.notifier)
                      .refreshAnalytics(),
                  child: Text(
                    l10n.retryButton,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          data: (analyticsData) {
            if (analyticsData.isEmpty) {
              return Center(
                child: Text(
                  l10n.emptyAnalyticsData ??
                      'Chưa có dữ liệu chi tiêu trong tháng này! 📝',
                  style: TextStyle(
                    color: AppColors.primaryDark.withOpacity(0.5),
                  ),
                ),
              );
            }

            // 🧠 Tính tổng chi tiêu toàn bộ để tính % tỷ trọng
            final double totalSpending = analyticsData.fold(
              0.0,
              (sum, item) => sum + (item['totalAmount'] ?? 0.0),
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 🎯 Khu vực 1: Vẽ biểu đồ tròn Doughnut Chart
                  SizedBox(
                    height: 240,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    });
                                  },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4, // Khoảng cách giữa các miếng bánh
                            centerSpaceRadius:
                                70, // Tạo lỗ rỗng ở giữa thành hình bánh Donut
                            sections: _buildPieChartSections(
                              analyticsData,
                              totalSpending,
                            ),
                          ),
                        ),
                        // Hiển thị tổng tiền ngay chính giữa tâm biểu đồ
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.totalLabel ?? 'Tổng chi',
                                style: TextStyle(
                                  color: AppColors.primaryDark.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormatter.format(totalSpending),
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🎯 Khu vực 2: Danh sách thống kê chi tiết theo hàng
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: analyticsData.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: AppColors.background.withOpacity(0.5)),
                      itemBuilder: (context, index) {
                        final item = analyticsData[index];
                        final color = AppColors.getCategoryColor(index);
                        final double amount =
                            (item['totalAmount'] as num?)?.toDouble() ?? 0.0;
                        final double percentage = totalSpending > 0
                            ? (amount / totalSpending) * 100
                            : 0.0;
                        final bool isSelected = touchedIndex == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Mã màu + Emoji đại diện danh mục
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item['emoji'] ?? '📝',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Tên danh mục & tỉ lệ %
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['category'] ?? '',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: AppColors.primaryDark
                                            .withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tổng số tiền tiêu hao
                              Text(
                                currencyFormatter.format(amount),
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🧠 Hàm biến đổi danh sách dữ liệu thô sang cấu trúc PieChartSectionData của fl_chart
  List<PieChartSectionData> _buildPieChartSections(
    List<Map<String, dynamic>> data,
    double total,
  ) {
    return List.generate(data.length, (i) {
      final item = data[i];
      final double amount = (item['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final isTouched = i == touchedIndex;

      // Nếu người dùng đang nhấn vào miếng bánh hiện tại, tăng kích thước phóng to để tạo hiệu ứng động
      final radius = isTouched ? 30.0 : 22.0;

      return PieChartSectionData(
        color: AppColors.getCategoryColor(i),
        value: amount,
        title:
            '', // Không vẽ chữ trực tiếp đè lên biểu đồ nhìn sẽ rối, tụi mình show ở list dưới
        radius: radius,
      );
    });
  }
}
