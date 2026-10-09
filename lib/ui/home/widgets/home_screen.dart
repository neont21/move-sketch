import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/config/dependencies.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../config/assets.dart';
import '../../../domain/models/enums/update_type.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
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

  void _showSessionResumeDialog(TrackingSession session) {
    if (_isResumeDialogShowing || !mounted) {
      return;
    }

    _isResumeDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(child: SessionResumeDialog(session: session)),
      ),
    ).then((_) {
      _isResumeDialogShowing = false;
    });
  }

  Future<void> _checkAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

    final appVersionRepository = ref.read(appVersionRepositoryProvider);
    final result = await appVersionRepository.getVersionPolicy();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok(:final value):
        final updateType = value.checkUpdateType(currentBuildNumber);
        if (updateType == UpdateType.none) {
          return;
        }

        final isForceUpdate = updateType == UpdateType.force;
        showDialog(
          context: context,
          barrierDismissible: !isForceUpdate,
          builder: (dialogContext) => Dialog(
            child: UpdateDialog(policy: value, isForceUpdate: isForceUpdate),
          ),
        );
      case Error():
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    _formattedDate = DateTime.now().formattedHeaderDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppVersion();

      final session = ref.read(homeViewModelProvider).value?.uncompletedSession;
      if (session != null) {
        _showSessionResumeDialog(session);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    ref.listen<AsyncValue<HomeState>>(homeViewModelProvider, (prev, next) {
      final session = next.value?.uncompletedSession;
      if (session != null &&
          prev?.value?.uncompletedSession?.id != session.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSessionResumeDialog(session);
        });
      }
    });

    final currentUser = ref.watch(currentUserProvider);
    final homeState = ref.watch(homeViewModelProvider).value;
    final latestResult = homeState?.latestResult;
    final weatherInfo = homeState?.weatherInfo;

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
              Row(
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
                        : '날씨 정보를 불러오는 중...',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              Expanded(
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
