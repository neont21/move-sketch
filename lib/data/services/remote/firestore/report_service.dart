import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/enums/report_status.dart';
import '../../../../domain/models/social/report.dart';

class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  Future<void> submitReport(Report report) async {
    final data = report.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _reportsRef.doc(report.id).set(data);
  }

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

  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    await _reportsRef.doc(reportId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
