import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';

import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/notification/notification_provider.dart';
import 'package:moment_u_payment/features/notification/models/in_app_notification.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _showOnlyUnread = false;
  final Set<int> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  Map<String, dynamic> _parseNotificationContent(
    InAppNotification noti,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    final String title = noti.getTitle(l10n);
    final String body = noti.getBody(l10n);
    IconData icon = CupertinoIcons.bell;
    Color color = appColors.primary;
    String? route;

    switch (noti.type) {
      // 💡 CẬP NHẬT CHÍNH XÁC TỪ SERVER
      case 'badge_unlocked':
        icon = CupertinoIcons.rosette; // Icon cúp/huy chương
        color = Colors.amber;
        route = '/badge_gallery';
        break;
      case 'badge_reset':
        icon = CupertinoIcons.arrow_2_squarepath; // Icon xoay vòng/reset
        color = Colors.blueGrey;
        route = '/badge_gallery';
        break;
      case 'budget_80':
      case 'budget_100':
        icon = CupertinoIcons.exclamationmark_triangle;
        color = noti.type == 'budget_100' ? Colors.red : Colors.orange;
        route = '/budget_analytics';
        break;
      case 'monthly_summary':
        icon = CupertinoIcons.chart_bar_alt_fill;
        color = Colors.purple;
        route = '/budget_analytics';
        break;
      case 'transaction_reminder':
      case 'onboarding_first_transaction':
        icon = CupertinoIcons.add_circled_solid;
        color = Colors.green;
        route = '/create_transaction';
        break;
      case 'onboarding_set_budget':
        icon = CupertinoIcons.shield_fill;
        color = Colors.blue;
        route = '/budget_settings';
        break;
      default:
        icon = CupertinoIcons.bell_fill;
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

  void _handleNotificationClick(InAppNotification noti, String? route) {
    if (!noti.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(noti.id);
    }
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

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
      final isSameType = noti.type == lastNoti.type;
      final isSameTitle = noti.titleKey == lastNoti.titleKey;
      final timeDiff = lastNoti.createdAt.difference(noti.createdAt).abs();

      if (isSameType && isSameTitle && timeDiff.inHours < 6) {
        lastGroup.add(noti);
      } else {
        groupedList.add([noti]);
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

    final filteredNotifications = state.notifications.where((noti) {
      if (_showOnlyUnread) return !noti.isRead;
      return true;
    }).toList();

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
              icon: Icon(Icons.done_all, color: appColors.primary),
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
                AppToast.showSuccess(
                  context,
                  l10n.markAllAsReadSuccess,
                  appColors,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(appColors, l10n, state),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: groupedNotifications.length,
              itemBuilder: (context, index) {
                final group = groupedNotifications[index];
                final bool isExpanded = _expandedGroups.contains(index);
                return Column(
                  children: [
                    _buildGroupHeader(
                      group,
                      index,
                      isExpanded,
                      appColors,
                      l10n,
                    ),
                    if (isExpanded)
                      ...group
                          .skip(1)
                          .map(
                            (noti) => _buildIndividualNotification(
                              noti,
                              appColors,
                              l10n,
                            ),
                          ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(
    List<InAppNotification> group,
    int index,
    bool isExpanded,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    final primaryNoti = group.first;
    final content = _parseNotificationContent(primaryNoti, appColors, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _handleNotificationClick(primaryNoti, content['route']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(content),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(
                      content,
                      group,
                      index,
                      isExpanded,
                      appColors,
                    ),
                    const SizedBox(height: 6),

                    _ResizableText(
                      text: content['body'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: appColors.primaryDark.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),
                    // 💡 SỬA LỖI 2: Truyền group.length vào hàm _buildFooterRow
                    _buildFooterRow(
                      primaryNoti,
                      isExpanded,
                      index,
                      group.length,
                      appColors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndividualNotification(
    InAppNotification noti,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    final content = _parseNotificationContent(noti, appColors, l10n);

    return Container(
      margin: const EdgeInsets.only(left: 45, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: noti.isRead
            ? appColors.cardBackground.withOpacity(0.6)
            : appColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.primary.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleNotificationClick(noti, content['route']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResizableText(
              text: content['body'] as String,
              style: TextStyle(
                fontSize: 12,
                color: appColors.primaryDark.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              intl.DateFormat('HH:mm').format(noti.createdAt),
              style: TextStyle(
                fontSize: 9,
                color: appColors.primaryDark.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(Map<String, dynamic> content) {
    return Container(
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
    );
  }

  Widget _buildHeaderRow(
    Map<String, dynamic> content,
    List<InAppNotification> group,
    int index,
    bool isExpanded,
    AppColorTheme appColors,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            content['title'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: appColors.primaryDark,
            ),
          ),
        ),
        if (group.length > 1)
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded)
                  _expandedGroups.remove(index);
                else
                  _expandedGroups.add(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.1),
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
          ),
      ],
    );
  }

  // 💡 SỬA LỖI 2: Thêm groupLength và bọc Icon bằng GestureDetector
  Widget _buildFooterRow(
    InAppNotification noti,
    bool isExpanded,
    int index,
    int groupLength,
    AppColorTheme appColors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          intl.DateFormat('HH:mm - dd/MM/yyyy').format(noti.createdAt),
          style: TextStyle(
            fontSize: 10,
            color: appColors.primaryDark.withOpacity(0.3),
          ),
        ),
        if (groupLength > 1)
          GestureDetector(
            behavior: HitTestBehavior.opaque, // Giúp vùng bấm dễ nhận diện hơn
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedGroups.remove(index);
                } else {
                  _expandedGroups.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(
                4.0,
              ), // Mở rộng vùng bấm của ngón tay
              child: Icon(
                isExpanded
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 16,
                color: appColors.primary.withOpacity(0.8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterSection(
    AppColorTheme appColors,
    AppLocalizations l10n,
    dynamic state,
  ) {
    if (state.isLoading || state.notifications.isEmpty)
      return const SizedBox.shrink();
    return Padding(
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
}

// ==========================================
// WIDGET TỰ ĐỘNG ĐO ĐỘ DÀI & ĐA NGÔN NGỮ
// ==========================================
class _ResizableText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const _ResizableText({
    required this.text,
    required this.style,
    this.maxLines = 2,
  });

  @override
  ConsumerState<_ResizableText> createState() => _ResizableTextState();
}

class _ResizableTextState extends ConsumerState<_ResizableText> {
  bool _isTextExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: TextDirection.ltr,
          maxLines: widget.maxLines,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isTruncated = textPainter.didExceedMaxLines;

        if (!isTruncated) {
          return Text(widget.text, style: widget.style);
        }

        return GestureDetector(
          onTap: () => setState(() => _isTextExpanded = !_isTextExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: widget.style,
                maxLines: _isTextExpanded ? null : widget.maxLines,
                overflow: _isTextExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _isTextExpanded ? l10n.collapse : l10n.readMore,
                style: TextStyle(
                  fontSize: widget.style.fontSize! - 1,
                  fontWeight: FontWeight.bold,
                  color: appColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
