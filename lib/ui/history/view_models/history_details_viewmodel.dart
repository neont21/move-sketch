import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:move_sketch/ui/auth/view_models/auth_viewmodel.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

@immutable
class HistoryDetailsState {
  final SessionResult sessionResult;
  final bool isLatest;
  final bool isSavingMemo;
  final bool isDownloadingImage;

  const HistoryDetailsState({
    required this.sessionResult,
    required this.isLatest,
    this.isSavingMemo = false,
    this.isDownloadingImage = false,
  });

  HistoryDetailsState copyWith({
    SessionResult? sessionResult,
    bool? isLatest,
    bool? isSavingMemo,
    bool? isDownloadingImage,
  }) {
    return HistoryDetailsState(
      sessionResult: sessionResult ?? this.sessionResult,
      isLatest: isLatest ?? this.isLatest,
      isSavingMemo: isSavingMemo ?? this.isSavingMemo,
      isDownloadingImage: isDownloadingImage ?? this.isDownloadingImage,
    );
  }
}

class HistoryDetailsViewModel extends AsyncNotifier<HistoryDetailsState> {
  final String sessionId;

  HistoryDetailsViewModel(this.sessionId);

  @override
  Future<HistoryDetailsState> build() async {
    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final result = await sessionResultRepository.getResultById(sessionId);

    final SessionResult sessionResult;
    switch (result) {
      case Ok(:final value):
        if (value == null) {
          throw const NotFoundException('세션 기록을 찾을 수 없습니다.');
        }
        sessionResult = value;
      case Error(:final error):
        throw error;
    }

    final user = await ref.watch(authViewModelProvider.future);
    bool isLatest = false;
    if (user != null) {
      final result = await sessionResultRepository.getLatestResult(user.uid);
      switch (result) {
        case Ok(:final value):
          isLatest = value?.id == sessionId;
        case Error():
          isLatest = false;
      }
    }

    return HistoryDetailsState(
      sessionResult: sessionResult,
      isLatest: isLatest,
    );
  }

  Future<Result<void>> updateSecretMemo(String secretMemo) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(SessionException('세션 정보가 없습니다.'));
    }

    state = AsyncData(current.copyWith(isSavingMemo: true));

    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final result = await sessionResultRepository.updateSecretMemo(
      sessionId: sessionId,
      secretMemo: secretMemo,
    );

    switch (result) {
      case Ok():
        state = AsyncData(
          current.copyWith(
            sessionResult: current.sessionResult.copyWith(
              secretMemo: () => secretMemo.trim(),
            ),
            isSavingMemo: false,
          ),
        );
      case Error():
        state = AsyncData(current.copyWith(isSavingMemo: false));
    }

    return result;
  }

  Future<Result<void>> downloadSketchImage() async {
    final current = state.value;
    if (current == null) {
      return const Result.error(SessionException('세션 정보가 없습니다.'));
    }

    final imageUrl = current.sessionResult.resultSketchImageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Result.error(ValidationException('저장할 스케치 이미지가 없습니다.'));
    }

    state = AsyncData(current.copyWith(isDownloadingImage: true));

    final sessionResultRepository = ref.read(sessionResultRepositoryProvider);
    final downloadResult = await sessionResultRepository.downloadSketchImage(
      imageUrl,
    );

    switch (downloadResult) {
      case Ok(:final value):
        try {
          final fileName =
              'MoveSketch_${current.sessionResult.endedAt.formattedFileTimestamp}';
          await Gal.putImageBytes(value, album: 'MoveSketch', name: fileName);
          state = AsyncData(current.copyWith(isDownloadingImage: false));
          return const Result.ok(null);
        } on GalException catch (e) {
          state = AsyncData(current.copyWith(isDownloadingImage: false));
          final message = switch (e.type) {
            GalExceptionType.accessDenied =>
              '사진 보관함 접근 권한이 거부되었습니다. 설정에서 권한을 허용해 주세요.',
            GalExceptionType.notEnoughSpace => '기기 저장 공간이 부족합니다.',
            _ => '스케치 이미지를 앨범에 저장하지 못했습니다.',
          };
          return Result.error(SessionException(message, cause: e));
        } catch (e) {
          state = AsyncData(current.copyWith(isDownloadingImage: false));
          return Result.error(
            SessionException('스케치 이미지 저장 중 오류가 발생했습니다.', cause: e),
          );
        }
      case Error(:final error):
        state = AsyncData(current.copyWith(isDownloadingImage: false));
        return Result.error(error);
    }
  }
}

final historyDetailsViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<HistoryDetailsViewModel, HistoryDetailsState, String>(
      (sessionId) => HistoryDetailsViewModel(sessionId),
    );
