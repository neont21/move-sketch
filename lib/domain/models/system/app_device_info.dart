import 'package:flutter/foundation.dart';

/// 앱이 구동되는 클라이언트 기기 및 애플리케이션 버전 메타데이터를 나타내는 불변 모델입니다.
@immutable
final class AppDeviceInfo {
  /// 단말기 모델 식별자.
  final String deviceModel;
  /// 운영체제 버전 문자열.
  final String osVersion;
  /// 앱 버전 및 빌드 번호.
  final String appVersion;

  const AppDeviceInfo({
    required this.deviceModel,
    required this.osVersion,
    required this.appVersion,
  });

  /// 이메일 프리셋 본문 등에 삽입하기 위한 표준 다중 행 텍스트를 반환합니다.
  String toFormattedString() {
    return '- 앱 버전: $appVersion\n'
        '- 기기 모델: $deviceModel\n'
        '- OS 버전: $osVersion';
  }

  @override
  String toString() =>
      'AppDeviceInfo(deviceModel: $deviceModel, osVersion: $osVersion, appVersion: $appVersion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDeviceInfo &&
          runtimeType == other.runtimeType &&
          deviceModel == other.deviceModel &&
          osVersion == other.osVersion &&
          appVersion == other.appVersion;
  @override
  int get hashCode => Object.hash(deviceModel, osVersion, appVersion);
}
