import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/social/comment.dart';
import '../../../models/social/sketch_post.dart';

class SketchPostService {
  final FirebaseFirestore _firestore;

  SketchPostService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sketchsRef =>
      _firestore.collection('sketch_posts');

  CollectionReference<Map<String, dynamic>> _commentsRef(String sketchId) =>
      _sketchsRef.doc(sketchId).collection('comments');

  Future<SketchPost> createPost(SketchPost sketch) async {
    final data = sketch.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data.remove('updatedAt');

    final postRef = _sketchsRef.doc(sketch.id);
    await postRef.set(data);

    final savedDoc = await postRef.get();
    return SketchPost.fromMap(savedDoc.data()!);
  }

  Future<SketchPost> updatePost({
    required String sketchId,
    String? caption,
    String? locationTag,
    String? weather,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (caption != null) {
      updates['caption'] = caption;
    }
    if (locationTag != null) {
      updates['locationTag'] = locationTag;
    }
    if (weather != null) {
      updates['weather'] = weather;
    }

    final postRef = _sketchsRef.doc(sketchId);
    await postRef.update(updates);

    final savedDoc = await postRef.get();
    return SketchPost.fromMap(savedDoc.data()!);
  }

  Future<SketchPost?> getPostById(String sketchId) async {
    final doc = await _sketchsRef.doc(sketchId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final sketch = SketchPost.fromMap(doc.data()!);
    if (sketch.isDeleted) {
      return null;
    }
    return sketch;
  }

  Future<List<SketchPost>> getFeedPosts({
    required List<String> authorIds,
    int limit = 20,
    DateTime? lastCreatedAt,
  }) async {
    if (authorIds.isEmpty) {
      return [];
    }

    if (authorIds.length <= 30) {
      Query<Map<String, dynamic>> query = _sketchsRef
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

      for (var i = 0; i < authorIds.length; i += 30) {
        chunks.add(
          authorIds.sublist(
            i,
            i + 30 > authorIds.length ? authorIds.length : i + 30,
          ),
        );
      }

      final futures = chunks.map((chunk) {
        Query<Map<String, dynamic>> query = _sketchsRef
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
          .expand((s) => s.docs)
          .map((doc) => SketchPost.fromMap(doc.data()))
          .toList();

      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allPosts;
    }
  }

  Future<List<SketchPost>> getUserPosts({
    required String userId,
    int limit = 18,
    DateTime? lastCreatedAt,
  }) async {
    Query<Map<String, dynamic>> query = _sketchsRef
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

  Future<void> deletePost(String sketchId) async {
    await _sketchsRef.doc(sketchId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleCheer({
    required String sketchId,
    required String userId,
    required bool isCheered,
  }) async {
    final sketchRef = _sketchsRef.doc(sketchId);

    await sketchRef.update({
      'cheeredUserIds': isCheered
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Comment> addComment({
    required String sketchId,
    required Comment comment,
  }) async {
    final batch = _firestore.batch();

    final postRef = _sketchsRef.doc(sketchId);
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

  Future<void> deleteComment({
    required String sketchId,
    required String commentId,
  }) async {
    final batch = _firestore.batch();

    final postRef = _sketchsRef.doc(sketchId);
    final commentRef = _commentsRef(sketchId).doc(commentId);

    batch.update(commentRef, {'deletedAt': FieldValue.serverTimestamp()});
    batch.update(postRef, {
      'commentCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
