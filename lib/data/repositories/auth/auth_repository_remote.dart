import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/auth_service.dart';
import '../../services/remote/firestore/user_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'auth_repository.dart';

final class AuthRepositoryRemote implements AuthRepository {
  final AuthService authService;
  final UserService userService;

  AuthRepositoryRemote({required this.authService, required this.userService});

  @override
  String? get currentUid {
    final user = authService.currentUser;
    if (user == null || !user.emailVerified) {
      return null;
    }
    return user.uid;
  }

  @override
  Stream<String?> get authStateChanges =>
      authService.authStateChanges.map((user) => user?.uid);

  @override
  bool get isEmailVerified => authService.isEmailVerified;

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
    String selectedCharacterId = 'bear',
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
        selectedCharacterId: selectedCharacterId,
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
  Future<Result<User>> signInWithGoogle() async {
    return const Result.error(AuthException('Google 로그인은 준비 중입니다.'));
  }

  @override
  Future<Result<User>> signInWithApple() async {
    return const Result.error(AuthException('Apple 로그인은 준비 중입니다.'));
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

  @override
  Future<Result<void>> deleteAccount({
    required String currentPassword,
    required String username,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      return const Result.error(AuthException('로그인된 사용자가 없습니다.'));
    }

    try {
      await authService.reauthenticate(currentPassword: currentPassword);
      await userService.deleteUserDocuments(uid: uid, username: username);
      await authService.deleteCurrentUser();

      return const Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        e.toAuthException(defaultMessage: '계정 삭제 중 오류가 발생했습니다.'),
      );
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '계정 삭제 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(AuthException('계정 삭제 중 오류가 발생했습니다.', cause: e));
    }
  }
}
