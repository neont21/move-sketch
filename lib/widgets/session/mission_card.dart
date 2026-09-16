import 'package:flutter/material.dart';
import '../../models/mock_mission.dart';

class MissionCard extends StatelessWidget {
  final MockMission mission;
  final bool isSelected;
  final VoidCallback onTap;
  const MissionCard({
    super.key,
    required this.mission,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(mission.title, style: textTheme.bodyLarge),
        subtitle: Text(mission.description, style: textTheme.bodyMedium),
        trailing: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.outline,
          ),
          width: 60,
          height: 28,
          child: Center(
            child: Text(mission.parts, style: textTheme.bodyMedium),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline),
        ),
        tileColor: colorScheme.surface,
        selected: isSelected,
        selectedTileColor: colorScheme.primary,
        selectedColor: colorScheme.onPrimary,
        onTap: onTap,
      ),
    );
  }
}
