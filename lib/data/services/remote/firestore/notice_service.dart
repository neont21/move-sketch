import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/notice.dart';

class NoticeService {
  final FirebaseFirestore _firestore;

  NoticeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _noticesRef =>
      _firestore.collection('notices');

  Future<Notice?> getNoticeById(String noticeId) async {
    final doc = await _noticesRef.doc(noticeId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Notice.fromMap(doc.data()!, doc.id);
  }

  Future<List<Notice>> getAllNotices() async {
    final snapshot = await _noticesRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((document) => Notice.fromMap(document.data(), document.id))
        .toList();
  }

  Future<void> createNotice(Notice notice) async {
    if (notice.id.isNotEmpty) {
      await _noticesRef.doc(notice.id).set(notice.toMap());
    } else {
      await _noticesRef.add(notice.toMap());
    }
  }

  Future<void> updateNotice(Notice notice) async {
    await _noticesRef.doc(notice.id).update(notice.toMap());
  }

  Future<void> deleteNotice(String noticeId) async {
    await _noticesRef.doc(noticeId).delete();
  }
}
