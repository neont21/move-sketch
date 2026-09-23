import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/mock_session_data.dart';
import '../../../routing/routes.dart';
import 'hold_button.dart';
import 'path_tracker_view.dart';
import 'session_pause_dialog.dart';
import 'session_stats_view.dart';

const uuid = Uuid();

class SessionTrackingScreen extends StatefulWidget {
  const SessionTrackingScreen({super.key});

  @override
  State<SessionTrackingScreen> createState() => _SessionTrackingScreenState();
}

class _SessionTrackingScreenState extends State<SessionTrackingScreen> {
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
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            children: [
              PathTrackerView(),
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
              Row(children: [Text('오늘의 미션', style: textTheme.bodySmall)]),
              SessionStatsView(),
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
                              Dialog(child: SessionPauseDialog()),
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
                      child: HoldButton(title: '종료', onActionTriggered: () {
                        context.go(Routes.sessionResult(_sessionData.id));
                      }),
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
