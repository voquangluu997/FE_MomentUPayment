import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class DateTimeHelper {
  // =========================================================
  // 🔥 NHÓM HÀM MỚI: XỬ LÝ TIMEZONE & BOUNDARY (RANH GIỚI NGÀY)
  // =========================================================

  /// Lấy mốc 00:00:00 của một ngày theo giờ Local và chuyển thẳng sang UTC
  static DateTime getStartOfDayUtc(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc();
  }

  /// Lấy mốc 23:59:59 của một ngày theo giờ Local và chuyển thẳng sang UTC
  static DateTime getEndOfDayUtc(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc();
  }

  /// Lấy mốc 00:00:00 của một ngày theo giờ Local
  static DateTime getLocalStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  /// Lấy mốc 23:59:59 của một ngày theo giờ Local
  static DateTime getLocalEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Trộn ngày được chọn (Date) với giờ hiện tại của thiết bị (Time) và xuất ra UTC
  static DateTime combineDateWithCurrentTimeUtc(DateTime selectedDate) {
    final now = DateTime.now();
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    ).toUtc();
  }

  /// 🌐 Tự động tính toán Timezone Offset của thiết bị (Ví dụ: Việt Nam sẽ là "+07:00")
  static String getTimezoneOffsetString() {
    final Duration offset = DateTime.now().timeZoneOffset;
    final String hours = offset.inHours.toString().padLeft(2, '0');
    final String minutes = (offset.inMinutes % 60).abs().toString().padLeft(
      2,
      '0',
    );
    return '${offset.isNegative ? "-" : "+"}$hours:$minutes';
  }

  // =========================================================
  // NHÓM HÀM CŨ ĐÃ ĐƯỢC BẠN TỐI ƯU
  // =========================================================

  /// 📦 Nhóm danh sách phẳng thành Map<String, List> dựa trên ngày (yyyy-MM-dd) local
  static Map<String, List<Map<String, dynamic>>> groupTransactionsByDate(
    List<Map<String, dynamic>> transactions,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    final sortedList = List<Map<String, dynamic>>.from(transactions);
    sortedList.sort((a, b) {
      final DateTime dateA = DateTime.parse(a['spentAt'].toString()).toLocal();
      final DateTime dateB = DateTime.parse(b['spentAt'].toString()).toLocal();
      return dateB.compareTo(dateA);
    });

    for (var tx in sortedList) {
      if (tx['spentAt'] == null) continue;
      try {
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
  static String getFriendlyDateLabel(String dateKey, AppLocalizations l10n) {
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
    return DateTime(now.year, now.month + 1, 0).day;
  }
}
