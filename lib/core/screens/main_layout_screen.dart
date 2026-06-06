import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/badge_service.dart';
import 'package:moment_u_payment/core/features/badges/widgets/multiple_badge_premium_dialog.dart';
import 'package:moment_u_payment/core/services/quick_actions_service.dart';
import 'package:moment_u_payment/core/services/home_widget_service.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:moment_u_payment/features/transaction/presentation/transaction_provider.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

// Đảm bảo import đúng model UserBadge của bạn
import 'package:moment_u_payment/core/features/badges/badge_model.dart';

// 🚀 NẾU BẠN CÓ TRANSACTION PROVIDER, HÃY IMPORT Ở ĐÂY
// import 'package:moment_u_payment/features/transaction/providers/transaction_provider.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🚀 1. Gọi hàm đồng bộ ngay khi mở app
      _syncDataWithBackend();

      // 🚀 2. Tự động kiểm tra huy hiệu ngay lần dựng UI đầu tiên (Vừa login xong)
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

  // 🚀 HÀM ĐỒNG BỘ DỮ LIỆU TỔNG HỢP
  Future<void> _syncDataWithBackend() async {
    if (!mounted) return;

    // 1. Làm mới danh sách huy hiệu từ API/Local
    ref.read(badgeServiceProvider.notifier).refreshBadges();

    // 2. Làm mới đếm số thông báo
    ref.read(notificationProvider.notifier).fetchUnreadCount();

    // 3. LÀM MỚI DỮ LIỆU GIAO DỊCH & NGÂN SÁCH
    // Cập nhật dòng thời gian
    ref.read(transactionTimelineProvider.notifier).refreshTimeline();

    // Cập nhật biểu đồ thống kê
    ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();

    // Ép ví ngoan tính lại tiền ngân sách
    ref.invalidate(homeBudgetProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Gọi hàm đồng bộ khi người dùng mở lại app từ chế độ nền
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
    // Đồng bộ lại toàn bộ dữ liệu sau khi thêm giao dịch (đóng màn hình Add)
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
      pageBuilder: (context, _, __) => MultipleBadgePremiumDialog(
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

    // 🌟 CHỈ LẮNG NGHE SỰ THAY ĐỔI MỚI TRONG QUÁ TRÌNH DÙNG APP
    ref.listen<List<UserBadge>>(newlyUnlockedBadgeProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        // Delay một chút để tránh xung đột animation khi đang chuyển trang
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
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
                  color: appColors.cardBackground.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
                        // Thay thế lệnh refresh cũ bằng hàm _syncData tổng
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
    final Color inactiveColor = appColors.textMuted.withOpacity(0.5);

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
              ? appColors.primary.withOpacity(0.1)
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
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: appColors.primary.withOpacity(0.4),
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
                        Colors.white.withOpacity(0.25),
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
