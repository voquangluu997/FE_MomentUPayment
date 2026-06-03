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

  // Lấy số lượng thông báo chưa đọc hiển thị ở badge trên HomeAppBar
  Future<void> fetchUnreadCount() async {
    try {
      final response = await dioClient.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        final data = response.data;
        state = state.copyWith(unreadCount: data['count'] ?? 0);
      }
    } catch (_) {
      // Xử lý lỗi im lặng để không làm gián đoạn UI trang chủ
    }
  }

  // Lấy danh sách chi tiết hộp thư thông báo nội bộ
  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await dioClient.get('/notifications');
      if (response.statusCode == 200) {
        // 1. Ép kiểu response data về List<dynamic>
        final List<dynamic> data = response.data;

        // 2. 🔑 SỬA LỖI Ở ĐÂY: Chỉ định rõ <InAppNotification> cho hàm map()
        // và ép kiểu json element về Map<String, dynamic>
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

  // Đánh dấu đã đọc một mục thông báo cụ thể
  Future<void> markAsRead(String id) async {
    try {
      final response = await dioClient.patch('/notifications/$id/read');
      if (response.statusCode == 200) {
        // Hàm map ở đây tự động nội suy đúng kiểu vì state.notifications đã là List<InAppNotification>
        final updatedList = state.notifications.map((n) {
          if (n.id == id) {
            return InAppNotification(
              id: n.id,
              titleKey: n.titleKey,
              bodyKey: n.bodyKey,
              arguments: n.arguments,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();

        state = state.copyWith(
          notifications: updatedList,
          unreadCount: updatedList.where((n) => !n.isRead).length,
        );
      }
    } catch (_) {}
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
      (ref) => NotificationNotifier(),
    );
