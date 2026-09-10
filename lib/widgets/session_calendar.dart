import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../theme.dart';
import '../utils/diagonal_painter.dart';
import '../models/mock_monthly_history.dart';

class SessionCalendar extends StatelessWidget {
  final DateTime _focusedDay;
  final MockMonthlyHistory _monthlyHistory;
  final Function(DateTime) _onMonthChanged;

  const SessionCalendar({
    super.key,
    required this._focusedDay,
    required this._monthlyHistory,
    required this._onMonthChanged,
  });

  /// 원하는 연/월의 기록을 확인하기 위한 helper function
  Future<void> _pickYearMonth(BuildContext context) async {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final selected = await showMonthPicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2026),
      lastDate: DateTime(DateTime.now().year + 1),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        dialogSettings: PickerDialogSettings(locale: Locale('ko')),
        dateButtonsSettings: PickerDateButtonsSettings(
          selectedMonthBackgroundColor: colorScheme.primary,
          selectedMonthTextColor: colorScheme.onPrimary,
          currentMonthTextColor: colorScheme.secondary,
          buttonBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        actionBarSettings: PickerActionBarSettings(),
      ),
    );
    if (selected != null) {
      _onMonthChanged(selected);
    }
  }

  /// 기록에 따라 날짜에 표시하기 위한 helper function
  Widget _buildCellBackground(BuildContext context, int day) {
    ActivityColors activityColors = context.activityColors;

    if (_monthlyHistory.dayJogging.contains(day) &&
        _monthlyHistory.dayRiding.contains(day)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: DiagonalPainter(
            topLeftColor: activityColors.joggingFill,
            bottomRightColor: activityColors.ridingFill,
          ),
        ),
      );
    } else if (_monthlyHistory.dayJogging.contains(day)) {
      return Container(
        decoration: BoxDecoration(
          color: activityColors.joggingFill,
          shape: BoxShape.circle,
        ),
      );
    } else if (_monthlyHistory.dayRiding.contains(day)) {
      return Container(
        decoration: BoxDecoration(
          color: activityColors.ridingFill,
          shape: BoxShape.circle,
        ),
      );
    }
    return Container();
  }

  /// 날짜를 꾸며주는 helper function
  Widget? decorateDayCell(
    BuildContext context,
    DateTime day,
    DateTime currentFocus,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (day.month != currentFocus.month) {
      return Center(
        child: Text('${day.day}', style: const TextStyle(color: Colors.grey)),
      );
    }

    final isToday = isSameDay(day, DateTime.now());

    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: isToday
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant, width: 2),
              )
            : null,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: _buildCellBackground(context, day.day),
            ),
            Text(
              '${day.day}',
              style: TextStyle(
                fontWeight:
                    isToday ||
                        _monthlyHistory.dayJogging.contains(day.day) ||
                        _monthlyHistory.dayRiding.contains(day.day)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2026),
      lastDay: DateTime.utc(DateTime.now().year + 1),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => false,
      onDaySelected: null,
      onPageChanged: (date) => _onMonthChanged(date),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, date) => InkWell(
          onTap: () => _pickYearMonth(context),
          child: Text(
            '${date.year}년 ${date.month}월',
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        prioritizedBuilder: decorateDayCell,
      ),
    );
  }
}
