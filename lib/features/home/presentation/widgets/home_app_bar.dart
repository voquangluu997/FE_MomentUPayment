import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/widgets/animated_ringing_bell.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/notification/presentation/screens/notification_screen.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Lấy thông tin user
    final userInfo = ref.watch(userInfoProvider);
    final String userName = userInfo?.name ?? 'User';

    // ✨ Lấy bộ màu động hiện tại (Sáng hoặc Tối)
    final appColors = ref.watch(appColorsProvider);

    return AppBar(
      backgroundColor: appColors.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: appColors.cardBackground,
            child: Text('👋', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.hello} $userName👋',
                  style: TextStyle(
                    color: appColors.primaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.homeSubGreeting,
                  style: TextStyle(
                    color: appColors.primaryDark.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // 1. Nút Thông Báo
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      hasUnread
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: hasUnread
                          ? appColors.primary
                          : appColors.primaryDark,
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: appColors.errorAccent,
                          shape: BoxShape.circle,
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
                              fontSize: 9,
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
        const SizedBox(width: 6),

        // 2. Nút mở Settings
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: appColors.primaryDark,
            size: 24,
          ),
          onPressed: () {
            SettingsBottomSheet.show(context);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
