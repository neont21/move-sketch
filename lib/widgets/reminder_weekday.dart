import 'package:flutter/material.dart';

class ReminderWeekday extends StatelessWidget {
  final Set<int> _selectedSet;
  final Function(Set<int>) _onSelectionChanged;
  const ReminderWeekday({super.key, required this._selectedSet, required this._onSelectionChanged});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SegmentedButton(
      multiSelectionEnabled: true,
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: 0, label: Text('월')),
        ButtonSegment(value: 1, label: Text('화')),
        ButtonSegment(value: 2, label: Text('수')),
        ButtonSegment(value: 3, label: Text('목')),
        ButtonSegment(value: 4, label: Text('금')),
        ButtonSegment(value: 5, label: Text('토')),
        ButtonSegment(value: 6, label: Text('일')),
      ],
      selected: _selectedSet,
      onSelectionChanged: _onSelectionChanged,
      style: ButtonStyle(
        backgroundColor:WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surface;
        }),
        foregroundColor:WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.tertiaryContainer;
        }),

      ),
    );
  }
}
