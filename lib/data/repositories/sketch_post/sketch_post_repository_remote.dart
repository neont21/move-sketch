import 'package:firebase_core/firebase_core.dart';
import '../../../domain/models/social/comment.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/friendship_service.dart';
import '../../services/remote/firestore/sketch_post_service.dart';
import '../../services/remote/firestore/user_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'sketch_post_repository.dart';

final class SketchPostRepositoryRemote implements SketchPostRepository {
  final SketchPostService sketchPostService;
  final FriendshipService friendshipService;
  final UserService userService;

  SketchPostRepositoryRemote({
    required this.sketchPostService,
    required this.friendshipService,
    required this.userService,
  });

  @override
  Future<Result<SketchPost>> createPost(SketchPost sketch) async {
    try {
      final sketchPost = await sketchPostService.createPost(sketch);
      return Result.ok(sketchPost);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '스케치 작성 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('스케치 작성 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<SketchPost?>> getPostById(String sketchId) async {
    try {
      final sketchPost = await sketchPostService.getPostById(sketchId);
      return Result.ok(sketchPost);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '스케치 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('스케치 조회 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<List<SketchPost>>> getFeedPosts({
    required String currentUserId,
    int limit = 20,
    DateTime? lastCreatedAt,
  }) async {
    try {
      final friends = await friendshipService.getFriendUserIds(currentUserId);
      final sketchPosts = await sketchPostService.getFeedPosts(
        authorIds: [currentUserId, ...friends],
        limit: limit,
        lastCreatedAt: lastCreatedAt,
      );

      return Result.ok(sketchPosts);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '피드 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('피드 조회 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<List<SketchPost>>> getUserPosts({
    required String userId,
    int limit = 18,
    DateTime? lastCreatedAt,
  }) async {
    try {
      final sketchPosts = await sketchPostService.getUserPosts(
        userId: userId,
        limit: limit,
        lastCreatedAt: lastCreatedAt,
      );

      return Result.ok(sketchPosts);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '스케치 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('스케치 조회 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<SketchPost>> updatePost({
    required String sketchId,
    String? caption,
    String? locationTag,
    String? weather,
  }) async {
    try {
      final sketchPost = await sketchPostService.updatePost(
        sketchId: sketchId,
        caption: caption?.trim(),
        locationTag: locationTag,
        weather: weather,
      );

      return Result.ok(sketchPost);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '스케치 편집 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('스케치 편집 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> deletePost(String sketchId) async {
    try {
      await sketchPostService.deletePost(sketchId);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '스케치 삭제 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('스케치 삭제 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> toggleCheer({
    required String sketchId,
    required String userId,
    required bool isCheered,
  }) async {
    try {
      await sketchPostService.toggleCheer(
        sketchId: sketchId,
        userId: userId,
        isCheered: isCheered,
      );
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '응원 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('응원 처리 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<List<UserSummary>>> getCheeredUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) {
      return const Result.ok([]);
    }
    try {
      final cheeredFriends = await userService.getUserSummaries(userIds);
      return Result.ok(cheeredFriends);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '응원한 친구 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('응원한 친구 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Comment>> addComment({
    required String sketchId,
    required Comment comment,
  }) async {
    final trimmed = comment.text.trim();
    if (trimmed.isEmpty) {
      return const Result.error(ValidationException('댓글 내용을 입력해 주세요.'));
    }
    try {
      final trimmedComment = comment.text != trimmed
          ? comment.copyWith(text: trimmed)
          : comment;
      final savedComment = await sketchPostService.addComment(
        sketchId: sketchId,
        comment: trimmedComment,
      );
      return Result.ok(savedComment);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '댓글 작성 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('댓글 작성 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<List<Comment>>> getComments(String sketchId) async {
    try {
      final comments = await sketchPostService.getComments(sketchId);
      return Result.ok(comments);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '댓글 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('댓글 조회 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteComment({
    required String sketchId,
    required String commentId,
  }) async {
    try {
      await sketchPostService.deleteComment(
        sketchId: sketchId,
        commentId: commentId,
      );
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '댓글 삭제 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('댓글 삭제 중 오류가 발생했습니다.', cause: e));
    }
  }
}
