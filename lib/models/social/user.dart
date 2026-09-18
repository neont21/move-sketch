import 'package:flutter/foundation.dart';
import '../../utils/date_time_utils.dart';
import '../enums/character_type.dart';
import 'notification_settings.dart';

@immutable
class UserSummary {
  final String uid;
  final String username;
  final String nickname;
  final String? imageUrl;

  const UserSummary({
    required this.uid,
    required this.username,
    required this.nickname,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'username': username, 'nickname': nickname, 'imageUrl': imageUrl};
  }

  factory UserSummary.fromMap(Map<String, dynamic> map) {
    return UserSummary(
      uid: map['uid'] as String,
      username: map['username'] as String,
      nickname: map['nickname'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  UserSummary copyWith({
    String? uid,
    String? username,
    String? nickname,
    ValueGetter<String?>? imageUrl,
  }) {
    return UserSummary(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSummary &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

@immutable
class User {
  final String uid;
  final String username;
  final String? email;
  final String nickname;
  final String? imageUrl;
  final String? description;
  final CharacterType selectedCharacter;

  final NotificationSettings notificationSettings;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const User({
    required this.uid,
    required this.username,
    required this.email,
    required this.nickname,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.imageUrl,
    this.description,
    this.selectedCharacter = CharacterType.bear,
    this.notificationSettings = const NotificationSettings(),
  });

  bool get isDeleted => deletedAt != null;

  UserSummary toSummary() {
    return UserSummary(
      uid: uid,
      username: username,
      nickname: nickname,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'nickname': nickname,
      'imageUrl': imageUrl,
      'description': description,
      'selectedCharacterId': selectedCharacter.id,
      'notificationSettings': notificationSettings.toMap(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'deletedAt': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map, {String? uid}) {
    return User(
      uid: (map['uid'] as String?) ?? uid ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      nickname: map['nickname'] as String,
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      selectedCharacter: CharacterType.fromString(
        map['selectedCharacterId'] as String?,
      ),
      notificationSettings: map['notificationSettings'] != null
          ? NotificationSettings.fromMap(
              map['notificationSettings'] as Map<String, dynamic>,
            )
          : const NotificationSettings(),
      createdAt: parseDateTime(map['createdAt']).toLocal(),
      updatedAt: tryParseDateTime(map['updatedAt'])?.toLocal(),
      deletedAt: tryParseDateTime(map['deletedAt'])?.toLocal(),
    );
  }

  User copyWith({
    String? uid,
    String? username,
    ValueGetter<String?>? email,
    String? nickname,
    ValueGetter<String?>? imageUrl,
    ValueGetter<String?>? description,
    CharacterType? selectedCharacter,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    ValueGetter<DateTime?>? updatedAt,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email != null ? email() : this.email,
      nickname: nickname ?? this.nickname,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      description: description != null ? description() : this.description,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
