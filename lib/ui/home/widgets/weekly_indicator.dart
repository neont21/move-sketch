import 'package:flutter/material.dart';

class WeeklyIndicator extends StatelessWidget {
  final List<bool> isDone;

  const WeeklyIndicator({super.key, required this.isDone});

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
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final completedCount = isDone.where((done) => done).length;
    final message = completedCount == 0
        ? '최근 기록이 아직 없어요'
        : '일주일동안 $completedCount일 움직였어요';

    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(message, style: textTheme.bodyLarge),
        ...generateIndicator(colorScheme),
      ],
    );
  }
}
