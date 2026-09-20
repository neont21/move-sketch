import 'package:flutter/foundation.dart';

@immutable
class NotificationSettings {
  final bool pushEnabled;
  final bool friendNotification;
  final bool responseNotification;
  final bool reminderNotification;
  final Set<int> reminderDays;
  final int reminderHour;

  const NotificationSettings({
    this.pushEnabled = true,
    this.friendNotification = true,
    this.responseNotification = true,
    this.reminderNotification = false,
    this.reminderDays = const {1, 2, 3, 4, 5},
    this.reminderHour = 19,
  });

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'friendNotification': friendNotification,
      'responseNotification': responseNotification,
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
      reminderNotification: map['reminderNotification'] as bool? ?? false,
      reminderDays:
          (map['reminderDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toSet() ??
          const {1, 2, 3, 4, 5},
      reminderHour: (map['reminderHour'] as num?)?.toInt() ?? 19,
    );
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? friendNotification,
    bool? responseNotification,
    bool? reminderNotification,
    Set<int>? reminderDays,
    int? reminderHour,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      friendNotification: friendNotification ?? this.friendNotification,
      responseNotification: responseNotification ?? this.responseNotification,
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
              reminderNotification == other.reminderNotification &&
              reminderHour == other.reminderHour &&
              setEquals(reminderDays, other.reminderDays);
  @override
  int get hashCode => Object.hash(
    pushEnabled,
    friendNotification,
    responseNotification,
    reminderNotification,
    Object.hashAllUnordered(reminderDays),
    reminderHour,
  );
}
