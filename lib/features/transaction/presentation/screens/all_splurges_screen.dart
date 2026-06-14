import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/widgets/app_network_image.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/all_splurges_controller.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';

// 🚀 ENUM CHO BỘ LỌC
enum SplurgeFilter { all, month, week }

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

  // 🚀 STATE LƯU TRỮ BỘ LỌC
  SplurgeFilter _currentFilter = SplurgeFilter.all;

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
    final appColors = ref.watch(appColorsProvider);
    AppLocalizations.of(context);

    ref.listen<AsyncValue>(allSplurgesProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        AppToast.showError(context, next.error.toString(), appColors);
      }
    });

    return Scaffold(
      backgroundColor: widget.appColors.background,
      body: splurgesAsync.when(
        skipLoadingOnReload: true,
        loading: () =>
            const Center(child: CupertinoActivityIndicator(radius: 16)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 48,
                color: widget.appColors.errorAccent.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text(
                widget.l10n.errorOccurred,
                style: TextStyle(
                  color: widget.appColors.errorAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        data: (splurges) {
          // 🚀 FIX: LOGIC LỌC DỮ LIỆU ĐÃ CHUYỂN VỀ LOCAL TIME VÀ CHUẨN MỐC 00:00
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);

          final List<dynamic> filteredSplurges = splurges.where((item) {
            // Đảm bảo đưa item.date (thường là UTC) về múi giờ thiết bị trước khi so sánh
            final DateTime localDate = (item.date).toLocal();

            if (_currentFilter == SplurgeFilter.month) {
              return localDate.year == now.year && localDate.month == now.month;
            } else if (_currentFilter == SplurgeFilter.week) {
              final itemStartOfDay = DateTime(
                localDate.year,
                localDate.month,
                localDate.day,
              );
              // Tính số ngày chênh lệch một cách an toàn (tránh sai số giờ/phút)
              final difference = todayStart.difference(itemStartOfDay).inDays;
              return difference <= 7 && difference >= 0;
            }
            return true;
          }).toList();

          // 📊 TÍNH TOÁN DỰA TRÊN DANH SÁCH ĐÃ LỌC
          final double totalSpent = filteredSplurges.fold(
            0.0,
            (sum, item) => sum + item.amount,
          );
          final double highestSpent = filteredSplurges.isEmpty
              ? 0.0
              : filteredSplurges
                    .map((e) => e.amount)
                    .reduce((a, b) => a > b ? a : b);

          // 🚀 KIỂM TRA LAZY LOAD CHO SỐ LƯỢNG MÓN
          final int count = filteredSplurges.length;
          final String displayCount = count >= 20 ? '20+' : count.toString();

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
                        widget.l10n.allSplurgesTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: widget.appColors.text,
                          letterSpacing: 0.5,
                        ),
                      ),
                      background: Container(
                        color: widget.appColors.background.withValues(
                          alpha: 0.6,
                        ),
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Text(
                    widget.l10n.allSplurgesSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.appColors.textMuted,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // 🎛️ BỘ LỌC SEGMENTED CONTROL
              SliverToBoxAdapter(child: _buildFilterSegment(widget.l10n)),

              // 📊 DASHBOARD THỐNG KÊ NHANH
              SliverToBoxAdapter(
                child: _buildSplurgeDashboard(
                  totalSpent,
                  highestSpent,
                  displayCount,
                  widget.l10n,
                ),
              ),

              // 📸 DANH SÁCH THẺ SPLURGE
              if (filteredSplurges.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      widget.l10n.noSplurgesYet,
                      style: textTheme.bodyLarge?.copyWith(
                        color: widget.appColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildPremiumSplurgeCard(
                        filteredSplurges[index],
                        context,
                      );
                    }, childCount: filteredSplurges.length),
                  ),
                ),

              if (notifier.isLoadingMore && _currentFilter == SplurgeFilter.all)
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

  // --- 🎛️ WIDGET: BỘ LỌC ---
  Widget _buildFilterSegment(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<SplurgeFilter>(
          backgroundColor: widget.appColors.primary.withValues(alpha: 0.08),
          thumbColor: widget.appColors.cardBackground,
          groupValue: _currentFilter,
          children: {
            SplurgeFilter.all: _buildSegmentText(
              l10n.filterAll,
              _currentFilter == SplurgeFilter.all,
            ),
            SplurgeFilter.month: _buildSegmentText(
              l10n.filterMonth,
              _currentFilter == SplurgeFilter.month,
            ),
            SplurgeFilter.week: _buildSegmentText(
              l10n.filterWeek,
              _currentFilter == SplurgeFilter.week,
            ),
          },
          onValueChanged: (SplurgeFilter? value) {
            if (value != null) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentFilter = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSegmentText(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? widget.appColors.text
              : widget.appColors.textMuted,
        ),
      ),
    );
  }

  // --- 📊 WIDGET: BẢNG THỐNG KÊ TỔNG QUAN ---
  Widget _buildSplurgeDashboard(
    double totalSpent,
    double maxSpent,
    String displayCount,
    AppLocalizations l10n,
  ) {
    final formattedTotal = CurrencyHelper.formatCompactAmount(
      totalSpent,
      symbol: widget.currencySymbol,
    );
    final formattedMax = CurrencyHelper.formatCompactAmount(
      maxSpent,
      symbol: widget.currencySymbol,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.appColors.primary.withValues(alpha: 0.08),
            widget.appColors.primaryDark.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.appColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            l10n.dashboardTotalSpent,
            formattedTotal,
            CupertinoIcons.drop_fill,
            widget.appColors.errorAccent,
          ),
          Container(
            width: 1,
            height: 32,
            color: widget.appColors.textMuted.withValues(alpha: 0.15),
          ),
          _buildStatItem(
            l10n.dashboardHighestSpent,
            formattedMax,
            CupertinoIcons.star_fill,
            const Color(0xFFFFB300),
          ),
          Container(
            width: 1,
            height: 32,
            color: widget.appColors.textMuted.withValues(alpha: 0.15),
          ),
          _buildStatItem(
            l10n.dashboardQuantity,
            '$displayCount ${l10n.displayCountItem}',
            CupertinoIcons.bag_fill,
            widget.appColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.appColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: widget.appColors.text,
          ),
        ),
      ],
    );
  }

  // --- 📸 WIDGET: THẺ LUXURY SPLURGE CARD ---
  Widget _buildPremiumSplurgeCard(dynamic item, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 🚀 FIX: XỬ LÝ CHUYỂN ĐỔI LOCAL DATE NGAY TRƯỚC KHI FORMAT
    final DateTime localDate = (item.date as DateTime).toLocal();
    final DateFormat dateFormat = DateFormat(
      'dd MMM, yyyy',
      widget.l10n.localeName,
    );
    final DateFormat timeFormat = DateFormat('HH:mm');

    final String displayPrice = CurrencyHelper.formatFullAmount(
      item.amount,
      symbol: widget.currencySymbol,
    );
    final String emoji = item.emoji ?? '✨';

    // 🚀 FIX: XỬ LÝ NOTE VÀ ĐƯA VÀO BIẾN CỤ THỂ
    final String note = item.note ?? '';
    final bool isNoteEmpty = note.trim().isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: widget.appColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.appColors.textMuted.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.appColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.35,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AppNetworkImage(
                      imageUrl: item.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      customErrorWidget: _buildGradientPlaceholder(emoji),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          color: Colors.black.withValues(alpha: 0.25),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
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
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: widget.appColors.primary.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                // 👉 Truyền biến localDate thay vì item.date
                                text: dateFormat
                                    .format(localDate)
                                    .toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  color: widget.appColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.clock_fill,
                                    size: 11,
                                    color: widget.appColors.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(
                                // 👉 Truyền biến localDate thay vì item.date
                                text: timeFormat.format(localDate),
                                style: textTheme.labelSmall?.copyWith(
                                  color: widget.appColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 🚀 FIX: RENDER HIỆU ỨNG NOTE Y HỆT TRONG MOMENT LIST ITEM
                      isNoteEmpty
                          ? Text(
                              widget.l10n.emptyTransactionNote,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: widget.appColors.textMuted.withValues(
                                  alpha: 0.5,
                                ),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) =>
                                  LinearGradient(
                                    colors: [
                                      widget.appColors.primaryDark,
                                      widget.appColors.primary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      bounds.width,
                                      bounds.height,
                                    ),
                                  ),
                              child: Text(
                                note,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Cụm hiển thị số tiền
                Text(
                  displayPrice,
                  style: textTheme.titleLarge?.copyWith(
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
            widget.appColors.primary.withValues(alpha: 0.2),
            widget.appColors.primary.withValues(alpha: 0.5),
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
