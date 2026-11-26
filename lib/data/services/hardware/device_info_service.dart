import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../domain/models/system/app_device_info.dart';

/// 실행 중인 단말기의 하드웨어 모델, OS 버전 및 앱 버전 정보를 수집하는 하드웨어 서비스 클래스입니다.
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceInfoService({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  /// 현재 실행 플랫폼에 맞는 기기 및 앱 메타데이터를 조회하여 [AppDeviceInfo]로 반환합니다.
  Future<AppDeviceInfo> getDeviceInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion =
        'v${packageInfo.version} (${packageInfo.buildNumber})';

    if (kIsWeb) {
      final WebBrowserInfo webInfo = await _deviceInfoPlugin.webBrowserInfo;
      return AppDeviceInfo(
        deviceModel: 'Web Browser (${webInfo.browserName.name})',
        osVersion: webInfo.userAgent ?? 'Unknown Web UserAgent',
        appVersion: appVersion,
      );
    }

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
      final String manufacturer = androidInfo.manufacturer.isNotEmpty
          ? '${androidInfo.manufacturer} '
          : '';
      final String deviceModel = '$manufacturer${androidInfo.model}'.trim();
      final String osVersion =
          'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})';

      return AppDeviceInfo(
        deviceModel: deviceModel,
        osVersion: osVersion,
        appVersion: appVersion,
      );
    }

    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
      final String machine = iosInfo.utsname.machine;
      final String deviceModel = machine.isNotEmpty
          ? '${iosInfo.name} ($machine)'
          : iosInfo.name;
      final String osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';

      return AppDeviceInfo(
        deviceModel: deviceModel,
        osVersion: osVersion,
        appVersion: appVersion,
      );
    }

    return AppDeviceInfo(
      deviceModel: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      appVersion: appVersion,
    );
  }
}
