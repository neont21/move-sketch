import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'exceptions.dart';
import 'result.dart';

abstract final class UrlLauncherUtils {
  static const String _iosAppId = '6819965333';
  static const String _androidPackageName = 'com.neonsightrap.move_sketch';

  static const String iosStoreUrl =
      'https://apps.apple.com/kr/app//id$_iosAppId';

  static const String androidStoreUrl =
      'market://details?id=$_androidPackageName';

  static const String androidWebStoreUrl =
      'https://play.google.com/store/apps/details?id=$_androidPackageName';

  static Future<Result<void>> openExternalUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      return Result.error(ValidationException('유효하지 않은 URL 형식입니다: $urlString'));
    }

    try {
      final isLaunched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!isLaunched) {
        return Result.error(
          ExternalAppException('해당 URL을 열 수 있는 애플리케이션을 찾을 수 없습니다: $urlString'),
        );
      }

      return const Result.ok(null);
    } catch (e) {
      return Result.error(
        ExternalAppException('외부 링크 실행 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  static Future<Result<void>> openStore() async {
    if (kIsWeb) {
      return const Result.error(
        ExternalAppException('웹 플랫폼에서는 스토어 이동을 지원하지 않습니다.'),
      );
    }

    if (Platform.isIOS) {
      return openExternalUrl(iosStoreUrl);
    } else if (Platform.isAndroid) {
      final marketResult = await openExternalUrl(androidStoreUrl);

      return switch (marketResult) {
        Ok() => const Result.ok(null),
        Error() => openExternalUrl(androidWebStoreUrl),
      };
    } else {
      return const Result.error(ExternalAppException('지원되지 않는 운영체제입니다.'));
    }
  }
}
