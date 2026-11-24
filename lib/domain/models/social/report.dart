import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/date_time_utils.dart';
import '../enums/report_status.dart';
import '../enums/report_type.dart';
import 'user.dart';

/// 부적절한 사용자, 스케치 게시물 또는 댓글에 대한 신고 접수 내역을 나타내는 불변 모델입니다.
@immutable
final class Report {
  /// 신고 고유 식별자.
  final String id;

  /// 신고 대상 사용자의 요약 정보.
  final UserSummary targetUser;

  /// 신고를 접수한 사용자의 요약 정보.
  final UserSummary reporter;

  /// 신고 대상이 스케치 게시물인 경우 해당 게시물 식별자.
  final String? sketchId;

  /// 신고 대상이 댓글인 경우 해당 댓글 식별자.
  final String? commentId;

  /// 신고 사유 유형.
  final ReportType reportType;

  /// 신고자가 추가로 작성한 상세 신고 사유.
  final String? description;

  /// 관리자의 신고 접수 및 처리 대응 상태.
  final ReportStatus status;

  /// 신고 접수 일시.
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.targetUser,
    required this.reporter,
    required this.reportType,
    required this.createdAt,
    this.status = ReportStatus.unconfirmed,
    this.sketchId,
    this.commentId,
    this.description,
  });

  /// UUID v7 식별자와 현재 시각을 부여하여 신규 [Report]를 생성합니다.
  ///
  /// 상세 설명([description])은 공백 제거 후 빈 문자열인 경우 `null`로 정규화됩니다.
  factory Report.create({
    required UserSummary targetUser,
    required UserSummary reporter,
    required ReportType reportType,
    String? sketchId,
    String? commentId,
    String? description,
  }) {
    return Report(
      id: const Uuid().v7(),
      targetUser: targetUser,
      reporter: reporter,
      reportType: reportType,
      sketchId: sketchId,
      commentId: commentId,
      description: description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      status: ReportStatus.unconfirmed,
      createdAt: DateTime.now(),
    );
  }

  factory Report.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Report(
      id: documentId ?? (map['id'] as String? ?? ''),
      targetUser: UserSummary.fromMap(
        map['targetUser'] as Map<String, dynamic>? ?? const {},
      ),
      reporter: UserSummary.fromMap(
        map['reporter'] as Map<String, dynamic>? ?? const {},
      ),
      reportType: ReportType.fromString(map['reportType'] as String?),
      status: ReportStatus.fromString(map['status'] as String?),
      sketchId: map['sketchId'] as String?,
      commentId: map['commentId'] as String?,
      description: map['description'] as String?,
      createdAt: parseDateTime(map['createdAt']).toLocal(),
    );
  }

  Report copyWith({ReportStatus? status, String? description}) {
    return Report(
      id: id,
      targetUser: targetUser,
      reporter: reporter,
      reportType: reportType,
      status: status ?? this.status,
      sketchId: sketchId,
      commentId: commentId,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetUser': targetUser.toMap(),
      'reporter': reporter.toMap(),
      'sketchId': sketchId,
      'commentId': commentId,
      'reportType': reportType.name,
      'description': description,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Report &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          targetUser == other.targetUser &&
          reporter == other.reporter &&
          sketchId == other.sketchId &&
          commentId == other.commentId &&
          reportType == other.reportType &&
          description == other.description &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    targetUser,
    reporter,
    sketchId,
    commentId,
    reportType,
    description,
    status,
    createdAt,
  );
}
