import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/widgets/animated_ringing_bell.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

// 🔑 Import thêm các provider cần thiết
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/notification/presentation/screens/notification_screen.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Lấy thông tin user
    final userInfo = ref.watch(userInfoProvider);
    final String userName = userInfo?.name ?? 'User';

    // Lấy thông tin thông báo và tiền tệ
    final unreadCount = ref.watch(notificationProvider).unreadCount;
    final currentCurrency = ref.watch(currencyProvider);

    return AppBar(
      backgroundColor:
          AppColors.background, // Dùng màu nền tiệp với nền app cho liền mạch
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.cardBackground,
            child: Text('👋', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.hello} $userName👋',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.homeSubGreeting,
                  style: TextStyle(
                    color: AppColors.primaryDark.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // 1. Nút Đổi Tiền Tệ (Đã sửa lại bằng PopupMenu mềm mại, không che nút)
        Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            initialValue: currentCurrency,

            // 🔥 THAY ĐỔI QUAN TRỌNG: Ép buộc Flutter hiển thị menu ở dưới nút
            position: PopupMenuPosition.under,
            constraints: const BoxConstraints(
              maxWidth: 75, // Khoảng cách vừa đủ cho 1 ký hiệu và bo góc
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.cardBackground,
            elevation: 3,
            onSelected: (newValue) {
              ref.read(currencyProvider.notifier).setCurrency(newValue);
            },
            itemBuilder: (BuildContext context) {
              return ['₫', '\$', '€', '¥'].map((String value) {
                final isSelected = value == currentCurrency;
                return PopupMenuItem<String>(
                  value: value,
                  height: 40,
                  child: Center(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                );
              }).toList();
            },
            // Giao diện nút gốc
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentCurrency,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 2. Nút Thông Báo (Có chuông đỏ)
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
                      // Nếu có thông báo thì đổi icon và màu cho nổi bật hơn
                      hasUnread
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: hasUnread
                          ? AppColors.primary
                          : AppColors.primaryDark,
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.errorAccent,
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
        const SizedBox(width: 10),

        // 3. Tiện ích mở rộng (Menu chức năng: Đăng xuất, Cài đặt...)
        Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 45), // Canh menu xổ xuống đẹp hơn
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.cardBackground,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.primaryDark,
            ),
            onSelected: (value) async {
              if (value == 'settings') {
                // Điều hướng mượt mà sang màn hình cài đặt thông báo nội bộ
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              } else if (value == 'logout') {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
              // Tương lai bạn thêm case 'settings', 'profile' vào đây
            },
            itemBuilder: (BuildContext context) => [
              // Mục Cài đặt thông báo mới thêm vào
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.notificationSettingsTitle,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              // Mục Đăng xuất
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.errorAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.errorAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: AppColors.errorAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
