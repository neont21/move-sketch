import '../../../utils/date_time_utils.dart';
import 'user.dart';

class BlockStatus {
  final String id;
  final String blockerUid;
  final UserSummary blockedUser;
  final DateTime createdAt;

  const BlockStatus({
    required this.id,
    required this.blockerUid,
    required this.blockedUser,
    required this.createdAt,
  });

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

  factory BlockStatus.fromMap(Map<String, dynamic> map) {
    return BlockStatus(
      id: map['id'] as String,
      blockerUid: map['blockerUid'] as String,
      blockedUser: UserSummary.fromMap(
        map['blockedUser'] as Map<String, dynamic>,
      ),
      createdAt: parseDateTime(map['createdAt']),
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
      other is BlockStatus && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
