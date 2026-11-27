import '../../../utils/result.dart';

/// 사용자의 신규 경로 개척 데이터를 관리하는 저장소 인터페이스입니다.
abstract interface class ExplorationRepository {
  /// 특정 사용자([userId])가 과거에 방문한 모든 Geohash 타일 집합을 조회합니다.
  Future<Result<Set<String>>> getVisitedGeohashes(String userId);

  /// 특정 사용자([userId])가 지금까지 개척한 고유 Geohash 타일의 총 개수를 조회합니다.
  Future<Result<int>> getVisitedGeohashCount(String userId);

  /// 세션 완료 시 해당 세션에서 방문한 Geohash 목록([geohashes])을 기록합니다.
  Future<Result<void>> recordVisitedGeohashes({
    required String userId,
    required Iterable<String> geohashes,
    DateTime? visitedAt,
  });
}
