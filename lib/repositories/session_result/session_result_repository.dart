import 'dart:typed_data';
import '../../models/session/session_result.dart';

abstract interface class SessionResultRepository {
  /// 이미지를 서버에 업로드하고 그 URL과 함께 세션 결과를 서버에 저장한다.
  Future<SessionResult> saveResult({
    required SessionResult result,
    required Uint8List? sketchBytes,
    required Uint8List? routeBytes,
  });

  /// 특정 세션 결과를 조회한다.
  Future<SessionResult?> getResultById(String sessionId);

  /// 사용자의 가장 최근 세션 결과를 조회한다. (홈 탭)
  Future<SessionResult?> getLatestResult(String userId);

  /// 특정 연/월의 세션 결과 목록을 조회한다. (기록 탭)
  Future<List<SessionResult>> getResultsByMonth({
    required String userId,
    required int year,
    required int month,
  });

  /// 나만 보는 메모를 작성/수정한다. (기록 탭)
  Future<void> updateSecretMemo({
    required String sessionId,
    required String secretMemo,
  });

  /// 피드 공유 상태를 업데이트한다.
  Future<void> updateShareStatus({
    required String sessionId,
    required bool isShared,
  });

  /// 세션 결과를 삭제한다.
  Future<void> deleteResult(
    String sessionId, {
    bool deletePostIfShared = false,
  });
}
