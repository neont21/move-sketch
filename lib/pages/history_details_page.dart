import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:move_sketch/theme.dart';
import 'package:move_sketch/widgets/sketch_card.dart';

import '../models/mock_mission_data.dart';
import '../models/mock_session_data.dart';
import '../models/mock_session_history.dart';
import '../widgets/path_tracker_view.dart';

class HistoryDetailsPage extends StatelessWidget {
  final String _sessionId;
  HistoryDetailsPage({super.key, required this._sessionId});

  final _history = MockSessionHistory(
    sessionId: 'test1',
    createdAt: DateTime(2026, 9, 2, 11, 23),
    isJogging: true,
    sessionData: MockSessionData(
      minutes: 32,
      seconds: 12,
      km: 3,
      kcal: 123,
      id: 'test1',
    ),
    missionData: [
      MockMissionData(
        title: '거리',
        data: '4.3',
        unit: 'km',
        comment: '충분히 해냈어요',
      ),
      MockMissionData(title: '인터벌', data: '2', unit: '회', comment: '충분히 해냈어요'),
    ],
  );

  List<Row> _buildMissionData(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    List<Row> texts = [];

    for (var mission in _history.missionData) {
      texts.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${mission.title} · ${mission.comment}',
              style: textTheme.bodyMedium,
            ),
            Text('${mission.data}${mission.unit}', style: textTheme.labelLarge),
          ],
        ),
      );
    }

    return texts;
  }

  Widget? _buildBottomButton(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_history.shared) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              context.go('/history/feed/$_sessionId');
            },
            style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainer,
                foregroundColor: colorScheme.tertiaryContainer,
                side: BorderSide(color: colorScheme.outline)
            ), child: Text('피드에서 보기'),
          ),
        ),
      );
      } else if (_history.createdAt == DateTime.now()) {
      // TODO: 조건 변경 필요 -- 가장 최근 기록일 때
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              context.go('/history/share/$_sessionId');
            },
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ), child: Text('피드에 올리기'),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    ActivityColors activityColors = context.activityColors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Row(
          spacing: 20,
          children: [
            Text(DateFormat('yyyy-MM-dd (E)', 'ko').format(_history.createdAt)),
            Container(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _history.isJogging
                      ? activityColors.joggingInk
                      : activityColors.ridingInk,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              spacing: 4,
              children: [
                SketchCard(
                  imageProvider: _history.imageURL != null
                      ? NetworkImage(_history.imageURL!)
                      : AssetImage('assets/sample_sketch.png'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download),
                  label: Text(
                    '이미지 내려받기',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainer,
                    foregroundColor: colorScheme.tertiaryContainer,
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: PathTrackerView(),
                ),
                Divider(color: Colors.transparent),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '소요 시간\n', style: textTheme.bodySmall),
                          TextSpan(
                            text: '${_history.sessionData.minutes}분',
                            style: textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '이동 거리\n', style: textTheme.bodySmall),
                          TextSpan(
                            text: '${_history.sessionData.km}km',
                            style: textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '소모 칼로리\n',
                            style: textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: '${_history.sessionData.kcal}kcal',
                            style: textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                ..._buildMissionData(context),
                Divider(color: Colors.transparent),
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.lock,
                      color: textTheme.labelLarge?.color,
                      size: textTheme.labelLarge?.fontSize,
                    ),
                    Text('나만 보는 메모', style: textTheme.labelLarge),
                  ],
                ),
                TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 20,
                  minLines: 4,
                  maxLength: 500,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '나만 보는 메모를 남길 수 있어요. 피드에도 친구에게도 보이지 않아요.',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiaryContainer,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    counterStyle: textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }
}
