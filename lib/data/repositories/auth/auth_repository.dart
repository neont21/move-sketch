import 'dart:io';

import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/social/social_auth_result.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/result.dart';

/// 사용자 인증, 소셜 로그인, 계정 연동 및 탈퇴를 추상화한 저장소 인터페이스입니다.
abstract interface class AuthRepository {
  /// 현재 로그인된 유효 사용자의 UID.
  String? get currentUid;

  /// 로그인 및 로그아웃에 따른 유효 사용자 UID 변화 스트림.
  Stream<String?> get authStateChanges;

  /// 캐시된 이메일 인증 완료 여부.
  bool get isEmailVerified;

  /// 현재 계정에 연결된 인증 공급자 식별자 목록.
  List<String> get linkedProviders;

  /// 인증 공급자별 연결된 이메일 주소 매핑.
  Map<String, String> get providerEmails;

  /// 서버에서 최신 사용자 정보를 새로고침하여 이메일 인증 여부를 확인합니다.
  Future<Result<bool>> checkEmailVerified();

  /// 지정된 아이디([username])의 사용 가능 여부를 확인합니다.
  Future<Result<bool>> isUsernameAvailable(String username);

  /// 아이디([username])와 이메일([email]) 기반으로 신규 회원가입을 수행합니다.
  Future<Result<User>> signUpWithUsername({
    required String username,
    required String nickname,
    required String email,
    required String password,
    CharacterType selectedCharacter = CharacterType.bear,
  });

  /// 아이디 또는 이메일([username])과 비밀번호([password])로 로그인합니다.
  Future<Result<User>> signInWithUsername({
    required String username,
    required String password,
  });

  /// Google 계정으로 로그인하거나 신규 온보딩 상태를 반환합니다.
  Future<Result<SocialAuthResult>> signInWithGoogle();

  /// Apple 계정으로 로그인하거나 신규 온보딩 상태를 반환합니다.
  Future<Result<SocialAuthResult>> signInWithApple();

  /// 소셜 로그인 인증 후 신규 사용자의 프로필([username], [nickname], [selectedCharacter])을 확정하여 가입을 완료합니다.
  Future<Result<User>> completeSocialSignUp({
    required String username,
    required String nickname,
    required CharacterType selectedCharacter,
    File? imageFile,
    String? profileImageUrl,
  });

  /// 현재 계정에 Google 인증 수단을 연동합니다.
  Future<Result<bool>> linkGoogle();

  /// 현재 계정에 Apple 인증 수단을 연동합니다.
  Future<Result<bool>> linkApple();

  /// 현재 소셜 계정에 이메일([email]) 및 비밀번호 인증 수단을 연동합니다.
  Future<Result<void>> linkEmailAndPassword({
    required String email,
    required String password,
  });

  /// 현재 계정에서 지정된 인증 공급자([providerId]) 연동을 해제합니다.
  Future<Result<void>> unlinkProvider(String providerId);

  /// 현재 사용자 계정을 로그아웃합니다.
  Future<Result<void>> signOut();

  /// 지정된 이메일([email])로 비밀번호 재설정 메일을 전송합니다.
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// 현재 사용자에게 이메일 인증 메일을 재발송합니다.
  Future<Result<void>> resendVerificationEmail();

  /// 기존 비밀번호([currentPassword])를 검증한 뒤 새 비밀번호([newPassword])로 변경합니다.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// 비밀번호 재인증을 거쳐 사용자 계정 및 관련 문서를 영구 삭제합니다.
  Future<Result<void>> deleteAccountWithPassword({
    required String currentPassword,
    required String username,
  });

  /// Google 재인증을 거쳐 사용자 계정 및 관련 문서를 영구 삭제합니다.
  Future<Result<bool>> deleteAccountWithGoogle({required String username});

  /// Apple 재인증을 거쳐 사용자 계정 및 관련 문서를 영구 삭제합니다.
  Future<Result<bool>> deleteAccountWithApple({required String username});
}
