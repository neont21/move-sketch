import '../../../domain/models/social/comment.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../domain/models/social/user.dart';
import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/result.dart';

/// 소셜 피드 스케치 게시물, 응원 및 댓글 관리를 추상화한 저장소 인터페이스입니다.
abstract interface class SketchPostRepository {
  /// 신규 스케치 피드 게시물([sketch])을 등록합니다.
  Future<Result<SketchPost>> createPost(SketchPost sketch);

  /// 지정된 게시물([sketchId])의 상세 정보를 조회합니다. (게시물 상세 화면)
  Future<Result<SketchPost?>> getPostById(String sketchId);

  /// 사용자([currentUserId])와 친구들의 최신 피드 게시물 목록을 커서 페이징으로 조회합니다. (피드 탭)
  Future<Result<List<SketchPost>>> getFeedPosts({
    required String currentUserId,
    int limit = 20,
    DateTime? lastCreatedAt,
  });

  /// 특정 사용자([userId])가 작성한 게시물 목록을 커서 페이징으로 조회합니다. (프로필 화면)
  Future<Result<List<SketchPost>>> getUserPosts({
    required String userId,
    int limit = 18,
    DateTime? lastCreatedAt,
  });

  /// 지정된 게시물([sketchId])의 캡션, 대표 위치, 날씨, 서명 및 경로 정보를 수정합니다.
  Future<Result<SketchPost>> updatePost({
    required String sketchId,
    String? caption,
    int? locationIndex,
    WeatherInfo? weather,
    bool? useSignature,
    String? routePolyline,
  });

  /// 지정된 게시물([sketchId])을 삭제합니다. (게시물 상세 화면 혹은 피드 탭)
  Future<Result<void>> deletePost(String sketchId);

  /// 게시물([sketchId])에 대한 사용자([userId])의 응원 상태를 토글합니다. (친구 게시물 상세 화면)
  Future<Result<void>> toggleCheer({
    required String sketchId,
    required String userId,
    required bool isCheered,
  });

  /// 내 게시물을 응원한 사용자 ID 목록([userIds])에 해당하는 프로필 요약 목록을 조회합니다. (내 게시물 상세 화면)
  Future<Result<List<UserSummary>>> getCheeredUsers(List<String> userIds);

  /// 게시물([sketchId])에 댓글 또는 답글([comment])을 작성합니다. (게시물 상세 화면)
  Future<Result<Comment>> addComment({
    required String sketchId,
    required Comment comment,
  });

  /// 지정된 게시물([sketchId])의 댓글 목록을 조회합니다. (게시물 상세 화면)
  Future<Result<List<Comment>>> getComments(String sketchId);

  /// 게시물([sketchId])의 특정 댓글([commentId])을 삭제합니다. (게시물 상세 화면)
  Future<Result<void>> deleteComment({
    required String sketchId,
    required String commentId,
  });
}
