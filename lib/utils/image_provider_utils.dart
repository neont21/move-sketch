import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

abstract final class ImageProviderUtils {
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
