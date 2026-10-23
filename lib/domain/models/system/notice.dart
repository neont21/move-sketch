import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/date_time_utils.dart';

@immutable
final class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? actionUrl;
  final String? actionButtonText;
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
}
