class DateTimeHelper {
  /// 📦 Nhóm danh sách phẳng thành Map<String, List> dựa trên ngày (yyyy-MM-dd) local
  static Map<String, List<Map<String, dynamic>>> groupTransactionsByDate(
    List<Map<String, dynamic>> transactions,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    final sortedList = List<Map<String, dynamic>>.from(transactions);
    sortedList.sort((a, b) {
      // Ép kiểu về local để so sánh chính xác theo múi giờ user
      final DateTime dateA = DateTime.parse(a['spentAt'].toString()).toLocal();
      final DateTime dateB = DateTime.parse(b['spentAt'].toString()).toLocal();
      return dateB.compareTo(dateA);
    });

    for (var tx in sortedList) {
      if (tx['spentAt'] == null) continue;
      try {
        // 🔥 CHỐT HẠ: Chuyển chuỗi UTC từ server về múi giờ thiết bị (ví dụ: +7)
        final DateTime parsedDate = DateTime.parse(
          tx['spentAt'].toString(),
        ).toLocal();

        final String dateKey =
            "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";

        if (grouped[dateKey] == null) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(tx);
      } catch (_) {}
    }
    return grouped;
  }

  /// 📝 Chuyển đổi key ngày thành nhãn hiển thị thân thiện
  static String getFriendlyDateLabel(String dateKey) {
    try {
      final List<String> parts = dateKey.split('-');
      final DateTime txDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));

      if (txDate == today) {
        return "HÔM NAY";
      } else if (txDate == yesterday) {
        return "HÔM QUA";
      } else {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    } catch (_) {
      return dateKey;
    }
  }
}
