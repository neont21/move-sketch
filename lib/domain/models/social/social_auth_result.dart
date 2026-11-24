import 'package:flutter/foundation.dart';

import 'user.dart';

/// 소셜 로그인 시도 후 분기되는 인증 결과 상태를 정의하는 sealed 클래스입니다.
@immutable
sealed class SocialAuthResult {
  const SocialAuthResult();
}

/// 기존 가입 계정으로 인증되어 정상 로그인된 성공 결과 모델입니다.
final class SocialAuthSuccess extends SocialAuthResult {
  /// 로그인에 성공한 사용자 도메인 모델.
  final User user;

  const SocialAuthSuccess(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialAuthSuccess &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

/// 소셜 인증은 완료되었으나 서비스 온보딩이 추가로 필요한 상태 모델입니다.
final class SocialAuthNeedsOnboarding extends SocialAuthResult {
  /// Firebase 인증으로부터 발급된 사용자 고유 식별자.
  final String uid;

  /// 소셜 계정에서 제공된 이메일 주소.
  final String? email;

  /// 온보딩 초기값으로 제안할 기본 닉네임.
  final String? defaultNickname;

  /// 온보딩 초기값으로 제안할 기본 프로필 사진 URL.
  final String? defaultPhotoUrl;

  const SocialAuthNeedsOnboarding({
    required this.uid,
    this.email,
    this.defaultNickname,
    this.defaultPhotoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialAuthNeedsOnboarding &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          defaultNickname == other.defaultNickname &&
          defaultPhotoUrl == other.defaultPhotoUrl;

  @override
  int get hashCode => Object.hash(uid, email, defaultNickname, defaultPhotoUrl);
}

/// 사용자가 소셜 로그인 절차를 직접 취소한 상태 모델입니다.
final class SocialAuthCanceled extends SocialAuthResult {
  const SocialAuthCanceled();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialAuthCanceled && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
