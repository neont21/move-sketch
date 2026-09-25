import 'package:flutter/material.dart';
import '../../../domain/models/session/mission_instance.dart';

class ResultStatsView extends StatelessWidget {
  final List<MissionInstance> missions;
  final double distanceInMeters;
  final Duration elapsedDuration;
  final int caloriesBurned;

  const ResultStatsView({super.key,
    required this.missions,
    required this. distanceInMeters,
    required this.elapsedDuration,
    required this.caloriesBurned,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final km = (distanceInMeters / 1000.0).toStringAsFixed(1);
    final minutes = elapsedDuration.inMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final mission in missions)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${mission.axis.label} · ${mission.tierComment}',
                style: textTheme.labelMedium,
              ),
              Text(
                '${mission.formattedValue} ${mission.axis.unit}',
                style: textTheme.labelLarge,
              ),
            ],
          ),
        const Divider(),
        Text(
          '${km}km · $minutes분 · ${caloriesBurned}kcal',
          style: textTheme.labelMedium,
        ),
      ],
    );
  }
}
