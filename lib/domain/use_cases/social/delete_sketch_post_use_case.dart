import '../../../data/repositories/session_result/session_result_repository.dart';
import '../../../data/repositories/sketch_post/sketch_post_repository.dart';
import '../../../utils/result.dart';

class DeleteSketchPostUseCase {
  final SketchPostRepository sketchPostRepository;
  final SessionResultRepository sessionResultRepository;

  DeleteSketchPostUseCase({
    required this.sketchPostRepository,
    required this.sessionResultRepository,
  });

  Future<Result<void>> execute(String sketchId) async {
    final result = await sketchPostRepository.deletePost(sketchId);

    switch (result) {
      case Ok():
        return await sessionResultRepository.updateShareStatus(
          sessionId: sketchId,
          isShared: false,
        );
      case Error(:final error):
        return Result.error(error);
    }
  }
}
