import 'package:flutter/material.dart';
import 'package:move_sketch/models/mock_mission_data.dart';

class SessionStatsView extends StatefulWidget {
  const SessionStatsView({super.key});

  @override
  State<SessionStatsView> createState() => _SessionStatsViewState();
}

class _SessionStatsViewState extends State<SessionStatsView> {
  final List<MockMissionData> _missionStats = [];

  @override
  void initState() {
    super.initState();
    _missionStats.add(MockMissionData(title: '현재 페이스', data: '6\' 17\'\'', unit: '/km'));
    _missionStats.add(MockMissionData(title: '지속 시간', data: '18', unit: '분'));
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 20,
      children: [
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: colorScheme.outline,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_missionStats[0].title, style: textTheme.bodySmall,),
              RichText(text: TextSpan(
                  children: [
                    TextSpan(text: _missionStats[0].data, style: textTheme.headlineMedium),
                    TextSpan(text: _missionStats[0].unit, style: textTheme.bodySmall),
                  ]
              ))
            ],
          ),
        )),
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: colorScheme.outline,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_missionStats[1].title, style: textTheme.bodySmall,),
              RichText(text: TextSpan(
                children: [
                  TextSpan(text: _missionStats[1].data, style: textTheme.headlineMedium),
                  TextSpan(text: _missionStats[1].unit, style: textTheme.bodySmall),
                ]
              ))
            ],
          ),
        )),
      ],
    );
  }
}
