import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/mock_mission_data.dart';
import '../../../domain/models/mock_session_data.dart';
import '../../../routing/routes.dart';
import '../../history/widgets/weekly_indicator.dart';
import '../../session/widgets/session_resume_dialog.dart';
import '../../session/widgets/sketch_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _formattedDate;

  void _checkUncompletedSession() {
    if (mounted) {
      // FIXME only if the session is not completed
      final MockSessionData sessionData = MockSessionData(
        id: 'mock-data',
        minutes: 18,
        seconds: 42,
        km: 3.1,
        kcal: 186,
      );
      final List<MockMissionData> missionStats = [
        MockMissionData(title: '페이스', data: '6\' 17\'\'', unit: '/km'),
        MockMissionData(title: '지속 시간', data: '18', unit: '분'),
      ];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: Dialog(
              child: SessionResumeDialog(
                sessionData: sessionData,
                missionStats: missionStats,
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _formattedDate = DateFormat('M월 d일 EEEE', 'ko').format(DateTime.now());
    _checkUncompletedSession();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(_formattedDate, style: textTheme.bodySmall),
                      Text('오늘도 가볍게\n움직여 볼까요?', style: textTheme.displaySmall),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go(Routes.me);
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: const AssetImage(
                        'assets/default_profile.png',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 8.0,
                children: [
                  Icon(Icons.sunny, color: colorScheme.primary),
                  Text('서울 맑음 18℃ · 움직이기 좋아요', style: textTheme.bodySmall),
                ],
              ),
              Expanded(
                child: Transform.rotate(
                  angle: 0.05,
                  child: SketchCard(
                    imageProvider: AssetImage('assets/sample_sketch.png'),
                    caption: '첫 장을 기다리는 중',
                    isHome: true,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(Routes.sessionStart);
                  },
                  child: Text('세션 시작하기'),
                ),
              ),
              WeeklyIndicator(isDone: List.filled(7, false)),
            ],
          ),
        ),
      ),
    );
  }
}
