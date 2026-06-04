import 'package:moment_u_payment/core/utils/notification_translator.dart';

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

  // HÀM HELPER MỚI
  String getTitle(String langCode) =>
      NotificationTranslator.translate(titleKey, arguments, langCode);
  String getBody(String langCode) =>
      NotificationTranslator.translate(bodyKey, arguments, langCode);

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id']?.toString() ?? '',
      titleKey: json['titleKey'] ?? '',
      bodyKey: json['bodyKey'] ?? '',
      arguments: List<String>.from(json['arguments'] ?? []),
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
    );
  }
}
