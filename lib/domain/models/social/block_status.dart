import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/date_time_utils.dart';
import 'user.dart';

/// 특정 사용자 간의 차단 관계 정보를 나타내는 불변 모델입니다.
@immutable
final class BlockStatus {
  /// 차단 관계 고유 식별자. (`{blockerUid}_{blockedUid}` 형식)
  final String id;

  /// 차단을 실행한 사용자의 고유 식별자.
  final String blockerUid;

  /// 차단 대상 사용자의 요약 정보.
  final UserSummary blockedUser;

  /// 차단 등록 일시.
  final DateTime createdAt;

  const BlockStatus({
    required this.id,
    required this.blockerUid,
    required this.blockedUser,
    required this.createdAt,
  });

  /// 차단 주체와 대상의 UID를 조합한 고유 ID를 부여하여 신규 [BlockStatus]를 생성합니다.
  factory BlockStatus.create({
    required String blockerUid,
    required UserSummary blockedUser,
  }) {
    return BlockStatus(
      id: createId(blockerUid, blockedUser.uid),
      blockerUid: blockerUid,
      blockedUser: blockedUser,
      createdAt: DateTime.now(),
    );
  }

  /// 차단 대상 사용자의 고유 식별자.
  String get blockedUid => blockedUser.uid;

  /// 차단 주체([blockerId])와 대상([blockedId]) 식별자를 조합하여 결정론적 문서 ID를 생성합니다.
  static String createId(String blockerId, String blockedId) =>
      '${blockerId}_$blockedId';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockerUid': blockerUid,
      'blockedUser': blockedUser.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BlockStatus.fromMap(Map<String, dynamic> map) {
    return BlockStatus(
      id: map['id'] as String,
      blockerUid: map['blockerUid'] as String,
      blockedUser: UserSummary.fromMap(
        map['blockedUser'] as Map<String, dynamic>,
      ),
      createdAt: parseDateTime(map['createdAt']).toLocal(),
    );
  }

  BlockStatus copyWith({
    String? id,
    String? blockerUid,
    UserSummary? blockedUser,
    DateTime? createdAt,
  }) {
    return BlockStatus(
      id: id ?? this.id,
      blockerUid: blockerUid ?? this.blockerUid,
      blockedUser: blockedUser ?? this.blockedUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockStatus &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          blockerUid == other.blockerUid &&
          blockedUser == other.blockedUser &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, blockerUid, blockedUser, createdAt);
}
