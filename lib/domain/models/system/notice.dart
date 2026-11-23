import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/date_time_utils.dart';

/// 전체 사용자에게 공지되는 시스템 공지사항 정보를 나타내는 불변 모델입니다.
@immutable
final class Notice {
  /// 공지사항 고유 식별자.
  final String id;

  /// 공지사항 제목.
  final String title;

  /// 공지사항 본문 내용.
  final String content;

  /// 공지사항 작성 및 게시 일시.
  final DateTime createdAt;

  /// 외부 웹 페이지 또는 딥링크 이동을 위한 액션 URL.
  final String? actionUrl;

  /// 액션 링크 버튼에 표시될 레이블 텍스트.
  final String? actionButtonText;

  /// 중요 공지 여부.
  final bool isImportant;

  const Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.actionUrl,
    this.actionButtonText,
    this.isImportant = false,
  });

  /// 관리자의 입력값으로부터 UUID v7 식별자와 현재 시각을 부여하여 신규 [Notice]를 생성합니다.
  ///
  /// [actionUrl]과 [actionButtonText]는 공백 문자열인 경우 `null`로 정규화됩니다.
  factory Notice.create({
    required String title,
    required String content,
    String? actionUrl,
    String? actionButtonText,
    bool isImportant = false,
  }) {
    return Notice(
      id: const Uuid().v7(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      actionUrl: actionUrl?.trim().isEmpty == true ? null : actionUrl?.trim(),
      actionButtonText: actionButtonText?.trim().isEmpty == true
          ? null
          : actionButtonText?.trim(),
      isImportant: isImportant,
    );
  }

  factory Notice.fromMap(Map<String, dynamic> map, String documentId) {
    return Notice(
      id: documentId,
      title: map['title'] as String? ?? '공지사항',
      content: map['content'] as String? ?? '',
      createdAt: parseDateTime(map['createdAt']),
      actionUrl: map['actionUrl'] as String?,
      actionButtonText: map['actionButtonText'] as String?,
      isImportant: map['isImportant'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (actionButtonText != null) 'actionButtonText': actionButtonText,
      'isImportant': isImportant,
    };
  }

  Notice copyWith({
    String? title,
    String? content,
    String? actionUrl,
    String? actionButtonText,
    bool? isImportant,
  }) {
    return Notice(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      actionUrl: actionUrl ?? this.actionUrl,
      actionButtonText: actionButtonText ?? this.actionButtonText,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          createdAt == other.createdAt &&
          actionUrl == other.actionUrl &&
          actionButtonText == other.actionButtonText &&
          isImportant == other.isImportant;
  @override
  int get hashCode => Object.hash(
    id,
    title,
    content,
    createdAt,
    actionUrl,
    actionButtonText,
    isImportant,
  );
}
