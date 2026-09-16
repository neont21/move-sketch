import 'package:flutter/foundation.dart';
import '../../utils/date_time_utils.dart';
import '../enums/activity_type.dart';
import 'user.dart';

@immutable
class SketchPost {
  final String id;
  final String authorId;
  final UserSummary author;
  final String sketchUrl;
  final String? caption;
  final String locationTag;
  final String? weather;
  final ActivityType activityType;
  final Set<String> cheeredUserIds;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const SketchPost({
    required this.id,
    required this.authorId,
    required this.author,
    required this.sketchUrl,
    required this.locationTag,
    required this.activityType,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.caption,
    this.weather,
    this.cheeredUserIds = const {},
    this.commentCount = 0,
  });

  String get sessionId => id;
  int get cheerCount => cheeredUserIds.length;
  bool get isDeleted => deletedAt != null;

  bool isCheeredBy(String userId) => cheeredUserIds.contains(userId);

  SketchPost toggleCheer(String userId) {
    final updated = Set<String>.from(cheeredUserIds);
    if (updated.contains(userId)) {
      updated.remove(userId);
    } else {
      updated.add(userId);
    }
    return copyWith(cheeredUserIds: updated);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'author': author.toMap(),
      'sketchUrl': sketchUrl,
      'caption': caption,
      'locationTag': locationTag,
      'weather': weather,
      'activityType': activityType.name,
      'cheeredUserIds': cheeredUserIds,
      'commentCount': commentCount,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'deletedAt': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory SketchPost.fromMap(Map<String, dynamic> map) {
    final cheeredList =
        (map['cheeredUserIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {};

    return SketchPost(
      id: (map['id'] ?? map['sessionId']) as String,
      authorId: map['authorId'] as String,
      author: UserSummary.fromMap(map['author'] as Map<String, dynamic>),
      sketchUrl: map['sketchUrl'] as String,
      caption: map['caption'] as String?,
      locationTag: map['locationTag'] as String? ?? '',
      weather: map['weather'] as String?,
      activityType: ActivityType.fromString(map['activityType'] as String?),
      cheeredUserIds: cheeredList,
      commentCount: (map['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: parseDateTime(map['createdAt']).toLocal(),
      updatedAt: tryParseDateTime(map['updatedAt'])?.toLocal(),
      deletedAt: tryParseDateTime(map['deletedAt'])?.toLocal(),
    );
  }

  SketchPost copyWith({
    String? id,
    String? authorId,
    UserSummary? author,
    String? sketchUrl,
    ValueGetter<String?>? caption,
    String? locationTag,
    ValueGetter<String?>? weather,
    ActivityType? activityType,
    Set<String>? cheeredUserIds,
    int? commentCount,
    DateTime? createdAt,
    ValueGetter<DateTime?>? updatedAt,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return SketchPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      sketchUrl: sketchUrl ?? this.sketchUrl,
      caption: caption != null ? caption() : this.caption,
      locationTag: locationTag ?? this.locationTag,
      weather: weather != null ? weather() : this.weather,
      activityType: activityType ?? this.activityType,
      cheeredUserIds: cheeredUserIds ?? this.cheeredUserIds,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SketchPost && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
