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

    // 🌟 KÉO FONT CHỮ CHUẨN (PLUS JAKARTA SANS) TỪ THEME TOÀN CỤC VỀ
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: appColors.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (currentBadge != null) {
            _showCongratsDialog(
              context,
              currentBadge,
              appColors,
              l10n,
              textTheme,
            );
          } else {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const BadgeGalleryPage()),
            );
          }
        },
        child: Row(
          children: [
            // Container Icon Vẫy Tay bo tròn mượt mà hơn
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: appColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: const Text('👋', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌟 TÊN NGƯỜI DÙNG: Đồng bộ font TextTheme
                  Text(
                    '${l10n.hello} $userName',
                    style: textTheme.titleLarge?.copyWith(
                      color: appColors.primaryDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // 🌟 LỜI CHÀO & HUY HIỆU: Đồng bộ font TextTheme
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
                    child: (currentBadge != null && _showBadgeName)
                        ? Row(
                            key: const ValueKey('badge_greeting'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "🏆 ${l10n.badgeUnlocked}: ${currentBadge.getLocalizedTitle(l10n)}",
                                  style: textTheme.labelLarge?.copyWith(
                                    color: currentBadge.color,
                                    fontWeight: FontWeight.w800,
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
                            style: textTheme.bodyMedium?.copyWith(
                              color: appColors.textMuted,
                              fontSize: 12,
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
                      color: hasUnread
                          ? appColors.primary
                          : appColors.primaryDark.withOpacity(0.6),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: appColors.errorAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appColors.background,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: appColors.errorAccent.withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            // Đồng bộ font số đếm
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
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
            color: appColors.primaryDark.withOpacity(0.6),
            size: 22,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            SettingsBottomSheet.show(context);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 🚀 DIALOG CHÚC MỪNG - ĐÃ UPGRADE KÍNH MỜ & ĐỒNG BỘ TEXT
  void _showCongratsDialog(
    BuildContext context,
    UserBadge badge,
    AppColorTheme appColors,
    AppLocalizations l10n,
    TextTheme textTheme, // Nhận textTheme từ hàm build
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(
        0.7,
      ), // Giảm độ tối một chút để thấy mờ mờ background
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
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: appColors.cardBackground.withOpacity(
                    0.95,
                  ), // Lớp kính mờ xịn xò
                  borderRadius: BorderRadius.circular(
                    32,
                  ), // Bo tròn mềm mại hơn
                  border: Border.all(
                    color: badge.color.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badge.color.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Badge phát sáng
                    Container(
                      width: 130,
                      height: 130, // Chuyển thành hình vuông bo góc cao cấp
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: badge.gradientColors,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: badge.color.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(badge.icon, size: 60, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tiêu đề đồng bộ font
                    Text(
                      l10n.congratsTitle,
                      style: textTheme.headlineMedium?.copyWith(
                        color: appColors.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Lời nhắn đồng bộ font
                    Text(
                      l10n.badgeOwnedMessage(badge.getLocalizedTitle(l10n)),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: appColors.textMuted,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Nút bấm Gradient
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(colors: badge.gradientColors),
                        boxShadow: [
                          BoxShadow(
                            color: badge.color.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
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
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nút Later
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: appColors.textMuted,
                      ),
                      child: Text(
                        l10n.later,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
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
