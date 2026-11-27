import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/system/notice.dart';

/// Firestore `notices` 컬렉션의 시스템 공지사항 조회·등록·수정·삭제를 처리하는 서비스 클래스입니다.
class NoticeService {
  final FirebaseFirestore _firestore;

  NoticeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _noticesRef =>
      _firestore.collection('notices');

  /// 공지사항 고유 식별자([noticeId])에 해당하는 단건 공지를 조회하여 [Notice]로 반환합니다.
  Future<Notice?> getNoticeById(String noticeId) async {
    final doc = await _noticesRef.doc(noticeId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Notice.fromMap(doc.data()!, doc.id);
  }

  /// 최신 공지사항 목록(최대 50건)을 작성 일시 내림차순으로 조회합니다.
  Future<List<Notice>> getAllNotices() async {
    final snapshot = await _noticesRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((document) => Notice.fromMap(document.data(), document.id))
        .toList();
  }

  /// 신규 공지사항([notice])을 생성하여 저장합니다.
  Future<void> createNotice(Notice notice) async {
    if (notice.id.isNotEmpty) {
      await _noticesRef.doc(notice.id).set(notice.toMap());
    } else {
      await _noticesRef.add(notice.toMap());
    }
  }

  /// 기존 공지사항([notice])의 내용을 수정합니다.
  Future<void> updateNotice(Notice notice) async {
    await _noticesRef.doc(notice.id).update(notice.toMap());
  }

  /// 지정된 공지사항([noticeId])을 Firestore에서 삭제합니다.
  Future<void> deleteNotice(String noticeId) async {
    await _noticesRef.doc(noticeId).delete();
  }
}
