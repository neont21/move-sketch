import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as auth show User;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/social/social_auth_result.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/auth_service.dart';
import '../../services/remote/firestore/user_service.dart';
import '../../services/remote/storage_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'auth_repository.dart';

final class AuthRepositoryRemote implements AuthRepository {
  final AuthService authService;
  final UserService userService;
  final StorageService storageService;

  AuthRepositoryRemote({
    required this.authService,
    required this.userService,
    required this.storageService,
  });

  @override
  String? get currentUid {
    final user = authService.currentUser;
    if (user == null) {
      return null;
    }

    final hasSocialProvider = user.providerData.any(
      (info) =>
          info.providerId == 'google.com' || info.providerId == 'apple.com',
    );
    if (!hasSocialProvider && !user.emailVerified) {
      return null;
    }

    return user.uid;
  }

  @override
  Stream<String?> get authStateChanges =>
      authService.authStateChanges.map((user) {
        if (user == null) {
          return null;
        }
        final hasSocialProvider = user.providerData.any(
          (info) =>
              info.providerId == 'google.com' || info.providerId == 'apple.com',
        );

        if (!hasSocialProvider && !user.emailVerified) {
          return null;
        }

        return user.uid;
      }).distinct();

  @override
  bool get isEmailVerified => authService.isEmailVerified;

  @override
  List<String> get linkedProviders => authService.linkedProviders;

  @override
  Map<String, String> get providerEmails => authService.providerEmails;

