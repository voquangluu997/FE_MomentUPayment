import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/app_calendar_sheet.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/features/budget/presentation/widgets/home_budget_card.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_app_bar.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_badge_carousel.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_header_section.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_details_dialog.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_grid_item.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/transaction_card.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/photo_calendar_cell.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';

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
  bool _showBadgeCarousel = true;

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
      final appColors = ref.read(appColorsProvider);
      ref.read(transactionTimelineProvider.notifier).refreshTimeline();
      ref.read(notificationProvider.notifier).fetchUnreadCount();
      AppToast.showSuccess(context, l10n.updateSuccessMessage, appColors);
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
          : DateTime.tryParse(rawDate.toString())?.toLocal();

      if (txDate == null) return false;

      return txDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          txDate.isBefore(endOfDay);
    }).toList();
  }

  Widget _buildBudgetCardWithNavigation(AppLocalizations l10n) {
    return Column(
      children: [
        if (_showBadgeCarousel) ...[
          HomeBadgeCarousel(
            onClose: () {
              setState(() {
                _showBadgeCarousel = false;
              });
            },
          ),
          const SizedBox(height: 8),
        ],
        const Stack(children: [HomeBudgetCard()]),
      ],
    );
  }

  Widget _buildEmptyState(AppColorTheme appColors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: appColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Text('📝', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedDateRange != null
                ? l10n.emptyFilterTransaction
                : l10n.emptyTransactionList,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: appColors.primaryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emptyTransactionSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: appColors.primaryDark.withOpacity(0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(
    AppColorTheme appColors,
    ViewMode viewMode,
    AppLocalizations l10n,
  ) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildBudgetCardWithNavigation(l10n),
        _buildControlHeaderRow(appColors, viewMode, []),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 28,
                decoration: BoxDecoration(
                  color: appColors.cardBackground.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                4,
                (index) => _buildSkeletonItem(appColors, viewMode),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonItem(AppColorTheme appColors, ViewMode viewMode) {
    if (viewMode == ViewMode.grid) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: appColors.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: appColors.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: appColors.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: appColors.background,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 140, height: 16, color: appColors.background),
                const SizedBox(height: 8),
                Container(width: 80, height: 12, color: appColors.background),
              ],
            ),
            const Spacer(),
            Container(width: 60, height: 18, color: appColors.background),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timelineState = ref.watch(transactionTimelineProvider);
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
        strokeWidth: 3,
        onRefresh: () async {
          ref.read(transactionTimelineProvider.notifier).refreshTimeline();
          ref.read(notificationProvider.notifier).fetchUnreadCount();
        },
        child: timelineState.when(
          skipLoadingOnRefresh: true,
          loading: () => _buildSkeletonLoading(appColors, viewMode, l10n),
          error: (error, stack) => Center(
            child: Text(
              l10n.errorLoadData,
              style: TextStyle(color: appColors.errorAccent),
            ),
          ),
          data: (allTransactions) {
            final filteredTransactions = _applyDateFilter(allTransactions);

            if (filteredTransactions.isEmpty && timelineState.isLoading) {
              return _buildSkeletonLoading(appColors, viewMode, l10n);
            }

            final dailyGrouped = DateTimeHelper.groupTransactionsByDate(
              filteredTransactions,
            );
            final dailyKeys = dailyGrouped.keys.toList();

            Map<DateTime, List<Map<String, dynamic>>> monthlyGrouped = {};
            List<DateTime> monthlyKeys = [];

            if (viewMode == ViewMode.calendar) {
              for (var tx in filteredTransactions) {
                final date =
                    DateTime.tryParse(
                      tx['spentAt']?.toString() ?? '',
                    )?.toLocal() ??
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
                  _buildControlHeaderRow(
                    appColors,
                    viewMode,
                    filteredTransactions,
                  ),
                  _buildEmptyState(appColors, l10n),
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
              itemCount: 2 + listLength + (isLoadingMore && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) return _buildBudgetCardWithNavigation(l10n);
                if (index == 1)
                  return _buildControlHeaderRow(
                    appColors,
                    viewMode,
                    filteredTransactions,
                  );

                if (index == 2 + listLength) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: appColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }

                final dataIndex = index - 2;

                if (viewMode == ViewMode.calendar) {
                  return _buildMonthlyCalendar(
                    monthlyKeys[dataIndex],
                    monthlyGrouped[monthlyKeys[dataIndex]]!,
                    l10n,
                    ref,
                    context,
                    appColors,
                  );
                } else if (viewMode == ViewMode.grid) {
                  return _buildMasonryGridGroup(
                    dailyKeys[dataIndex],
                    dailyGrouped[dailyKeys[dataIndex]]!,
                    l10n,
                    ref,
                    context,
                    appColors,
                  );
                } else {
                  return _buildListGroup(
                    dailyKeys[dataIndex],
                    dailyGrouped[dailyKeys[dataIndex]]!,
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
    );
  }

  Widget _buildControlHeaderRow(
    AppColorTheme appColors,
    ViewMode currentMode,
    List<Map<String, dynamic>> currentTransactions,
  ) {
    return HomeHeaderSection(
      isGridView: currentMode == ViewMode.grid,
      isFiltered: _selectedDateRange != null,
      isCalendarView: currentMode == ViewMode.calendar,
      selectedDateRange: _selectedDateRange,
      onClearFilter: () => setState(() => _selectedDateRange = null),
      onToggleView: () {
        ref.read(viewModeProvider.notifier).state = currentMode == ViewMode.grid
            ? ViewMode.list
            : ViewMode.grid;
      },
      onFilterTap: () {
        AppCalendarSheet.show(
          context: context,
          initialRange:
              _selectedDateRange ??
              DateTimeRange(start: DateTime.now(), end: DateTime.now()),
          appColors: appColors,
          onRangeSelected: (range) =>
              setState(() => _selectedDateRange = range),
        );
      },
      onCalendarTap: () {
        ref
            .read(viewModeProvider.notifier)
            .state = currentMode == ViewMode.calendar
            ? ViewMode.list
            : ViewMode.calendar;
      },
    );
  }

  Widget _buildDateHeaderPill(
    String dateKey,
    AppLocalizations l10n,
    AppColorTheme appColors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: appColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.calendar, size: 16, color: appColors.primary),
            const SizedBox(width: 8),
            Text(
              DateTimeHelper.getFriendlyDateLabel(dateKey, l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: appColors.primary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
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
        _buildDateHeaderPill(dateKey, l10n, appColors),
        ...txList.map(
          (tx) => _buildDismissibleCard(context, ref, tx, l10n, appColors),
        ),
      ],
    );
  }

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
        _buildDateHeaderPill(dateKey, l10n, appColors),
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
          DateTime.tryParse(tx['spentAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now();

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
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 16),
          child: Text(
            '${l10n.month} ${monthKey.month}, ${monthKey.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: appColors.primaryDark,
              letterSpacing: -0.5,
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
                  final isWeekend = entry.key == 5 || entry.key == 6;
                  return SizedBox(
                    width: 32,
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isWeekend
                            ? FontWeight.w800
                            : FontWeight.bold,
                        color: isWeekend
                            ? appColors.errorAccent.withOpacity(0.9)
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
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
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
              onTap: () async {
                if (dayData != null) {
                  _showDayDetailsBottomSheet(
                    context,
                    dayDate,
                    dayData,
                    appColors,
                    l10n,
                  );
                } else {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  if (dayDate.isAfter(today)) {
                    AppToast.showError(
                      context,
                      l10n.futureDateError,
                      appColors,
                    );
                    return;
                  }

                  // 🚀 UPDATE: Await kết quả trả về từ màn hình thêm giao dịch
                  final bool? isAdded = await Navigator.of(context).push<bool>(
                    CupertinoPageRoute(
                      builder: (_) =>
                          AddTransactionScreen(initialDate: dayDate),
                    ),
                  );

                  // 🚀 Kích hoạt load lại dữ liệu & tính toán huy hiệu ngầm
                  // nếu người dùng đã thêm thành công
                  if (isAdded == true && mounted) {
                    ref
                        .read(transactionTimelineProvider.notifier)
                        .refreshTimeline();
                  }
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
      backgroundColor: appColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final List txList = dayData['transactions'];
        return FractionallySizedBox(
          heightFactor: 0.65,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: appColors.primaryDark.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.doc_text,
                        color: appColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${l10n.day} ${date.day} ${l10n.month} ${date.month}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: appColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          l10n.transactionCount(txList.length),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryDark.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4B4B).withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l10n.deleteActionLabel,
              style: const TextStyle(
                color: Color(0xFFFF4B4B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.trash,
              color: Color(0xFFFF4B4B),
              size: 24,
            ),
          ],
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4B4B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: Color(0xFFFF4B4B),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.deleteDialogTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: appColors.primaryDark,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteDialogContent,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appColors.primaryDark.withOpacity(0.7),
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    l10n.deleteDialogCancel,
                    style: TextStyle(
                      color: appColors.primaryDark.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4B4B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    l10n.deleteDialogConfirm,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isConfirm == true) {
      try {
        await ref
            .read(transactionTimelineProvider.notifier)
            .deleteTransaction(tx['id'].toString());

        // 🚀 UPDATE: Đã gỡ bỏ hàm removeMomentLocally thừa thãi ở đây
        // vì hàm deleteTransaction của Controller ĐÃ BAO GỒM logic xóa dữ liệu khỏi State
        // VÀ nó cũng đã chạy ngầm hàm _evaluateBadges() cho ta luôn rồi.

        if (mounted) {
          AppToast.showSuccess(context, l10n.deleteSuccessMessage, appColors);
        }
      } catch (e) {
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
        if (mounted) {
          AppToast.showError(context, l10n.deleteErrorMessage, appColors);
        }
      }
    }
  }
}
