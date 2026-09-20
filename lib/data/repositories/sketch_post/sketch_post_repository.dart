import '../../../domain/models/social/comment.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../domain/models/social/user.dart';

abstract interface class SketchPostRepository {
  /// 피드 게시물을 등록한다.
  Future<SketchPost> createPost(SketchPost sketch);

  /// 특정 게시물을 조회한다. (게시물 상세 화면)
  Future<SketchPost?> getPostById(String sketchId);

  /// 최신 게시물 목록을 페이징 조회한다. (피드 탭)
  Future<List<SketchPost>> getFeedPosts({
    required String currentUserId,
    int limit = 20,
    DateTime? lastCreatedAt,
  });

  /// 특정 사용자의 게시물 목록을 조회한다. (프로필 화면)
  Future<List<SketchPost>> getUserPosts({
    required String userId,
    int limit = 18,
    DateTime? lastCreatedAt,
  });

  /// 게시물 내용을 수정한다.
  Future<SketchPost> updatePost({
    required String sketchId,
    String? caption,
    String? locationTag,
    String? weather,
  });

  /// 게시물을 삭제한다. (게시물 상세 화면 혹은 피드 탭)
  Future<void> deletePost(String sketchId);

  /// 친구의 게시물에 대해 응원하거나 취소한다. (친구 게시물 상세 화면)
  Future<void> toggleCheer({
    required String sketchId,
    required String userId,
    required bool isCheered,
  });

  /// 내 게시물을 응원한 친구들의 목록을 조회한다. (내 게시물 상세 화면)
  Future<List<UserSummary>> getCheeredUsers(List<String> userIds);

  /// 댓글 및 답글을 작성한다. (게시물 상세 화면)
  Future<Comment> addComment({
    required String sketchId,
    required Comment comment,
  });

  /// 특정 게시물의 댓글 목록을 조회한다. (게시물 상세 화면)
  Future<List<Comment>> getComments(String sketchId);

  /// 댓글을 삭제한다. (게시물 상세 화면)
  Future<void> deleteComment({
    required String sketchId,
    required String commentId,
  });
}
