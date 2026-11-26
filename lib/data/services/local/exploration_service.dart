import 'database/daos/exploration_dao.dart';

/// [ExplorationDao]를 통해 사용자의 과거 Geohash 방문 이력을 조회하고 저장하는 로컬 서비스 클래스입니다.
class ExplorationService {
  final ExplorationDao _explorationDao;

  const ExplorationService(this._explorationDao);

  /// 지정된 사용자([userId])의 과거 방문 Geohash 타일 코드 집합을 조회하여 반환합니다.
  Future<Set<String>> getVisitedGeohashes(String userId) {
    return _explorationDao.getVisitedGeohashSet(userId);
  }

  /// 지정된 사용자([userId])가 방문한 고유 Geohash 타일의 총 개수를 반환합니다.
  Future<int> getVisitedGeohashCount(String userId) {
    return _explorationDao.getVisitedGeohashCount(userId);
  }

  /// 사용자([userId])가 방문한 Geohash 목록([geohashes])을 방문 시각([visitedAt])과 함께 저장합니다.
  Future<void> saveVisitedGeohashes({
    required String userId,
    required Iterable<String> geohashes,
    required DateTime visitedAt,
  }) {
    return _explorationDao.upsertVisitedGeohashes(
      userId: userId,
      geohashes: geohashes,
      visitedAt: visitedAt,
    );
  }
}
