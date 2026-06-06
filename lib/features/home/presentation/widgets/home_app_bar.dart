import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/screens/badge_gallery_page.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';
import 'package:moment_u_payment/core/features/badges/badge_service.dart';
import 'package:moment_u_payment/core/widgets/animated_ringing_bell.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/notification/presentation/screens/notification_screen.dart';

class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  ConsumerState<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  bool _showBadgeName = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // ⏱️ Hẹn giờ đúng 30 giây để ẩn thông tin huy hiệu, show lại lời chào mặc định
    _timer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _showBadgeName = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userInfo = ref.watch(userInfoProvider);
    final String userName = userInfo?.name ?? (l10n.defaultUser ?? 'User');
    final appColors = ref.watch(appColorsProvider);
    final currentBadge = ref.watch(currentMonthBadgeProvider);

    return AppBar(
      backgroundColor: appColors.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (currentBadge != null) {
            _showCongratsDialog(context, currentBadge, appColors, l10n);
          } else {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const BadgeGalleryPage()),
            );
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('👋', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌟 HÀNG 1: TÊN NGƯỜI DÙNG (Đã xóa các icon huy hiệu cũ ở đây)
                  Text(
                    '${l10n.hello} $userName',
                    style: TextStyle(
                      color: appColors.primaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // 🌟 HÀNG 2: LỜI CHÀO VÀ HIỆU ỨNG CHUYỂN ĐỔI THÔNG BÁO HUY HIỆU
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.2),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    // Đưa Icon Huy hiệu vào chung hàng chữ khi đang trong 30s đếm ngược
                    child: (currentBadge != null && _showBadgeName)
                        ? Row(
                            key: const ValueKey('badge_greeting'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "🏆 ${l10n.badgeUnlocked}: ${currentBadge.getLocalizedTitle(l10n)}",
                                  style: TextStyle(
                                    color: currentBadge.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                currentBadge.icon,
                                size: 14,
                                color: currentBadge.color,
                              ),
                            ],
                          )
                        : Text(
                            l10n.homeSubGreeting,
                            key: const ValueKey('normal_greeting'),
                            style: TextStyle(
                              color: appColors.primaryDark.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Nút Thông Báo
        Consumer(
          builder: (context, ref, child) {
            final unreadCount = ref.watch(notificationProvider).unreadCount;
            final hasUnread = unreadCount > 0;

            return AnimatedRingingBell(
              isRinging: hasUnread,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    ),
                    icon: Icon(
                      hasUnread
                          ? CupertinoIcons.bell_fill
                          : CupertinoIcons.bell,
                      color: appColors.primaryDark.withOpacity(0.7),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: appColors.errorAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appColors.background,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        // Nút Settings
        IconButton(
          icon: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: appColors.primaryDark.withOpacity(0.7),
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            SettingsBottomSheet.show(context);
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  // 🚀 DIALOG CHÚC MỪNG TỪ APP BAR - ĐỒNG BỘ UI PREMIUM NEON
  void _showCongratsDialog(
    BuildContext context,
    UserBadge badge,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16 * anim1.value,
            sigmaY: 16 * anim1.value,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: appColors.cardBackground,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: badge.color.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badge.color.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: badge.gradientColors,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: badge.color.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(color: Colors.white54, width: 2.0),
                      ),
                      child: Center(
                        child: Icon(badge.icon, size: 52, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.congratsTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: appColors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.badgeOwnedMessage(badge.getLocalizedTitle(l10n)),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: appColors.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badge.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const BadgeGalleryPage(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.exploreCollection,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.later,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: appColors.textMuted.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
