import 'package:flutter/material.dart';
import '../models/mock_mission.dart';

class MissionCard extends StatelessWidget {
  final MockMission _mission;
  final bool _isSelected;
  final VoidCallback _onTap;
  const MissionCard({
    super.key,
    required this._mission,
    required this._isSelected,
    required this._onTap,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(_mission.title, style: textTheme.bodyLarge),
        subtitle: Text(_mission.description, style: textTheme.bodyMedium),
        trailing: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.outline,
          ),
          width: 60,
          height: 28,
          child: Center(
            child: Text(_mission.parts, style: textTheme.bodyMedium),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline),
        ),
        tileColor: Colors.white,
        selected: _isSelected,
        selectedTileColor: colorScheme.primary,
        selectedColor: colorScheme.onPrimary,
        onTap: _onTap,
      ),
    );
  }
}
