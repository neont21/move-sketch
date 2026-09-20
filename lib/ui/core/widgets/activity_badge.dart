import 'package:flutter/material.dart';
import '../theme/activity_colors.dart';

class ActivityBadge extends StatelessWidget {
  final bool isJogging;

  const ActivityBadge({super.key, required this.isJogging});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ActivityColors activityColors = context.activityColors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJogging
              ? activityColors.jogging
              : activityColors.riding,
        ),
        color: isJogging
            ? activityColors.joggingFill
            : activityColors.ridingFill,
      ),
      child: Text(
        isJogging ? '조깅' : '라이딩',
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: isJogging
              ? activityColors.joggingInk
              : activityColors.ridingInk,
        ),
      ),
    );
  }
}
