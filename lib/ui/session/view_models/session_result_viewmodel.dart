import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/enums/session_status.dart';
import '../../../domain/models/enums/sync_status.dart';
import '../../../domain/models/fixed/sketch_parts.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/polyline_utils.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../history/view_models/history_viewmodel.dart';
import '../../home/view_models/home_viewmodel.dart';

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

    final composeSketchUseCase = ref.read(composeSketchUseCaseProvider);

    final sketchComposition =  composeSketchUseCase.execute(
      missions: session.missions,
      character: user.selectedCharacter,
    );

    final simplifiedPoints = await PolylineUtils.simplifyLocationPoints(
      session.pathPoints,
    );
    final routePolyline = PolylineUtils.encodePolyline(simplifiedPoints);

    final sketchRenderer = ref.read(sketchImageRendererProvider);
    final sketchBytes = await sketchRenderer.renderSketch(
      composition: sketchComposition,
    );

    SessionResult? sessionResult;
    String? sketchImageUrl;

    if (sketchBytes != null && sketchBytes.isNotEmpty) {
      final completeSessionUseCase = ref.read(completeSessionUseCaseProvider);
      final saveResult = await completeSessionUseCase.execute(
        sessionId: session.id,
        sketchComposition: sketchComposition,
        sketchBytes: sketchBytes,
        routePolyline: routePolyline,
      );

      switch (saveResult) {
        case Ok(:final value):
          sessionResult = value;
          sketchImageUrl = value.resultSketchImageUrl;
          ref.invalidate(homeViewModelProvider);
          ref.invalidate(historyViewModelProvider);
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

      final completeSessionUseCase = ref.read(completeSessionUseCaseProvider);
      final result = await completeSessionUseCase.execute(
        sessionId: current.session.id,
        sketchComposition: current.sketchComposition,
        sketchBytes: sketchBytes,
        routePolyline: routePolyline,
      );
      switch (result) {
        case Ok():
          ref.invalidate(homeViewModelProvider);
          ref.invalidate(historyViewModelProvider);
        case Error():
          break;
      }
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
    try {
      final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
      final saveResult = await sessionResultRepository
          .saveResult(result: current.sessionResult!, sketchBytes: sketchBytes)
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
