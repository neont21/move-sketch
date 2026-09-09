import 'package:flutter/material.dart';
import '../models/mock_mission_data.dart';
import '../models/mock_session_data.dart';
import '../pages/session_tracking_page.dart';

class ResultStatsView extends StatelessWidget {
  ResultStatsView({super.key});
  final _sessionData = MockSessionData(
    id: uuid.v4(),
    minutes: 32,
    seconds: 42,
    km: 5.2,
    kcal: 310,
  );
  final List<MockMissionData> _missionStats = [
    MockMissionData(title: '현재 페이스', data: '6\' 21\'\'', unit: '/km'),
    MockMissionData(title: '지속 시간', data: '32', unit: '분'),
  ];

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Divider(),
        Text(
          '${_sessionData.km}km · ${_sessionData.minutes}분 · ${_sessionData.kcal}kcal',
          style: textTheme.labelMedium,
        ),
      ],
    );
  }
}
