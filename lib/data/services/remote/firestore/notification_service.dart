import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/social/app_notification.dart';

/// Firestore `notifications` 컬렉션에서 사용자 알림의 생성·조회·읽음 처리 및 삭제를 담당하는 서비스 클래스입니다.
class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  /// 신규 알림([notification])을 서버 타임스탬프와 함께 저장하고 생성된 [AppNotification]을 반환합니다.
  ///
  /// 수신자와 발신자가 동일한 자기 자신 대상 알림인 경우 생성하지 않고 `null`을 반환합니다.
  Future<AppNotification?> createNotification(
    AppNotification notification,
  ) async {
    if (notification.recipientId == notification.senderUid) {
      return null;
    }

    final docRef = notification.id.isEmpty
        ? _notificationsRef.doc()
        : _notificationsRef.doc(notification.id);

    final data = notification.toMap();
    data['id'] = docRef.id;
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);

    final savedDoc = await docRef.get();
    return AppNotification.fromMap(savedDoc.data()!);
  }

  /// 지정된 사용자([userId])의 알림 목록을 커서 기반 페이지네이션([lastCreatedAt])으로 최신순 조회합니다.
  Future<List<AppNotification>> getNotifications({
    required String userId,
    int limit = 30,
    DateTime? lastCreatedAt,
  }) async {
    Query<Map<String, dynamic>> query = _notificationsRef.where(
      'recipientId',
      isEqualTo: userId,
    );

    if (lastCreatedAt != null) {
      query = query.where(
        'createdAt',
        isLessThan: Timestamp.fromDate(lastCreatedAt),
      );
    }

    final snapshot = await query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppNotification.fromMap(data);
    }).toList();
  }

  /// 지정된 사용자([userId])에게 읽지 않은 알림이 1건 이상 존재하는지 실시간 스트림으로 감시합니다.
  Stream<bool> watchHasUnreadNotifications(String userId) {
    return _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  /// 단건 알림([notificationId])을 읽음 상태로 갱신합니다.
  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({
      'isRead': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 지정된 사용자([userId])의 미읽음 알림(배치 한도 최대 500건)을 일괄 읽음 처리합니다.
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .limit(500)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// 지정된 알림([notificationId])을 삭제합니다.
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRef.doc(notificationId).delete();
  }

  /// 지정된 사용자([userId])의 이미 읽은 알림(배치 한도 최대 500건)을 일괄 삭제합니다.
  Future<void> deleteReadNotifications(String userId) async {
    final snapshot = await _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: true)
        .limit(500)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// 지정된 사용자([userId])에게 읽지 않은 알림이 존재하는지 단발성으로 확인합니다.
  Future<bool> hasUnreadNotifications(String userId) async {
    final snapshot = await _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
