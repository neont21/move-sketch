import '../../../data/repositories/session_result/session_result_repository.dart';
import '../../../data/repositories/sketch_post/sketch_post_repository.dart';
import '../../../utils/result.dart';

/// 소셜 피드에 공유된 스케치 게시물을 삭제하고 원본 세션 결과의 공유 상태를 해제하는 유즈케이스 클래스입니다.
final class DeleteSketchPostUseCase {
  /// 피드 게시물 삭제 처리를 담당하는 저장소.
  final SketchPostRepository sketchPostRepository;

  /// 원본 운동 세션 결과의 공유 상태(`isShared`)를 갱신하는 저장소.
  final SessionResultRepository sessionResultRepository;

  DeleteSketchPostUseCase({
    required this.sketchPostRepository,
    required this.sessionResultRepository,
  });

  /// 지정된 스케치 게시물([sketchId])을 삭제한 뒤, 연계된 세션 결과의 공유 상태를 `false`로 되돌립니다.
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
