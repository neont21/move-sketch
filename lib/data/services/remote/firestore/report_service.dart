import 'package:cloud_firestore/cloud_firestore.dart';
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
}
