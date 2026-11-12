import 'database/daos/exploration_dao.dart';

final class ExplorationService {
  final ExplorationDao _explorationDao;
  const ExplorationService(this._explorationDao);

  Future<Set<String>> getVisitedGeohashes(String userId) {
    return _explorationDao.getVisitedGeohashSet(userId);
  }

  Future<int> getVisitedGeohashCount(String userId) {
    return _explorationDao.getVisitedGeohashCount(userId);
  }

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