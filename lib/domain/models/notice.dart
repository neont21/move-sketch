import 'package:flutter/foundation.dart';

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

  factory Notice.fromMap(Map<String, dynamic> map, String documentId) {
    return Notice(
      id: documentId,
      title: map['title'] as String? ?? '공지사항',
      content: map['content'] as String? ?? '',
      createdAt: (map['createdAt'] != null)
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      actionUrl: map['actionUrl'] as String?,
      actionButtonText: map['actionButtonText'] as String?,
      isImportant: map['isImportant'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (actionButtonText != null) 'actionButtonText': actionButtonText,
      'isImportant': isImportant,
    };
  }
}
