import 'package:flutter/foundation.dart';

@immutable
final class AppDeviceInfo {
  final String deviceModel;
  final String appVersion;
  final String osVersion;

  const AppDeviceInfo({
    required this.deviceModel,
    required this.osVersion,
    required this.appVersion,
  });

  String toFormattedString() {
    return '- 앱 버전: $appVersion\n'
        '- 기기 모델: $deviceModel\n'
        '- OS 버전: $osVersion';
  }

  @override
  String toString() =>
      'AppDeviceInfo(deviceModel: $deviceModel, osVersion: $osVersion, appVersion: $appVersion)';
}
