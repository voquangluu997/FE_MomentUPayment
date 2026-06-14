import 'dart:io';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moment_u_payment/core/network/api_client.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 🌐 Bộ dịch thuật nhanh cho Tên Channel và Nút bấm
  static String _getLocaleString(String key) {
    final String languageCode = PlatformDispatcher.instance.locale.languageCode;

    final Map<String, Map<String, String>> localizedValues = {
      'en': {
        'channel_name': 'Survival Budget Alert',
        'btn_promise': 'Promise to save 🤐',
        'btn_ignore': 'Whatever, spend! 💸',
        'log_promise': 'User promised to stop spending today! 🤐',
        'log_ignore': 'User ignored! Opening Add Moment screen... 💸',
      },
      'vi': {
        'channel_name': 'Báo động ngân sách sinh tồn',
        'btn_promise': 'Hứa nhịn tiêu 🤐',
        'btn_ignore': 'Kệ, tiêu tiếp 💸',
        'log_promise':
            'User bấm: Hứa hôm nay nhịn tiêu! Hiện hiệu ứng cute... 🤐',
        'log_ignore': 'User bấm: Kệ, tiêu tiếp! Mở màn hình Add Moment... 💸',
      },
    };

    return localizedValues[languageCode]?[key] ?? localizedValues['en']![key]!;
  }

  static Future<void> initNotifications() async {
    // 1. Xin quyền thông báo
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2. Lấy FCM Token và gửi đồng bộ lên Backend NestJS
    String? token;
    if (Platform.isIOS) {
      // Trên iOS Simulator, không gọi getToken() để tránh crash
      // Chỉ gọi khi chạy trên thiết bị thật
      token = await _messaging.getAPNSToken() != null
          ? await _messaging.getToken()
          : null;
    } else {
      token = await _messaging.getToken();
    }

    if (token != null) {
      await _sendTokenToBackend(token);
    }

    // 3. CẤU HÌNH CÁC NÚT BẤM (ACTION BUTTONS) CHO CẢ ANDROID & IOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cấu hình riêng cho iOS: Đăng ký Category để nút bấm hiện ra
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          notificationCategories: [
            DarwinNotificationCategory(
              'SURVIVAL_BUDGET_CATEGORY',
              actions: [
                DarwinNotificationAction.plain(
                  'promise_action',
                  _getLocaleString('btn_promise'),
                ),
                DarwinNotificationAction.plain(
                  'ignore_action',
                  _getLocaleString('btn_ignore'),
                ),
              ],
            ),
          ],
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.d(
          'd',
          "DEBUG: Đã nhận phản hồi từ Notification! ActionID: ${response.actionId}",
        );
        if (response.actionId == 'promise_action') {
          AppLogger.i('i', _getLocaleString('log_promise'));
        } else if (response.actionId == 'ignore_action') {
          AppLogger.i('i', _getLocaleString('log_ignore'));
        }
      },
    );

    // 4. Lắng nghe thông báo khi app đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'survival_budget_channel',
              _getLocaleString('channel_name'),
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              actions: <AndroidNotificationAction>[
                AndroidNotificationAction(
                  'promise_action',
                  _getLocaleString('btn_promise'),
                  showsUserInterface: true,
                ),
                AndroidNotificationAction(
                  'ignore_action',
                  _getLocaleString('btn_ignore'),
                  showsUserInterface: true,
                ),
              ],
            ),
            iOS: const DarwinNotificationDetails(
              categoryIdentifier: 'SURVIVAL_BUDGET_CATEGORY',
            ),
          ),
        );
      }
    });
  }

  static Future<void> _sendTokenToBackend(String token) async {
    AppLogger.i('i', "🎯 FCM Token chuẩn bị gửi lên NestJS: $token");
    try {
      final response = await dioClient.patch(
        '/users/fcm-token',
        data: {
          'fcmToken': token,
          'language': PlatformDispatcher.instance.locale.languageCode,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i(
          'i',
          "✅ Moments u Payment: Đồng bộ FCM Token và Ngôn ngữ thành công!",
        );
      }
    } catch (e) {
      AppLogger.e('e', "❌ Lỗi gửi token lên backend: $e");
    }
  }
}
