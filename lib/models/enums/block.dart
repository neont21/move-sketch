import '../social/user.dart';

class Block {
  final String id;
  final String blockerId;
  final UserSummary blockedUser;
  final DateTime createdAt;

  const Block({
    required this.id,
    required this.blockerId,
    required this.blockedUser,
    required this.createdAt,
  });

  String get blockedId => blockedUser.id;

  static String createId(String blockerId, String blockedId) =>
      '${blockerId}_$blockedId';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockerId': blockerId,
      'blockedUser': blockedUser.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
      id: map['id'] as String,
      blockerId: map['blockerId'] as String,
      blockedUser: UserSummary.fromMap(
        map['blockedUser'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Block copyWith({
    String? id,
    String? blockerId,
    UserSummary? blockedUser,
    DateTime? createdAt,
  }) {
    return Block(
      id: id ?? this.id,
      blockerId: blockerId ?? this.blockerId,
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
