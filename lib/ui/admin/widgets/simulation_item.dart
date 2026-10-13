import 'package:flutter/material.dart';

class SimulationItem extends StatelessWidget {
  final String badgeText;
  final Color badgeColor;
  final String conditionText;
  final String descriptionText;

  const SimulationItem({
    super.key,
    required this.badgeText,
    required this.badgeColor,
    required this.conditionText,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badgeText,
            style: textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          conditionText,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            descriptionText,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.tertiaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
