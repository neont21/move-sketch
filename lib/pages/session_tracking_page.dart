import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../models/mock_session_data.dart';
import '../widgets/session_stats_view.dart';
import '../widgets/path_tracker_view.dart';
import 'session_pause_modal.dart';

const uuid = Uuid();

class SessionTrackingPage extends StatefulWidget {
  const SessionTrackingPage({super.key});

  @override
  State<SessionTrackingPage> createState() => _SessionTrackingPageState();
}

class _SessionTrackingPageState extends State<SessionTrackingPage> {
  late MockSessionData _sessionData;

  @override
  void initState() {
    super.initState();
    _sessionData = MockSessionData(
      id: uuid.v4(),
      minutes: 18,
      seconds: 42,
      km: 3.1,
      kcal: 186,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            children: [
              // 지나온 길
              PathTrackerView(),
              // 기본 요약
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '움직인 시간\n', style: textTheme.bodyMedium),
                        TextSpan(
                          text:
                              '${_sessionData.minutes}:${_sessionData.seconds}',
                          style: textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '이동 거리\n', style: textTheme.bodyMedium),
                        TextSpan(
                          text: '${_sessionData.km}km',
                          style: textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '소모 칼로리\n', style: textTheme.bodyMedium),
                        TextSpan(
                          text: '${_sessionData.kcal}kcal',
                          style: textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              // 미션
              Row(children: [Text('오늘의 미션', style: textTheme.bodySmall)]),
              SessionStatsView(),
              // 버튼
              Spacer(),
              Row(
                spacing: 20,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              Dialog(child: SessionPauseModal()),
                        );
                      },
                      icon: Icon(Icons.pause),
                      color: colorScheme.tertiaryContainer,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.outline,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/session-result/${_sessionData.id}');
                        },
                        child: Text('종료'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
