import 'package:moment_u_payment/core/utils/notification_translator.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart'; // Đảm bảo import đúng đường dẫn L10n của bạn

class InAppNotification {
  final String id;
  final String titleKey;
  final String bodyKey;
  final List<String> arguments;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  InAppNotification({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.arguments,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  // HÀM HELPER ĐÃ CẬP NHẬT
  // Truyền AppLocalizations vào để NotificationTranslator có dữ liệu dịch
  String getTitle(AppLocalizations l10n) =>
      NotificationTranslator.translate(titleKey, arguments, l10n);

  String getBody(AppLocalizations l10n) =>
      NotificationTranslator.translate(bodyKey, arguments, l10n);

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id']?.toString() ?? '',
      titleKey: json['titleKey'] ?? '',
      bodyKey: json['bodyKey'] ?? '',
      // Xử lý an toàn cho arguments (tránh lỗi nếu server trả về null)
      arguments: json['arguments'] != null
          ? List<String>.from(json['arguments'])
          : [],
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
    );
  }

  // Thêm copyWith để tiện cập nhật trạng thái isRead trên UI
  InAppNotification copyWith({bool? isRead}) {
    return InAppNotification(
      id: id,
      titleKey: titleKey,
      bodyKey: bodyKey,
      arguments: arguments,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
