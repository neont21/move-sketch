import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/ui/session/view_models/session_result_viewmodel.dart';
import 'package:move_sketch/utils/date_time_utils.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
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
  final GlobalKey _sketchKey = GlobalKey();
  bool _isSaving = false;

  Future<Uint8List?> _captureSketch() async {
    final boundary =
        _sketchKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _handleDownloadImage() async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final bytes = await _captureSketch();

      if (bytes == null || bytes.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('스케치 이미지를 캡처하지 못했습니다.'),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }

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
              content: const Text('사진 앨범(MoveSketch)에 스케치를 저장했습니다.'),
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

  Future<void> _handleCompleteAndProceed() async {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final bytes = await _captureSketch();

    if (bytes == null || bytes.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('스케치 이미지를 캡처하지 못했습니다.'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final result = await ref
        .read(sessionResultViewModelProvider(widget.sessionId).notifier)
        .completeAndSaveSession(sketchBytes: bytes);

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        context.go(Routes.sessionResultShare(widget.sessionId));
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '세션 결과 저장에 실패했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final resultState = ref.watch(
      sessionResultViewModelProvider(widget.sessionId),
    );

    return Scaffold(
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

            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
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
                    RepaintBoundary(
                      key: _sketchKey,
                      child: SketchCard(
                        imageProvider:
                            state.sketchImageUrl != null &&
                                state.sketchImageUrl!.isNotEmpty
                            ? NetworkImage(state.sketchImageUrl!)
                            : const AssetImage('assets/sample_sketch.png'),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _handleDownloadImage,
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          spacing: 20,
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
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
                child: resultState.maybeWhen(
                  data: (state) {
                    final isBusy = state.isSubmitting || _isSaving;
                    return ElevatedButton(
                      onPressed: isBusy ? null : _handleCompleteAndProceed,
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('기록하기'),
                    );
                  },
                  orElse: () => ElevatedButton(
                    onPressed: null,
                    child: const Text('기록하기'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
