import 'package:flutter/foundation.dart';
import '../../../utils/date_time_utils.dart';
import '../enums/notification_type.dart';
import 'user.dart';

@immutable
class AppNotification {
  final String id;
  final String recipientId;
  final UserSummary sender;
  final NotificationType type;
  final String? targetPostId;
  final String? targetCommentId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.sender,
    required this.type,
    required this.createdAt,
    this.targetPostId,
    this.targetCommentId,
    this.isRead = false,
  });

  String get senderUid => sender.uid;
  String get message => '${sender.nickname} ${type.notification}';

  AppNotification markAsRead() => copyWith(isRead: true);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientId': recipientId,
      'sender': sender.toMap(),
      'type': type.name,
      'targetPostId': targetPostId,
      'targetCommentId': targetCommentId,
      'isRead': isRead,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      recipientId: map['recipientId'] as String,
      sender: UserSummary.fromMap(map['sender'] as Map<String, dynamic>),
      type: NotificationType.fromString(map['type'] as String?),
      targetPostId: map['targetPostId'] as String?,
      targetCommentId: map['targetCommentId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: parseDateTime(map['createdAt']).toLocal(),
    );
  }

  AppNotification copyWith({
    String? id,
    String? recipientId,
    UserSummary? sender,
    NotificationType? type,
    String? targetPostId,
    String? targetCommentId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      targetPostId: targetPostId ?? this.targetPostId,
      targetCommentId: targetCommentId ?? this.targetCommentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
