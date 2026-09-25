import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:move_sketch/ui/core/theme/theme.dart';

import '../../../domain/models/session/location_point.dart';

class RouteImageRenderer {
  const RouteImageRenderer();

  Future<Uint8List?> renderRoute({
    required List<LatLng> gpsPoints,
    double width = 512,
    double height = 512,
    double padding = 48,
    ColorScheme? colorScheme,
    Color? routeColor,
    Color? startColor,
    Color? endColor,
    Color? backgroundColor,
    double strokeWidth = 8.0,
  }) async {
    if (gpsPoints.length < 2) {
      return null;
    }

    final scheme = colorScheme ?? MoveSketchTheme.lightTheme.colorScheme;
    final bgColor = backgroundColor ?? scheme.surfaceContainer;
    final lineColor = routeColor ?? scheme.primary;
    final fromColor = startColor ?? scheme.primary;
    final toColor = endColor ?? scheme.primary;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTRB(0, 0, width, height));

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    double minLat = gpsPoints.first.latitude;
    double maxLat = gpsPoints.first.latitude;
    double minLng = gpsPoints.first.longitude;
    double maxLng = gpsPoints.first.longitude;

    for (final point in gpsPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final latSpan = maxLat - minLat;
    final lngSpan = maxLng - minLng;
    final drawWidth = width - (padding * 2);
    final drawHeight = height - (padding * 2);

    final scaleX = lngSpan > 0 ? drawWidth / lngSpan : 1.0;
    final scaleY = latSpan > 0 ? drawHeight / latSpan : 1.0;
    final scale = math.min(scaleX, scaleY);

    final contentWidth = lngSpan * scale;
    final contentHeight = latSpan * scale;
    final offsetX = padding + (drawWidth - contentWidth) / 2;
    final offsetY = padding + (drawHeight - contentHeight) / 2;

    Offset toCanvasOffset(LatLng latLng) {
      final x = offsetX + (latLng.longitude - minLng) * scale;
      final y = offsetY + (maxLat - latLng.latitude) * scale;
      return Offset(x, y);
    }

    final path = Path();
    final firstOffset = toCanvasOffset(gpsPoints.first);
    path.moveTo(firstOffset.dx, firstOffset.dy);
    for (int i = 1; i < gpsPoints.length; i++) {
      final nextOffset = toCanvasOffset(gpsPoints[i]);
      path.lineTo(nextOffset.dx, nextOffset.dy);
    }
    final routePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    final startOffset = toCanvasOffset(gpsPoints.first);
    final endOffset = toCanvasOffset(gpsPoints.last);

    canvas.drawCircle(startOffset, 9, Paint()..color = scheme.surface);
    canvas.drawCircle(startOffset, 7, Paint()..color = fromColor);

    canvas.drawCircle(endOffset, 9, Paint()..color = scheme.surface);
    canvas.drawCircle(endOffset, 7, Paint()..color = toColor);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<Uint8List?> renderLocationPoints({
    required List<LocationPoint> points,
    ColorScheme? colorScheme,
    double width = 512,
    double height = 512,
  }) {
    final latLngs =
    points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    return renderRoute(
      gpsPoints: latLngs,
      colorScheme: colorScheme,
      width: width,
      height: height,
    );
  }
}
