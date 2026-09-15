import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../dialogs/delete_history_dialog.dart';
import '../widgets/activity_badge.dart';
import '../models/mock_session_history.dart';

class SessionCard extends StatelessWidget {
  final MockSessionHistory history;
  const SessionCard({super.key, required this.history});

  List<TextSpan> _buildMetadata() {
    List<TextSpan> texts = [];

    for (var mission in history.missionData) {
      texts.add(TextSpan(text: '${mission.title} · ${mission.comment}\n'));
    }
    texts.add(
      TextSpan(
        text: '${history.sessionData.km}km · ${history.sessionData.minutes}분',
      ),
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
          context.go('/history/details/${history.sessionId}');
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: DeleteHistoryDialog(sessionId: history.sessionId)
              ),
          );

        },
        leading: Image(
          image: history.imageURL != null
              ? NetworkImage(history.imageURL!)
              : AssetImage('assets/sample_sketch.png'),
        ),
        title: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('yyyy-MM-dd (E)', 'ko').format(history.createdAt),
              style: textTheme.labelLarge,
            ),
            ActivityBadge(isJogging: history.isJogging),
            history.shared
                ? Container(
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
                  )
                : const SizedBox.shrink(),
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
