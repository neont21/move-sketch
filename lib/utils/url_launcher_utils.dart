import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/models/system/app_device_info.dart';
import 'exceptions.dart';
import 'result.dart';

abstract final class UrlLauncherUtils {
  static const String _iosAppId = '6819965333';
  static const String _androidPackageName = 'com.neonsigntrap.move_sketch';

  static const String supportEmail = 'movesketch@neonsigntrap.com';

  static const String iosStoreUrl =
      'https://apps.apple.com/kr/app/id$_iosAppId';
  static const String androidStoreUrl =
      'market://details?id=$_androidPackageName';
  static const String androidWebStoreUrl =
      'https://play.google.com/store/apps/details?id=$_androidPackageName';

  static const String noticesWebUrl =
      'https://movesketch.neonsigntrap.com/notices.html';
  static const String privacyWebUrl =
      'https://movesketch.neonsigntrap.com/privacy.html';
  static const String termsWebUrl =
      'https://movesketch.neonsigntrap.com/terms.html';

  static Future<Result<void>> openExternalUrl(
    String urlString, {
    bool inApp = false,
  }) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      return Result.error(ValidationException('유효하지 않은 URL 형식입니다: $urlString'));
    }

    try {
      final isLaunched = await launchUrl(
        uri,
        mode: inApp
            ? LaunchMode.inAppBrowserView
            : LaunchMode.externalApplication,
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

  static Future<Result<void>> openStore({String? customStoreUrl}) async {
    if (customStoreUrl != null && customStoreUrl.trim().isNotEmpty) {
      return openExternalUrl(customStoreUrl);
    }

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

  static String? _encodeQueryParameters(Map<String, String> parameters) {
    return parameters.entries
        .map(
          (MapEntry<String, String> parameterEntry) =>
              '${Uri.encodeComponent(parameterEntry.key)}=${Uri.encodeComponent(parameterEntry.value)}',
        )
        .join('&');
  }

  static Future<Result<void>> openInquiryEmail({
    required AppDeviceInfo deviceInfo,
  }) async {
    final String emailBody =
        '아래에 문의나 겪으신 문제를 자유롭게 작성해 주세요.\n'
        '(스크린샷을 함께 첨부해 주시면 더욱 신속한 확인이 가능합니다.)\n\n'
        '-----------------------------\n'
        '[기기 및 앱 정보]\n'
        '※ 기기 및 OS 환경에 따른 문제 원인을 정확히 파악하고 신속하게 조치하기 위해 필요한 정보이므로 삭제하지 말아주세요.\n'
        '${deviceInfo.toFormattedString()}\n'
        '-----------------------------\n';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': '[MoveSketch] 문의 및 버그 제보',
        'body': emailBody,
      }),
    );

    return openExternalUrl(emailLaunchUri.toString());
  }
}
