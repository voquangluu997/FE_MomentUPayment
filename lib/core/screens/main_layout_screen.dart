import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moment_u_payment/core/features/recap/screens/story_recap_screen.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/utils/gamification_utils.dart';
import 'package:moment_u_payment/features/budget/data/models/budget_summary.dart';
import 'package:moment_u_payment/features/transaction/data/transaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/badge_service.dart';
import 'package:moment_u_payment/core/features/badges/widgets/multiple_badge_premium_dialog.dart';
import 'package:moment_u_payment/core/services/quick_actions_service.dart';
import 'package:moment_u_payment/core/services/home_widget_service.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_analytics_controller.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isNavbarVisible = true;

  StreamSubscription<Uri?>? _widgetClickSubscription;
  final List<Widget> _screens = [const HomeScreen(), const AnalyticsScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 🚀 1. Gọi hàm đồng bộ ngay khi mở app
      await _syncDataWithBackend();

      // 🚀 2. Kiểm tra và hiển thị Story Recap thông minh (Chạy ngầm sau khi sync data)
      _checkAndShowMonthlyRecap();

      // 🚀 3. Tự động kiểm tra huy hiệu ngay lần dựng UI đầu tiên
      final initialBadges = ref.read(newlyUnlockedBadgeProvider);
      if (initialBadges.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            final appColors = ref.read(appColorsProvider);
            final l10n = AppLocalizations.of(context)!;
            _showCelebrationDialog(context, initialBadges, appColors, l10n);
          }
        });
      }

      // Khởi tạo Quick Actions & Home Widget
      ref.read(quickActionsServiceProvider).init(() {
        _navigateToAddTransaction();
      });

      HomeWidgetService.checkWidgetLaunch(() {
        _navigateToAddTransaction();
      });
    });

    _widgetClickSubscription = HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null && uri.host == 'add_transaction') {
        _navigateToAddTransaction();
      }
    });
  }

  // =========================================================================
  // 🌟 LOGIC: KIỂM TRA & HIỂN THỊ STORY RECAP THÔNG MINH
  // =========================================================================
  Future<void> _checkAndShowMonthlyRecap() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final recapKey = 'recap_shown_${now.year}_${now.month}';

    // Điều kiện hiển thị thực tế
    if (now.day > 5) return;
    if (prefs.getBool(recapKey) ?? false) return;

    try {
      final repo = ref.read(transactionRepositoryProvider);
      // ignore: use_build_context_synchronously
      final l10n = AppLocalizations.of(context)!;
      final currencySymbol = ref.read(currencyProvider).toString();
      final appColors = ref.read(appColorsProvider);

      // ---------------------------------------------------------
      // 🌟 BƯỚC 1: XÁC ĐỊNH MỐC THỜI GIAN CHUẨN LOCAL TIME M-1 và M-2
      // ---------------------------------------------------------
      final DateTime lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final DateTime lastMonthEnd = DateTime(
        now.year,
        now.month,
        0,
        23,
        59,
        59,
        999,
      );

      final DateTime monthBeforeStart = DateTime(now.year, now.month - 2, 1);
      final DateTime monthBeforeEnd = DateTime(
        now.year,
        now.month - 1,
        0,
        23,
        59,
        59,
        999,
      );

      // 🚀 Kéo toàn bộ dữ liệu đồng thời từ server
      final results = await Future.wait([
        repo.getTransactions(
          page: 1,
          limit: 1000,
          startDate: lastMonthStart.toUtc(),
          endDate: lastMonthEnd.toUtc(),
        ),
        repo.getTransactions(
          page: 1,
          limit: 1000,
          startDate: monthBeforeStart.toUtc(),
          endDate: monthBeforeEnd.toUtc(),
        ),
        // ignore: invalid_return_type_for_catch_error
        ref.read(homeBudgetProvider.future).catchError((_) => null),
      ]);

      final List<Map<String, dynamic>> lastMonthTx =
          results[0] as List<Map<String, dynamic>>;
      final List<Map<String, dynamic>> monthBeforeTx =
          results[1] as List<Map<String, dynamic>>;
      final budgetSummary = results[2] as BudgetSummary?;

      if (lastMonthTx.isEmpty) {
        await prefs.setBool(recapKey, true);
        return;
      }

      // ---------------------------------------------------------
      // 🌟 BƯỚC 2: TÍNH TOÁN SỐ LIỆU CHI TIÊU & SO SÁNH TĂNG GIẢM
      // ---------------------------------------------------------
      final int swipeCount = lastMonthTx.length;
      final double spentLastMonth = lastMonthTx.fold(
        0.0,
        (sum, tx) => sum + ((tx['amount'] as num?)?.toDouble() ?? 0.0),
      );
      final double spentMonthBefore = monthBeforeTx.fold(
        0.0,
        (sum, tx) => sum + ((tx['amount'] as num?)?.toDouble() ?? 0.0),
      );

      final String formattedSpentLastMonth = CurrencyHelper.formatCompactAmount(
        spentLastMonth,
        symbol: currencySymbol,
      );

      // 🔥 Cập nhật yêu cầu: Nếu m-2 không có dữ liệu (=0) thì để chuỗi rỗng không hiển thị dòng so sánh
      String comparisonText = '';
      if (spentMonthBefore > 0) {
        final double difference = (spentLastMonth - spentMonthBefore).abs();
        final String formattedDifference = CurrencyHelper.formatCompactAmount(
          difference,
          symbol: currencySymbol,
        );

        if (spentLastMonth > spentMonthBefore) {
          comparisonText = l10n.recapComparisonMore(formattedDifference);
        } else if (spentLastMonth < spentMonthBefore) {
          comparisonText = l10n.recapComparisonLess(formattedDifference);
        } else {
          comparisonText = l10n.recapComparisonEqual;
        }
      }

      // ---------------------------------------------------------
      // 🌟 BƯỚC 3: KIỂM TRA NGÂN SÁCH & TRÍCH XUẤT DANH SÁCH BADGES M-1
      // ---------------------------------------------------------
      final double budgetLimit = budgetSummary?.budgetLimit.toDouble() ?? 0.0;
      final double budgetDiff = budgetLimit - spentLastMonth;

      String budgetAnalysisText;
      if (budgetLimit <= 0) {
        budgetAnalysisText = formattedSpentLastMonth;
      } else {
        final String formattedBudgetDiff = CurrencyHelper.formatCompactAmount(
          budgetDiff.abs(),
          symbol: currencySymbol,
        );
        budgetAnalysisText = budgetDiff >= 0
            ? l10n.recapUnderBudget(formattedBudgetDiff)
            : l10n.recapOverBudget(formattedBudgetDiff);
      }

      final List<BadgeType> earnedTypes = GamificationUtils.calculateBadges(
        [],
        lastMonthTx,
        spentLastMonth,
      );
      final List<UserBadge> earnedBadges = earnedTypes
          .map(
            (type) =>
                GamificationUtils.allBadges.firstWhere((b) => b.type == type),
          )
          .toList();

      // ---------------------------------------------------------
      // 🌟 BƯỚC 4: THIẾT LẬP DỮ LIỆU SLIDE MỚI & ĐIỀU HƯỚNG
      // ---------------------------------------------------------
      final List<RecapSlideData> recapSlides = [
        RecapSlideData(
          title: l10n.recapSwipeCountMain(swipeCount),
          mainText: formattedSpentLastMonth,
          subText: comparisonText, // Sẽ hiển thị trống nếu tháng m-2 bằng 0
          type: RecapSlideType.spending,
        ),
        RecapSlideData(
          title: l10n.recapEarnedBadges,
          mainText: budgetAnalysisText,
          subText: l10n.recapBadgeResetNotice,
          badges: earnedBadges,
          type: RecapSlideType.badges,
          shouldCelebrate: earnedBadges.isNotEmpty,
        ),
      ];

      await prefs.setBool(recapKey, true);

      if (!mounted) return;

      // Giữ lại context an toàn của MainLayoutScreen
      final mainLayoutContext = context;

      // ignore: use_build_context_synchronously
      Navigator.of(mainLayoutContext).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => StoryRecapScreen(
            appColors: appColors,
            title: l10n.recapTitleMonthly(
              lastMonthStart.month.toString().padLeft(2, '0'),
            ),
            slides: recapSlides,
            actionLabel: l10n.recapViewAnalytics,
            onFinish: () {
              Navigator.of(mainLayoutContext, rootNavigator: true).pop();

              // Cập nhật tab bằng tham chiếu trực tiếp an toàn
              if (mainLayoutContext.mounted) {
                setState(() {
                  _currentIndex = 1;
                  _isNavbarVisible = true;
                });
                AppLogger.i(
                  'i',
                  "🚀 Đã điều hướng thành công đến tab Analytics",
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      AppLogger.e("err", "Error generating Enhanced Recap Story: $e");
    }
  }

  // 🚀 HÀM ĐỒNG BỘ DỮ LIỆU TỔNG HỢP
  Future<void> _syncDataWithBackend() async {
    if (!mounted) return;

    ref.read(badgeServiceProvider.notifier).refreshBadges();
    ref.read(notificationProvider.notifier).fetchUnreadCount();
    await ref.read(transactionTimelineProvider.notifier).refreshTimeline();
    ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();
    ref.invalidate(homeBudgetProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncDataWithBackend();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  Future<void> _navigateToAddTransaction() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (mounted) {
      _syncDataWithBackend();
    }
  }

  void _showCelebrationDialog(
    BuildContext context,
    List<UserBadge> badgesList,
    dynamic appColors,
    AppLocalizations l10n,
  ) {
    HapticFeedback.vibrate();

    if (badgesList.isEmpty) return;

    List<UserBadge> sortedBadges = List.from(badgesList);
    sortedBadges.sort((a, b) {
      final titleA = a.getLocalizedTitle(l10n).toLowerCase();
      final titleB = b.getLocalizedTitle(l10n).toLowerCase();
      final isLowPriorityA =
          titleA.contains('khởi đầu mới') || titleA.contains('new beginning');
      final isLowPriorityB =
          titleB.contains('khởi đầu mới') || titleB.contains('new beginning');

      if (isLowPriorityA && !isLowPriorityB) return 1;
      if (!isLowPriorityA && isLowPriorityB) return -1;
      return 0;
    });

    final bool isMultiple = sortedBadges.length > 1;

    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, _) => MultipleBadgePremiumDialog(
        badges: sortedBadges,
        title: isMultiple
            ? l10n.congratsMultipleTitle
            : l10n.congratsSingleTitle,
        description: isMultiple
            ? l10n.congratsMultipleSub
            : l10n.congratsSingleSub,
        appColors: appColors,
        onConfirm: () {
          Navigator.of(context).pop();
          ref.read(badgeServiceProvider.notifier).clearNewlyUnlocked();
          ref.read(notificationProvider.notifier).fetchUnreadCount();
        },
      ),
      transitionBuilder: (context, anim1, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<List<UserBadge>>(newlyUnlockedBadgeProvider, (previous, next) {
      if (next.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // ignore: use_build_context_synchronously
            _showCelebrationDialog(context, next, appColors, l10n);
          }
        });
      }
    });

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
            _isNavbarVisible = true;
          });
        }
      },
      child: Scaffold(
        extendBody: true,
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (_isNavbarVisible) setState(() => _isNavbarVisible = false);
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_isNavbarVisible) setState(() => _isNavbarVisible = true);
            }
            return true;
          },
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
        bottomNavigationBar: _buildPremiumNavigationBar(appColors, l10n),
      ),
    );
  }

  Widget _buildPremiumNavigationBar(dynamic appColors, AppLocalizations l10n) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      offset: _isNavbarVisible ? Offset.zero : const Offset(0, 1.5),
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 16,
            top: 8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  color: appColors.cardBackground.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: CupertinoIcons.house,
                      activeIcon: CupertinoIcons.house_fill,
                      label: l10n.navHome,
                      appColors: appColors,
                    ),
                    _buildNavItem(
                      index: -1,
                      icon: CupertinoIcons.creditcard,
                      activeIcon: CupertinoIcons.creditcard_fill,
                      label: l10n.navBudget,
                      appColors: appColors,
                      customAction: () async {
                        await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const SetBudgetScreen(),
                          ),
                        );
                        if (mounted) _syncDataWithBackend();
                      },
                    ),
                    Tooltip(
                      message: l10n.addMomentTooltip,
                      child: PremiumAddButton(
                        appColors: appColors,
                        onTap: _navigateToAddTransaction,
                      ),
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: CupertinoIcons.chart_bar_square,
                      activeIcon: CupertinoIcons.chart_bar_square_fill,
                      label: l10n.navAnalytics,
                      appColors: appColors,
                    ),
                    _buildNavItem(
                      index: -1,
                      icon: CupertinoIcons.slider_horizontal_3,
                      activeIcon: CupertinoIcons.slider_horizontal_3,
                      label: l10n.navMenu,
                      appColors: appColors,
                      customAction: () {
                        if (mounted) SettingsBottomSheet.show(context);
                      },
                      isMenu: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required dynamic appColors,
    VoidCallback? customAction,
    bool isMenu = false,
  }) {
    final bool isSelected = (customAction == null) && _currentIndex == index;
    final Color inactiveColor = appColors.textMuted.withValues(alpha: 0.5);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (customAction != null) {
          HapticFeedback.lightImpact();
          customAction();
        } else {
          if (_currentIndex != index) {
            HapticFeedback.lightImpact();
            setState(() {
              _currentIndex = index;
            });
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? appColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? appColors.primary
                    : (isMenu ? appColors.text : inactiveColor),
                size: isSelected ? 24 : 22,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: appColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumAddButton extends StatefulWidget {
  final dynamic appColors;
  final VoidCallback onTap;
  const PremiumAddButton({
    super.key,
    required this.appColors,
    required this.onTap,
  });

  @override
  State<PremiumAddButton> createState() => _PremiumAddButtonState();
}

class _PremiumAddButtonState extends State<PremiumAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.90,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = widget.appColors;
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                appColors.primary,
                Color.lerp(appColors.primary, appColors.primaryDark, 0.4)!,
                appColors.primaryDark,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: appColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: 44,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              RotationTransition(
                turns: _rotationAnimation,
                child: const Icon(
                  CupertinoIcons.add,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
