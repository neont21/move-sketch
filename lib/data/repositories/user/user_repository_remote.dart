import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/social/notification_settings.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/auth_service.dart';
import '../../services/remote/firestore/friendship_service.dart';
import '../../services/remote/firestore/user_service.dart';
import '../../services/remote/storage_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'user_repository.dart';

final class UserRepositoryRemote implements UserRepository {
  final AuthService authService;
  final UserService userService;
  final StorageService storageService;
  final FriendshipService friendshipService;

  UserRepositoryRemote({
    required this.authService,
    required this.userService,
    required this.storageService,
    required this.friendshipService,
  });

  @override
  Future<Result<User?>> getCurrentUserProfile() async {
    final uid = authService.currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }
    try {
      final user = await userService.getUserProfile(uid);
      return Result.ok(user);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '사용자 프로필을 가져오는 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('사용자 프로필을 가져오는 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<User?>> getUserProfile(String uid) async {
    try {
      final user = await userService.getUserProfile(uid);
      return Result.ok(user);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '사용자 프로필을 가져오는 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('사용자 프로필을 가져오는 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<User?>> getUserByUsername(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return const Result.error(ValidationException('아이디를 입력해 주세요.'));
    }
    try {
      final user = await userService.getUserProfileByUsername(trimmed);
      return Result.ok(user);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '사용자 프로필을 가져오는 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('사용자 프로필을 가져오는 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateUserProfile({
    String? nickname,
    String? description,
    String? imageUrl,
    File? imageFile,
  }) async {
    final uid = authService.currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }
    if (nickname != null && nickname.trim().isEmpty) {
      return const Result.error(ValidationException('닉네임을 올바르게 입력해 주세요.'));
    }

    try {
      String? newImageUrl = imageUrl;
      if (imageFile != null) {
        newImageUrl = await storageService.uploadProfileImage(
          userId: uid,
          imageFile: imageFile,
        );
      }

      await userService.updateUserProfile(
        uid: uid,
        nickname: nickname?.trim(),
        description: description?.trim(),
        imageUrl: newImageUrl,
      );

      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '프로필 업데이트 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('프로필 업데이트 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateCharacter(CharacterType character) async {
    final uid = authService.currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }
    try {
      await userService.updateCharacterId(
        uid: uid,
        selectedCharacterId: character.id,
      );
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '캐릭터 변경 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('캐릭터 변경 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    final uid = authService.currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }
    try {
      await userService.updateNotificationSettings(
        uid: uid,
        settingsMap: settings.toMap(),
      );
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '알림 설정 변경 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('알림 설정 변경 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<User>>> searchUsers({
    required String currentUserId,
    required String query,
    int limit = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const Result.ok([]);
    }
    try {
      final blocked = await friendshipService.getBlockedUserIds(currentUserId);
      final searchedUsers = await userService.searchUsers(
        query: trimmed,
        limit: limit,
        excludeUserIds: [currentUserId, ...blocked],
      );
      return Result.ok(searchedUsers);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '사용자 검색 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('사용자 검색 중 오류가 발생했습니다.', cause: e));
    }
  }
}
