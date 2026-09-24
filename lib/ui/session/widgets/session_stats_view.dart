import 'package:flutter/material.dart';
import '../../../domain/models/session/mission_instance.dart';

class SessionStatsView extends StatelessWidget {
  final List<MissionInstance> missions;

  const SessionStatsView({super.key, this.missions = const []});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return const SizedBox.shrink();
    }

    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 20,
      children: missions
          .map(
            (mission) => Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.axis.label, style: textTheme.bodySmall),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: mission.formattedValue,
                            style: textTheme.headlineMedium,
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: mission.axis.unit,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
