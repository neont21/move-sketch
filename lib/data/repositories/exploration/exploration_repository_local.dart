import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/local/exploration_service.dart';
import 'exploration_repository.dart';

final class ExplorationRepositoryLocal implements ExplorationRepository {
  final ExplorationService explorationService;

  const ExplorationRepositoryLocal({required this.explorationService});

  @override
  Future<Result<Set<String>>> getVisitedGeohashes(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.error(
        ValidationException('사용자 식별자가 비어 있어 방문 이력을 조회할 수 없습니다.'),
      );
    }

    try {
      final visitedSet = await explorationService.getVisitedGeohashes(userId);
      return Result.ok(Set.unmodifiable(visitedSet));
    } catch (error) {
      return Result.error(
        DatabaseException('방문한 경로 격자 목록을 불러오는 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<int>> getVisitedGeohashCount(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.error(
        ValidationException('사용자 식별자가 비어 있어 개척 타일 수를 조회할 수 없습니다.'),
      );
    }

    try {
      final count = await explorationService.getVisitedGeohashCount(userId);
      return Result.ok(count);
    } catch (error) {
      return Result.error(
        DatabaseException('개척한 경로 격자 통계를 불러오는 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> recordVisitedGeohashes({
    required String userId,
    required Iterable<String> geohashes,
    DateTime? visitedAt,
  }) async {
    if (userId.trim().isEmpty) {
      return const Result.error(
        ValidationException('사용자 식별자가 비어 있어 방문 격자를 저장할 수 없습니다.'),
      );
    }

    final uniqueGeohashes = geohashes.toSet();
    if (uniqueGeohashes.isEmpty) {
      return const Result.ok(null);
    }

    try {
      await explorationService.saveVisitedGeohashes(
        userId: userId,
        geohashes: uniqueGeohashes,
        visitedAt: visitedAt ?? DateTime.now(),
      );
      return const Result.ok(null);
    } catch (error) {
      return Result.error(
        DatabaseException('방문한 경로 격자 기록을 저장하는 중 오류가 발생했습니다.', cause: error),
      );
    }
  }
}
