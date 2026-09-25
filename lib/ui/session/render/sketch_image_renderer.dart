import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../../../config/assets.dart';
import '../../../domain/models/fixed/sketch_parts.dart';

class SketchImageRenderer {
  const SketchImageRenderer();
  Future<Uint8List?> renderSketch({
    required SketchComposition composition,
    double width = 512,
    double height = 512,
  }) async {
    final ordered = composition.orderedParts;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    var drawnAny = false;

    for (final part in ordered) {
      try {
        final byteData = await rootBundle.load(part.assetPath);
        final codec = await ui.instantiateImageCodec(
          byteData.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        final image = frame.image;
        final src = Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
        final dst = Rect.fromLTWH(0, 0, width, height);

        canvas.drawImageRect(image, src, dst, ui.Paint()..isAntiAlias = true);
        drawnAny = true;
      } catch (_) {
        // 아직 추가되지 않은 에셋이나 로드 실패 파일은 무시하고 안전하게 진행
      }
    }
    if (!drawnAny) {
      try {
        final fallbackData = await rootBundle.load(Assets.sampleSketch);
        return fallbackData.buffer.asUint8List();
      } catch (_) {
        return null;
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
