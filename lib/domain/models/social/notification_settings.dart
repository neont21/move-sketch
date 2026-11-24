import 'package:flutter/foundation.dart';

/// 사용자의 푸시 알림 수신 여부 및 운동 리마인더 스케줄 설정을 나타내는 불변 모델입니다.
@immutable
final class NotificationSettings {
  /// 전체 푸시 알림 마스터 활성화 여부.
  final bool pushEnabled;

  /// 친구 요청 및 수락 알림 수신 여부.
  final bool friendNotification;

  /// 내 스케치에 대한 응원 및 댓글 반응 알림 수신 여부.
  final bool responseNotification;

  /// 친구의 새로운 스케치 게시물 업로드 알림 수신 여부.
  final bool sketchNotification;

  /// 정기 운동 리마인더 로컬 알림 활성화 여부.
  final bool reminderNotification;

  /// 리마인더 알림을 수신할 요일 집합. (ISO-8601 기준: 1=월요일 ~ 7=일요일)
  final Set<int> reminderDays;

  /// 리마인더 알림을 발송할 시간. (24시간 기준 0~23)
  final int reminderHour;

  const NotificationSettings({
    this.pushEnabled = true,
    this.friendNotification = true,
    this.responseNotification = true,
    this.sketchNotification = true,
    this.reminderNotification = false,
    this.reminderDays = const {1, 2, 3, 4, 5},
    this.reminderHour = 19,
  });

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'friendNotification': friendNotification,
      'responseNotification': responseNotification,
      'sketchNotification': sketchNotification,
      'reminderNotification': reminderNotification,
      'reminderDays': reminderDays.toList()..sort(),
      'reminderHour': reminderHour,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushEnabled: map['pushEnabled'] as bool? ?? true,
      friendNotification: map['friendNotification'] as bool? ?? true,
      responseNotification: map['responseNotification'] as bool? ?? true,
      sketchNotification: map['sketchNotification'] as bool? ?? true,
      reminderNotification: map['reminderNotification'] as bool? ?? false,
      reminderDays:
          (map['reminderDays'] as List<dynamic>?)
              ?.map((day) => (day as num).toInt())
              .toSet() ??
          const {1, 2, 3, 4, 5},
      reminderHour: (map['reminderHour'] as num?)?.toInt() ?? 19,
    );
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? friendNotification,
    bool? responseNotification,
    bool? sketchNotification,
    bool? reminderNotification,
    Set<int>? reminderDays,
    int? reminderHour,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      friendNotification: friendNotification ?? this.friendNotification,
      responseNotification: responseNotification ?? this.responseNotification,
      sketchNotification: sketchNotification ?? this.sketchNotification,
      reminderNotification: reminderNotification ?? this.reminderNotification,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderHour: reminderHour ?? this.reminderHour,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          pushEnabled == other.pushEnabled &&
          friendNotification == other.friendNotification &&
          responseNotification == other.responseNotification &&
          sketchNotification == other.sketchNotification &&
          reminderNotification == other.reminderNotification &&
          reminderHour == other.reminderHour &&
          setEquals(reminderDays, other.reminderDays);

  @override
  int get hashCode => Object.hash(
    pushEnabled,
    friendNotification,
    responseNotification,
    sketchNotification,
    reminderNotification,
    Object.hashAllUnordered(reminderDays),
    reminderHour,
  );
}
