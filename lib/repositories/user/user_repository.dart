import 'dart:io';
import '../../models/enums/character_type.dart';
import '../../models/social/notification_settings.dart';
import '../../models/social/user.dart';

abstract interface class UserRepository {
  /// 현재 사용자의 프로필 정보를 조회한다.
  Future<User?> getCurrentUserProfile();

  /// UID를 통해 특정 사용자의 프로필 정보를 조회한다.
  Future<User?> getUserProfile(String uid);

  /// username을 통해 특정 사용자의 프로필 정보를 조회한다.
  Future<User?> getUserByUsername(String username);

  /// 현재 사용자의 프로필 정보를 수정한다.
  Future<void> updateUserProfile({
    String? nickname,
    String? description,
    String? imageUrl,
    File? imageFile,
  });

  /// 현재 사용자의 캐릭터를 변경한다.
  Future<void> updateCharacter(CharacterType character);

  /// 현재 사용자의 푸시 알림 설정을 변경한다.
  Future<void> updateNotificationSettings(NotificationSettings settings);

  /// query로 시작하는 username을 가진 사용자의 프로필 정보를 조회한다.
  Future<List<User>> searchUsers({
    required String query,
    int limit = 20,
  });
}
