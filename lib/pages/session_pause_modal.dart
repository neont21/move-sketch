import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/pages/session_tracking_page.dart';
import '../models/mock_mission_data.dart';
import '../models/mock_session_data.dart';

class SessionPauseModal extends StatelessWidget {
  SessionPauseModal({super.key});
  final _sessionData = MockSessionData(
    id: uuid.v4(),
    minutes: 18,
    seconds: 42,
    km: 3.1,
    kcal: 186,
  );
  final List<MockMissionData> _missionStats = [
    MockMissionData(title: '현재 페이스', data: '6\' 17\'\'', unit: '/km'),
    MockMissionData(title: '지속 시간', data: '18', unit: '분'),
  ];

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('여기까지 ${_sessionData.km}km 왔어요', style: textTheme.headlineSmall,),
            Text('잠시 쉬었다 가도 괜찮아요.', style: textTheme.labelMedium,),
            Divider(),
            Text('지금 종료하면', style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary),),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('페이스 · 충분히 해냈어요', style: textTheme.labelMedium,),
                  Text('6\'18\'\'/km', style: textTheme.labelLarge,),
                ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('지속 시간 · 무난히 해냈어요', style: textTheme.labelMedium,),
                Text('32분', style: textTheme.labelLarge,),
              ]
            ),
            Divider(color: colorScheme.surface,),
            Row(
              spacing: 20,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/session-result/${_sessionData.id}');
                      },
                      style:  ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.outline,
                      ),
                      child: Text('여기서 종료', style: textTheme.bodyMedium?.copyWith(color: colorScheme.tertiaryContainer),),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text('계속하기', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
