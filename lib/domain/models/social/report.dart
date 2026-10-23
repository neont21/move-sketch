import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/date_time_utils.dart';
import '../enums/report_status.dart';
import '../enums/report_type.dart';
import 'user.dart';

@immutable
class Report {
  final String id;
  final UserSummary targetUser;
  final UserSummary reporter;
  final String? sketchId;
  final String? commentId;
  final ReportType reportType;
  final String? description;
  final ReportStatus status;
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
}
