import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/widgets/analytics_components.dart';
import 'package:moment_u_payment/core/widgets/app_network_image.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/all_splurges_controller.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class AllSplurgesScreen extends ConsumerStatefulWidget {
  final AppColorTheme appColors;
  final AppLocalizations l10n;
  final String currencySymbol;

  const AllSplurgesScreen({
    super.key,
    required this.appColors,
    required this.l10n,
    required this.currencySymbol,
  });

  @override
  ConsumerState<AllSplurgesScreen> createState() => _AllSplurgesScreenState();
}

class _AllSplurgesScreenState extends ConsumerState<AllSplurgesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Tự động load thêm khi scroll đến gần cuối trang (cách đáy 200px)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(allSplurgesProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final splurgesAsync = ref.watch(allSplurgesProvider);
    final notifier = ref.watch(allSplurgesProvider.notifier);

    return Scaffold(
      backgroundColor: widget.appColors.background,
      body: splurgesAsync.when(
        loading: () =>
            const Center(child: CupertinoActivityIndicator(radius: 16)),
        error: (error, stack) => Center(
          child: Text(
            'Lỗi: $error',
            style: TextStyle(color: widget.appColors.errorAccent),
          ),
        ),
        data: (splurges) {
          if (splurges.isEmpty) {
            return const Center(
              child: Text("Chưa có khoản chi tiêu khủng nào ✨"),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 💎 Glassmorphism AppBar
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        widget.l10n.allSplurgesTitle ?? "Hall of Fame 🏆",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: widget.appColors.text,
                          letterSpacing: 0.5,
                        ),
                      ),
                      background: Container(
                        color: widget.appColors.background.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(CupertinoIcons.back, color: widget.appColors.text),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: Text(
                    widget.l10n.allSplurgesSubtitle ??
                        "Nhìn lại những lần rút hầu bao đậm sâu nhất của bạn! Đừng tiếc nuối nhé ✨",
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.appColors.textMuted,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // 📸 Danh sách các thẻ Splurge
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildPremiumSplurgeCard(splurges[index], context);
                  }, childCount: splurges.length),
                ),
              ),

              // 🔄 Vòng xoay Load More dưới đáy
              if (notifier.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPremiumSplurgeCard(SplurgeInfo item, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat dateFormat = DateFormat(
      'dd MMMM, yyyy',
      widget.l10n.localeName,
    );

    final String displayPrice = CurrencyHelper.formatFullAmount(
      item.amount,
      symbol: widget.currencySymbol,
    );
    final String emoji = item.emoji ?? '✨';
    final bool hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: widget.appColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: widget.appColors.primaryDark.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AppNetworkImage(
                  imageUrl: item.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  customErrorWidget: _buildGradientPlaceholder(emoji),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.appColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dateFormat.format(item.date).toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: widget.appColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        // Thêm trường note vào SplurgeInfo nếu bạn muốn hiện ghi chú
                        widget.l10n.emptyTransactionNote ??
                            "Một khoản chi đáng nhớ",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: widget.appColors.text,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  displayPrice,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: widget.appColors.errorAccent,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientPlaceholder(String emoji) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.appColors.primary.withOpacity(0.2),
            widget.appColors.primary.withOpacity(0.5),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.15,
              child: Text(emoji, style: const TextStyle(fontSize: 160)),
            ),
          ),
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 64,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
