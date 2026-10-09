import 'package:flutter/foundation.dart';
import 'enums/update_type.dart';

@immutable
final class AppVersionPolicy {
  final String latestVersion;
  final int latestBuildNumber;
  final String minRequiredVersion;
  final int minRequiredBuildNumber;
  final String title;
  final String releaseNotes;

  const AppVersionPolicy({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.minRequiredVersion,
    required this.minRequiredBuildNumber,
    required this.title,
    required this.releaseNotes,
  });

  UpdateType checkUpdateType(int currentBuildNumber) {
    if (currentBuildNumber < minRequiredBuildNumber) {
      return UpdateType.force;
    } else if (currentBuildNumber < latestBuildNumber) {
      return UpdateType.recommend;
    } else {
      return UpdateType.none;
    }
  }

  factory AppVersionPolicy.fromMap(Map<String, dynamic> map) {
    return AppVersionPolicy(
      latestVersion: map['latestVersion'] as String? ?? '1.0.0',
      latestBuildNumber: (map['latestBuildNumber'] as num?)?.toInt() ?? 1,
      minRequiredVersion: map['minRequiredVersion'] as String? ?? '1.0.0',
      minRequiredBuildNumber:
          (map['minRequiredBuildNumber'] as num?)?.toInt() ?? 1,
      title: map['title'] as String? ?? '새로운 버전이 출시되었습니다!',
      releaseNotes: map['releaseNotes'] as String? ?? '',
    );
  }
}
