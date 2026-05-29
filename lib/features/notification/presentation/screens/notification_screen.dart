import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/notification/models/in_app_notification.dart';

// 🌸 IMPORT WIDGET DÙNG CHUNG (Bạn nhớ chỉnh lại đường dẫn nếu lúc nãy lưu file khác thư mục nhé)
import 'package:moment_u_payment/core/widgets/animated_ringing_bell.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

// 🌸 Đã gỡ bỏ SingleTickerProviderStateMixin vì State không cần tự giữ AnimationController nữa
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

  // Hàm xử lý Đa ngôn ngữ và Giao diện động (Màu sắc, Icon, Route) theo loại (type)
  Map<String, dynamic> _parseNotificationContent(
    InAppNotification noti,
    AppLocalizations l10n,
  ) {
    String title = '';
    String body = '';
    IconData icon = Icons.notifications_rounded;
    Color color = AppColors.primary;
    String? route; // Biến định tuyến

    // Trích xuất an toàn các tham số (arguments) từ Backend trả về
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
        color = Colors.orange;
        break;

      case 'budget_100':
        title = l10n.notiBudgetExceededTitle;
        body = l10n.notiBudgetExceededBody(
          arg1.isEmpty ? 'Ví' : arg1,
          arg2.isEmpty ? '100' : arg2,
        );
        icon = Icons.error_rounded;
        color = Colors.red;
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
        route = '/create_transaction'; // Key định tuyến
        break;

      case 'onboarding_set_budget':
        title = l10n.notiSetBudgetTitle;
        body = l10n.notiSetBudgetBody;
        icon = Icons.security_rounded;
        color = Colors.blue;
        route = '/budget_settings'; // Key định tuyến
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
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationProvider);

    // 🌸 1. KIỂM TRA CHUÔNG RUNG
    final hasUnread = state.notifications.any((noti) => !noti.isRead);

    // 🌸 2. LỌC DANH SÁCH (Dùng biến này thay vì list gốc)
    final filteredNotifications = state.notifications.where((noti) {
      if (_showOnlyUnread) {
        return !noti.isRead;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notificationSettingsTitle.replaceAll("Cài đặt", "Danh sách"),
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 🌸 3. HIỂN THỊ CHUÔNG LẮC (Dùng Widget Reusable)
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
                        ? AppColors.primary
                        : AppColors.primaryDark.withOpacity(0.5),
                    size: 26,
                  ),
                  // Dấu chấm đỏ nhỏ xinh
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
                            color: AppColors.background,
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
          // 🌸 4. NÚT CHUYỂN ĐỔI BỘ LỌC (FILTER SWITCH)
          if (!state.isLoading && state.notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.06),
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
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !_showOnlyUnread
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
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
                                  : AppColors.primaryDark.withOpacity(0.6),
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
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _showOnlyUnread
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
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
                                  : AppColors.primaryDark.withOpacity(0.6),
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

          // 🌸 5. DANH SÁCH THÔNG BÁO CHÍNH
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state.notifications.isEmpty
                // Case 1: Chưa từng có thông báo nào
                ? _buildEmptyState(
                    "Hộp thư trống",
                    Icons.notifications_off_rounded,
                  )
                : filteredNotifications.isEmpty
                // Case 2: Đang lọc "Chưa đọc" nhưng đã đọc hết rồi
                ? _buildEmptyState(
                    "Bạn đã đọc hết thông báo rồi! 🎉",
                    Icons.done_all_rounded,
                  )
                // Case 3: Hiển thị danh sách
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final noti = filteredNotifications[index];
                      final content = _parseNotificationContent(noti, l10n);

                      return GestureDetector(
                        onTap: () {
                          // 1. Đánh dấu đã đọc khi click vào
                          if (!noti.isRead) {
                            ref
                                .read(notificationProvider.notifier)
                                .markAsRead(noti.id);
                          }

                          // 2. Xử lý chuyển trang trực tiếp
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
                                ? AppColors.cardBackground
                                : AppColors.primary.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: noti.isRead
                                ? null
                                : Border.all(
                                    color: AppColors.primary.withOpacity(0.15),
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
                                              color: AppColors.primaryDark,
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
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      content['body'] as String,
                                      style: TextStyle(
                                        color: AppColors.primaryDark
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
                                        color: AppColors.primaryDark
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

  // 🌸 Hàm phụ trợ để tái sử dụng UI trạng thái trống (Empty State)
  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.primaryDark.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: AppColors.primaryDark.withOpacity(0.4),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
