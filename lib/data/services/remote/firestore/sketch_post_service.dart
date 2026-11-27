import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/social/comment.dart';
import '../../../../domain/models/social/sketch_post.dart';
import '../../../../domain/models/weather/weather_info.dart';

/// Firestore `sketch_posts` 컬렉션 및 `comments` 서브컬렉션의 CRUD, 응원 및 계층 댓글 조회를 처리하는 서비스 클래스입니다.
class SketchPostService {
  final FirebaseFirestore _firestore;

  SketchPostService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sketchesRef =>
      _firestore.collection('sketch_posts');

  CollectionReference<Map<String, dynamic>> _commentsRef(String sketchId) =>
      _sketchesRef.doc(sketchId).collection('comments');

  /// 신규 스케치 게시물([sketch])을 서버 타임스탬프와 함께 저장하고 확정된 [SketchPost]를 반환합니다.
  Future<SketchPost> createPost(SketchPost sketch) async {
    final data = sketch.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data.remove('updatedAt');

    final postRef = _sketchesRef.doc(sketch.id);
    await postRef.set(data);

    final savedDoc = await postRef.get();
    return SketchPost.fromMap(savedDoc.data()!);
  }

  /// 지정된 게시물([sketchId])의 전달된 선택 필드만 부분 갱신합니다.
  Future<SketchPost> updatePost({
    required String sketchId,
    String? caption,
    int? locationIndex,
    WeatherInfo? weather,
    bool? useSignature,
    String? routePolyline,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (caption != null) {
      updates['caption'] = caption;
    }
    if (locationIndex != null) {
      updates['locationIndex'] = locationIndex;
    }
    if (weather != null) {
      updates['weather'] = weather.toMap();
    }
    if (useSignature != null) {
      updates['useSignature'] = useSignature;
    }
    if (routePolyline != null) {
      updates['routePolyline'] = routePolyline;
    }

    final postRef = _sketchesRef.doc(sketchId);
    await postRef.update(updates);

    final savedDoc = await postRef.get();
    return SketchPost.fromMap(savedDoc.data()!);
  }

  /// 게시물 고유 식별자([sketchId])에 해당하는 단건 게시물을 조회합니다.
  Future<SketchPost?> getPostById(String sketchId) async {
    final doc = await _sketchesRef.doc(sketchId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final sketch = SketchPost.fromMap(doc.data()!);
    if (sketch.isDeleted) {
      return null;
    }
    return sketch;
  }

  /// 작성자 목록([authorIds])에 해당하는 피드 게시물을 커서 기반 페이지네이션([lastCreatedAt])으로 최신순 조회합니다.
  ///
  /// Firestore `whereIn` 절의 최대 30개 제한을 우회하기 위해, 작성자 목록이 30명을 초과하면
  /// 30개 단위의 청크로 분할해 병렬 쿼리한 뒤 작성 일시 내림차순으로 병합 정렬합니다.
  Future<List<SketchPost>> getFeedPosts({
    required List<String> authorIds,
    int limit = 20,
    DateTime? lastCreatedAt,
  }) async {
    if (authorIds.isEmpty) {
      return [];
    }

    if (authorIds.length <= 30) {
      Query<Map<String, dynamic>> query = _sketchesRef
          .where('authorId', whereIn: authorIds)
          .where('deletedAt', isNull: true);

      if (lastCreatedAt != null) {
        query = query.where(
          'createdAt',
          isLessThan: Timestamp.fromDate(lastCreatedAt),
        );
      }
      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SketchPost.fromMap(doc.data()))
          .toList();
    } else {
      final chunks = <List<String>>[];

      for (var index = 0; index < authorIds.length; index += 30) {
        chunks.add(
          authorIds.sublist(
            index,
            index + 30 > authorIds.length ? authorIds.length : index + 30,
          ),
        );
      }

      final futures = chunks.map((chunk) {
        Query<Map<String, dynamic>> query = _sketchesRef
            .where('authorId', whereIn: chunk)
            .where('deletedAt', isNull: true);

        if (lastCreatedAt != null) {
          query = query.where(
            'createdAt',
            isLessThan: Timestamp.fromDate(lastCreatedAt),
          );
        }

        return query.orderBy('createdAt', descending: true).limit(limit).get();
      });

      final snapshots = await Future.wait(futures);
      final allPosts = snapshots
          .expand((snapshot) => snapshot.docs)
          .map((doc) => SketchPost.fromMap(doc.data()))
          .toList();

      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allPosts;
    }
  }

  /// 특정 사용자([userId])가 작성한 게시물 목록을 커서 기반 페이지네이션([lastCreatedAt])으로 조회합니다.
  Future<List<SketchPost>> getUserPosts({
    required String userId,
    int limit = 18,
    DateTime? lastCreatedAt,
  }) async {
    Query<Map<String, dynamic>> query = _sketchesRef
        .where('authorId', isEqualTo: userId)
        .where('deletedAt', isNull: true);

    if (lastCreatedAt != null) {
      query = query.where(
        'createdAt',
        isLessThan: Timestamp.fromDate(lastCreatedAt),
      );
    }

    final snapshot = await query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => SketchPost.fromMap(doc.data())).toList();
  }

