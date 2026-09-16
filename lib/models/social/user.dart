import 'package:flutter/foundation.dart';
import '../../utils/date_time_utils.dart';
import '../enums/character_type.dart';
import 'notification_settings.dart';

@immutable
class UserSummary {
  final String id;
  final String username;
  final String? imageUrl;

  const UserSummary({required this.id, required this.username, this.imageUrl});

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'imageUrl': imageUrl};
  }

  factory UserSummary.fromMap(Map<String, dynamic> map) {
    return UserSummary(
      id: map['id'] as String,
      username: map['username'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  UserSummary copyWith({
    String? id,
    String? username,
    ValueGetter<String?>? imageUrl,
  }) {
    return UserSummary(
      id: id ?? this.id,
      username: username ?? this.username,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSummary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class User {
  final String id;
  final String username;
  final String? email;
  final String? imageUrl;
  final String? description;
  final CharacterType selectedCharacter;

  final NotificationSettings notificationSettings;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.imageUrl,
    this.description,
    this.selectedCharacter = CharacterType.bear,
    this.notificationSettings = const NotificationSettings(),
  });

  UserSummary toSummary() {
    return UserSummary(id: id, username: username, imageUrl: imageUrl);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'imageUrl': imageUrl,
      'description': description,
      'selectedCharacterId': selectedCharacter.id,
      'notificationSettings': notificationSettings.toMap(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'deletedAt': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map, {String? id}) {
    return User(
      id: (map['id'] as String?) ?? id ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String,
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      selectedCharacter: CharacterType.fromString(map['selectedCharacterId'] as String?),
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
    String? id,
    String? username,
    ValueGetter<String?>? email,
    ValueGetter<String?>? imageUrl,
    ValueGetter<String?>? description,
    CharacterType? selectedCharacter,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    ValueGetter<DateTime?>? updatedAt,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email != null ? email() : this.email,
      username: username ?? this.username,
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
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
