import 'dart:typed_data';
import '../../../domain/models/enums/activity_type.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/result.dart';

abstract interface class SessionResultRepository {
  /// 이미지를 서버에 업로드하고 그 URL과 함께 세션 결과를 서버에 저장한다.
  Future<Result<SessionResult>> saveResult({
    required SessionResult result,
    required Uint8List sketchBytes,
  });

  /// 스케치 이미지 URL로부터 이미지 바이트를 내려받는다.
  Future<Result<Uint8List>> downloadSketchImage(String imageUrl);

  /// 특정 세션 결과를 조회한다.
  Future<Result<SessionResult?>> getResultById(String sessionId);

  /// 사용자의 가장 최근 세션 결과를 조회한다. (홈 탭)
  Future<Result<SessionResult?>> getLatestResult(String userId);

  /// 사용자의 특정 활동에 대한 최근 세션 결과 목록을 조회한다. (세션 시작 화면)
  Future<Result<List<SessionResult>>> getRecentResults({
    required String userId,
    required ActivityType activityType,
    int limit = 5,
  });

  /// 오늘 포함 최근 7일(D-6 ~ D-Day) 운동 달성 여부(길이 7의 boolean 리스트)를 반환한다.
  Future<Result<List<bool>>> getWeeklyCompletionStatus(String userId);

  /// 특정 연/월의 세션 결과 목록을 조회한다. (기록 탭)
  Future<Result<List<SessionResult>>> getResultsByMonth({
    required String userId,
    required int year,
    required int month,
  });

  /// 나만 보는 메모를 작성/수정한다. (기록 탭)
  Future<Result<void>> updateSecretMemo({
    required String sessionId,
    required String secretMemo,
  });

  /// 피드 공유 상태를 업데이트한다.
  Future<Result<void>> updateShareStatus({
    required String sessionId,
    required bool isShared,
  });

  /// 역지오코딩된 위치 태그를 업데이트한다.
  Future<Result<void>> updateLocationTags({
    required String sessionId,
    required List<String> locationTags,
  });

  /// 세션 결과를 삭제한다.
  Future<Result<void>> deleteResult(
    String sessionId, {
    bool deletePostIfShared = false,
  });
}
