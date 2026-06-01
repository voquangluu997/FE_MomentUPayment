class InAppNotification {
  final String id;
  final String titleKey; // Key để dịch tiêu đề đa ngôn ngữ
  final String bodyKey; // Key để dịch nội dung đa ngôn ngữ
  final List<String>
  arguments; // Các biến truyền vào (Ví dụ: tên ví, số %, số lượng tx)
  final String
  type; // 'budget_80', 'budget_100', 'email_verified', 'aggregated_tx'
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
