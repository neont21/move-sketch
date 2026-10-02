import 'package:flutter/foundation.dart';
import 'user.dart';

@immutable
sealed class SocialAuthResult {
  const SocialAuthResult();
}

final class SocialAuthSuccess extends SocialAuthResult {
  final User user;

  const SocialAuthSuccess(this.user);
}

final class SocialAuthNeedsOnboarding extends SocialAuthResult {
  final String uid;
  final String? email;
  final String? defaultNickname;
  final String? defaultPhotoUrl;

  const SocialAuthNeedsOnboarding({
    required this.uid,
    this.email,
    this.defaultNickname,
    this.defaultPhotoUrl,
  });
}

final class SocialAuthCanceled extends SocialAuthResult {
  const SocialAuthCanceled();
}
