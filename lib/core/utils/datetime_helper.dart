import '../../l10n/app_localizations.dart';

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

  /// 📝 Chuyển đổi key ngày thành nhãn hiển thị thân thiện (Đã tích hợp đa ngôn ngữ)
  static String getFriendlyDateLabel(String dateKey, AppLocalizations l10n) {
    // 🔑 Bổ sung tham số l10n
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
        // 🔑 Lấy từ l10n và viết hoa toàn bộ để giữ nguyên thiết kế gốc
        return l10n.today.toUpperCase();
      } else if (txDate == yesterday) {
        return l10n.yesterday.toUpperCase();
      } else {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    } catch (_) {
      return dateKey;
    }
  }

  static Map<String, List<Map<String, dynamic>>> groupMomentsByMonth(
    List<dynamic> transactions,
    AppLocalizations l10n,
  ) {
    final Map<String, List<Map<String, dynamic>>> monthlyGroups = {};
    final now = DateTime.now();

    for (var item in transactions) {
      if (item is Map<String, dynamic>) {
        final createdAtStr = item['spentAt'] ?? '';
        String monthKey = '';

        if (createdAtStr.isNotEmpty) {
          try {
            final datePart = createdAtStr.contains('T')
                ? createdAtStr.split('T').first
                : createdAtStr;
            final parts = datePart.split('-');
            if (parts.length >= 2) {
              final String year = parts[0].trim();
              final String month = parts[1].trim().padLeft(2, '0');

              if (int.parse(year) == now.year &&
                  int.parse(month) == now.month) {
                monthKey = l10n.thisMonth;
              } else {
                monthKey = l10n.monthLabel(month, year);
              }
            }
          } catch (_) {
            monthKey = l10n.unknownMonth;
          }
        }
        monthlyGroups.putIfAbsent(monthKey.toUpperCase(), () => []).add(item);
      }
    }
    return monthlyGroups;
  }

  /// 🗓️ Lấy số lượng ngày của tháng hiện tại
  static int getDaysInCurrentMonth() {
    final now = DateTime.now();
    // DateTime(year, month + 1, 0) sẽ trả về ngày cuối cùng của tháng hiện tại
    return DateTime(now.year, now.month + 1, 0).day;
  }
}
