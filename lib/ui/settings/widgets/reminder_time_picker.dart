import 'package:flutter/material.dart';

class ReminderTimePicker extends StatelessWidget {
  final int selectedTime;
  final List<int> timeList;
  final ValueChanged<int?> onChanged;
  const ReminderTimePicker({
    super.key,
    required this.selectedTime,
    required this.timeList,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: BoxBorder.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<int>(
        value: selectedTime,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: timeList.map((int hour) {
          return DropdownMenuItem(
            value: hour,
            child: Text('$hour시', style: textTheme.bodyMedium),
          );
        }).toList(),
      ),
    );
  }
}
