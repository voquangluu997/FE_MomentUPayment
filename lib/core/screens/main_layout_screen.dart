import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'; // 📳 Quản lý HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';

import 'package:moment_u_payment/core/services/quick_actions_service.dart';
import 'package:moment_u_payment/core/services/home_widget_service.dart';

import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;
  bool _isNavbarVisible = true;

  // Luồng lắng nghe click widget khi app chạy ngầm (Warm Start)
  StreamSubscription<Uri?>? _widgetClickSubscription;

  // Giờ chỉ còn Home (index 0) và Analytics (index 1)
  final List<Widget> _screens = [const HomeScreen(), const AnalyticsScreen()];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

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
                      customAction: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const SetBudgetScreen(),
                          ),
                        );
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
          // 📳 Đã đổi sang Rung NHẸ (light) khi mở một màn hình mới hoặc BottomSheet
          HapticFeedback.lightImpact();
          customAction();
        } else {
          // Chỉ rung khi thực sự chuyển sang tab khác (không bấm trùng tab hiện tại)
          if (_currentIndex != index) {
            // 📳 Rung NHẸ (light) tạo cảm giác mượt mà khi chuyển Tab
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

/// 🚀 NÚT THÊM GIAO DỊCH NÂNG CẤP MỚI - FINTECH GLOWING STYLE
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
        // 📳 Rung NHẸ ngay khoảnh khắc ngón tay vừa ấn xuống làm nút co lại
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        // 📳 Đã đổi sang Rung NHẸ khi thả tay ra và mở màn hình
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
