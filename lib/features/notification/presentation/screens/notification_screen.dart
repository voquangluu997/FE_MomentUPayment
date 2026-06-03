import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
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

  Map<String, dynamic> _parseNotificationContent(
    InAppNotification noti,
    AppLocalizations l10n,
    AppColorTheme appColors,
  ) {
    String title = '';
    String body = '';
    IconData icon = CupertinoIcons.bell;
    Color color = appColors.primary;
    String? route;

    // Logic dịch các argument backend trả về
    String translateArg(String arg) {
      if (arg == 'monthBudget') return l10n.monthBudget;
      return arg;
    }

    final arg1 = noti.arguments.isNotEmpty
        ? translateArg(noti.arguments[0])
        : '';
    final arg2 = noti.arguments.length > 1
        ? translateArg(noti.arguments[1])
        : '';

    switch (noti.type) {
      case 'budget_80':
        title = l10n.notiBudgetWarningTitle;
        body = l10n.notiBudgetWarningBody(
          arg1.isEmpty ? l10n.budgetThisMonthLabel : arg1,
          arg2.isEmpty ? '80' : arg2,
        );
        icon = CupertinoIcons.exclamationmark_triangle;
        color = Colors.orange;
        break;
      case 'budget_100':
        title = l10n.notiBudgetExceededTitle;
        body = l10n.notiBudgetExceededBody(
          arg1.isEmpty ? l10n.budgetThisMonthLabel : arg1,
          arg2.isEmpty ? '100' : arg2,
        );
        icon = CupertinoIcons.exclamationmark_triangle;
        color = Colors.red;
        break;
      case 'email_verified':
        title = l10n.notiEmailVerifiedTitle;
        body = l10n.notiEmailVerifiedBody;
        icon = CupertinoIcons.checkmark_seal;
        color = Colors.green;
        break;
      case 'onboarding_first_transaction':
        title = l10n.notiFirstTxnTitle;
        body = l10n.notiFirstTxnBody;
        icon = CupertinoIcons.add;
        color = Colors.green;
        route = '/create_transaction';
        break;
      case 'onboarding_set_budget':
        title = l10n.notiSetBudgetTitle;
        body = l10n.notiSetBudgetBody;
        icon = CupertinoIcons.shield;
        color = Colors.blue;
        route = '/budget_settings';
        break;
      default:
        title = l10n.notificationSettingsTitle;
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
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationProvider);
    final hasUnread = state.notifications.any((noti) => !noti.isRead);

    final filteredNotifications = state.notifications.where((noti) {
      if (_showOnlyUnread) return !noti.isRead;
      return true;
    }).toList();

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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
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
          // Filter Bar (Modern Segmented Control)
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
                : filteredNotifications.isEmpty
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
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final noti = filteredNotifications[index];
                      final content = _parseNotificationContent(
                        noti,
                        l10n,
                        appColors,
                      );
                      return _buildNotificationCard(
                        noti,
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
    InAppNotification noti,
    Map<String, dynamic> content,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () {
        if (!noti.isRead) {
          ref.read(notificationProvider.notifier).markAsRead(noti.id);
          AppToast.showSuccess(context, l10n.markAsReadSuccess, appColors);
        }
        final route = content['route'] as String?;
        if (route != null) {
          if (route == '/create_transaction')
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            );
          else if (route == '/budget_settings')
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SetBudgetScreen()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: noti.isRead
              ? null
              : Border.all(color: appColors.primary.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(noti.isRead ? 0.02 : 0.06),
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
                        child: Text(
                          content['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: appColors.primaryDark,
                          ),
                        ),
                      ),
                      if (!noti.isRead)
                        Container(
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
                    DateFormat('HH:mm - dd/MM/yyyy').format(noti.createdAt),
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
