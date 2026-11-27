import 'dart:typed_data';

import '../../../domain/models/enums/activity_type.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/result.dart';

/// 완료된 운동 세션 결과 및 스케치 이미지의 원격 영속화를 추상화한 저장소 인터페이스입니다.
abstract interface class SessionResultRepository {
  /// 스케치 이미지([sketchBytes])를 스토리지에 업로드하고, 이미지 URL을 포함한 세션 결과([result])를 저장합니다.
  Future<Result<SessionResult>> saveResult({
    required SessionResult result,
    required Uint8List sketchBytes,
  });

  /// 원격 스토리지 URL([imageUrl])로부터 스케치 이미지 바이너리를 내려받습니다.
  Future<Result<Uint8List>> downloadSketchImage(String imageUrl);

  /// 지정된 세션([sessionId])의 완료 결과 단건을 조회합니다.
  Future<Result<SessionResult?>> getResultById(String sessionId);

  /// 지정된 사용자([userId])의 가장 최근 운동 세션 결과를 조회합니다. (홈 탭 요약용)
  Future<Result<SessionResult?>> getLatestResult(String userId);

  /// 지정된 사용자([userId])의 특정 활동 종목([activityType]) 최근 세션 결과 목록을 조회합니다. (세션 시작 기준값 산출용)
  Future<Result<List<SessionResult>>> getRecentResults({
    required String userId,
    required ActivityType activityType,
    int limit = 5,
  });

  /// 오늘 포함 최근 7일간의 일별 운동 달성 여부를 반환합니다.
  Future<Result<List<bool>>> getWeeklyCompletionStatus(String userId);

  /// 특정 연도([year]) 및 월([month])에 사용자([userId])가 완료한 세션 결과 목록을 조회합니다. (기록 탭)
  Future<Result<List<SessionResult>>> getResultsByMonth({
    required String userId,
    required int year,
    required int month,
  });

  /// 지정된 세션([sessionId])의 비공개 메모([secretMemo])를 작성하거나 수정합니다. (기록 탭)
  Future<Result<void>> updateSecretMemo({
    required String sessionId,
    required String secretMemo,
  });

  /// 지정된 세션([sessionId])의 소셜 피드 공유 상태([isShared])를 갱신합니다.
  Future<Result<void>> updateShareStatus({
    required String sessionId,
    required bool isShared,
  });

  /// 역지오코딩으로 산출된 행정구역 위치 태그 목록([locationTags])을 갱신합니다.
  Future<Result<void>> updateLocationTags({
    required String sessionId,
    required List<String> locationTags,
  });

  /// 지정된 세션 결과([sessionId])를 논리 삭제합니다. ([deletePostIfShared]가 `true`이면 공유된 피드 게시물도 함께 삭제)
  Future<Result<void>> deleteResult(
    String sessionId, {
    bool deletePostIfShared = false,
  });
}
