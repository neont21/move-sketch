import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/date_time_utils.dart';
import '../enums/activity_type.dart';
import '../weather/weather_info.dart';
import 'user.dart';

/// 소셜 피드에 공유된 사용자의 운동 스케치 게시물을 나타내는 불변 모델입니다.
@immutable
final class SketchPost {
  /// 게시물 고유 식별자.
  final String id;

  /// 게시물 작성자의 고유 식별자. (Firebase 쿼리용)
  final String authorId;

  /// 게시물 작성자의 요약 정보.
  final UserSummary author;

  /// 원격 스토리지에 업로드된 스케치 이미지 URL.
  final String sketchUrl;

  /// 사용자가 작성한 게시물 한 줄 소감 문구.
  final String? caption;

  /// 세션 경로가 속한 행정구역 또는 지역 위치 태그 후보 목록.
  final List<String> locationTags;

  /// [locationTags] 중 사용자가 대표로 노출하기로 선택한 위치 태그의 인덱스.
  final int locationIndex;

  /// 운동 당시 관측된 기상 정보.
  final WeatherInfo? weather;

  /// 운동 활동 종목.
  final ActivityType activityType;

  /// 이 게시물에 응원을 누른 사용자들의 고유 식별자 집합.
  final Set<String> cheeredUserIds;

  /// 게시물에 달린 누적 댓글 수.
  final int commentCount;

  /// 스케치 이미지 하단에 사용자 닉네임 서명을 포함했는지 여부.
  final bool useSignature;

  /// 이동 경로의 구글 인코딩 폴리라인(Encoded Polyline) 문자열.
  final String? routePolyline;

  /// 게시물 최초 작성 일시.
  final DateTime createdAt;

  /// 게시물 최종 수정 일시.
  final DateTime? updatedAt;

  /// 논리 삭제 일시.
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
    this.useSignature = false,
    this.routePolyline,
  });

  /// 연계된 원본 운동 세션의 고유 식별자.
  String get sessionId => id;

  /// 게시물이 받은 총 응원 수.
  int get cheerCount => cheeredUserIds.length;

  /// 논리적으로 삭제 처리된 게시물인지 여부.
  bool get isDeleted => deletedAt != null;

  /// [locationIndex]에 해당하는 현재 대표 지역 위치 태그.
  String get locationTag => locationTags.length > locationIndex
      ? locationTags[locationIndex]
      : (locationTags.firstOrNull ?? '');

  /// 지정된 사용자([userId])가 이 게시물을 응원했는지 판별합니다.
  bool isCheeredBy(String userId) => cheeredUserIds.contains(userId);

  /// 지정된 사용자([userId])의 응원 상태를 토글한 새 [SketchPost] 인스턴스를 반환합니다.
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
      'useSignature': useSignature,
      'routePolyline': routePolyline,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory SketchPost.fromMap(Map<String, dynamic> map) {
    final cheeredList =
        (map['cheeredUserIds'] as List<dynamic>?)
            ?.map((userId) => userId as String)
            .toSet() ??
        {};

    return SketchPost(
      id: (map['id'] ?? map['sessionId']) as String,
      authorId: map['authorId'] as String,
      author: UserSummary.fromMap(map['author'] as Map<String, dynamic>),
      sketchUrl: map['sketchUrl'] as String,
      caption: map['caption'] as String?,
      locationTags:
          (map['locationTags'] as List<dynamic>?)
              ?.map((tag) => tag as String)
              .toList() ??
          (map['locationTag'] != null
              ? [map['locationTag'] as String]
              : const []),
      locationIndex: (map['locationIndex'] as num?)?.toInt() ?? 0,
      weather: map['weather'] != null
          ? WeatherInfo.fromMap(map['weather'] as Map<String, dynamic>)
          : null,
      activityType: ActivityType.fromString(map['activityType'] as String?),
      cheeredUserIds: cheeredList.toSet(),
      commentCount: (map['commentCount'] as num?)?.toInt() ?? 0,
      useSignature: (map['useSignature'] as bool?) ?? false,
      routePolyline: map['routePolyline'] as String?,
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
    bool? useSignature,
    String? routePolyline,
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
      useSignature: useSignature ?? this.useSignature,
      routePolyline: routePolyline ?? this.routePolyline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SketchPost &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          authorId == other.authorId &&
          author == other.author &&
          sketchUrl == other.sketchUrl &&
          caption == other.caption &&
          listEquals(locationTags, other.locationTags) &&
          locationIndex == other.locationIndex &&
          weather == other.weather &&
          activityType == other.activityType &&
          setEquals(cheeredUserIds, other.cheeredUserIds) &&
          commentCount == other.commentCount &&
          useSignature == other.useSignature &&
          routePolyline == other.routePolyline &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(
    id,
    authorId,
    author,
    sketchUrl,
    caption,
    Object.hashAll(locationTags),
    locationIndex,
    weather,
    activityType,
    Object.hashAllUnordered(cheeredUserIds),
    commentCount,
    useSignature,
    routePolyline,
    createdAt,
    updatedAt,
    deletedAt,
  );
}
