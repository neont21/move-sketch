import '../../../domain/models/social/user.dart';

abstract interface class AuthRepository {
  /// 현재 로그인 중인 사용자의 UID를 조회한다.
  String? get currentUid;

  /// 로그인 및 로그아웃 시 계정 인증 상태 변화를 탐지한다.
  Stream<String?> get authStateChanges;

  /// 이메일 인증 여부를 확인한다. (cache data)
  bool get isEmailVerified;

  /// 캐싱되지 않은 이메일 인증 여부를 확인한다.
  Future<bool> checkEmailVerified();

  /// 아이디 사용 가능 여부를 확인한다.
  Future<bool> isUsernameAvailable(String username);

  /// 아이디를 사용하여 내부적으로 이메일 기반 회원가입을 한다.
  Future<User> signUpWithUsername({
    required String username,
    required String nickname,
    required String email,
    required String password,
    String selectedCharacterId = 'bear',
  });

  /// 아이디를 사용하여 내부적으로 이메일 기반 로그인을 한다.
  Future<User> signInWithUsername({
    required String username,
    required String password,
  });

  /// Google 계정으로 로그인(회원가입)한다.
  Future<User> signInWithGoogle();

  /// Apple 계정으로 로그인(회원가입)한다.
  Future<User> signInWithApple();

  /// 현재 사용자 계정을 로그아웃한다.
  Future<void> signOut();

  /// 비밀번호 재설정 이메일을 전송한다.
  Future<void> sendPasswordResetEmail(String email);

  /// 이메일 인증을 재발송한다.
  Future<void> resendVerificationEmail();

  /// 기존 비밀번호를 사용하여 비밀번호를 변경한다.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// 비밀번호 인증을 통해 계정을 삭제한다.
  Future<void> deleteAccount({
    required String currentPassword,
    required String username,
  });
}
