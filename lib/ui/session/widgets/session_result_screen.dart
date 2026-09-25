import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/enums/sync_status.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../view_models/session_result_viewmodel.dart';
import 'path_tracker_view.dart';
import 'sketch_card.dart';
import 'result_stats_view.dart';

class SessionResultScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionResultScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionResultScreen> createState() =>
      _SessionResultScreenState();
}

class _SessionResultScreenState extends ConsumerState<SessionResultScreen> {
  bool _isSaving = false;

  Future<void> _handleDownloadImage(Uint8List? bytes) async {
    if (_isSaving) {
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;

    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('저장할 스케치 이미지가 없습니다.'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await ref
          .read(sessionResultViewModelProvider(widget.sessionId).notifier)
          .saveSketchImage(bytes: bytes);

      if (!mounted) {
        return;
      }

      switch (result) {
        case Ok():
          messenger.showSnackBar(
            SnackBar(
              content: const Text('앨범에 스케치를 저장했습니다.'),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '갤러리 열기',
                onPressed: () => Gal.open(),
              ),
            ),
          );
        case Error(:final error):
          final errorMessage = error is AppException
              ? error.message
              : '스케치 이미지를 앨범에 저장하지 못했습니다.';
          messenger.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: colorScheme.error,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AppException
            ? e.message
            : '스케치 이미지 저장 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final resultState = ref.watch(
      sessionResultViewModelProvider(widget.sessionId),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: resultState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  error is AppException
                      ? error.message
                      : '세션 결과 데이터를 불러오는 중 오류가 발생했습니다.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (state) {
              final session = state.session;
              final activityLabel = session.activityType.label;
              final startTime = session.startedAt.formattedTime;
              final endTime = session.endedAt.formattedTime;

              final ImageProvider sketchImageProvider =
                  state.sketchBytes != null
                  ? MemoryImage(state.sketchBytes!)
                  : (state.sketchImageUrl != null &&
                            state.sketchImageUrl!.isNotEmpty
                        ? NetworkImage(state.sketchImageUrl!)
                        : AssetImage(state.character.defaultImagePath)
                              as ImageProvider);

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 20,
                    children: [
                      if (state.sessionResult?.syncStatus ==
                          SyncStatus.syncFailed) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_off, color: colorScheme.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '네트워크가 불안정하여 서버에 저장되지 않았습니다.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final result = await ref
                                            .read(
                                              sessionResultViewModelProvider(
                                                widget.sessionId,
                                              ).notifier,
                                            )
                                            .retrySync();
                                        if (!context.mounted) return;
                                        switch (result) {
                                          case Ok():
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '운동 기록이 서버에 안전하게 저장되었습니다.',
                                                ),
                                              ),
                                            );
                                          case Error(:final error):
                                            final msg = error is AppException
                                                ? error.message
                                                : '서버 저장에 실패했습니다. 다시 시도해 주세요.';
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(msg),
                                                backgroundColor:
                                                    colorScheme.error,
                                              ),
                                            );
                                        }
                                      },
                                child: state.isSubmitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('다시 시도'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(
                                '$activityLabel · $startTime–$endTime',
                                style: textTheme.bodySmall,
                              ),
                              Text('오늘도 수고했어요', style: textTheme.displaySmall),
                            ],
                          ),
                        ],
                      ),
                      SketchCard(imageProvider: sketchImageProvider),
                      ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _handleDownloadImage(state.sketchBytes),
                        icon: Icon(Icons.download),
                        label: Text(
                          _isSaving ? '저장 중...' : '이미지 내려받기',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainer,
                          foregroundColor: colorScheme.tertiaryContainer,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              '이동 경로',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: PathTrackerView.fromLocationPoints(
                          points: session.pathPoints,
                          isTracking: false,
                        ),
                      ),
                      ResultStatsView(
                        missions: session.missions,
                        distanceInMeters: session.distanceInMeters,
                        elapsedDuration: session.elapsedDuration,
                        caloriesBurned: session.caloriesBurned,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: resultState.isLoading
                          ? null
                          : () {
                              context.go(Routes.home);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.outline,
                      ),
                      child: Text(
                        '홈으로',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.tertiaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: resultState.isLoading
                          ? null
                          : () {
                              final current = resultState.value;
                              final syncStatus =
                                  current?.sessionResult?.syncStatus;
                              final isSubmitting =
                                  current?.isSubmitting ?? false;

                              if (isSubmitting ||
                                  syncStatus == SyncStatus.syncing) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '운동 기록을 서버에 저장하고 있습니다. 잠시만 기다려 주세요.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (syncStatus != SyncStatus.synced) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      '서버 저장이 완료되어야 피드에 공유할 수 있습니다. 상단의 [다시 시도]를 눌러주세요.',
                                    ),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                                return;
                              }
                              context.go(
                                Routes.sessionResultShare(widget.sessionId),
                              );
                            },
                      child: const Text('피드 공유'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
