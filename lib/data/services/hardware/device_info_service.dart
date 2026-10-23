import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:move_sketch/domain/models/system/app_device_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceInfoService({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

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
