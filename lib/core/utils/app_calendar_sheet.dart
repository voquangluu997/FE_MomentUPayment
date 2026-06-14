import 'package:flutter/material.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';

class AppCalendarSheet extends StatefulWidget {
  final DateTimeRange initialRange;
  final Function(DateTimeRange) onRangeSelected;
  final AppColorTheme appColors;

  const AppCalendarSheet({
    super.key,
    required this.initialRange,
    required this.onRangeSelected,
    required this.appColors,
  });

  static Future<void> show({
    required BuildContext context,
    required DateTimeRange initialRange,
    required Function(DateTimeRange) onRangeSelected,
    required AppColorTheme appColors,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppCalendarSheet(
        initialRange: initialRange,
        onRangeSelected: onRangeSelected,
        appColors: appColors,
      ),
    );
  }

  @override
  State<AppCalendarSheet> createState() => _AppCalendarSheetState();
}

class _AppCalendarSheetState extends State<AppCalendarSheet> {
  late DateTime? _rangeStart;
  late DateTime? _rangeEnd;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialRange.start;
    _rangeEnd = widget.initialRange.end;
    _focusedDay = widget.initialRange.start;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.appColors.cardBackground,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: widget.appColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              // Định nghĩa màu cho các ngày trong tuần (T2, T3,...)
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: widget.appColors.textMuted),
                weekendStyle: TextStyle(color: widget.appColors.textMuted),
              ),
              calendarStyle: CalendarStyle(
                // Màu chữ các ngày
                defaultTextStyle: TextStyle(color: widget.appColors.text),
                weekendTextStyle: TextStyle(color: widget.appColors.text),
                outsideTextStyle: TextStyle(color: widget.appColors.textMuted),
                todayTextStyle: TextStyle(
                  color: widget.appColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),

                // Decor
                rangeHighlightColor: widget.appColors.primary.withValues(
                  alpha: 0.2,
                ),
                rangeStartDecoration: BoxDecoration(
                  color: widget.appColors.primary,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: widget.appColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: widget.appColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.appColors.text,
                  fontSize: 16,
                ),
                // Fix icon mũi tên bị ẩn trong Dark Mode
                leftChevronIcon: Icon(
                  CupertinoIcons.chevron_left,
                  color: widget.appColors.text,
                ),
                rightChevronIcon: Icon(
                  CupertinoIcons.chevron_right,
                  color: widget.appColors.text,
                ),
              ),
              onRangeSelected: (start, end, focused) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end;
                  _focusedDay = focused;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.appColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: (_rangeStart != null && _rangeEnd != null)
                    ? () {
                        widget.onRangeSelected(
                          DateTimeRange(start: _rangeStart!, end: _rangeEnd!),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text(
                  "Xác nhận",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
