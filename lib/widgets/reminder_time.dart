import 'package:flutter/material.dart';

class ReminderTime extends StatelessWidget {
  final int _selectedTime;
  final List<int> _timeList;
  final Function(int?) _onChanged;
  const ReminderTime({
    super.key,
    required this._selectedTime,
    required this._timeList,
    required this._onChanged,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: BoxBorder.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<int>(
        value: _selectedTime,
        onChanged: _onChanged,
        underline: const SizedBox(),
        items: _timeList.map((int hour) {
          return DropdownMenuItem(
            value: hour,
            child: Text('$hour시', style: textTheme.bodyMedium),
          );
        }).toList(),
      ),
    );
  }
}
