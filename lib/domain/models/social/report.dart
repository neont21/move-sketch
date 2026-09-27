import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
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
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.targetUser,
    required this.reporter,
    required this.reportType,
    required this.createdAt,
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
      description: description?.trim().isEmpty == true ? null : description?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetUser': targetUser.toMap(),
      'reporter': reporter.toMap(),
      'sketchId': sketchId,
      'commentId': commentId,
      'reportType': reportType.label,
      'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}