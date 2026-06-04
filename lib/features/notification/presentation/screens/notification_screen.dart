import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/notification_translator.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/notification/models/in_app_notification.dart';
import 'package:moment_u_payment/core/widgets/animated_ringing_bell.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  /// 🧠 Dịch nội dung bằng Translator và xác định style UI
  Map<String, dynamic> _parseNotificationContent(
    InAppNotification noti,
    AppColorTheme appColors,
    String langCode,
  ) {
    final String title = NotificationTranslator.translate(
      noti.titleKey,
      noti.arguments,
      langCode,
    );
    final String body = NotificationTranslator.translate(
      noti.bodyKey,
      noti.arguments,
      langCode,
    );

    IconData icon = CupertinoIcons.bell;
    Color color = appColors.primary;
    String? route;

    switch (noti.type) {
      case 'budget_80':
        icon = CupertinoIcons.exclamationmark_triangle;
        color = Colors.orange;
        break;
      case 'budget_100':
        icon = CupertinoIcons.exclamationmark_triangle;
        color = Colors.red;
        break;
      case 'monthly_summary':
        icon = CupertinoIcons.chart_bar_alt_fill;
        color = Colors.purple;
        route = '/budget_analytics';
        break;
      case 'email_verified':
        icon = CupertinoIcons.checkmark_seal;
        color = Colors.green;
        break;
      case 'onboarding_first_transaction':
        icon = CupertinoIcons.add;
        color = Colors.green;
        route = '/create_transaction';
        break;
      case 'onboarding_set_budget':
        icon = CupertinoIcons.shield;
        color = Colors.blue;
        route = '/budget_settings';
        break;
      default:
        icon = CupertinoIcons.bell;
        color = appColors.primary;
    }

    return {
      'title': title,
      'body': body,
      'icon': icon,
      'color': color,
      'route': route,
    };
  }

  /// 💡 LOGIC GỘP: Nhóm các thông báo giống nhau nằm liên tiếp
  List<List<InAppNotification>> _groupNotifications(
    List<InAppNotification> notifications,
  ) {
    final groupedList = <List<InAppNotification>>[];

    for (final noti in notifications) {
      if (groupedList.isEmpty) {
        groupedList.add([noti]);
        continue;
      }

      final lastGroup = groupedList.last;
      final lastNoti = lastGroup.first;

      // Điều kiện gộp: Cùng Type, Cùng Title, và cách nhau dưới 24 giờ
      final isSameType = noti.type == lastNoti.type;
      final isSameTitle = noti.titleKey == lastNoti.titleKey;
      final timeDiff = lastNoti.createdAt.difference(noti.createdAt).abs();

      if (isSameType && isSameTitle && timeDiff.inHours < 24) {
        lastGroup.add(noti); // Nhét chung vào 1 nhóm nếu thỏa mãn
      } else {
        groupedList.add([noti]); // Tạo nhóm mới
      }
    }

    return groupedList;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationProvider);

    final hasUnread = state.unreadCount > 0;
    final String lang = Localizations.localeOf(context).languageCode;

    final filteredNotifications = state.notifications.where((noti) {
      if (_showOnlyUnread) return !noti.isRead;
      return true;
    }).toList();

    // 🚀 GỌI HÀM NHÓM THÔNG BÁO TẠI ĐÂY
    final groupedNotifications = _groupNotifications(filteredNotifications);

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        backgroundColor: appColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_back,
            color: appColors.primaryDark,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notificationListTitle,
          style: TextStyle(
            color: appColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (hasUnread)
            IconButton(
              icon: Icon(Icons.done_all, color: appColors.primary, size: 24),
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
                AppToast.showSuccess(
                  context,
                  'Đã đánh dấu đọc tất cả',
                  appColors,
                );
              },
            ),

          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: AnimatedRingingBell(
              isRinging: hasUnread,
              child: Icon(
                hasUnread
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: hasUnread
                    ? appColors.primary
                    : appColors.primaryDark.withOpacity(0.5),
                size: 26,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!state.isLoading && state.notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: appColors.primaryDark.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildFilterTab(
                      l10n.allNotifications,
                      !_showOnlyUnread,
                      () => setState(() => _showOnlyUnread = false),
                      appColors,
                    ),
                    _buildFilterTab(
                      l10n.unreadNotifications,
                      _showOnlyUnread,
                      () => setState(() => _showOnlyUnread = true),
                      appColors,
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: appColors.primary),
                  )
                : state.notifications.isEmpty
                ? _buildEmptyState(
                    l10n.emptyNotificationsTitle,
                    CupertinoIcons.bell_slash,
                    appColors,
                  )
                : groupedNotifications.isEmpty
                ? _buildEmptyState(
                    l10n.allReadNotificationsTitle,
                    CupertinoIcons.checkmark_seal,
                    appColors,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: groupedNotifications
                        .length, // Render theo số lượng NHÓM
                    itemBuilder: (context, index) {
                      final group = groupedNotifications[index];
                      final primaryNoti =
                          group.first; // Lấy thông báo đầu tiên làm chuẩn

                      final content = _parseNotificationContent(
                        primaryNoti,
                        appColors,
                        lang,
                      );

                      return _buildNotificationCard(
                        group, // Truyền nguyên list vào card
                        content,
                        appColors,
                        l10n,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    String text,
    bool isSelected,
    VoidCallback onTap,
    AppColorTheme appColors,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? appColors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? appColors.primary
                  : appColors.primaryDark.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    List<InAppNotification> group, // Cập nhật tham số nhận list
    Map<String, dynamic> content,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    final primaryNoti = group.first;
    // Nhóm được coi là "Chưa đọc" nếu CÓ BẤT KỲ 1 thông báo nào trong nhóm chưa đọc
    final bool hasUnreadInGroup = group.any((n) => !n.isRead);

    return GestureDetector(
      onTap: () {
        // Đánh dấu tất cả trong nhóm này là đã đọc
        bool markedAny = false;
        for (var n in group) {
          if (!n.isRead) {
            ref.read(notificationProvider.notifier).markAsRead(n.id);
            markedAny = true;
          }
        }

        if (markedAny) {
          AppToast.showSuccess(context, l10n.markAsReadSuccess, appColors);
        }

        final route = content['route'] as String?;
        if (route != null) {
          if (route == '/create_transaction') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            );
          } else if (route == '/budget_settings') {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SetBudgetScreen()));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: !hasUnreadInGroup
              ? null
              : Border.all(color: appColors.primary.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(!hasUnreadInGroup ? 0.02 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (content['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                content['icon'] as IconData,
                color: content['color'] as Color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                content['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: appColors.primaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // 🌟 HIỂN THỊ BADGE x2, x3... NẾU NHÓM CÓ > 1 THÔNG BÁO
                            if (group.length > 1) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: appColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'x${group.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: appColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (hasUnreadInGroup)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: appColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content['body'] as String,
                    style: TextStyle(
                      color: appColors.primaryDark.withOpacity(0.7),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'HH:mm - dd/MM/yyyy',
                    ).format(primaryNoti.createdAt),
                    style: TextStyle(
                      color: appColors.primaryDark.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon, AppColorTheme appColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: appColors.primaryDark.withOpacity(0.1)),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: appColors.primaryDark.withOpacity(0.4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
