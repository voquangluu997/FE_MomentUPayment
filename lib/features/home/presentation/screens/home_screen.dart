import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/features/budget/presentation/widgets/home_budget_card.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_app_bar.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_header_section.dart'; // 👈 Import Widget Mới
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

  @override
  void initState() {
    super.initState();

    // Tự động gọi API lấy số lượng thông báo chưa đọc khi user vừa mở App
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () =>
            ref.read(transactionTimelineProvider.notifier).refreshTimeline(),
        child: timelineState.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Text(
              l10n.errorLoadData,
              style: const TextStyle(color: AppColors.errorAccent),
            ),
          ),
          data: (transactions) {
            final monthlyGrouped = DateTimeHelper.groupMomentsByMonth(
              transactions,
              l10n,
            );
            final dailyGrouped = DateTimeHelper.groupTransactionsByDate(
              transactions,
            );
            final keys = isGridView
                ? monthlyGrouped.keys.toList()
                : dailyGrouped.keys.toList();

            if (transactions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  _buildBudgetCardWithNavigation(l10n),
                  const HomeHeaderSection(), // 👈 Dùng Widget đã tách
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        l10n.emptyTransactionList,
                        style: TextStyle(
                          color: AppColors.primaryDark.withOpacity(0.5),
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
              itemCount: 2 + keys.length + (isLoadingMore && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) return _buildBudgetCardWithNavigation(l10n);

                if (index == 1)
                  return const HomeHeaderSection(); // 👈 Dùng Widget đã tách

                if (index == 2 + keys.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }

                final dataIndex = index - 2;
                final groupKey = keys[dataIndex];

                if (isGridView) {
                  return _buildGridGroup(
                    groupKey,
                    monthlyGrouped[groupKey]!,
                    l10n,
                    ref,
                    context,
                  );
                } else {
                  return _buildListGroup(
                    groupKey,
                    dailyGrouped[groupKey]!,
                    l10n,
                    ref,
                    context,
                  );
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
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

  Widget _buildListGroup(
    String dateKey,
    List<Map<String, dynamic>> txList,
    AppLocalizations l10n,
    WidgetRef ref,
    BuildContext context,
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
              color: AppColors.primaryDark.withOpacity(0.45),
            ),
          ),
        ),
        ...txList.map((tx) => _buildDismissibleCard(context, ref, tx, l10n)),
      ],
    );
  }

  Widget _buildGridGroup(
    String monthKey,
    List<Map<String, dynamic>> txList,
    AppLocalizations l10n,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
          child: Text(
            monthKey,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark.withOpacity(0.45),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemCount: txList.length,
            itemBuilder: (context, gridIdx) => MomentGridItem(
              moment: txList[gridIdx],
              l10n: l10n,
              onLongPress: () =>
                  _showDeleteConfirmDialog(context, ref, txList[gridIdx], l10n),
              onTap: () => _openMomentDetails(txList[gridIdx], l10n),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> tx,
    AppLocalizations l10n,
  ) {
    return Dismissible(
      key: Key(tx['id'].toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        await _showDeleteConfirmDialog(context, ref, tx, l10n);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.errorAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_sweep, color: AppColors.errorAccent),
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
  ) async {
    final isConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteDialogTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.deleteDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.deleteDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteDialogConfirm,
              style: const TextStyle(color: AppColors.errorAccent),
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
