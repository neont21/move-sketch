import 'package:flutter/foundation.dart';
import '../enums/update_type.dart';

@immutable
final class AppVersionPolicy {
  final String latestVersion;
  final int latestBuildNumber;
  final String minRequiredVersion;
  final int minRequiredBuildNumber;
  final String title;
  final String releaseNotes;
  final String? androidStoreUrl;
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
