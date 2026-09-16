import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/widgets/common/system_alert_dialog.dart';
import 'package:move_sketch/widgets/common/dialog_action_buttons.dart';
import '../../models/mock_session_data.dart';
import '../../models/mock_mission_data.dart';

class SessionResumeDialog extends StatelessWidget {
  final MockSessionData sessionData;
  final List<MockMissionData> missionStats;
  const SessionResumeDialog({
    super.key,
    required this.sessionData,
    required this.missionStats,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비정상 종료된 세션이 있어요.', style: textTheme.headlineSmall),
          Divider(),
          Text('중단된 조깅 기록', style: textTheme.labelMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('소요 시간', style: textTheme.bodyLarge),
              Text(
                '${sessionData.minutes}분 ${sessionData.seconds}초',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이동 거리', style: textTheme.bodyLarge),
              Text('${sessionData.km}km', style: textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 8),
          Text('진행 중이던 미션', style: textTheme.labelMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(missionStats[0].title, style: textTheme.bodyLarge),
              Text(
                '${missionStats[0].data} ${missionStats[0].unit}',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(missionStats[1].title, style: textTheme.bodyLarge),
              Text(
                '${missionStats[1].data} ${missionStats[1].unit}',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 8,),
          DialogActionButtons(
            confirmText: '이어하기',
            onConfirm: () {
              context.go('/session-tracking');
            },
            cancelText: '이대로 저장',
            onCancel: () {
              context.go('/session-result/${sessionData.id}');
            },
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: SystemAlertDialog(
                    title: '정말 기록을 남기지 않나요?',
                    description: '기록을 남기지 않고 폐기하면 되돌릴 수 없어요.',
                    confirmText: '그래도 폐기',
                    onConfirm: () {
                      context.pop();
                      context.pop();
                    },
                  ),
                ),
              );
            },
            child: Center(
              child: Text(
                '기록을 남기지 않고 폐기하기',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.error,
                  decoration: TextDecoration.underline,
                  decorationColor: colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
