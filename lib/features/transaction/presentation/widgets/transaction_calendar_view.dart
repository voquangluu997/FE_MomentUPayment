import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'photo_calendar_cell.dart';

class TransactionCalendarView extends ConsumerWidget {
  final List<Map<String, dynamic>> transactions;
  final DateTime currentMonth; // Tháng đang xem (Ví dụ: DateTime.now())

  const TransactionCalendarView({
    super.key,
    required this.transactions,
    required this.currentMonth,
  });

  /// 🧠 THUẬT TOÁN 1: Gom nhóm giao dịch theo từng ngày
  Map<DateTime, Map<String, dynamic>> _groupTransactionsByDate() {
    final Map<DateTime, Map<String, dynamic>> grouped = {};

    for (var tx in transactions) {
      final rawDate =
          tx['spentAt'] ?? tx['createdAt'] ?? DateTime.now().toIso8601String();
      // Parse sang Local để không bị lệch ngày so với timezone người dùng
      final parsedDate = DateTime.parse(rawDate).toLocal();

      // Ép về đúng 00:00:00 của ngày đó để làm Key gom nhóm
      final dateKey = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'totalAmount': (tx['amount'] as num?)?.toDouble() ?? 0.0,
          'imageUrl': tx['imageUrl'] ?? '',
          'emoji': tx['emoji'] ?? '✨',
          'transactions': [tx],
        };
      } else {
        // Cộng dồn tiền
        grouped[dateKey]!['totalAmount'] +=
            (tx['amount'] as num?)?.toDouble() ?? 0.0;
        grouped[dateKey]!['transactions'].add(tx);

        // Cực kỳ quan trọng: Nếu ngày đó có nhiều GD, ưu tiên GD có ảnh làm nền!
        if ((grouped[dateKey]!['imageUrl'] as String).isEmpty &&
            (tx['imageUrl'] ?? '').toString().isNotEmpty) {
          grouped[dateKey]!['imageUrl'] = tx['imageUrl'];
        }
      }
    }
    return grouped;
  }

  /// 🧠 THUẬT TOÁN 2: Dựng mảng các ngày trong tháng (Bao gồm ô trống để khớp thứ 2 -> CN)
  List<DateTime?> _generateCalendarDays() {
    final int year = currentMonth.year;
    final int month = currentMonth.month;

    // Ngày đầu tiên của tháng
    final firstDayOfMonth = DateTime(year, month, 1);
    // Tổng số ngày trong tháng
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    // Thứ của ngày mùng 1 (1 = Thứ 2, 7 = Chủ Nhật)
    final int firstWeekday = firstDayOfMonth.weekday;

    List<DateTime?> days = [];

    // Thêm các ô trống (null) cho các ngày trước mùng 1
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }

    // Thêm các ngày thực tế trong tháng
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(year, month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final groupedData = _groupTransactionsByDate();
    final calendarDays = _generateCalendarDays();

    return Column(
      children: [
        // THỨ 2 -> CHỦ NHẬT HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) {
              final isWeekend = day == 'T7' || day == 'CN';
              return SizedBox(
                width: 30,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isWeekend
                        ? appColors.errorAccent.withOpacity(0.8)
                        : appColors.primaryDark.withOpacity(0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // LƯỚI LỊCH CHÍNH
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.75,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final date = calendarDays[index];

              // Nếu là ô trống bù trừ đầu tháng
              if (date == null) {
                return const SizedBox.shrink();
              }

              final dayData = groupedData[date];

              return PhotoCalendarCell(
                date: date,
                dayData: dayData,
                onTap: () {
                  if (dayData != null) {
                    _showDayDetailsBottomSheet(
                      context,
                      date,
                      dayData,
                      appColors,
                    );
                  } else {
                    // 🔥 FIX LỖI TIMEZONE VÀ MỐC 00:00:00 Ở ĐÂY
                    final now = DateTime.now();

                    // Ghép (Năm-Tháng-Ngày của ô được chọn) với (Giờ-Phút-Giây hiện tại)
                    // Như vậy khi chuyển sang UTC sẽ không bị lùi về ngày hôm trước do kẹt ở mốc 0h
                    final safeDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      now.hour,
                      now.minute,
                      now.second,
                    );

                    // TODO: Truyền safeDateTime vào màn hình Add Transaction của bạn
                    // Navigator.pushNamed(context, '/add_transaction', arguments: safeDateTime);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thêm chi tiêu cho: ${safeDateTime.day}/${safeDateTime.month} lúc ${safeDateTime.hour}:${safeDateTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Bảng bật lên (BottomSheet) khi bấm vào 1 ngày có dữ liệu
  void _showDayDetailsBottomSheet(
    BuildContext context,
    DateTime date,
    Map<String, dynamic> dayData,
    AppColorTheme appColors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List txList = dayData['transactions'];
        // 1. Tạo chuỗi format: "04" + "th" + " June 2024"
        final String dayString = DateFormat(
          'dd',
        ).format(date); // Lấy ngày có số 0 ở đầu (04)
        final String suffix = DateTimeHelper.getDaySuffix(
          date.day,
        ); // Lấy hậu tố (th)
        final String monthYearString = DateFormat(
          'MMMM, yyyy',
          'en_US',
        ).format(date); // Lấy tháng và năm

        final String formattedDisplayDate =
            "$dayString$suffix $monthYearString";

        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  formattedDisplayDate,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryDark,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: txList.length,
                  itemBuilder: (context, index) {
                    final tx = txList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: appColors.primary.withOpacity(0.1),
                        child: Text(tx['emoji'] ?? '✨'),
                      ),
                      title: Text(
                        tx['category'] ?? 'Khác',
                        style: TextStyle(
                          color: appColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(tx['note'] ?? ''),
                      trailing: Text(
                        '-${tx['amount']}',
                        style: TextStyle(
                          color: appColors.errorAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
