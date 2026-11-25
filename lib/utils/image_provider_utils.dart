import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// 실행 플랫폼(Web/Mobile)에 적합한 네트워크 [ImageProvider]를 생성하는 유틸리티입니다.
abstract final class ImageProviderUtils {
  /// 원격 이미지 URL([imageUrl])에 대해 플랫폼에 맞는 [ImageProvider]를 반환합니다.
  ///
  /// 웹 환경에서는 CORS 및 캐시 엔진 호환성을 위해 [NetworkImage]를 사용하고,
  /// 모바일 환경에서는 디스크 캐싱과 리사이징([maxWidth], [maxHeight])을 지원하는 [CachedNetworkImageProvider]를 반환합니다.
  static ImageProvider resolve(
    String imageUrl, {
    int? maxWidth,
    int? maxHeight,
  }) {
    if (kIsWeb) {
      return NetworkImage(imageUrl);
    }

    return CachedNetworkImageProvider(
      imageUrl,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}
