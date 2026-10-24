import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/enums/inquiry_status.dart';
import '../../../../domain/models/system/inquiry.dart';

class InquiryService {
  final FirebaseFirestore _firestore;

  InquiryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _inquiriesRef =>
      _firestore.collection('inquiries');

  Future<void> createInquiry(Inquiry inquiry) async {
    final data = inquiry.toMap();

    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = null;

    await _inquiriesRef.doc(inquiry.id).set(data);
  }

  Future<List<Inquiry>> getInquiries({InquiryStatus? statusFilter}) async {
    Query<Map<String, dynamic>> query = _inquiriesRef;

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.name);
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => Inquiry.fromMap(doc.data(), documentId: doc.id))
        .toList();
  }

  Future<void> updateInquiryStatus(
    String inquiryId,
    InquiryStatus status, {
    String? adminNote,
  }) async {
    final updatePayload = {
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (adminNote != null) {
      updatePayload['adminNote'] = adminNote;
    }

    await _inquiriesRef.doc(inquiryId).update(updatePayload);
  }
}
