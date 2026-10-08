import 'package:flutter/material.dart';

class WeeklyIndicator extends StatelessWidget {
  final List<bool> isDone;

  const WeeklyIndicator({super.key, required this.isDone});

  SizedBox _buildIndicator(ColorScheme colorScheme) {
    return SizedBox(
      height: 16,
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          7,
          (index) => Container(
            width: 8,
            height: isDone[index] ? 16 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDone[index]
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(message, style: textTheme.bodyLarge),
        _buildIndicator(colorScheme),
      ],
    );
  }
}
