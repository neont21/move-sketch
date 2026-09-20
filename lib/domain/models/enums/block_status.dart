import 'package:move_sketch/utils/date_time_utils.dart';

import '../social/user.dart';

class Block {
  final String id;
  final String blockerUid;
  final UserSummary blockedUser;
  final DateTime createdAt;

  const Block({
    required this.id,
    required this.blockerUid,
    required this.blockedUser,
    required this.createdAt,
  });

  String get blockedUid => blockedUser.uid;

  static String createId(String blockerId, String blockedId) =>
      '${blockerId}_$blockedId';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockerUid': blockerUid,
      'blockedUser': blockedUser.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
      id: map['id'] as String,
      blockerUid: map['blockerUid'] as String,
      blockedUser: UserSummary.fromMap(
        map['blockedUser'] as Map<String, dynamic>,
      ),
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  Block copyWith({
    String? id,
    String? blockerUid,
    UserSummary? blockedUser,
    DateTime? createdAt,
  }) {
    return Block(
      id: id ?? this.id,
      blockerUid: blockerUid ?? this.blockerUid,
      blockedUser: blockedUser ?? this.blockedUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
