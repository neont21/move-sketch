import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/date_time_utils.dart';
import 'user.dart';

/// 스케치 게시물에 작성된 댓글 및 답글을 나타내는 불변 모델입니다.
@immutable
final class Comment {
  /// 댓글 고유 식별자.
  final String id;

  /// 댓글이 달린 대상 스케치 게시물의 고유 식별자.
  final String sketchId;

  /// 댓글 작성자 요약 정보.
  final UserSummary author;

  /// 댓글 본문 내용.
  final String text;

  /// 답글인 경우 상위 부모 댓글의 고유 식별자.
  final String? parentCommentId;

  /// 댓글 최초 작성 일시.
  final DateTime createdAt;

  /// 논리 삭제 일시.
  final DateTime? deletedAt;

  const Comment({
    required this.id,
    required this.sketchId,
    required this.author,
    required this.text,
    required this.createdAt,
    this.parentCommentId,
    this.deletedAt,
  });

  /// UUID v7 식별자와 현재 시각을 부여하여 신규 [Comment]를 생성합니다.
  factory Comment.create({
    required String sketchId,
    required UserSummary author,
    required String text,
    String? parentCommentId,
  }) {
    return Comment(
      id: const Uuid().v7(),
      sketchId: sketchId,
      author: author,
      text: text,
      parentCommentId: parentCommentId,
      createdAt: DateTime.now(),
    );
  }

  /// 다른 댓글에 종속된 답글인지 여부.
  bool get isReply => parentCommentId != null && parentCommentId!.isNotEmpty;

  /// 댓글 작성자의 고유 식별자.
  String get authorId => author.uid;

  /// 논리적으로 삭제 처리된 댓글인지 여부.
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sketchId': sketchId,
      'author': author.toMap(),
      'text': text,
      'parentCommentId': parentCommentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      sketchId: map['sketchId'] as String,
      author: UserSummary.fromMap(map['author'] as Map<String, dynamic>),
      text: map['text'] as String,
      parentCommentId: map['parentCommentId'] as String?,
      createdAt: parseDateTime(map['createdAt']).toLocal(),
      deletedAt: tryParseDateTime(map['deletedAt'])?.toLocal(),
    );
  }

  Comment copyWith({
    String? id,
    String? sketchId,
    UserSummary? author,
    String? text,
    ValueGetter<String?>? parentCommentId,
    DateTime? createdAt,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      sketchId: sketchId ?? this.sketchId,
      author: author ?? this.author,
      text: text ?? this.text,
      parentCommentId: parentCommentId != null
          ? parentCommentId()
          : this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sketchId == other.sketchId &&
          author == other.author &&
          text == other.text &&
          parentCommentId == other.parentCommentId &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(
    id,
    sketchId,
    author,
    text,
    parentCommentId,
    createdAt,
    deletedAt,
  );
}
