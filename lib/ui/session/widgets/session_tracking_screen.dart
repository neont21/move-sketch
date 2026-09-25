import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../view_models/session_tracking_viewmodel.dart';
import 'hold_button.dart';
import 'path_tracker_view.dart';
import 'session_pause_dialog.dart';
import 'session_stats_view.dart';

class SessionTrackingScreen extends ConsumerWidget {
  const SessionTrackingScreen({super.key});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final trackingState = ref.watch(sessionTrackingViewModelProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: trackingState.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  error is AppException
                      ? error.message
                      : '세션 데이터를 불러오는 중 오류가 발생했습니다.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (state) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  spacing: 20,
                  children: [
                    PathTrackerView.fromLocationPoints(
                      points: state.pathPoints,
                      initialCenter: state.initialLocation != null
                          ? LatLng(
                              state.initialLocation!.latitude,
                              state.initialLocation!.longitude,
                            )
                          : null,
                      isTracking: true,
                      isPaused: state.isPaused,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '움직인 시간\n',
                                style: textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: _formatDuration(state.elapsedDuration),
                                style: textTheme.headlineLarge,
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '이동 거리\n',
                                style: textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text:
                                    '${state.distanceInKm.toStringAsFixed(2)}km',
                                style: textTheme.headlineLarge,
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '소모 칼로리\n',
                                style: textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: '${state.caloriesBurned}kcal',
                                style: textTheme.headlineLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(children: [Text('오늘의 미션', style: textTheme.bodySmall)]),
                    SessionStatsView(missions: state.missions),
                    Spacer(),
                    Row(
                      spacing: 20,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: IconButton(
                            onPressed: () async {
                              final notifier = ref.read(
                                sessionTrackingViewModelProvider.notifier,
                              );
                              await notifier.pauseSession();
                              if (!context.mounted) {
                                return;
                              }
                              final shouldResume = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => PopScope(
                                  canPop: false,
                                  child: Dialog(
                                    child: SessionPauseDialog(
                                      trackingState: state,
                                    ),
                                  ),
                                ),
                              );
                              if (shouldResume != true) {
                                return;
                              }
                              if (!context.mounted) {
                                return;
                              }
                              await notifier.resumeSession();
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
                            child: HoldButton(
                              title: '종료',
                              onActionTriggered: () async {
                                if (!state.isValidSession) {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final colorScheme = Theme.of(
                                    context,
                                  ).colorScheme;
                                  await ref
                                      .read(
                                        sessionTrackingViewModelProvider
                                            .notifier,
                                      )
                                      .discardSession();
                                  if (!context.mounted) return;
                                  context.go(Routes.home);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        '운동 기록이 너무 짧아 저장되지 않았습니다.',
                                      ),
                                      backgroundColor: colorScheme.secondary,
                                    ),
                                  );
                                  return;
                                }
                                context.go(
                                  Routes.sessionResult(state.session.id),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
