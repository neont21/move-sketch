import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/assets.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/polyline_utils.dart';
import '../../../utils/result.dart';
import '../../core/widgets/activity_badge.dart';
import '../../session/widgets/path_tracker_view.dart';
import '../../session/widgets/sketch_card.dart';
import '../view_models/history_details_viewmodel.dart';

class HistoryDetailsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const HistoryDetailsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<HistoryDetailsScreen> createState() =>
      _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends ConsumerState<HistoryDetailsScreen> {
  late final TextEditingController _memoController;
  bool _isMemoInitialized = false;

  @override
  void initState() {
    super.initState();

    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _memoController.dispose();

    super.dispose();
  }

  List<Row> _buildMissionData(
    BuildContext context,
    List<MissionInstance> missions,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<Row> texts = [];

    for (var mission in missions) {
      texts.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${mission.axis.label} · ${mission.tierComment}',
              style: textTheme.bodyMedium,
            ),
            Text(
              '${mission.formattedValue}${mission.axis.unit}',
              style: textTheme.labelLarge,
            ),
          ],
        ),
      );
    }

    return texts;
  }

  String? _formatCourseRoute(List<String> tags) {
    if (tags.isEmpty) {
      return null;
    }

    final validTags = tags
        .where((t) => t.isNotEmpty && t != '알 수 없는 위치')
        .toList();
    if (validTags.isEmpty) {
      return null;
    }

    if (tags.length == 3) {
      final start = tags[0];
      final mid = tags[1];
      final end = tags[2];

      final isStartValid = start != '알 수 없는 위치';
      final isMidValid = mid != '알 수 없는 위치';
      final isEndValid = end != '알 수 없는 위치';

      if (isStartValid && isEndValid && start == end) {
        if (isMidValid && mid != start) {
          return '$start ↔︎ $mid';
        }
        return start;
      }
    }

    final uniqueConsecutive = <String>[];
    for (final t in validTags) {
      if (uniqueConsecutive.isEmpty || uniqueConsecutive.last != t) {
        uniqueConsecutive.add(t);
      }
    }

    return uniqueConsecutive.join(' ➔ ');
  }

  Widget? _buildBottomButton(BuildContext context, HistoryDetailsState state) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final result = state.sessionResult;

    if (result.isShared) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              context.go(Routes.historyPost(widget.sessionId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainer,
              foregroundColor: colorScheme.tertiaryContainer,
              side: BorderSide(color: colorScheme.outline),
            ),
            child: Text('피드에서 보기'),
          ),
        ),
      );
    } else if (state.isLatest) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              context.go(Routes.historyShare(widget.sessionId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text('피드에 올리기'),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final detailsState = ref.watch(
      historyDetailsViewModelProvider(widget.sessionId),
    );

    return detailsState.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('기록 상세')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('기록 상세')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              error is AppException ? error.message : '기록을 불러오는 중 오류가 발생했습니다.',
              style: textTheme.bodyMedium,
            ),
          ),
        ),
      ),
      data: (state) {
        final result = state.sessionResult;

        if (!_isMemoInitialized) {
          _memoController.text = result.secretMemo ?? '';
          _isMemoInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              spacing: 20,
              children: [
                Text(result.endedAt.formattedDateWithDay),
                ActivityBadge(activityType: result.activityType),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  spacing: 4,
                  children: [
                    SketchCard(
                      imageProvider:
                          result.resultSketchImageUrl != null &&
                              result.resultSketchImageUrl!.isNotEmpty
                          ? NetworkImage(result.resultSketchImageUrl!)
                          : const AssetImage(Assets.sampleSketch),
                    ),
                    ElevatedButton.icon(
                      onPressed: state.isDownloadingImage
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final downloadResult = await ref
                                  .read(
                                    historyDetailsViewModelProvider(
                                      widget.sessionId,
                                    ).notifier,
                                  )
                                  .downloadSketchImage();
                              switch (downloadResult) {
                                case Ok():
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('스케치 이미지를 갤러리에 저장했습니다.'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                case Error(:final error):
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error is AppException
                                            ? error.message
                                            : '이미지 저장에 실패했습니다.',
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                              }
                            },
                      icon: state.isDownloadingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        '이미지 내려받기',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainer,
                        foregroundColor: colorScheme.tertiaryContainer,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      child: PathTrackerView(
                        gpsPoints: PolylineUtils.decodePolyline(
                          result.routePolyline ?? '',
                        ),
                        isTracking: false,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final courseRoute = _formatCourseRoute(
                          result.locationTags,
                        );
                        if (courseRoute == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    courseRoute,
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '소요 시간\n',
                                style: textTheme.bodySmall,
                              ),
                              TextSpan(
                                text: '${result.elapsedDuration.inMinutes}분',
                                style: textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '이동 거리\n',
                                style: textTheme.bodySmall,
                              ),
                              TextSpan(
                                text:
                                    '${result.distanceInKm.toStringAsFixed(1)}km',
                                style: textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '소모 칼로리\n',
                                style: textTheme.bodySmall,
                              ),
                              TextSpan(
                                text: '${result.caloriesBurned}kcal',
                                style: textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    ..._buildMissionData(context, result.missions),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: textTheme.labelLarge?.color,
                          size: textTheme.labelLarge?.fontSize,
                        ),
                        const SizedBox(width: 8),
                        Text('나만 보는 메모', style: textTheme.labelLarge),
                        const Spacer(),
                        TextButton(
                          onPressed: state.isSavingMemo
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final saveResult = await ref
                                      .read(
                                        historyDetailsViewModelProvider(
                                          widget.sessionId,
                                        ).notifier,
                                      )
                                      .updateSecretMemo(_memoController.text);
                                  switch (saveResult) {
                                    case Ok():
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('메모가 저장되었습니다.'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    case Error(:final error):
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            error is AppException
                                                ? error.message
                                                : '메모 저장에 실패했습니다.',
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                  }
                                },
                          child: state.isSavingMemo
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('저장'),
                        ),
                      ],
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      controller: _memoController,
                      maxLines: 20,
                      minLines: 4,
                      maxLength: 500,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '나만 보는 메모를 남길 수 있어요. 피드에도 친구에게도 보이지 않아요.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomButton(context, state),
        );
      },
    );
  }
}
