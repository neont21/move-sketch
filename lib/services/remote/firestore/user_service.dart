import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/social/user.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _accountIdsRef =>
      _firestore.collection('account_ids');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _accountIdsRef.doc(username).get();
    return !doc.exists;
  }

  Future<String?> getEmailByUsername(String username) async {
    final doc = await _accountIdsRef.doc(username).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data()?['email'] as String?;
  }

  Future<void> createUserDocuments({
    required String uid,
    required String username,
    required String nickname,
    required String email,
    String selectedCharacterId = 'bear',
  }) async {
    final batch = _firestore.batch();

    final accountIdRef = _accountIdsRef.doc(username);
    batch.set(accountIdRef, {
      'uid': uid,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final userRef = _usersRef.doc(uid);
    batch.set(userRef, {
      'uid': uid,
      'username': username,
      'nickname': nickname,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'selectedCharacterId': selectedCharacterId,
    });

    await batch.commit();
  }

  Future<void> deleteUserDocuments({
    required String uid,
    required String username,
  }) async {
    final batch = _firestore.batch();

    final accountIdRef = _accountIdsRef.doc(username);
    batch.delete(accountIdRef);

    final userRef = _usersRef.doc(uid);
    batch.update(userRef, {
      'username': 'deleted_$uid',
      'nickname': '탈퇴한 사용자',
      'email': null,
      'imageUrl': null,
      'description': null,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<User?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return User.fromMap(doc.data()!, uid: doc.id);
  }

  Future<User?> getUserProfileByUsername(String username) async {
    final querySnapshot = await _usersRef
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    final doc = querySnapshot.docs.first;
    final user =  User.fromMap(doc.data(), uid: doc.id);

    if (user.isDeleted) {
      return null;
    }

    return user;
  }

  Future<void> updateUserProfile({
    required String uid,
    String? nickname,
    String? description,
    String? imageUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (nickname != null) {
      updates['nickname'] = nickname;
    }
    if (description != null) {
      updates['description'] = description;
    }
    if (imageUrl != null) {
      updates['imageUrl'] = imageUrl;
    }

    await _usersRef.doc(uid).update(updates);
  }

  Future<void> updateCharacterId({
    required String uid,
    required String selectedCharacterId,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    updates['selectedCharacterId'] = selectedCharacterId;
    await _usersRef.doc(uid).update(updates);
  }

  Future<void> updateNotificationSettings({
    required String uid,
    required Map<String, dynamic> settingsMap,
  }) async {
    await _usersRef.doc(uid).update({
      'notificationSettings': settingsMap,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<User>> searchUsers({
    required String query,
    int limit = 20,
    List<String>? excludeUserIds,
  }) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return [];
    }

    final snapshot = await _usersRef
        .where('username', isGreaterThanOrEqualTo: trimmed)
        .where('username', isLessThanOrEqualTo: '$trimmed\uf8ff')
        .limit(limit)
        .get();

    final excludeSet = excludeUserIds?.toSet() ?? {};

    return snapshot.docs
        .map((doc) => User.fromMap(doc.data(), uid: doc.id))
        .where((user) => !user.isDeleted && !excludeSet.contains(user.uid))
        .toList();
  }
}
