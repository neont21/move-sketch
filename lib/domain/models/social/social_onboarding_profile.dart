import 'dart:io';
import 'package:flutter/foundation.dart';

@immutable
class SocialOnboardingProfile {
  final String username;
  final String nickname;
  final File? imageFile;
  final String? socialPhotoUrl;

  const SocialOnboardingProfile({
    required this.username,
    required this.nickname,
    this.imageFile,
    this.socialPhotoUrl,
  });
}