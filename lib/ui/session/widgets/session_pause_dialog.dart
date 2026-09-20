import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/mock_mission_data.dart';
import '../../../domain/models/mock_session_data.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../../core/widgets/system_alert_dialog.dart';
import 'session_tracking_page.dart';

class SessionPauseDialog extends StatelessWidget {
  SessionPauseDialog({super.key});
  final _sessionData = MockSessionData(
    id: uuid.v7(),
    minutes: 18,
    seconds: 42,
    km: 3.1,
    kcal: 186,
  );
  final List<MockMissionData> _missionStats = [
    MockMissionData(title: '페이스', data: '6\' 17\'\'', unit: '/km'),
    MockMissionData(title: '지속 시간', data: '18', unit: '분'),
  ];

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
          Text('여기까지 ${_sessionData.km}km 왔어요', style: textTheme.headlineSmall),
          Text('잠시 쉬었다 가도 괜찮아요.', style: textTheme.labelMedium),
          Divider(),
          Text(
            '지금 종료하면',
            style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_missionStats[0].title} · 충분히 해냈어요',
                style: textTheme.labelMedium,
              ),
              Text(
                '${_missionStats[0].data}${_missionStats[0].unit}',
                style: textTheme.labelLarge,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_missionStats[1].title} · 무난히 해냈어요',
                style: textTheme.labelMedium,
              ),
              Text(
                '${_missionStats[1].data}${_missionStats[1].unit}',
                style: textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DialogActionButtons(
            confirmText: '계속하기',
            onConfirm: () {
              context.pop();
            },
            cancelText: '여기서 종료',
            onCancel: () {
              context.go(Routes.sessionResult(_sessionData.id));
            },
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: SystemAlertDialog(
                    title: '정말 기록을 남기지 않나요?',
                    description: '기록을 남기지 않고 종료하면 되돌릴 수 없어요.',
                    confirmText: '그래도 종료',
                    onConfirm: () {
                      context.pop();
                      context.go(Routes.home);
                    },
                  ),
                ),
              );
            },
            child: Center(
              child: Text(
                '기록을 남기지 않고 종료하기',
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
