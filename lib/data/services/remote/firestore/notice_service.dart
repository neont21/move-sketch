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
}
