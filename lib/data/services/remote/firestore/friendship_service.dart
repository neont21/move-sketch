import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../domain/models/social/block_status.dart';
import '../../../../domain/models/enums/friendship_status.dart';
import '../../../../domain/models/social/friendship.dart';
import '../../../../utils/exceptions.dart';

/// Firestore `friendships` 및 `blocks` 컬렉션에 접근하여 친구 관계와 사용자 차단을 관리하는 서비스 클래스입니다.
class FriendshipService {
  final FirebaseFirestore _firestore;

  FriendshipService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _friendshipsRef =>
      _firestore.collection('friendships');

  CollectionReference<Map<String, dynamic>> get _blocksRef =>
      _firestore.collection('blocks');

  /// 두 사용자 식별자([uid1], [uid2])를 사전순 정렬하여 결정론적인 단일 친구 관계 문서 ID를 생성합니다.
  static String generateFriendshipId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// 친구 요청([requesterId] → [receiverId])을 트랜잭션으로 생성하거나 기존 상태를 반환합니다.
  ///
  /// 상대방([receiverId])이 이미 먼저 보낸 대기([FriendshipStatus.pending]) 요청이 존재하는 경우,
  /// 중복 문서를 만들지 않고 즉시 수락([FriendshipStatus.accepted]) 상태로 전환합니다.
  Future<Friendship> requestFriendship({
    required String requesterId,
    required String receiverId,
  }) async {
    final docId = generateFriendshipId(requesterId, receiverId);
    final docRef = _friendshipsRef.doc(docId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists && snapshot.data() != null) {
        final existing = Friendship.fromMap(snapshot.data()!);

        if (existing.isAccepted) {
          return existing;
        }

        if (existing.isPending && existing.requesterId == receiverId) {
          transaction.update(docRef, {
            'status': FriendshipStatus.accepted.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return existing.accept();
        }

        if (existing.isPending && existing.requesterId == requesterId) {
          return existing;
        }
      }

      final data = <String, dynamic>{
        'id': docId,
        'requesterId': requesterId,
        'receiverId': receiverId,
        'members': [requesterId, receiverId],
        'status': FriendshipStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(docRef, data);
    });

    final savedDoc = await docRef.get();
    return Friendship.fromMap(savedDoc.data()!);
  }

  /// 지정된 친구 관계 문서([friendshipId])를 수락([FriendshipStatus.accepted]) 상태로 갱신합니다.
  Future<Friendship> acceptFriendship(String friendshipId) async {
    final docRef = _friendshipsRef.doc(friendshipId);
    await docRef.update({
      'status': FriendshipStatus.accepted.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final snapshot = await docRef.get();
    return Friendship.fromMap(snapshot.data()!);
  }

  /// 지정된 친구 관계 문서([friendshipId])를 Firestore에서 영구 삭제합니다.
  Future<void> deleteFriendship(String friendshipId) async {
    await _friendshipsRef.doc(friendshipId).delete();
  }

  /// 두 사용자([myUid], [otherUid]) 사이의 친구 관계 문서를 조회하여 [Friendship]으로 반환합니다.
  Future<Friendship?> getFriendship({
    required String myUid,
    required String otherUid,
  }) async {
    final docId = generateFriendshipId(myUid, otherUid);
    final doc = await _friendshipsRef.doc(docId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Friendship.fromMap(doc.data()!);
  }

  /// 지정된 사용자([userId])와 수락된 친구 관계를 맺고 있는 상대방 UID 목록을 조회합니다.
  Future<List<String>> getFriendUserIds(String userId) async {
    final snapshot = await _friendshipsRef
        .where('members', arrayContains: userId)
        .where('status', isEqualTo: FriendshipStatus.accepted.name)
        .get();

    return snapshot.docs
        .map((doc) => Friendship.fromMap(doc.data()).getOtherUserId(userId))
        .toList();
  }

  /// 사용자([userId])가 수신하여 수락 대기 중인 친구 요청 목록을 최신순으로 조회합니다.
  Future<List<Friendship>> getReceivedRequests(String userId) async {
    final snapshot = await _friendshipsRef
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: FriendshipStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Friendship.fromMap(doc.data())).toList();
  }

  /// 사용자([userId])가 발송하여 상대방 응답을 대기 중인 친구 요청 목록을 최신순으로 조회합니다.
  Future<List<Friendship>> getSentRequests(String userId) async {
    final snapshot = await _friendshipsRef
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: FriendshipStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Friendship.fromMap(doc.data())).toList();
  }

  /// 차단 정보([block])를 기록하고 기존 친구 관계 문서를 단일 배치([WriteBatch])로 원자적 삭제합니다.
  Future<void> blockUser(BlockStatus block) async {
    final batch = _firestore.batch();

    final blockRef = _blocksRef.doc(block.id);
    final blockData = block.toMap();
    blockData['createdAt'] = FieldValue.serverTimestamp();
    batch.set(blockRef, blockData);

    final friendshipId = generateFriendshipId(
      block.blockerUid,
      block.blockedUid,
    );
    final friendshipsRef = _friendshipsRef.doc(friendshipId);
    batch.delete(friendshipsRef);

    await batch.commit();
  }

  /// 지정된 차단 문서([blockId])를 삭제하여 차단을 해제합니다.
  Future<void> unblockUser(String blockId) async {
    await _blocksRef.doc(blockId).delete();
  }

  /// 지정된 사용자([blockerUid])가 차단한 사용자 목록을 최신순으로 조회합니다.
  Future<List<BlockStatus>> getBlockedUsers(String blockerUid) async {
    final snapshot = await _blocksRef
        .where('blockerUid', isEqualTo: blockerUid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => BlockStatus.fromMap(doc.data())).toList();
  }

  /// 나([userId])가 차단한 사용자 및 나를 차단한 사용자 UID를 양방향으로 모두 조회하여 반환합니다.
  Future<List<String>> getBlockedUserIds(String userId) async {
    final snapshots = await Future.wait([
      _blocksRef.where('blockerUid', isEqualTo: userId).get(),
      _blocksRef.where('blockedUser.uid', isEqualTo: userId).get(),
    ]);

    final blockedByMe = snapshots[0].docs
        .map((doc) => doc.data()['blockedUser']?['uid'] as String?)
        .whereType<String>();

    final blockingMe = snapshots[1].docs
        .map((doc) => doc.data()['blockerUid'] as String?)
        .whereType<String>();

    return {...blockedByMe, ...blockingMe}.toList();
  }

  /// 친구([targetUserId])에 대한 현재 사용자([currentUserId])의 즐겨찾기 등록 상태를 토글하고 변경된 상태를 반환합니다.
  ///
  /// 친구 관계 문서가 존재하지 않는 경우 [NotFoundException]을 던집니다.
  Future<bool> toggleFavoriteFriend({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final friendshipId = generateFriendshipId(currentUserId, targetUserId);
    final friendshipRef = _friendshipsRef.doc(friendshipId);

    final snapshot = await friendshipRef.get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw const NotFoundException('친구 관계 문서를 찾을 수 없습니다.');
    }

    final friendship = Friendship.fromMap(snapshot.data()!);
    final isCurrentlyFavorite = friendship.isFavoriteOf(currentUserId);
    final nextFavoriteState = !isCurrentlyFavorite;
    await friendshipRef.update({
      'favorites': nextFavoriteState
          ? FieldValue.arrayUnion([currentUserId])
          : FieldValue.arrayRemove([currentUserId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return nextFavoriteState;
  }
}
