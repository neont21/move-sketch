import 'package:flutter/foundation.dart';
import '../../utils/date_time_utils.dart';
import '../enums/friendship_status.dart';

@immutable
class Friendship {
  final String id;
  final String requesterId;
  final String receiverId;
  final List<String> members;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Friendship({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
  });

  factory Friendship.create({
    required String id,
    required String requesterId,
    required String receiverId,
    FriendshipStatus status = FriendshipStatus.pending,
  }) {
    final now = DateTime.now();
    return Friendship(
      id: id,
      requesterId: requesterId,
      receiverId: receiverId,
      status: status,
      members: List.unmodifiable([requesterId, receiverId]),
      createdAt: now,
      updatedAt: now,
    );
  }

  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isPending => status == FriendshipStatus.pending;

  bool isReceivedBy(String myUid) {
    return receiverId == myUid && status == FriendshipStatus.pending;
  }

  bool isSentBy(String myUid) {
    return requesterId == myUid && status == FriendshipStatus.pending;
  }

  String getOtherUserId(String myUid) {
    if (requesterId == myUid) return receiverId;
    if (receiverId == myUid) return requesterId;
    throw ArgumentError('해당 유저는 본 친구 관계에 속해있지 않습니다: $myUid');
  }

  bool involves(String userId) => members.contains(userId);

  Friendship accept() =>
      copyWith(status: FriendshipStatus.accepted, updatedAt: DateTime.now());

  Friendship decline() =>
      copyWith(status: FriendshipStatus.declined, updatedAt: DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'receiverId': receiverId,
      'members': members,
      'status': status.name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory Friendship.fromMap(Map<String, dynamic> map) {
    final requester = map['requesterId'] as String;
    final receiver = map['receiverId'] as String;

    return Friendship(
      id: map['id'] as String,
      requesterId: requester,
      receiverId: receiver,
      members:
          (map['members'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [requester, receiver],
      status: FriendshipStatus.fromString(map['status'] as String?),
      createdAt: parseDateTime(map['createdAt']).toLocal(),
      updatedAt: parseDateTime(map['updatedAt']).toLocal(),
    );
  }

  Friendship copyWith({
    String? id,
    String? requesterId,
    String? receiverId,
    List<String>? members,
    FriendshipStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Friendship(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      receiverId: receiverId ?? this.receiverId,
      members: members ?? this.members,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Friendship && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
