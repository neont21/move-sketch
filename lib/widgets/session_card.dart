import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/mock_session_history.dart';
import '../theme.dart';

class SessionCard extends StatelessWidget {
  final MockSessionHistory _history;
  const SessionCard({super.key, required this._history});

  List<TextSpan> _buildMetadata() {
    List<TextSpan> texts = [];

    for (var mission in _history.missionData) {
      texts.add(TextSpan(text: '${mission.title} · ${mission.comment}\n'));
    }
    texts.add(
      TextSpan(
        text: '${_history.sessionData.km}km · ${_history.sessionData.minutes}분',
      ),
    );

    return texts;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    ActivityColors activityColors = context.activityColors;

    return Card(
      child: ListTile(
        onTap: () {
          context.go('/history/details/${_history.sessionId}');
        },
        leading: Image(
          image: _history.imageURL != null
              ? NetworkImage(_history.imageURL!)
              : AssetImage('assets/sample_sketch.png'),
        ),
        title: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('yyyy-MM-dd (E)', 'ko').format(_history.createdAt),
              style: textTheme.labelLarge,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _history.isJogging
                      ? activityColors.jogging
                      : activityColors.riding,
                ),
                color: _history.isJogging
                    ? activityColors.joggingFill
                    : activityColors.ridingFill,
              ),
              child: Text(
                _history.isJogging ? '조깅' : '라이딩',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _history.isJogging
                      ? activityColors.joggingInk
                      : activityColors.ridingInk,
                ),
              ),
            ),
            _history.shared ?
            Container(
              padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                ),
                color: colorScheme.outline,
              ),
              child: Text(
                '공유됨',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
            ) : Container(),
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