  /// 지정된 게시물([sketchId])에 삭제 시각(`deletedAt`)을 기록하여 소프트 딜리트 처리합니다.
  Future<void> deletePost(String sketchId) async {
    await _sketchesRef.doc(sketchId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 게시물([sketchId])의 응원 사용자 집합(`cheeredUserIds`)에 [userId]를 추가하거나 제거합니다.
  Future<void> toggleCheer({
    required String sketchId,
    required String userId,
    required bool isCheered,
  }) async {
    final sketchRef = _sketchesRef.doc(sketchId);

    await sketchRef.update({
      'cheeredUserIds': isCheered
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 게시물([sketchId])에 신규 댓글([comment])을 추가하고 게시물의 `commentCount`를 단일 배치([WriteBatch])로 1 증가시킵니다.
  Future<Comment> addComment({
    required String sketchId,
    required Comment comment,
  }) async {
    final batch = _firestore.batch();

    final postRef = _sketchesRef.doc(sketchId);
    final commentRef = _commentsRef(sketchId).doc(comment.id);

    final commentData = comment.toMap();
    commentData['createdAt'] = FieldValue.serverTimestamp();

    batch.set(commentRef, commentData);
    batch.update(postRef, {
      'commentCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    final savedCommentDoc = await commentRef.get();
    return Comment.fromMap(savedCommentDoc.data()!);
  }

  /// 게시물([sketchId])의 전체 댓글을 부모 댓글-답글 계층 구조로 정렬하여 반환합니다.
  ///
  /// 삭제된 부모 댓글이라도 미삭제 답글이 달려 있는 경우 대댓글 트리 유지를 위해 목록에 포함합니다.
  Future<List<Comment>> getComments(String sketchId) async {
    final snapshot = await _commentsRef(
      sketchId,
    ).orderBy('createdAt', descending: false).get();

    final allComments = snapshot.docs
        .map((doc) => Comment.fromMap(doc.data()))
        .toList();

    final parentIdsWithReplies = allComments
        .where(
          (comment) =>
              comment.isReply &&
              !comment.isDeleted &&
              comment.parentCommentId != null,
        )
        .map((reply) => reply.parentCommentId!)
        .toSet();

    final visibleComments = allComments.where((comment) {
      if (!comment.isDeleted) {
        return true;
      }
      if (!comment.isReply && parentIdsWithReplies.contains(comment.id)) {
        return true;
      }
      return false;
    }).toList();

    final parentComments = <Comment>[];
    final repliesByParentId = <String, List<Comment>>{};

    for (final comment in visibleComments) {
      if (!comment.isReply) {
        parentComments.add(comment);
      } else {
        repliesByParentId
            .putIfAbsent(comment.parentCommentId!, () => [])
            .add(comment);
      }
    }

    final organized = <Comment>[];
    for (final parent in parentComments) {
      organized.add(parent);
      if (repliesByParentId.containsKey(parent.id)) {
        organized.addAll(repliesByParentId[parent.id]!);
      }
    }
    return organized;
  }

  /// 댓글([commentId])에 `deletedAt`을 기록하여 논리 삭제하고 게시물의 `commentCount`를 단일 배치([WriteBatch])로 1 감소시킵니다.
  Future<void> deleteComment({
    required String sketchId,
    required String commentId,
  }) async {
    final batch = _firestore.batch();

    final postRef = _sketchesRef.doc(sketchId);
    final commentRef = _commentsRef(sketchId).doc(commentId);

    batch.update(commentRef, {'deletedAt': FieldValue.serverTimestamp()});
    batch.update(postRef, {
      'commentCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
