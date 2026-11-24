import 'dart:io';
import 'package:flutter/foundation.dart';

/// 소셜 로그인 신규 가입자가 온보딩 화면에서 입력한 초기 프로필 정보를 나타내는 불변 모델입니다.
@immutable
final class SocialOnboardingProfile {
  /// 사용자가 설정한 고유 계정 아이디.
  final String username;

  /// 서비스 내에 표시할 사용자 닉네임.
  final String nickname;

  /// 사용자가 기기 갤러리 등에서 직접 선택한 로컬 프로필 이미지 파일.
  final File? imageFile;

  /// 소셜 제공자로부터 전달받은 기본 프로필 사진 URL.
  final String? socialPhotoUrl;

  const SocialOnboardingProfile({
    required this.username,
    required this.nickname,
    this.imageFile,
    this.socialPhotoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialOnboardingProfile &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          nickname == other.nickname &&
          imageFile?.path == other.imageFile?.path &&
          socialPhotoUrl == other.socialPhotoUrl;

  @override
  int get hashCode =>
      Object.hash(username, nickname, imageFile?.path, socialPhotoUrl);
}
