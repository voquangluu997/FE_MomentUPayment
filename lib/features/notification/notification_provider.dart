import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/network/api_client.dart';
import 'models/in_app_notification.dart';

class NotificationState {
  final List<InAppNotification> notifications;
  final int unreadCount;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<InAppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState());

  Future<void> fetchUnreadCount() async {
    try {
      final response = await dioClient.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        final data = response.data;
        state = state.copyWith(unreadCount: data['count'] ?? 0);
      }
    } catch (_) {}
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await dioClient.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<InAppNotification> list = data
            .map<InAppNotification>(
              (e) => InAppNotification.fromJson(e as Map<String, dynamic>),
            )
            .toList();

        state = state.copyWith(
          notifications: list,
          unreadCount: list.where((n) => !n.isRead).length,
          isLoading: false,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ✅ Đã sửa lỗi: Dùng Optimistic Update để UI phản hồi tức thì
  Future<void> markAsRead(String id) async {
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return InAppNotification(
          id: n.id,
          titleKey: n.titleKey,
          bodyKey: n.bodyKey,
          arguments: n.arguments,
          type: n.type,
          isRead: true, // Chuyển thành đã đọc ngay lập tức
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: updatedList.where((n) => !n.isRead).length,
    );

    try {
      await dioClient.patch('/notifications/$id/read');
    } catch (_) {}
  }

  // 🚀 HÀM MỚI: ĐÁNH DẤU TẤT CẢ ĐÃ ĐỌC
  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return; // Không cần gọi API nếu đã đọc hết

    // 1. Cập nhật UI ngay lập tức
    final updatedList = state.notifications.map((n) {
      return InAppNotification(
        id: n.id,
        titleKey: n.titleKey,
        bodyKey: n.bodyKey,
        arguments: n.arguments,
        type: n.type,
        isRead: true, // Force tất cả thành true
        createdAt: n.createdAt,
      );
    }).toList();

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: 0, // Reset badge về 0
    );

    // 2. Gửi request chạy ngầm ở background
    try {
      // Giả định bạn tạo route này ở Backend (VD: /notifications/read-all)
      await dioClient.patch('/notifications/read-all');
    } catch (_) {}
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
      (ref) => NotificationNotifier(),
    );
