import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
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
      // Tuỳ thuộc vào field ngày tháng từ API của bạn, thường là 'spentAt' hoặc 'createdAt'
      final rawDate =
          tx['spentAt'] ?? tx['createdAt'] ?? DateTime.now().toIso8601String();
      final parsedDate = DateTime.parse(rawDate).toLocal();
      // Ép về đúng 00:00:00 của ngày đó để làm Key
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
          'transactions': [
            tx,
          ], // Lưu lại mảng để sau này bấm vào hiện danh sách
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
    // Ví dụ: Mùng 1 là Thứ 4 (weekday = 3) -> Cần 2 ô trống cho Thứ 2, Thứ 3.
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
              crossAxisCount: 7, // 7 cột
              childAspectRatio: 0.75, // Dáng Polaroid (cao hơn rộng 1 chút)
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
                    // Logic mở màn hình thêm mới chi tiêu (truyền date vào)
                    // Navigator.pushNamed(context, '/add_transaction', arguments: date);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thêm chi tiêu cho ngày ${date.day}/${date.month}',
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
                  "Ngày ${date.day} Tháng ${date.month}",
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
