import 'package:flutter/foundation.dart';

import '../enums/update_type.dart';

/// 앱 버전 강제/권장 업데이트 정책 및 배포 정보를 나타내는 불변 모델입니다.
@immutable
final class AppVersionPolicy {
  /// 현재 스토어에 배포된 최신 앱 버전.
  final String latestVersion;
  /// 현재 스토어에 배포된 최신 빌드 번호.
  final int latestBuildNumber;
  /// 앱 사용을 위해 요구되는 최소 필수 버전.
  final String minRequiredVersion;
  /// 앱 사용을 위해 요구되는 최소 필수 빌드 번호.
  final int minRequiredBuildNumber;
  /// 업데이트 안내 팝업의 제목.
  final String title;
  /// 업데이트 주요 변경 사항 및 배포 릴리즈 노트.
  final String releaseNotes;
  /// 구글 플레이스토어 바로가기 URL. (선택 사항)
  final String? androidStoreUrl;
  /// 애플 앱스토어 바로가기 URL. (선택 사항)
  final String? iosStoreUrl;

  const AppVersionPolicy({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.minRequiredVersion,
    required this.minRequiredBuildNumber,
    required this.title,
    required this.releaseNotes,
    this.androidStoreUrl,
    this.iosStoreUrl,
  });

  /// 현재 구동 중인 앱의 빌드 번호와 비교하여 필요한 업데이트 수준을 판정합니다.
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
      androidStoreUrl: map['androidStoreUrl'] as String?,
      iosStoreUrl: map['iosStoreUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latestVersion': latestVersion,
      'latestBuildNumber': latestBuildNumber,
      'minRequiredVersion': minRequiredVersion,
      'minRequiredBuildNumber': minRequiredBuildNumber,
      'title': title,
      'releaseNotes': releaseNotes,
      'androidStoreUrl': androidStoreUrl,
      'iosStoreUrl': iosStoreUrl,
    };
  }

  AppVersionPolicy copyWith({
    String? latestVersion,
    int? latestBuildNumber,
    String? minRequiredVersion,
    int? minRequiredBuildNumber,
    String? title,
    String? releaseNotes,
    String? androidStoreUrl,
    String? iosStoreUrl,
  }) {
    return AppVersionPolicy(
      latestVersion: latestVersion ?? this.latestVersion,
      latestBuildNumber: latestBuildNumber ?? this.latestBuildNumber,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
      minRequiredBuildNumber:
          minRequiredBuildNumber ?? this.minRequiredBuildNumber,
      title: title ?? this.title,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      androidStoreUrl: androidStoreUrl ?? this.androidStoreUrl,
      iosStoreUrl: iosStoreUrl ?? this.iosStoreUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AppVersionPolicy &&
        other.latestVersion == latestVersion &&
        other.latestBuildNumber == latestBuildNumber &&
        other.minRequiredVersion == minRequiredVersion &&
        other.minRequiredBuildNumber == minRequiredBuildNumber &&
        other.title == title &&
        other.releaseNotes == releaseNotes &&
        other.androidStoreUrl == androidStoreUrl &&
        other.iosStoreUrl == iosStoreUrl;
  }

  @override
  int get hashCode => Object.hash(
    latestVersion,
    latestBuildNumber,
    minRequiredVersion,
    minRequiredBuildNumber,
    title,
    releaseNotes,
    androidStoreUrl,
    iosStoreUrl,
  );
}
