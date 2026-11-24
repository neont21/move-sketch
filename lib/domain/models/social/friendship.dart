import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../enums/friendship_status.dart';

/// 두 사용자 간의 친구 요청 및 수락/즐겨찾기 관계 상태를 나타내는 불변 모델입니다.
@immutable
final class Friendship {
  /// 친구 관계 고유 식별자. (두 사용자 UID를 사전순 정렬하여 결합한 문자열)
  final String id;

  /// 친구 요청을 최초로 발송한 사용자의 고유 식별자.
  final String requesterId;

  /// 친구 요청을 수신한 사용자의 고유 식별자.
  final String receiverId;

  /// 친구 관계에 속한 두 사용자의 고유 식별자 목록.
  final List<String> members;

  /// 해당 친구 관계를 관심 친구로 지정한 사용자들의 고유 식별자 목록.
  final List<String> favorites;

  /// 현재 친구 관계 진행 상태.
  final FriendshipStatus status;

  /// 친구 요청이 최초 생성된 일시.
  final DateTime createdAt;

  /// 친구 상태가 최근 변경된 일시.
  final DateTime updatedAt;

  const Friendship({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    this.favorites = const [],
  });

  /// 두 사용자의 식별자와 현재 시각을 기반으로 신규 [Friendship]을 생성합니다.
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
      favorites: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 친구 관계가 수락 완료된 상태인지 여부.
  bool get isAccepted => status == FriendshipStatus.accepted;

  /// 친구 요청이 수락 대기 중인 상태인지 여부.
  bool get isPending => status == FriendshipStatus.pending;

  /// 지정된 사용자([myUid])가 이 친구를 즐겨찾기로 등록했는지 판별합니다.
  bool isFavoriteOf(String myUid) => favorites.contains(myUid);

  /// 지정된 사용자([myUid])가 수락을 기다리는 수신자인지 판별합니다.
  bool isReceivedBy(String myUid) {
    return receiverId == myUid && status == FriendshipStatus.pending;
  }

  /// 지정된 사용자([myUid])가 요청을 보낸 발신자인지 판별합니다.
  bool isSentBy(String myUid) {
    return requesterId == myUid && status == FriendshipStatus.pending;
  }

  /// 본인([myUid])을 기준으로 상대방 사용자의 고유 식별자를 반환합니다.
  ///
  /// 본인이 해당 친구 관계의 구성원이 아닌 경우 [ValidationException]을 던집니다.
  String getOtherUserId(String myUid) {
    if (requesterId == myUid) return receiverId;
    if (receiverId == myUid) return requesterId;
    throw ValidationException('해당 유저는 본 친구 관계에 속해있지 않습니다: $myUid');
  }

  /// 지정된 사용자([userId])가 이 친구 관계에 포함되어 있는지 확인합니다.
  bool involves(String userId) => members.contains(userId);

  /// 상태를 수락([FriendshipStatus.accepted])으로 변경한 새 [Friendship]을 반환합니다.
  Friendship accept() =>
      copyWith(status: FriendshipStatus.accepted, updatedAt: DateTime.now());

  /// 상태를 거절([FriendshipStatus.declined])으로 변경한 새 [Friendship]을 반환합니다.
  Friendship decline() =>
      copyWith(status: FriendshipStatus.declined, updatedAt: DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'receiverId': receiverId,
      'members': members,
      'favorites': favorites,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
              ?.map((member) => member as String)
              .toList() ??
          [requester, receiver],
      favorites:
          (map['favorites'] as List<dynamic>?)
              ?.map((element) => element as String)
              .toList() ??
          const [],
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
    List<String>? favorites,
  }) {
    return Friendship(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      receiverId: receiverId ?? this.receiverId,
      members: members ?? this.members,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Friendship &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          requesterId == other.requesterId &&
          receiverId == other.receiverId &&
          listEquals(members, other.members) &&
          listEquals(favorites, other.favorites) &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    requesterId,
    receiverId,
    Object.hashAll(members),
    Object.hashAll(favorites),
    status,
    createdAt,
    updatedAt,
  );
}
