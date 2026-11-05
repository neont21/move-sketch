import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class SketchSignaturePainter extends CustomPainter {
  static const double _innerPadding = 4.0;

  final List<LatLng> points;
  final Color inkColor;
  final Color haloColor;
  final double strokeWidth;

  const SketchSignaturePainter({
    required this.points,
    required this.inkColor,
    required this.haloColor,
    this.strokeWidth = 2.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    double minLatitude = points.first.latitude;
    double maxLatitude = points.first.latitude;
    double minLongitude = points.first.longitude;
    double maxLongitude = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLatitude) minLatitude = point.latitude;
      if (point.latitude > maxLatitude) maxLatitude = point.latitude;
      if (point.longitude < minLongitude) minLongitude = point.longitude;
      if (point.longitude > maxLongitude) maxLongitude = point.longitude;
    }

    final double latitudeSpan = maxLatitude - minLatitude;
    final double longitudeSpan = maxLongitude - minLongitude;

    if (latitudeSpan <= 0.000001 && longitudeSpan <= 0.000001) {
      return;
    }

    final double midLatitude = (minLatitude + maxLatitude) / 2.0;
    final double latitudeRadians = midLatitude * (math.pi / 180.0);
    final double longitudeCorrection = math.cos(latitudeRadians);

    final double realWidthRatio = (longitudeSpan * longitudeCorrection).abs();
    final double realHeightRatio = latitudeSpan.abs();

    final double availableWidth = size.width - (_innerPadding * 2);
    final double availableHeight = size.height - (_innerPadding * 2);

    if (availableWidth <= 0 || availableHeight <= 0) {
      return;
    }

    final double scale = math.min(
      availableWidth / (realWidthRatio > 0 ? realWidthRatio : 1.0),
      availableHeight / (realHeightRatio > 0 ? realHeightRatio : 1.0),
    );

    final double drawnWidth = realWidthRatio * scale;
    final double drawnHeight = realHeightRatio * scale;

    final double offsetX = _innerPadding + (availableWidth - drawnWidth) / 2.0;
    final double offsetY =
        _innerPadding + (availableHeight - drawnHeight) / 2.0;

    final Path path = Path();
    for (int index = 0; index < points.length; index++) {
      final point = points[index];
      final double normalizedX =
          (point.longitude - minLongitude) * longitudeCorrection * scale;
      final double normalizedY = (maxLatitude - point.latitude) * scale;

      final double pixelX = offsetX + normalizedX;
      final double pixelY = offsetY + normalizedY;

      if (index == 0) {
        path.moveTo(pixelX, pixelY);
      } else {
        path.lineTo(pixelX, pixelY);
      }
    }

    final Paint shadowPaint = Paint()
      ..color = haloColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, shadowPaint);

    final Paint inkPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, inkPaint);
  }

  @override
  bool shouldRepaint(covariant SketchSignaturePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.inkColor != inkColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
