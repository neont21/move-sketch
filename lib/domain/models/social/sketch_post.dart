import 'package:flutter/foundation.dart';
import '../../../utils/date_time_utils.dart';
import '../enums/activity_type.dart';
import '../weather/weather_info.dart';
import 'user.dart';

@immutable
class SketchPost {
  final String id;
  final String authorId;
  final UserSummary author;
  final String sketchUrl;
  final String? caption;
  final List<String> locationTags;
  final int locationIndex;
  final WeatherInfo? weather;
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
    required this.locationTags,
    required this.locationIndex,
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

  String get locationTag => locationTags.length > locationIndex
      ? locationTags[locationIndex]
      : (locationTags.firstOrNull ?? '');

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
      'locationTags': locationTags,
      'locationIndex': locationIndex,
      'weather': weather?.toMap(),
      'activityType': activityType.name,
      'cheeredUserIds': cheeredUserIds.toList(),
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
      locationTags: (map['locationTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          (map['locationTag'] != null ? [map['locationTag'] as String] : const []),
      locationIndex: (map['locationIndex'] as num?)?.toInt() ?? 0,
      weather: map['weather'] != null
          ? WeatherInfo.fromMap(map['weather'] as Map<String, dynamic>)
          : null,
      activityType: ActivityType.fromString(map['activityType'] as String?),
      cheeredUserIds: cheeredList.toSet(),
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
    List<String>? locationTags,
    int? locationIndex,
    ValueGetter<WeatherInfo?>? weather,
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
      locationTags: locationTags ?? this.locationTags,
      locationIndex: locationIndex ?? this.locationIndex,
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
