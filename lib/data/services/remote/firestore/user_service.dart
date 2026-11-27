import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/social/user.dart';

/// Firestore `users` 및 `account_ids` 컬렉션에서 사용자 프로필, 아이디 매핑, 검색 및 계정 탈퇴 처리를 담당하는 서비스 클래스입니다.
class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _accountIdsRef =>
      _firestore.collection('account_ids');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// 지정된 계정 아이디([username])가 아직 사용되지 않아 등록 가능한지 확인합니다.
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _accountIdsRef.doc(username).get();
    return !doc.exists;
  }

  /// 계정 아이디([username])에 매핑된 사용자의 이메일 주소를 조회합니다.
  Future<String?> getEmailByUsername(String username) async {
    final doc = await _accountIdsRef.doc(username).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data()?['email'] as String?;
  }

  /// `account_ids` 매핑 문서와 `users` 프로필 문서를 단일 배치([WriteBatch])로 원자적 생성합니다.
  Future<void> createUserDocuments({
    required String uid,
    required String username,
    required String nickname,
    required String email,
    String selectedCharacterId = 'bear',
    String? imageUrl,
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
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'selectedCharacterId': selectedCharacterId,
    });

    await batch.commit();
  }

  /// 사용자의 이메일 변경 시 `account_ids`와 `users` 두 컬렉션의 이메일 필드를 단일 배치([WriteBatch])로 동기화합니다.
  Future<void> updateAccountEmail({
    required String uid,
    required String username,
    required String email,
  }) async {
    final batch = _firestore.batch();

    final accountIdRef = _accountIdsRef.doc(username);
    batch.update(accountIdRef, {'email': email});

    final userRef = _usersRef.doc(uid);
    batch.update(userRef, {
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// 회원 탈퇴 시 `account_ids` 매핑은 즉시 삭제하고 `users` 문서의 개인정보는 익명화하여 소프트 딜리트 처리합니다.
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

  /// 사용자 고유 식별자([uid])로 프로필 문서를 조회하여 [User]로 반환합니다. ([source]로 캐시/서버 조회 전략 지정 가능)
  Future<User?> getUserProfile(
    String uid, {
    Source source = Source.serverAndCache,
  }) async {
    final doc = await _usersRef.doc(uid).get(GetOptions(source: source));
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return User.fromMap(doc.data()!, uid: doc.id);
  }

  /// 계정 아이디([username])로 활성 사용자의 프로필을 조회합니다.
  Future<User?> getUserProfileByUsername(String username) async {
    final querySnapshot = await _usersRef
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    final doc = querySnapshot.docs.first;
    final user = User.fromMap(doc.data(), uid: doc.id);

    if (user.isDeleted) {
      return null;
    }

    return user;
  }

  /// 다수의 사용자 식별자([uids])에 해당하는 [UserSummary] 목록을 일괄 조회합니다.
  ///
  /// Firestore `whereIn` 절 최대 30개 제한을 준수하기 위해 30개 단위 청크로 분할해 병렬 조회하며,
  /// [includeDeleted]가 `false`인 경우 탈퇴 계정은 결과에서 제외합니다.
  Future<List<UserSummary>> getUserSummaries(
    List<String> uids, {
    bool includeDeleted = false,
  }) async {
    final uniqueUids = uids.toSet().toList();
    if (uniqueUids.isEmpty) {
      return [];
    }

    final chunks = <List<String>>[];
    for (var index = 0; index < uniqueUids.length; index += 30) {
      chunks.add(
        uniqueUids.sublist(
          index,
          index + 30 > uniqueUids.length ? uniqueUids.length : index + 30,
        ),
      );
    }

    final futures = chunks.map((chunk) {
      return _usersRef.where(FieldPath.documentId, whereIn: chunk).get();
    });

    final snapshots = await Future.wait(futures);
    return snapshots
        .expand((snapshot) => snapshot.docs)
        .map((doc) => User.fromMap(doc.data(), uid: doc.id))
        .where((user) => includeDeleted || !user.isDeleted)
        .map((user) => user.toSummary())
        .toList();
  }

  /// 사용자([uid])의 프로필 필드 중 전달된 항목만 부분 갱신합니다.
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

  /// 사용자([uid])가 선택한 대표 파트너 캐릭터 식별자([selectedCharacterId])를 갱신합니다.
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

  /// 사용자([uid])의 푸시 알림 및 리마인더 설정 맵([settingsMap])을 갱신합니다.
  Future<void> updateNotificationSettings({
    required String uid,
    required Map<String, dynamic> settingsMap,
  }) async {
    await _usersRef.doc(uid).update({
      'notificationSettings': settingsMap,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 검색어([query])를 접두사 범위 쿼리(`\uf8ff`)로 매칭하여 아이디 또는 닉네임이 일치하는 사용자 목록을 반환합니다.
  ///
  /// 탈퇴한 계정 및 [excludeUserIds]에 포함된 사용자는 결과에서 제외됩니다.
  Future<List<UserSummary>> searchUsers({
    required String query,
    int limit = 20,
    List<String>? excludeUserIds,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final lowercased = trimmed.toLowerCase();

    final snapshots = await Future.wait([
      _usersRef
          .where('username', isGreaterThanOrEqualTo: lowercased)
          .where('username', isLessThanOrEqualTo: '$lowercased\uf8ff')
          .limit(limit)
          .get(),
      _usersRef
          .where('nickname', isGreaterThanOrEqualTo: trimmed)
          .where('nickname', isLessThanOrEqualTo: '$trimmed\uf8ff')
          .limit(limit)
          .get(),
    ]);

    final excludeSet = excludeUserIds?.toSet() ?? {};
    final userMap = <String, User>{};

    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        if (!userMap.containsKey(doc.id)) {
          final user = User.fromMap(doc.data(), uid: doc.id);
          if (!user.isDeleted && !excludeSet.contains(user.uid)) {
            userMap[doc.id] = user;
          }
        }
      }
    }

    return userMap.values.take(limit).map((user) => user.toSummary()).toList();
  }

  /// 사용자([uid])의 현재 기기 FCM 푸시 토큰([fcmToken])을 갱신합니다.
  Future<void> updateFcmToken({
    required String uid,
    required String? fcmToken,
  }) async {
    await _usersRef.doc(uid).update({
      'fcmToken': fcmToken,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
