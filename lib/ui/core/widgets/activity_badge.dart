import 'package:flutter/material.dart';
import '../../../domain/models/enums/activity_type.dart';
import '../theme/activity_colors.dart';

class ActivityBadge extends StatelessWidget {
  final ActivityType activityType;

  const ActivityBadge({super.key, required this.activityType});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ActivityColors activityColors = context.activityColors;

    final (borderColor, fillColor, inkColor) = switch (activityType) {
      ActivityType.jogging => (
        activityColors.jogging,
        activityColors.joggingFill,
        activityColors.joggingInk,
      ),
      ActivityType.riding => (
        activityColors.riding,
        activityColors.ridingFill,
        activityColors.ridingInk,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        color: fillColor,
      ),
      child: Text(
        activityType.label,
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: inkColor,
        ),
      ),
    );
  }
}
