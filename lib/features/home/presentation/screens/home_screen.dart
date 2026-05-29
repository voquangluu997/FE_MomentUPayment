import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart'; // ✨ Dùng để hiển thị tag ngày tháng cho đẹp
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/features/budget/presentation/widgets/home_budget_card.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_app_bar.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_header_section.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_details_dialog.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_grid_item.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/transaction_card.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';

final isGridViewProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  DateTimeRange? _selectedDateRange; // ✨ Lưu khoảng thời gian From - To để lọc

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchUnreadCount();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        ref.read(transactionTimelineProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openMomentDetails(
    Map<String, dynamic> moment,
    AppLocalizations l10n,
  ) async {
    final bool? isUpdated = await showDialog<bool>(
      context: context,
      builder: (context) => MomentDetailsDialog(moment: moment, l10n: l10n),
    );

    if (isUpdated == true && mounted) {
      ref.read(transactionTimelineProvider.notifier).refreshTimeline();
    }
  }

  // ===========================================================================
  // HÀM LỌC DANH SÁCH THEO NGÀY CHỌN
  // ===========================================================================
  List<Map<String, dynamic>> _applyDateFilter(
    List<Map<String, dynamic>> transactions,
  ) {
    if (_selectedDateRange == null) return transactions;

    // Lấy thời điểm bắt đầu ngày (00:00:00)
    final DateTime startOfDay = DateTime(
      _selectedDateRange!.start.year,
      _selectedDateRange!.start.month,
      _selectedDateRange!.start.day,
    );

    // Lấy thời điểm cuối ngày kết thúc (23:59:59)
    final DateTime endOfDay = DateTime(
      _selectedDateRange!.end.year,
      _selectedDateRange!.end.month,
      _selectedDateRange!.end.day,
    ).add(const Duration(days: 1)); // Cộng 1 ngày để bao trọn ngày end

    return transactions.where((tx) {
      // ✨ ĐỔI 'createdAt' THÀNH 'spentAt' Ở ĐÂY
      final dynamic rawDate = tx['spentAt'];

      if (rawDate == null) return false;

      // Chuyển đổi an toàn
      final DateTime? txDate = rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate.toString());

      if (txDate == null) return false;

      // Logic: txDate >= startOfDay VÀ txDate < endOfDay
      return txDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          txDate.isBefore(endOfDay);
    }).toList();
  }

  // Hộp thoại lịch chọn khoảng ngày xinh xắn
  Future<void> _pickDateRange(
    BuildContext context,
    AppColorTheme appColors,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColors.primary,
              onPrimary: Colors.white,
              onSurface: appColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildBudgetCardWithNavigation(AppLocalizations l10n) {
    return const Stack(children: [HomeBudgetCard()]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timelineState = ref.watch(transactionTimelineProvider);
    final isGridView = ref.watch(isGridViewProvider);

    final timelineNotifier = ref.watch(transactionTimelineProvider.notifier);
    final isLoadingMore = timelineNotifier.isLoadingMore;
    final hasMore = timelineNotifier.hasMore;
    final appColors = ref.watch(appColorsProvider);

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        color: appColors.primary,
        backgroundColor: appColors.cardBackground,
        onRefresh: () =>
            ref.read(transactionTimelineProvider.notifier).refreshTimeline(),
        child: timelineState.when(
          skipLoadingOnRefresh: true,
          loading: () => Center(
            child: CircularProgressIndicator(color: appColors.primary),
          ),
          error: (error, stack) => Center(
            child: Text(
              l10n.errorLoadData,
              style: TextStyle(color: appColors.errorAccent),
            ),
          ),
          data: (allTransactions) {
            // ✨ 1. Tiến hành lọc danh sách theo ngày trước khi nhóm dữ liệu
            final filteredTransactions = _applyDateFilter(allTransactions);

            // ✨ 2. Cả 2 chế độ bây giờ đều ĐỒNG BỘ nhóm theo Ngày (Daily)
            final dailyGrouped = DateTimeHelper.groupTransactionsByDate(
              filteredTransactions,
            );
            final keys = dailyGrouped.keys.toList();

            if (filteredTransactions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  _buildBudgetCardWithNavigation(l10n),
                  // Vẫn hiển thị Header chứa nút Filter để người dùng bấm hủy lọc
                  _buildControlHeaderRow(appColors, isGridView),
                  if (_selectedDateRange != null) _buildFilterTag(appColors),
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        _selectedDateRange != null
                            ? "Không có giao dịch nào trong khoảng ngày này 🌸"
                            : l10n.emptyTransactionList,
                        style: TextStyle(
                          color: appColors.primaryDark.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              // Cộng thêm 3 vì: index 0 (Budget), index 1 (Header + Filter Control Row), index 2 (Filter Tag nếu có)
              itemCount: 3 + keys.length + (isLoadingMore && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) return _buildBudgetCardWithNavigation(l10n);

                // ✨ index 1: Hợp nhất HomeHeaderSection và Thanh điều khiển Filter/Toggle View nằm ngang hàng
                if (index == 1) {
                  return _buildControlHeaderRow(appColors, isGridView);
                }

                // index 2: Hiển thị tag khoảng ngày đang chọn nếu có, nếu không có trả về khoảng trống rỗng
                if (index == 2) {
                  return _selectedDateRange != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildFilterTag(appColors),
                        )
                      : const SizedBox.shrink();
                }

                // Kiểm tra chỉ số loading cuối trang
                if (index == 3 + keys.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: appColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }

                // Tính toán vị trí data thực tế (bỏ qua 3 item đầu)
                final dataIndex = index - 3;
                final groupKey = keys[dataIndex];
                final txList = dailyGrouped[groupKey]!;

                // ✨ Trả về Grid hoặc List đồng bộ nhóm theo Ngày
                if (isGridView) {
                  return _buildGridGroup(
                    groupKey,
                    txList,
                    l10n,
                    ref,
                    context,
                    appColors,
                  );
                } else {
                  return _buildListGroup(
                    groupKey,
                    txList,
                    l10n,
                    ref,
                    context,
                    appColors,
                  );
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appColors.primary,
        onPressed: () async {
          final bool? isAdded = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          if (isAdded == true && mounted) {
            ref.read(transactionTimelineProvider.notifier).refreshTimeline();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ===========================================================================
  // WIDGET ROW: CHỨA TIÊU ĐỀ HOME + CẶP NÚT FILTER & CHUYỂN VIEW NẰM NGANG HÀNG
  // ===========================================================================
  Widget _buildControlHeaderRow(AppColorTheme appColors, bool isGridView) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bên trái giữ nguyên phần chữ Header của bạn
          Expanded(
            child: HomeHeaderSection(
              isGridView: isGridView,
              isFiltered: _selectedDateRange != null,
              onToggleView: () =>
                  ref.read(isGridViewProvider.notifier).state = !isGridView,
              onFilterTap: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  initialDateRange:
                      _selectedDateRange ??
                      DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  // 🔥 Tự động đóng/áp dụng khi chọn xong 2 điểm
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: appColors.primary,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedDateRange = picked);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
    );
  }

  Widget _buildFilterTag(AppColorTheme appColors) {
    final f = DateFormat('dd/MM');
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: appColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.date_range_rounded,
                size: 12,
                color: appColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Từ ${f.format(_selectedDateRange!.start)} đến ${f.format(_selectedDateRange!.end)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: appColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _selectedDateRange = null),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: appColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListGroup(
    String dateKey,
    List<Map<String, dynamic>> txList,
    AppLocalizations l10n,
    WidgetRef ref,
    BuildContext context,
    AppColorTheme appColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
          child: Text(
            DateTimeHelper.getFriendlyDateLabel(dateKey, l10n),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: appColors.primaryDark.withOpacity(0.45),
            ),
          ),
        ),
        ...txList.map(
          (tx) => _buildDismissibleCard(context, ref, tx, l10n, appColors),
        ),
      ],
    );
  }

  // ✨ ĐÃ UPDATE: Nhóm Grid theo Từng Ngày thay vì theo Tháng như trước
  Widget _buildGridGroup(
    String dateKey,
    List<Map<String, dynamic>> txList,
    AppLocalizations l10n,
    WidgetRef ref,
    BuildContext context,
    AppColorTheme appColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
          child: Text(
            // Sử dụng nhãn ngày thân thiện giống List View cho đồng bộ luôn bồ tèo nhé!
            DateTimeHelper.getFriendlyDateLabel(dateKey, l10n),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: appColors.primaryDark.withOpacity(0.45),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            itemCount: txList.length,
            itemBuilder: (context, gridIdx) => MomentGridItem(
              moment: txList[gridIdx],
              l10n: l10n,
              onLongPress: () => _showDeleteConfirmDialog(
                context,
                ref,
                txList[gridIdx],
                l10n,
                appColors,
              ),
              onTap: () => _openMomentDetails(txList[gridIdx], l10n),
            ),
          ),
        ),
      ],
    );
  }

  // Giữ nguyên hàm _buildDismissibleCard và _showDeleteConfirmDialog cũ bên dưới của bạn...
  Widget _buildDismissibleCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> tx,
    AppLocalizations l10n,
    AppColorTheme appColors,
  ) {
    return Dismissible(
      key: Key(tx['id'].toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        await _showDeleteConfirmDialog(context, ref, tx, l10n, appColors);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: appColors.errorAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_sweep, color: appColors.errorAccent),
      ),
      child: TransactionCard(
        transaction: tx,
        onTap: () => _openMomentDetails(tx, l10n),
        l10n: l10n,
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> tx,
    AppLocalizations l10n,
    AppColorTheme appColors,
  ) async {
    final isConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteDialogTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appColors.primaryDark,
          ),
        ),
        content: Text(
          l10n.deleteDialogContent,
          style: TextStyle(color: appColors.primaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.deleteDialogCancel,
              style: TextStyle(color: appColors.primaryDark.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteDialogConfirm,
              style: TextStyle(color: appColors.errorAccent),
            ),
          ),
        ],
      ),
    );

    if (isConfirm == true) {
      try {
        await ref
            .read(transactionTimelineProvider.notifier)
            .deleteTransaction(tx['id'].toString());
        ref
            .read(transactionTimelineProvider.notifier)
            .removeMomentLocally(tx['id'].toString());
      } catch (e) {
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
      }
    }
  }
}
