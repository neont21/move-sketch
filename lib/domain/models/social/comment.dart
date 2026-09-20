import 'package:flutter/foundation.dart';
import '../../../utils/date_time_utils.dart';
import 'user.dart';

@immutable
class Comment {
  final String id;
  final String sketchId;
  final UserSummary author;
  final String text;
  final String? parentCommentId;
  final DateTime createdAt;
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

  bool get isReply => parentCommentId != null && parentCommentId!.isNotEmpty;
  String get authorUid => author.uid;
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sketchId': sketchId,
      'author': author.toMap(),
      'text': text,
      'parentCommentId': parentCommentId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'deletedAt': deletedAt?.toUtc().toIso8601String(),
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
      parentCommentId: parentCommentId != null ? parentCommentId() : this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
