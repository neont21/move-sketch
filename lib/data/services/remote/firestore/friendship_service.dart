import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/enums/block.dart';
import '../../../../domain/models/enums/friendship_status.dart';
import '../../../../domain/models/social/friendship.dart';

class FriendshipService {
  final FirebaseFirestore _firestore;

  FriendshipService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _friendshipsRef =>
      _firestore.collection('friendships');

  CollectionReference<Map<String, dynamic>> get _blocksRef =>
      _firestore.collection('blocks');

  static String generateFriendshipId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

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

  Future<Friendship> acceptFriendship(String friendshipId) async {
    final docRef = _friendshipsRef.doc(friendshipId);
    await docRef.update({
      'status': FriendshipStatus.accepted.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final snapshot = await docRef.get();
    return Friendship.fromMap(snapshot.data()!);
  }

  Future<void> deleteFriendship(String friendshipId) async {
    await _friendshipsRef.doc(friendshipId).delete();
  }

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

  Future<List<Friendship>> getAcceptedFriendships(String userId) async {
    final snapshot = await _friendshipsRef
        .where('members', arrayContains: userId)
        .where('status', isEqualTo: FriendshipStatus.accepted.name)
        .get();

    return snapshot.docs.map((doc) => Friendship.fromMap(doc.data())).toList();
  }

  Future<List<String>> getFriendUserIds(String userId) async {
    final friendships = await getAcceptedFriendships(userId);
    return friendships.map((friend) => friend.getOtherUserId(userId)).toList();
  }

  Future<List<Friendship>> getReceivedRequests(String userId) async {
    final snapshot = await _friendshipsRef
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: FriendshipStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Friendship.fromMap(doc.data())).toList();
  }

  Future<List<Friendship>> getSentRequests(String userId) async {
    final snapshot = await _friendshipsRef
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: FriendshipStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Friendship.fromMap(doc.data())).toList();
  }

  Future<void> blockUser(Block block) async {
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

  Future<void> unblockUser(String blockId) async {
    await _blocksRef.doc(blockId).delete();
  }

  Future<List<Block>> getBlockedUsers(String blockerUid) async {
    final snapshot = await _blocksRef
        .where('blockerUid', isEqualTo: blockerUid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Block.fromMap(doc.data())).toList();
  }

  Future<List<String>> getBlockedUserIds(String userId) async {
    final snapshots = await Future.wait([
      _blocksRef.where('blockerUid', isEqualTo: userId).get(),
      _blocksRef.where('blockedUser.uid', isEqualTo: userId).get(),
    ]);

    final blockedByME = snapshots[0].docs
        .map((doc) => doc.data()['blockedUser']?['uid'] as String?)
        .whereType<String>();

    final blockingMe = snapshots[1].docs
        .map((doc) => doc.data()['blockerUid'] as String?)
        .whereType<String>();

    return {...blockedByME, ...blockingMe}.toList();
  }
}