  @override
  Future<Result<bool>> checkEmailVerified() async {
    try {
      final isVerified = await authService.checkEmailVerified();
      return Result.ok(isVerified);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        e.toAuthException(defaultMessage: '이메일 인증 확인 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '이메일 인증 확인 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('이메일 인증 확인 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return const Result.error(ValidationException('아이디를 입력해 주세요.'));
    }

    try {
      final isAvailable = await userService.isUsernameAvailable(trimmed);
      return Result.ok(isAvailable);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '아이디 중복 확인 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('아이디 중복 확인 중 오류가 발생하였습니다.', cause: e));
    }
  }

  @override
  Future<Result<User>> signUpWithUsername({
    required String username,
    required String nickname,
    required String email,
    required String password,
    CharacterType selectedCharacter = CharacterType.bear,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return const Result.error(ValidationException('아이디를 입력해 주세요.'));
    }

    try {
      final isAvailable = await userService.isUsernameAvailable(username);
      if (!isAvailable) {
        return const Result.error(ValidationException('이미 사용 중인 아이디입니다.'));
      }
      final credential = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return const Result.error(AuthException('계정 생성에 실패하였습니다.'));
      }

      await _createUserDocumentsWithRollback(
        uid: credential.user!.uid,
        username: username,
        nickname: nickname,
        email: email,
        selectedCharacterId: selectedCharacter.id,
      );

      await authService.resendVerificationEmail().catchError((_) {});

      final user = await userService.getUserProfile(credential.user!.uid);
      if (user == null) {
        return const Result.error(NotFoundException('사용자 프로필을 찾을 수 없습니다.'));
      }

      return Result.ok(user);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        e.toAuthException(defaultMessage: '회원 가입 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '회원 가입 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('회원 가입 중 오류가 발생했습니다.', cause: e));
    }
  }

  Future<void> _createUserDocumentsWithRollback({
    required String uid,
    required String username,
    required String nickname,
    required String email,
    required String selectedCharacterId,
  }) async {
    try {
      await userService.createUserDocuments(
        uid: uid,
        username: username,
        nickname: nickname,
        email: email,
        selectedCharacterId: selectedCharacterId,
      );
    } catch (e) {
      await authService.deleteCurrentUser();
      rethrow;
    }
  }

  @override
  Future<Result<User>> signInWithUsername({
    required String username,
    required String password,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return const Result.error(ValidationException('아이디 또는 이메일을 입력해 주세요.'));
    }
    try {
      final String email;
      if (trimmed.contains('@')) {
        email = trimmed.toLowerCase();
      } else {
        final resolvedEmail = await userService.getEmailByUsername(
          trimmed.toLowerCase(),
        );
        if (resolvedEmail == null) {
          return const Result.error(NotFoundException('존재하지 않는 아이디입니다.'));
        } else if (resolvedEmail.trim().isEmpty) {
          return const Result.error(
            AuthException('소셜 로그인으로 가입된 계정입니다. 소셜 로그인으로 시도해 주세요.'),
          );
        }
        email = resolvedEmail;
      }

      final credential = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const Result.error(AuthException('로그인에 실패하였습니다.'));
      }

      if (!credential.user!.emailVerified) {
        await authService.resendVerificationEmail().catchError((_) {});
        await authService.signOut();
        return const Result.error(
          AuthException('이메일 인증이 완료되지 않았습니다. 메일함의 인증 링크를 먼저 확인해 주세요.'),
        );
      }

      final user = await userService.getUserProfile(uid);
      if (user == null) {
        return const Result.error(NotFoundException('사용자 정보를 찾을 수 없습니다.'));
      }
      if (user.isDeleted) {
        return const Result.error(AuthException('탈퇴한 사용자 계정입니다.'));
      }

      return Result.ok(user);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        e.toAuthException(defaultMessage: '로그인 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '로그인 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('로그인 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<SocialAuthResult>> signInWithGoogle() async {
    try {
      final credential = await authService.signInWithGoogle();
      if (credential == null || credential.user == null) {
        return const Result.ok(SocialAuthCanceled());
      }

      return _handleSocialUserVerification(credential.user!);
    } on FirebaseAuthException catch (error) {
      return Result.error(
        error.toAuthException(defaultMessage: 'Google 로그인 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (error) {
      return Result.error(
        error.toAppException(defaultMessage: 'Google 로그인 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(
        AuthException('Google 로그인 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<SocialAuthResult>> signInWithApple() async {
    try {
      final credential = await authService.signInWithApple();
      if (credential == null || credential.user == null) {
        return const Result.ok(SocialAuthCanceled());
      }

      return _handleSocialUserVerification(credential.user!);
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return const Result.ok(SocialAuthCanceled());
      }
      return Result.error(
        AuthException('Apple 로그인 중 오류가 발생했습니다: ${error.message}'),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'web-context-canceled') {
        return const Result.ok(SocialAuthCanceled());
      }
      return Result.error(
        error.toAuthException(defaultMessage: 'Apple 로그인 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (error) {
      return Result.error(
        error.toAppException(defaultMessage: 'Apple 로그인 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(
        AuthException('Apple 로그인 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  Future<Result<SocialAuthResult>> _handleSocialUserVerification(
    auth.User fbUser,
  ) async {
    final String uid = fbUser.uid;
    final User? existingUser = await userService.getUserProfile(uid);

    if (existingUser != null) {
      if (existingUser.isDeleted) {
        await authService.signOut();
        return const Result.error(AuthException('탈퇴한 사용자 계정입니다.'));
      }
      return Result.ok(SocialAuthSuccess(existingUser));
    }

    return Result.ok(
      SocialAuthNeedsOnboarding(
        uid: uid,
        email: fbUser.email,
        defaultNickname: fbUser.displayName,
        defaultPhotoUrl: fbUser.photoURL,
      ),
    );
  }

  @override
  Future<Result<User>> completeSocialSignUp({
    required String username,
    required String nickname,
    required CharacterType selectedCharacter,
    File? imageFile,
    String? profileImageUrl,
  }) async {
    final String? currentUid = authService.currentUid;
    if (currentUid == null) {
      return const Result.error(AuthException('인증된 소셜 계정 정보가 없습니다.'));
    }

    final String trimmedUsername = username.trim().toLowerCase();
    if (trimmedUsername.isEmpty) {
      return const Result.error(ValidationException('아이디를 입력해 주세요.'));
    }

    try {
      final bool isAvailable = await userService.isUsernameAvailable(
        trimmedUsername,
      );
      if (!isAvailable) {
        return const Result.error(ValidationException('이미 사용 중인 아이디입니다.'));
      }

      String? finalImageUrl;
      if (imageFile != null) {
        finalImageUrl = await storageService.uploadProfileImage(
          userId: currentUid,
          imageFile: imageFile,
        );
      } else if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        try {
          finalImageUrl = await storageService.copyRemoteImageToProfile(
            userId: currentUid,
            remoteUrl: profileImageUrl,
          );
        } catch (_) {
          finalImageUrl = null;
        }
      }

      await userService.createUserDocuments(
        uid: currentUid,
        username: trimmedUsername,
        nickname: nickname.trim(),
        email: '',
        selectedCharacterId: selectedCharacter.id,
        imageUrl: finalImageUrl,
      );

      final User? createdUser = await userService.getUserProfile(currentUid);
      if (createdUser == null) {
        return const Result.error(NotFoundException('사용자 프로필을 생성하지 못했습니다.'));
      }

      return Result.ok(createdUser);
    } on FirebaseException catch (error) {
      return Result.error(
        error.toAppException(defaultMessage: '프로필 설정 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(AuthException('프로필 설정 중 오류가 발생했습니다.', cause: error));
    }
  }

  @override
  Future<Result<bool>> linkGoogle() async {
    try {
      final UserCredential? credential = await authService.linkGoogle();
      if (credential == null) {
        return const Result.ok(false);
      }

      return const Result.ok(true);
    } on FirebaseAuthException catch (error) {
      return Result.error(
        error.toAuthException(defaultMessage: 'Google 연동 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(
        AuthException('Google 연동 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<bool>> linkApple() async {
    try {
      final UserCredential? credential = await authService.linkApple();
      if (credential == null) {
        return const Result.ok(false);
      }

      return const Result.ok(true);
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return const Result.ok(false);
      }
      return Result.error(AuthException('Apple 연동 취소 또는 실패: ${error.message}'));
    } on FirebaseAuthException catch (error) {
      if (error.code == 'web-context-canceled') {
        return const Result.ok(false);
      }
      return Result.error(
        error.toAuthException(defaultMessage: 'Apple 연동 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(
        AuthException('Apple 연동 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> linkEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await authService.linkEmailAndPassword(email: email, password: password);

      final String? uid = authService.currentUid;
      if (uid == null) {
        return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
      }

      final user = await userService.getUserProfile(uid);
      if (user != null) {
        await _updateAccountEmailWithRollback(
          uid: currentUid!,
          username: user.username,
          email: email.trim(),
        );
      }

      return const Result.ok(null);
    } on FirebaseAuthException catch (error) {
      return Result.error(
        error.toAuthException(defaultMessage: '이메일 및 비밀번호 연결 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(
        AuthException('이메일 및 비밀번호 연결 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  Future<void> _updateAccountEmailWithRollback({
    required String uid,
    required String username,
    required String email,
  }) async {
    try {
      await userService.updateAccountEmail(
        uid: uid,
        username: username,
        email: email,
      );
    } catch (_) {
      await authService.unlinkProvider('password').catchError((_) {});
      rethrow;
    }
  }

  @override
  Future<Result<void>> unlinkProvider(String providerId) async {
    try {
      await authService.unlinkProvider(providerId);

      if (providerId == 'password' && currentUid != null) {
        final user = await userService.getUserProfile(currentUid!);
        if (user != null) {
          await _unlinkPasswordWithRollback(
            uid: currentUid!,
            username: user.username,
            email: '',
          );
        }
      }

      return const Result.ok(null);
    } on FirebaseAuthException catch (error) {
      return Result.error(
        error.toAuthException(defaultMessage: '연동 해제 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(AuthException('연동 해제 중 오류가 발생했습니다.', cause: error));
    }
  }

  Future<void> _unlinkPasswordWithRollback({
    required String uid,
    required String username,
    required String email,
  }) async {
    await userService.updateAccountEmail(
      uid: uid,
      username: username,
      email: '',
    );
    try {
      await authService.unlinkProvider('password');
    } catch (_) {
      await userService
          .updateAccountEmail(uid: uid, username: username, email: email)
          .catchError((_) {});
      rethrow;
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await authService.signOut();
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '로그아웃 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('로그아웃 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await authService.sendPasswordResetEmail(email);
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        e.toAuthException(defaultMessage: '비밀번호 재설정 이메일 전송 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '비밀번호 재설정 이메일 전송 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        AuthException('비밀번호 재설정 이메일 전송 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> resendVerificationEmail() async {
    try {
      await authService.resendVerificationEmail();
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        e.toAuthException(defaultMessage: '인증 이메일 전송 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '인증 이메일 전송 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('인증 이메일 전송 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword == newPassword) {
      return const Result.error(
        ValidationException('새 비밀번호는 현재 비밀번호와 달라야 합니다.'),
      );
    }
    try {
      await authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return const Result.error(AuthException('현재 비밀번호가 올바르지 않습니다.'));
      }
      return Result.error(
        e.toAuthException(defaultMessage: '비밀번호 변경 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '비밀번호 변경 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('비밀번호 변경 중 오류가 발생했습니다.', cause: e));
    }
  }

  Future<void> _executeAccountDeletion({
    required String uid,
    required String username,
  }) async {
    await userService.deleteUserDocuments(uid: uid, username: username);
    await authService.deleteCurrentUser();
  }

  @override
  Future<Result<void>> deleteAccountWithPassword({
    required String currentPassword,
    required String username,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }

    try {
      await authService.reauthenticate(currentPassword: currentPassword);
      await _executeAccountDeletion(uid: uid, username: username);

      return const Result.ok(null);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' || error.code == 'invalid-credential') {
        return const Result.error(AuthException('비밀번호가 올바르지 않습니다.'));
      }
      return Result.error(
        error.toAuthException(defaultMessage: '계정 삭제 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (error) {
      return Result.error(
        error.toAppException(defaultMessage: '계정 삭제 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(AuthException('계정 삭제 중 오류가 발생했습니다.', cause: error));
    }
  }

  @override
  Future<Result<bool>> deleteAccountWithGoogle({
    required String username,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }

    try {
      final credential = await authService.reauthenticateWithGoogle();
      if (credential == null) {
        return const Result.ok(false);
      }

      await _executeAccountDeletion(uid: uid, username: username);

      return const Result.ok(true);
    } on FirebaseAuthException catch (error) {
      return Result.error(
        error.toAuthException(defaultMessage: 'Google 재인증 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (error) {
      return Result.error(
        error.toAppException(defaultMessage: '계정 삭제 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(AuthException('계정 삭제 중 오류가 발생했습니다.', cause: error));
    }
  }

  @override
  Future<Result<bool>> deleteAccountWithApple({
    required String username,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }

    try {
      final credential = await authService.reauthenticateWithApple();
      if (credential == null) {
        return const Result.ok(false);
      }

      await _executeAccountDeletion(uid: uid, username: username);

      return const Result.ok(true);
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return const Result.ok(false);
      }
      return Result.error(AuthException('Apple 재인증 실패: ${error.message}'));
    } on FirebaseAuthException catch (error) {
      if (error.code == 'web-context-canceled') {
        return const Result.ok(false);
      }
      return Result.error(
        error.toAuthException(defaultMessage: 'Apple 재인증 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (error) {
      return Result.error(
        error.toAppException(defaultMessage: '계정 삭제 중 오류가 발생했습니다.'),
      );
    } catch (error) {
      return Result.error(AuthException('계정 삭제 중 오류가 발생했습니다.', cause: error));
    }
  }
}
