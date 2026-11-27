import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/enums/report_status.dart';
import '../../../../domain/models/social/report.dart';

/// Firestore `reports` 컬렉션에 신고 내역을 접수하고 관리자 콘솔에서 조회·상태 변경을 처리하는 서비스 클래스입니다.
class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  /// 신규 신고 내역([report])을 서버 타임스탬프와 함께 Firestore에 등록합니다.
  Future<void> submitReport(Report report) async {
    final data = report.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _reportsRef.doc(report.id).set(data);
  }

  /// 접수된 신고 내역 목록을 최신순으로 조회합니다. ([statusFilter] 지정 시 해당 상태만 필터링)
  Future<List<Report>> getReports({ReportStatus? statusFilter}) async {
    Query<Map<String, dynamic>> query = _reportsRef;
    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.name);
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => Report.fromMap(doc.data(), documentId: doc.id))
        .toList();
  }

  /// 관리자 콘솔에서 특정 신고 건([reportId])의 처리 상태([status])를 갱신합니다.
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    await _reportsRef.doc(reportId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
