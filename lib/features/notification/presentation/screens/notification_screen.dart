import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/notification/models/in_app_notification.dart';

// 🌸 IMPORT WIDGET DÙNG CHUNG
import 'package:moment_u_payment/core/widgets/animated_ringing_bell.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _showOnlyUnread = false; // Trạng thái của bộ lọc (Mặc định: Tất cả)

  @override
  void initState() {
    super.initState();
    // Tự động gọi API lấy danh sách thông báo khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  // ✨ Đã thêm tham số `AppColorTheme appColors` để sử dụng hệ màu động theo Theme
  Map<String, dynamic> _parseNotificationContent(
    InAppNotification noti,
    AppLocalizations l10n,
    AppColorTheme appColors,
  ) {
    String title = '';
    String body = '';
    IconData icon = Icons.notifications_rounded;
    Color color = appColors.primary; // Thay thế màu mặc định dynamic
    String? route;

    final arg1 = noti.arguments.isNotEmpty ? noti.arguments[0] : '';
    final arg2 = noti.arguments.length > 1 ? noti.arguments[1] : '';

    switch (noti.type) {
      case 'budget_80':
        title = l10n.notiBudgetWarningTitle;
        body = l10n.notiBudgetWarningBody(
          arg1.isEmpty ? 'Ví' : arg1,
          arg2.isEmpty ? '80' : arg2,
        );
        icon = Icons.warning_rounded;
        color = Colors.orange; // Giữ nguyên màu cam cảnh báo đặc trưng
        break;

      case 'budget_100':
        title = l10n.notiBudgetExceededTitle;
        body = l10n.notiBudgetExceededBody(
          arg1.isEmpty ? 'Ví' : arg1,
          arg2.isEmpty ? '100' : arg2,
        );
        icon = Icons.error_rounded;
        color = Colors.red; // Giữ nguyên màu đỏ lỗi hệ thống
        break;

      case 'email_verified':
        title = l10n.notiEmailVerifiedTitle;
        body = l10n.notiEmailVerifiedBody;
        icon = Icons.verified_user_rounded;
        color = Colors.green;
        break;

      case 'aggregated_tx':
        title = l10n.notiCategorySharedWallet;
        body = l10n.notiAggregatedTxBody(arg1, arg2.isEmpty ? 'vài' : arg2);
        icon = Icons.layers_rounded;
        color = Colors.blue;
        break;

      case 'first_login_reminder':
        title = l10n.notiFirstLoginReminderTitle;
        body = l10n.notiFirstLoginReminderBody(
          arg1.isEmpty ? 'bạn hiền' : arg1,
        );
        icon = Icons.lock_clock_rounded;
        color = Colors.amber;
        break;

      case 'onboarding_first_transaction':
        title = l10n.notiFirstTxnTitle;
        body = l10n.notiFirstTxnBody;
        icon = Icons.add_circle_outline_rounded;
        color = Colors.green;
        route = '/create_transaction';
        break;

      case 'onboarding_set_budget':
        title = l10n.notiSetBudgetTitle;
        body = l10n.notiSetBudgetBody;
        icon = Icons.security_rounded;
        color = Colors.blue;
        route = '/budget_settings';
        break;

      default:
        title = "Thông báo hệ thống";
        body = noti.bodyKey;
    }

    return {
      'title': title,
      'body': body,
      'icon': icon,
      'color': color,
      'route': route,
    };
  }

  @override
  Widget build(BuildContext context) {
    // ✨ Gọi bộ màu dynamic ngay tại đầu hàm build
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationProvider);

    // Kiểm tra xem có thông báo nào chưa đọc hay không
    final hasUnread = state.notifications.any((noti) => !noti.isRead);

    // Lọc danh sách thông báo theo bộ lọc
    final filteredNotifications = state.notifications.where((noti) {
      if (_showOnlyUnread) {
        return !noti.isRead;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        backgroundColor: appColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: appColors
                .primaryDark, // Tự động đổi: Nâu đậm (Light) -> Hồng phấn nhạt (Dark)
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notificationSettingsTitle.replaceAll("Cài đặt", "Danh sách"),
          style: TextStyle(
            color: appColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AnimatedRingingBell(
              isRinging: hasUnread,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    hasUnread
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: hasUnread
                        ? appColors.primary
                        : appColors.primaryDark.withOpacity(0.5),
                    size: 26,
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 2,
                      top: 14,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appColors
                                .background, // Viền bao quanh dot đỏ tiệp màu nền dynamic
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🌸 NÚT CHUYỂN ĐỔI BỘ LỌC (FILTER SWITCH)
          if (!state.isLoading && state.notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: appColors.primaryDark.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showOnlyUnread = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_showOnlyUnread
                                ? appColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !_showOnlyUnread
                                ? [
                                    BoxShadow(
                                      color: appColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Tất cả",
                            style: TextStyle(
                              color: !_showOnlyUnread
                                  ? Colors.white
                                  : appColors.primaryDark.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showOnlyUnread = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _showOnlyUnread
                                ? appColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _showOnlyUnread
                                ? [
                                    BoxShadow(
                                      color: appColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Chưa đọc",
                            style: TextStyle(
                              color: _showOnlyUnread
                                  ? Colors.white
                                  : appColors.primaryDark.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🌸 DANH SÁCH THÔNG BÁO CHÍNH
          Expanded(
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: appColors.primary),
                  )
                : state.notifications.isEmpty
                ? _buildEmptyState(
                    "Hộp thư trống",
                    Icons.notifications_off_rounded,
                    appColors,
                  )
                : filteredNotifications.isEmpty
                ? _buildEmptyState(
                    "Bạn đã đọc hết thông báo rồi! 🎉",
                    Icons.done_all_rounded,
                    appColors,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final noti = filteredNotifications[index];
                      // ✨ Truyền appColors vào bộ phân tích dữ liệu
                      final content = _parseNotificationContent(
                        noti,
                        l10n,
                        appColors,
                      );

                      return GestureDetector(
                        onTap: () {
                          if (!noti.isRead) {
                            ref
                                .read(notificationProvider.notifier)
                                .markAsRead(noti.id);
                          }

                          final route = content['route'] as String?;
                          if (route != null) {
                            switch (route) {
                              case '/create_transaction':
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AddTransactionScreen(),
                                  ),
                                );
                                break;

                              case '/budget_settings':
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SetBudgetScreen(),
                                  ),
                                );
                                break;
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: noti.isRead
                                ? appColors.cardBackground
                                : appColors.primary.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: noti.isRead
                                ? null
                                : Border.all(
                                    color: appColors.primary.withOpacity(0.15),
                                    width: 1,
                                  ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (content['color'] as Color)
                                      .withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  content['icon'] as IconData,
                                  color: content['color'] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            content['title'] as String,
                                            style: TextStyle(
                                              fontWeight: noti.isRead
                                                  ? FontWeight.bold
                                                  : FontWeight.w900,
                                              fontSize: 14.5,
                                              color: appColors.primaryDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (!noti.isRead)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            height: 8,
                                            width: 8,
                                            decoration: BoxDecoration(
                                              color: appColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      content['body'] as String,
                                      style: TextStyle(
                                        color: appColors.primaryDark
                                            .withOpacity(
                                              noti.isRead ? 0.6 : 0.85,
                                            ),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      DateFormat(
                                        'HH:mm - dd/MM/yyyy',
                                      ).format(noti.createdAt),
                                      style: TextStyle(
                                        color: appColors.primaryDark
                                            .withOpacity(0.4),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ✨ Đã thêm tham số `AppColorTheme appColors` vào hàm Empty State
  Widget _buildEmptyState(String text, IconData icon, AppColorTheme appColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: appColors.primaryDark.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: appColors.primaryDark.withOpacity(0.4),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
