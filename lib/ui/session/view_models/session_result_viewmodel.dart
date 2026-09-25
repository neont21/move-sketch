import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/enums/session_status.dart';
import '../../../domain/models/enums/sketch_slot.dart';
import '../../../domain/models/enums/sync_status.dart';
import '../../../domain/models/fixed/mission_template.dart';
import '../../../domain/models/fixed/sketch_parts.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/polyline_utils.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class SessionResultState {
  final TrackingSession session;
  final SessionResult? sessionResult;
  final SketchComposition sketchComposition;
  final CharacterType character;
  final Uint8List? sketchBytes;
  final String? sketchImageUrl;
  final bool isSubmitting;

  const SessionResultState({
    required this.session,
    this.sessionResult,
    required this.sketchComposition,
    required this.character,
    this.sketchBytes,
    this.sketchImageUrl,
    this.isSubmitting = false,
  });

  SessionResultState copyWith({
    TrackingSession? session,
    SessionResult? sessionResult,
    SketchComposition? sketchComposition,
    CharacterType? character,
    Uint8List? sketchBytes,
    String? sketchImageUrl,
    bool? isSubmitting,
  }) {
    return SessionResultState(
      session: session ?? this.session,
      sessionResult: sessionResult ?? this.sessionResult,
      sketchComposition: sketchComposition ?? this.sketchComposition,
      character: character ?? this.character,
      sketchBytes: sketchBytes ?? this.sketchBytes,
      sketchImageUrl: sketchImageUrl ?? this.sketchImageUrl,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class SessionResultViewModel extends AsyncNotifier<SessionResultState> {
  final String sessionId;

  SessionResultViewModel(this.sessionId);

  @override
  Future<SessionResultState> build() async {
    final sessionRepository = ref.read(sessionRepositoryProvider);

    final result = await sessionRepository.getSession(sessionId);
    TrackingSession? session;
    switch (result) {
      case Ok(:final value):
        session = value;
      case Error(:final error):
        throw error;
    }

    if (session == null) {
      final result = await sessionRepository.getActiveSession();
      switch (result) {
        case Ok(:final value):
          if (value != null && value.id == sessionId) {
            session = value;
          }
        case Error(:final error):
          throw error;
      }
    }

    if (session == null) {
      throw const SessionException('세션 정보를 찾을 수 없습니다.');
    }

    if (session.status != SessionStatus.completed) {
      final sessionService = ref.read(sessionServiceProvider);

      await sessionService.updateSessionStatus(
        sessionId: sessionId,
        status: SessionStatus.completed,
      );

      session = session.copyWith(status: SessionStatus.completed);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('사용자 정보를 찾을 수 없습니다.');
    }
    final sketchComposition = _composeSketch(
      missions: session.missions,
      character: user.selectedCharacter,
    );

    final simplifiedPoints = await PolylineUtils.simplifyLocationPoints(
      session.pathPoints,
    );
    final routePolyline = PolylineUtils.encodePolyline(simplifiedPoints);

    final routeRenderer = ref.read(routeImageRendererProvider);
    final routeBytes = await routeRenderer.renderRoute(
      gpsPoints: simplifiedPoints,
    );

    final sketchRenderer = ref.read(sketchImageRendererProvider);
    final sketchBytes = await sketchRenderer.renderSketch(
      composition: sketchComposition,
    );

    SessionResult? sessionResult;
    String? sketchImageUrl;

    if (sketchBytes != null &&
        sketchBytes.isNotEmpty &&
        routeBytes != null &&
        routeBytes.isNotEmpty) {
      final completeSessionUseCase = ref.read(completeSessionUseCaseProvider);
      final saveResult = await completeSessionUseCase.execute(
        sessionId: session.id,
        sketchComposition: sketchComposition,
        sketchBytes: sketchBytes,
        routeBytes: routeBytes,
        routePolyline: routePolyline,
      );

      switch (saveResult) {
        case Ok(:final value):
          sessionResult = value;
          sketchImageUrl = value.resultSketchImageUrl;
        case Error():
          sessionResult = null;
      }

      return SessionResultState(
        session: session.copyWith(status: SessionStatus.completed),
        sessionResult: sessionResult,
        character: user.selectedCharacter,
        sketchComposition: sketchComposition,
        sketchBytes: sketchBytes,
        sketchImageUrl: sketchImageUrl,
      );
    }

    return SessionResultState(
      session: session,
      character: user.selectedCharacter,
      sketchComposition: sketchComposition,
    );
  }

  SketchComposition _composeSketch({
    required List<MissionInstance> missions,
    required CharacterType character,
  }) {
    final characterPart = character.toSketchPart();
    final parts = <SketchSlot, SketchPart>{
      SketchSlot.character: characterPart,
      SketchSlot.background: SketchPartsCatalog.defaultBackground,
    };

    for (final mission in missions) {
      SketchPart? part;

      if (mission.partId != null && mission.partId!.isNotEmpty) {
        part = SketchPartsCatalog.findById(mission.partId!);
      }

      if (part == null && mission.achievedTier > 0) {
        final template = MissionTemplate.defaultTemplates
            .where((t) => t.id == mission.missionTemplateId)
            .firstOrNull;
        if (template != null) {
          part = SketchPartsCatalog.getPartForSlotAndTier(
            template.partsSlot,
            mission.achievedTier,
          );
        }
      }

      if (part != null) {
        parts[part.slot] = part;
      }
    }

    return SketchComposition(parts: parts);
  }

  Future<Result<SessionResult>> completeAndSaveSession({
    required Uint8List sketchBytes,
  }) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(SessionException('세션 정보가 없습니다.'));
    }

    state = AsyncData(current.copyWith(isSubmitting: true));

    try {
      final simplifiedPoints = await PolylineUtils.simplifyLocationPoints(
        current.session.pathPoints,
      );
      final routePolyline = PolylineUtils.encodePolyline(simplifiedPoints);

      final renderer = ref.read(routeImageRendererProvider);
      final routeBytes = await renderer.renderRoute(
        gpsPoints: simplifiedPoints,
      );

      if (routeBytes == null || routeBytes.isEmpty) {
        state = AsyncData(current.copyWith(isSubmitting: false));
        return const Result.error(ValidationException('경로 이미지 생성에 실패했습니다.'));
      }

      final completeSessionUseCase = ref.read(completeSessionUseCaseProvider);
      final result = await completeSessionUseCase.execute(
        sessionId: current.session.id,
        sketchComposition: current.sketchComposition,
        sketchBytes: sketchBytes,
        routeBytes: routeBytes,
        routePolyline: routePolyline,
      );
      state = AsyncData(current.copyWith(isSubmitting: false));
      return result;
    } catch (e) {
      state = AsyncData(current.copyWith(isSubmitting: false));
      return Result.error(SessionException('세션 결과 저장 중 오류가 발생했습니다.', cause: e));
    }
  }

  Future<Result<void>> saveSketchImage({required Uint8List bytes}) async {
    try {
      final fileName = 'MoveSketch_${DateTime.now().formattedFileTimestamp}';
      await Gal.putImageBytes(bytes, album: 'MoveSketch', name: fileName);

      return const Result.ok(null);
    } on GalException catch (e) {
      final message = switch (e.type) {
        GalExceptionType.accessDenied =>
          '사진 보관함 접근 권한이 거부되었습니다. 설정에서 권한을 허용해 주세요.',
        GalExceptionType.notEnoughSpace => '기기 저장 공간이 부족합니다.',
        _ => '스케치 이미지를 앨범에 저장하지 못했습니다.',
      };

      return Result.error(SessionException(message, cause: e));
    } catch (e) {
      return Result.error(
        SessionException('스케치 이미지 저장 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  Future<Result<SessionResult>> retrySync() async {
    final current = state.value;

    if (current == null) {
      return const Result.error(SessionException('세션 정보가 없습니다.'));
    }

    state = AsyncData(
      current.copyWith(
        isSubmitting: true,
        sessionResult: current.sessionResult?.copyWith(
          syncStatus: SyncStatus.syncing,
        ),
      ),
    );

    final sketchBytes = current.sketchBytes ?? Uint8List(0);
    Uint8List routeBytes = Uint8List(0);
    if (current.session.pathPoints.isNotEmpty) {
      final simplifiedPoints = await PolylineUtils.simplifyLocationPoints(
        current.session.pathPoints,
      );
      final routeRenderer = ref.read(routeImageRendererProvider);
      routeBytes =
          await routeRenderer.renderRoute(gpsPoints: simplifiedPoints) ??
          Uint8List(0);
    }
    try {
      final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
      // 이미지 2장 업로드 시간을 고려해 15초 타임아웃 부여
      final saveResult = await sessionResultRepository
          .saveResult(
            result: current.sessionResult!,
            sketchBytes: sketchBytes,
            routeBytes: routeBytes,
          )
          .timeout(const Duration(seconds: 15));
      switch (saveResult) {
        case Ok(:final value):
          final syncedResult = value.copyWith(syncStatus: SyncStatus.synced);
          state = AsyncData(
            current.copyWith(
              sessionResult: syncedResult,
              sketchImageUrl: syncedResult.resultSketchImageUrl,
              isSubmitting: false,
            ),
          );

          await ref
              .read(sessionRepositoryProvider)
              .discardSession(current.session.id);
          return Result.ok(syncedResult);
        case Error():
          state = AsyncData(
            current.copyWith(
              sessionResult: current.sessionResult?.copyWith(
                syncStatus: SyncStatus.syncFailed,
              ),
              isSubmitting: false,
            ),
          );
          return saveResult;
      }
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          sessionResult: current.sessionResult?.copyWith(
            syncStatus: SyncStatus.syncFailed,
          ),
          isSubmitting: false,
        ),
      );
      return const Result.error(NetworkException('서버 연결 시간 초과'));
    }
  }
}

final sessionResultViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<SessionResultViewModel, SessionResultState, String>(
      (sessionId) => SessionResultViewModel(sessionId),
    );
