import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/date_time_utils.dart';
import '../enums/notification_type.dart';
import 'user.dart';

/// 사용자에게 전달되는 인앱 및 푸시 알림 내역을 나타내는 불변 모델입니다.
@immutable
final class AppNotification {
  /// 알림 고유 식별자.
  final String id;

  /// 알림을 수신할 대상 사용자의 고유 식별자.
  final String recipientId;

  /// 알림을 발생시킨 발신자 요약 정보.
  final UserSummary sender;

  /// 알림 유형.
  final NotificationType type;

  /// 연관된 스케치 게시물의 고유 식별자.
  final String? targetSketchId;

  /// 연관된 댓글의 고유 식별자.
  final String? targetCommentId;

  /// 연관된 공지사항의 고유 식별자.
  final String? targetNoticeId;

  /// 공지사항 알림일 경우 표시할 공지 제목.
  final String? noticeTitle;

  /// 사용자가 해당 알림을 읽었는지 여부.
  final bool isRead;

  /// 알림 생성 일시.
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.sender,
    required this.type,
    required this.createdAt,
    this.targetSketchId,
    this.targetCommentId,
    this.targetNoticeId,
    this.noticeTitle,
    this.isRead = false,
  });

  /// 발신자 사용자의 고유 식별자.
  String get senderUid => sender.uid;

  /// 알림 유형과 발신자 닉네임을 조합하여 UI에 표시할 알림 문구.
  String get message {
    return switch (type) {
      NotificationType.notice => type.notification,
      NotificationType.reminder => type.notification,
      _ => '${sender.nickname} ${type.notification}',
    };
  }

  /// 읽음 상태(`isRead: true`)로 갱신된 새 [AppNotification] 인스턴스를 반환합니다.
  AppNotification markAsRead() => copyWith(isRead: true);

  /// UUID v7 식별자와 현재 시각을 부여하여 신규 [AppNotification]을 생성합니다.
  factory AppNotification.create({
    required String recipientId,
    required UserSummary sender,
    required NotificationType type,
    String? targetSketchId,
    String? targetCommentId,
  }) {
    return AppNotification(
      id: const Uuid().v7(),
      recipientId: recipientId,
      sender: sender,
      type: type,
      targetSketchId: targetSketchId,
      targetCommentId: targetCommentId,
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientId': recipientId,
      'sender': sender.toMap(),
      'type': type.name,
      'targetSketchId': targetSketchId,
      'targetCommentId': targetCommentId,
      'targetNoticeId': targetNoticeId,
      'noticeTitle': noticeTitle,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      recipientId: map['recipientId'] as String,
      sender: UserSummary.fromMap(map['sender'] as Map<String, dynamic>),
      type: NotificationType.fromString(map['type'] as String?),
      targetSketchId: map['targetSketchId'] as String?,
      targetCommentId: map['targetCommentId'] as String?,
      targetNoticeId: map['targetNoticeId'] as String?,
      noticeTitle: map['noticeTitle'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: parseDateTime(map['createdAt']).toLocal(),
    );
  }

  AppNotification copyWith({
    String? id,
    String? recipientId,
    UserSummary? sender,
    NotificationType? type,
    String? targetSketchId,
    String? targetCommentId,
    String? targetNoticeId,
    String? noticeTitle,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      targetSketchId: targetSketchId ?? this.targetSketchId,
      targetCommentId: targetCommentId ?? this.targetCommentId,
      targetNoticeId: targetNoticeId ?? this.targetNoticeId,
      noticeTitle: noticeTitle ?? this.noticeTitle,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          recipientId == other.recipientId &&
          sender == other.sender &&
          type == other.type &&
          targetSketchId == other.targetSketchId &&
          targetCommentId == other.targetCommentId &&
          targetNoticeId == other.targetNoticeId &&
          noticeTitle == other.noticeTitle &&
          isRead == other.isRead &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    recipientId,
    sender,
    type,
    targetSketchId,
    targetCommentId,
    targetNoticeId,
    noticeTitle,
    isRead,
    createdAt,
  );
}
