import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/assets.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../core/view_models/app_version_viewmodel.dart';
import '../../core/view_models/session_sync_viewmodel.dart';
import '../../core/widgets/update_dialog.dart';
import '../../core/widgets/user_avatar.dart';
import '../view_models/home_viewmodel.dart';
import '../../session/widgets/sketch_card.dart';
import 'session_resume_dialog.dart';
import 'weekly_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String _formattedDate;

  bool _isResumeDialogShowing = false;
  bool _isUpdateDialogShowing = false;

  void _showSessionResumeDialog(TrackingSession session) {
    if (_isResumeDialogShowing || !mounted) {
      return;
    }

    _isResumeDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(child: SessionResumeDialog(session: session)),
      ),
    ).then((_) {
      _isResumeDialogShowing = false;
    });
  }

  void _showUpdateDialog(AppVersionState versionState) {
    if (_isUpdateDialogShowing || !mounted) {
      return;
    }

    _isUpdateDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: !versionState.isForceUpdate,
      builder: (dialogContext) => Dialog(
        child: UpdateDialog(
          policy: versionState.policy!,
          isForceUpdate: versionState.isForceUpdate,
        ),
      ),
    ).then((_) {
      _isUpdateDialogShowing = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _formattedDate = DateTime.now().formattedHeaderDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(homeViewModelProvider).value?.uncompletedSession;
      if (session != null) {
        _showSessionResumeDialog(session);
      }

      ref.read(sessionSyncViewModelProvider.notifier).sync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    ref.listen<AsyncValue<AppVersionState>>(appVersionViewModelProvider, (
      prev,
      next,
    ) {
      final versionState = next.value;
      if (versionState != null && versionState.shouldUpdate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUpdateDialog(versionState);
        });
      }
    });

    ref.listen<AsyncValue<HomeState>>(homeViewModelProvider, (prev, next) {
      final session = next.value?.uncompletedSession;
      if (session != null &&
          prev?.value?.uncompletedSession?.id != session.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSessionResumeDialog(session);
        });
      }
    });

    ref.listen<SessionSyncState>(sessionSyncViewModelProvider, (
      previous,
      next,
    ) {
      final syncedCount = next.lastSyncedCount;
      if (previous?.isSyncing == true &&
          !next.isSyncing &&
          syncedCount != null &&
          syncedCount > 0) {
        ref.invalidate(homeViewModelProvider);
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(content: Text('$syncedCount개의 오프라인 세션이 안전하게 동기화되었습니다.')),
        );
      }
    });

    final currentUser = ref.watch(currentUserProvider);
    final homeState = ref.watch(homeViewModelProvider).value;
    final syncState = ref.watch(sessionSyncViewModelProvider);
    final latestResult = homeState?.latestResult;
    final weatherInfo = homeState?.weatherInfo;
    final bool isLoadingWeather = homeState?.isLoadingWeather ?? true;

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
                  UserAvatar(
                    username: currentUser?.username ?? 'user',
                    imageUrl: currentUser?.imageUrl,
                    radius: 36,
                    onTap: () {
                      context.go(Routes.me);
                    },
                  ),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (weatherInfo == null && !isLoadingWeather) {
                    ref.invalidate(homeViewModelProvider);
                  }
                },
                child: Row(
                  spacing: 8.0,
                  children: [
                    if (weatherInfo != null)
                      Image.network(
                        weatherInfo.iconUrl,
                        width: 20,
                        height: 20,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.wb_sunny,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      )
                    else
                      Icon(Icons.wb_sunny, size: 20, color: colorScheme.primary),
                    Text(
                      weatherInfo != null
                          ? '${weatherInfo.summaryWithCity} · ${weatherInfo.recommendation}'
                          : (isLoadingWeather
                                ? '날씨 정보를 불러오는 중...'
                                : '날씨 정보를 가져올 수 없습니다'),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (syncState.pendingCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '전송 대기 중인 세션이 ${syncState.pendingCount}개 있습니다.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (syncState.isSyncing)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            ref
                                .read(sessionSyncViewModelProvider.notifier)
                                .sync();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('동기화'),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (latestResult == null) {
                            ref.invalidate(homeViewModelProvider);
                            return;
                          }
                          if (latestResult.isShared) {
                            context.go(Routes.feedPost(latestResult.id));
                          } else {
                            context.go(Routes.historyDetails(latestResult.id));
                          }
                        },
                        child: Transform.rotate(
                          angle: 0.05,
                          child: SketchCard(
                            imageProvider:
                                latestResult?.resultSketchImageUrl != null &&
                                    latestResult!.resultSketchImageUrl!.isNotEmpty
                                ? NetworkImage(latestResult.resultSketchImageUrl!)
                                : const AssetImage(Assets.sampleSketch),
                            caption: latestResult != null
                                ? '${latestResult.endedAt.formattedDateDot} ${latestResult.activityType.label}'
                                : '첫 장을 기다리는 중',
                            isHome: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    final uncompleted = homeState?.uncompletedSession;
                    if (uncompleted != null) {
                      _showSessionResumeDialog(uncompleted);
                      return;
                    }
                    context.go(Routes.sessionStart);
                  },
                  child: Text('세션 시작하기'),
                ),
              ),
              WeeklyIndicator(
                isDone: homeState?.weeklyIndicator ?? List.filled(7, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
