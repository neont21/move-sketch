import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/enums/inquiry_status.dart';
import '../../../../domain/models/system/inquiry.dart';

/// Firestore `inquiries` 컬렉션에 인앱 문의 및 버그 제보 내역을 저장하고 관리하는 서비스 클래스입니다.
class InquiryService {
  final FirebaseFirestore _firestore;

  InquiryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _inquiriesRef =>
      _firestore.collection('inquiries');

  /// 신규 문의([inquiry])를 서버 타임스탬프와 함께 Firestore에 등록합니다.
  Future<void> createInquiry(Inquiry inquiry) async {
    final data = inquiry.toMap();

    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = null;

    await _inquiriesRef.doc(inquiry.id).set(data);
  }

  /// 접수된 문의 내역 목록을 최신순으로 조회합니다. ([statusFilter] 지정 시 해당 상태만 필터링)
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

  /// 관리자 콘솔에서 특정 문의([inquiryId])의 처리 상태([status]) 및 내부 메모([adminNote])를 갱신합니다.
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
