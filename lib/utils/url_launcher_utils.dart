import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/models/system/app_device_info.dart';
import 'exceptions.dart';
import 'result.dart';

/// 외부 웹 브라우저, 앱 스토어 및 문의 메일 클라이언트 실행 기능을 제공하는 유틸리티입니다.
abstract final class UrlLauncherUtils {
  static const String _iosAppId = '6819965333';
  static const String _androidPackageName = 'com.neonsigntrap.move_sketch';

  /// 고객 지원 및 문의 수신용 공식 이메일 주소.
  static const String supportEmail = 'movesketch@neonsigntrap.com';

  /// 애플 앱스토어 앱 상세 페이지 URL.
  static const String iosStoreUrl =
      'https://apps.apple.com/kr/app/id$_iosAppId';

  /// 구글 플레이스토어 앱 직접 실행 마켓 스킴 URL.
  static const String androidStoreUrl =
      'market://details?id=$_androidPackageName';

  /// 구글 플레이스토어 웹 폴백 URL.
  static const String androidWebStoreUrl =
      'https://play.google.com/store/apps/details?id=$_androidPackageName';

  /// 공지사항 웹 페이지 URL.
  static const String noticesWebUrl =
      'https://movesketch.neonsigntrap.com/notices.html';

  /// 개인정보 처리방침 웹 페이지 URL.
  static const String privacyWebUrl =
      'https://movesketch.neonsigntrap.com/privacy.html';

  /// 서비스 이용약관 웹 페이지 URL.
  static const String termsWebUrl =
      'https://movesketch.neonsigntrap.com/terms.html';

  /// 지정된 URL 문자열([urlString])을 외부 브라우저 또는 인앱 브라우저([inApp])로 실행합니다.
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

  /// 현재 플랫폼(iOS/Android)에 맞는 앱 스토어로 이동합니다. ([customStoreUrl]이 지정된 경우 해당 URL을 우선 실행)
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

  // mailto: URI 스킴에서 공백이 '+'로 잘못 인코딩되는 것을 방지하기 위해 퍼센트 인코딩(%20)을 적용한 쿼리 문자열을 생성합니다.
  static String? _encodeQueryParameters(Map<String, String> parameters) {
    return parameters.entries
        .map(
          (MapEntry<String, String> parameterEntry) =>
              '${Uri.encodeComponent(parameterEntry.key)}=${Uri.encodeComponent(parameterEntry.value)}',
        )
        .join('&');
  }

  /// 기기 및 앱 환경 정보([deviceInfo])가 미리 채워진 문의 이메일 작성 화면을 엽니다.
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
