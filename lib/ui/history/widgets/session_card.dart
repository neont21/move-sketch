import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/assets.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../core/widgets/activity_badge.dart';
import 'delete_history_dialog.dart';

class SessionCard extends StatelessWidget {
  final SessionResult result;

  const SessionCard({super.key, required this.result});

  List<TextSpan> _buildMetadata() {
    List<TextSpan> texts = [];

    for (var mission in result.missions) {
      texts.add(
        TextSpan(text: '${mission.axis.label} · ${mission.tierComment}\n'),
      );
    }
    final minutes = result.elapsedDuration.inMinutes;
    final km = result.distanceInKm.toStringAsFixed(1);
    texts.add(
      TextSpan(text: '${km}km · $minutes분 · ${result.caloriesBurned}kcal'),
    );

    return texts;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: () {
          context.go(Routes.historyDetails(result.id));
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) =>
                Dialog(child: DeleteHistoryDialog(sessionId: result.id, isShared: result.isShared)),
          );
        },
        leading: Image(
          image:
              result.resultSketchImageUrl != null &&
                  result.resultSketchImageUrl!.isNotEmpty
              ? NetworkImage(result.resultSketchImageUrl!)
              : const AssetImage(Assets.sampleSketch),
        ),
        title: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              result.endedAt.formattedDateWithDay,
              style: textTheme.labelLarge,
            ),
            ActivityBadge(activityType: result.activityType),
            if (result.isShared) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                  color: colorScheme.outline,
                ),
                child: Text(
                  '공유됨',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.tertiaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: RichText(
          text: TextSpan(
            children: _buildMetadata(),
            style: textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}
