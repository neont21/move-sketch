import 'dart:io';

import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/social/notification_settings.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/result.dart';

/// 사용자 프로필 조회·수정, 캐릭터·알림 설정 및 사용자 검색을 추상화한 저장소 인터페이스입니다.
abstract interface class UserRepository {
  /// 현재 로그인된 사용자의 프로필 정보를 조회합니다.
  Future<Result<User?>> getCurrentUserProfile();

  /// 지정된 [uid]에 해당하는 사용자의 프로필 정보를 조회합니다.
  Future<Result<User?>> getUserProfile(String uid);

  /// 지정된 아이디([username])를 가진 사용자의 프로필 정보를 조회합니다.
  Future<Result<User?>> getUserByUsername(String username);

  /// 현재 사용자의 프로필 정보를 수정합니다.
  Future<Result<void>> updateUserProfile({
    String? nickname,
    String? description,
    String? imageUrl,
    File? imageFile,
  });

  /// 현재 사용자의 대표 캐릭터([character])를 변경합니다.
  Future<Result<void>> updateCharacter(CharacterType character);

  /// 현재 사용자의 푸시 알림 설정([settings])을 변경합니다.
  Future<Result<void>> updateNotificationSettings(
    NotificationSettings settings,
  );

  /// 검색어([query])로 시작하는 아이디를 가진 사용자 요약 목록을 조회합니다. (차단된 사용자 및 본인 제외)
  Future<Result<List<UserSummary>>> searchUsers({
    required String currentUserId,
    required String query,
    int limit = 20,
  });

  /// 현재 사용자의 FCM 기기 등록 토큰([fcmToken])을 갱신하거나 무효화(`null`)합니다.
  Future<Result<void>> updateFcmToken(String? fcmToken);
}
