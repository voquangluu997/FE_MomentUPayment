import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/network/api_client.dart'; // Thay bằng đg dẫn ApiClient của bạn
import 'package:moment_u_payment/core/utils/app_logger.dart';
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

  static const String _logTag = 'NotificationNotifier';

  /// 📥 Lấy số lượng chưa đọc chính xác từ Server
  Future<void> fetchUnreadCount() async {
    try {
      final response = await dioClient.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        final data = response.data;
        state = state.copyWith(unreadCount: data['count'] ?? 0);
      }
    } catch (e, stackTrace) {
      AppLogger.e(_logTag, "❌ Lỗi fetchUnreadCount: $e", stackTrace);
    }
  }

  /// 📥 Lấy danh sách thông báo
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

        // ✅ FIX: Không dùng list.where...length nữa vì list bị giới hạn bởi 'take: 20' ở BE
        // Chúng ta giữ nguyên unreadCount hiện tại hoặc gọi kèm fetchUnreadCount() để đồng bộ toàn DB
        state = state.copyWith(notifications: list, isLoading: false);

        // Gọi sync lại số lượng chuẩn từ server
        await fetchUnreadCount();
      }
    } catch (e, stackTrace) {
      state = state.copyWith(isLoading: false);
      AppLogger.e(_logTag, "❌ Lỗi fetchNotifications: $e", stackTrace);
    }
  }

  /// 📑 Đánh dấu đọc 1 mục (Optimistic Update)
  Future<void> markAsRead(String id) async {
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
      unreadCount: (state.unreadCount - 1).clamp(0, double.infinity).toInt(),
    );

    try {
      await dioClient.patch('/notifications/$id/read');
    } catch (e, stackTrace) {
      AppLogger.e(_logTag, "❌ Lỗi markAsRead: $e", stackTrace);
      // Nếu lỗi thì fetch lại để sync với DB
      fetchNotifications();
    }
  }

  /// 🚀 Đánh dấu đọc TẤT CẢ (Optimistic Update)
  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;

    // 1. Cập nhật UI ngay lập tức thành đã đọc hết
    final updatedList = state.notifications.map((n) {
      return InAppNotification(
        id: n.id,
        titleKey: n.titleKey,
        bodyKey: n.bodyKey,
        arguments: n.arguments,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();

    state = state.copyWith(notifications: updatedList, unreadCount: 0);

    // 2. Gọi API chạy ngầm dữ liệu xuống DB
    try {
      await dioClient.patch('/notifications/read-all');
    } catch (e, stackTrace) {
      AppLogger.e(
        _logTag,
        "❌ Lỗi markAllAsRead API: $e. Kiểm tra lại route backend!",
        stackTrace,
      );
      // Nếu API lỗi (ví dụ 404), fetch lại để giao diện hiển thị đúng thực tế DB
      fetchNotifications();
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
      (ref) => NotificationNotifier(),
    );
