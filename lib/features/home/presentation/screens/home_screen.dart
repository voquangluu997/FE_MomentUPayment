import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
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
import 'package:moment_u_payment/features/transaction/presentation/widgets/photo_calendar_cell.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';

// ✨ TẠO ENUM 3 TRẠNG THÁI VIEW
enum ViewMode { list, grid, calendar }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  DateTimeRange? _selectedDateRange;

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

  List<Map<String, dynamic>> _applyDateFilter(
    List<Map<String, dynamic>> transactions,
  ) {
    if (_selectedDateRange == null) return transactions;

    final DateTime startOfDay = DateTime(
      _selectedDateRange!.start.year,
      _selectedDateRange!.start.month,
      _selectedDateRange!.start.day,
    );

    final DateTime endOfDay = DateTime(
      _selectedDateRange!.end.year,
      _selectedDateRange!.end.month,
      _selectedDateRange!.end.day,
    ).add(const Duration(days: 1));

    return transactions.where((tx) {
      final dynamic rawDate = tx['spentAt'];
      if (rawDate == null) return false;

      final DateTime? txDate = rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate.toString());

      if (txDate == null) return false;

      return txDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          txDate.isBefore(endOfDay);
    }).toList();
  }

  Widget _buildBudgetCardWithNavigation(AppLocalizations l10n) {
    return const Stack(children: [HomeBudgetCard()]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timelineState = ref.watch(transactionTimelineProvider);

    // ✨ Lắng nghe trạng thái View hiện tại (List, Grid, Calendar)
    final viewMode = ref.watch(viewModeProvider);

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
            final filteredTransactions = _applyDateFilter(allTransactions);

            // 1. NHÓM DỮ LIỆU THEO NGÀY (Dùng cho List và Masonry Grid)
            final dailyGrouped = DateTimeHelper.groupTransactionsByDate(
              filteredTransactions,
            );
            final dailyKeys = dailyGrouped.keys.toList();

            // 2. NHÓM DỮ LIỆU THEO THÁNG (Chỉ tạo khi đang ở chế độ Calendar)
            Map<DateTime, List<Map<String, dynamic>>> monthlyGrouped = {};
            List<DateTime> monthlyKeys = [];

            if (viewMode == ViewMode.calendar) {
              for (var tx in filteredTransactions) {
                final date =
                    DateTime.tryParse(tx['spentAt']?.toString() ?? '') ??
                    DateTime.now();
                final monthKey = DateTime(date.year, date.month, 1);
                monthlyGrouped.putIfAbsent(monthKey, () => []).add(tx);
              }
              monthlyKeys = monthlyGrouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));
            }

            if (filteredTransactions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  _buildBudgetCardWithNavigation(l10n),
                  _buildControlHeaderRow(appColors, viewMode),
                  if (_selectedDateRange != null)
                    _buildFilterTag(appColors, l10n),
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        _selectedDateRange != null
                            ? l10n.emptyFilterTransaction
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

            final listLength = viewMode == ViewMode.calendar
                ? monthlyKeys.length
                : dailyKeys.length;

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: 3 + listLength + (isLoadingMore && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) return _buildBudgetCardWithNavigation(l10n);
                if (index == 1)
                  return _buildControlHeaderRow(appColors, viewMode);
                if (index == 2) {
                  return _selectedDateRange != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildFilterTag(appColors, l10n),
                        )
                      : const SizedBox.shrink();
                }

                if (index == 3 + listLength) {
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

                final dataIndex = index - 3;

                // ✨ RẼ NHÁNH GIAO DIỆN CHÍNH Ở ĐÂY
                if (viewMode == ViewMode.calendar) {
                  final monthKey = monthlyKeys[dataIndex];
                  final txList = monthlyGrouped[monthKey]!;
                  return _buildMonthlyCalendar(
                    monthKey,
                    txList,
                    l10n,
                    ref,
                    context,
                    appColors,
                  );
                } else if (viewMode == ViewMode.grid) {
                  final dayKey = dailyKeys[dataIndex];
                  final txList = dailyGrouped[dayKey]!;
                  return _buildMasonryGridGroup(
                    dayKey,
                    txList,
                    l10n,
                    ref,
                    context,
                    appColors,
                  );
                } else {
                  // ViewMode.list
                  final dayKey = dailyKeys[dataIndex];
                  final txList = dailyGrouped[dayKey]!;
                  return _buildListGroup(
                    dayKey,
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
  // WIDGET ROW: CHỨA TIÊU ĐỀ HOME + CẶP NÚT FILTER & CHUYỂN VIEW
  // ===========================================================================
  Widget _buildControlHeaderRow(AppColorTheme appColors, ViewMode currentMode) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Expanded(
            child: HomeHeaderSection(
              // Truyền trạng thái để icon cũ biết đang ở Grid hay List
              isGridView: currentMode == ViewMode.grid,
              isFiltered: _selectedDateRange != null,

              // 🔄 Logic cho nút cũ: Chỉ xoay vòng giữa List và Grid
              onToggleView: () {
                if (currentMode == ViewMode.grid) {
                  ref.read(viewModeProvider.notifier).state = ViewMode.list;
                } else {
                  ref.read(viewModeProvider.notifier).state = ViewMode.grid;
                }
              },

              onFilterTap: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  initialDateRange:
                      _selectedDateRange ??
                      DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
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

          const SizedBox(width: 8),

          // ✨ NÚT CALENDAR ĐỘC LẬP NẰM BÊN CẠNH
          InkWell(
            onTap: () {
              if (currentMode == ViewMode.calendar) {
                // Đang mở Lịch, bấm vào sẽ tắt Lịch (trở về List mặc định)
                ref.read(viewModeProvider.notifier).state = ViewMode.list;
              } else {
                // Đang ở List/Grid, bấm vào sẽ bật Lịch
                ref.read(viewModeProvider.notifier).state = ViewMode.calendar;
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentMode == ViewMode.calendar
                    ? appColors.primary
                    : appColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 22,
                color: currentMode == ViewMode.calendar
                    ? Colors.white
                    : appColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(AppColorTheme appColors, AppLocalizations l10n) {
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
                '${l10n.from} ${f.format(_selectedDateRange!.start)} ${l10n.to} ${f.format(_selectedDateRange!.end)}',
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

  // ===========================================================================
  // 1. GIAO DIỆN LIST (MẶC ĐỊNH)
  // ===========================================================================
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

  // ===========================================================================
  // 2. GIAO DIỆN MASONRY GRID (GIỮ LẠI CŨ)
  // ===========================================================================
  Widget _buildMasonryGridGroup(
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

  // ===========================================================================
  // 3. GIAO DIỆN CALENDAR (MỚI THÊM VÀO)
  // ===========================================================================
  Widget _buildMonthlyCalendar(
    DateTime monthKey,
    List<Map<String, dynamic>> monthTx,
    AppLocalizations l10n,
    WidgetRef ref,
    BuildContext context,
    AppColorTheme appColors,
  ) {
    Map<int, Map<String, dynamic>> dailyData = {};
    for (var tx in monthTx) {
      final date =
          DateTime.tryParse(tx['spentAt']?.toString() ?? '') ?? DateTime.now();

      if (!dailyData.containsKey(date.day)) {
        dailyData[date.day] = {
          'totalAmount': (tx['amount'] as num?)?.toDouble() ?? 0.0,
          'imageUrl': tx['imageUrl'] ?? '',
          'emoji': tx['emoji'] ?? '✨',
          'transactions': [tx],
        };
      } else {
        dailyData[date.day]!['totalAmount'] +=
            (tx['amount'] as num?)?.toDouble() ?? 0.0;
        dailyData[date.day]!['transactions'].add(tx);

        if ((dailyData[date.day]!['imageUrl'] as String).isEmpty &&
            (tx['imageUrl'] ?? '').toString().isNotEmpty) {
          dailyData[date.day]!['imageUrl'] = tx['imageUrl'];
        }
      }
    }

    final daysInMonth = DateUtils.getDaysInMonth(monthKey.year, monthKey.month);
    final firstWeekday = DateTime(monthKey.year, monthKey.month, 1).weekday;
    final emptyDays = firstWeekday - 1;
    final totalCells = emptyDays + daysInMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 8),
          child: Text(
            '${l10n.month} ${monthKey.month}, ${monthKey.year}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: appColors.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                [
                  l10n.mon,
                  l10n.tue,
                  l10n.wed,
                  l10n.thu,
                  l10n.fri,
                  l10n.sat,
                  l10n.sun,
                ].asMap().entries.map((entry) {
                  final isWeekend =
                      entry.key == 5 || entry.key == 6; // Thứ 7, CN
                  final day = entry.value;

                  return SizedBox(
                    width: 30,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isWeekend
                            ? appColors.errorAccent.withOpacity(0.8)
                            : appColors.primaryDark.withOpacity(0.5),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.75,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < emptyDays) return const SizedBox.shrink();

            final day = index - emptyDays + 1;
            final dayDate = DateTime(monthKey.year, monthKey.month, day);
            final dayData = dailyData[day];

            return PhotoCalendarCell(
              date: dayDate,
              dayData: dayData,
              onTap: () {
                if (dayData != null) {
                  _showDayDetailsBottomSheet(
                    context,
                    dayDate,
                    dayData,
                    appColors,
                    l10n,
                  );
                } else {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(),
                        ),
                      )
                      .then((isAdded) {
                        if (isAdded == true && mounted) {
                          ref
                              .read(transactionTimelineProvider.notifier)
                              .refreshTimeline();
                        }
                      });
                }
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showDayDetailsBottomSheet(
    BuildContext context,
    DateTime date,
    Map<String, dynamic> dayData,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List txList = dayData['transactions'];
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "${l10n.day} ${date.day} ${l10n.month} ${date.month}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryDark,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: txList.length,
                  itemBuilder: (context, index) {
                    final tx = txList[index];
                    return TransactionCard(
                      transaction: tx,
                      onTap: () {
                        Navigator.pop(context);
                        _openMomentDetails(tx, l10n);
                      },
                      l10n: l10n,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
