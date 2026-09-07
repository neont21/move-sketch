import 'package:flutter/material.dart';

class WeeklyIndicator extends StatelessWidget {
  List<bool> isDone = List.filled(7, false);

  WeeklyIndicator({super.key, required this.isDone});

  List<Container> generateIndicator(ColorScheme colorScheme) {
    List<Container> indicator = [];
    for (var i = 0; i < 7; i++) {
      indicator.add(
        Container(
          height: isDone[i] ? 20 : 10,
          width: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDone[i] ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
      );
    }
    return indicator;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('이번 주 기록이 아직 없어요', style: textTheme.bodyLarge),
        ...generateIndicator(colorScheme),
      ],
    );
  }
}
