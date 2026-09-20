import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/social/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

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

    return snapshot.docs
        .map((doc) => AppNotification.fromMap(doc.data()))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({
      'isRead': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

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

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRef.doc(notificationId).delete();
  }

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

  Future<bool> hasUnreadNotifications(String userId) async {
    final snapshot = await _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
