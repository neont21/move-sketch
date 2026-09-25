import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../domain/models/session/location_point.dart';

abstract final class PolylineUtils {
  static Future<List<LatLng>> simplify(
    List<LatLng> gpsPoints, {
    double epsilon = 0.00005,
    int computeThreshold = 100,
  }) async {
    if (gpsPoints.length < 3) {
      return gpsPoints;
    }

    if (gpsPoints.length >= computeThreshold) {
      return compute(_simplifyRdpTask, (
        gpsPoints: gpsPoints,
        epsilon: epsilon,
      ));
    }

    return _rdp(gpsPoints, epsilon);
  }

  static Future<List<LatLng>> simplifyLocationPoints(
    List<LocationPoint> gpsPoints, {
    double epsilon = 0.00005,
    int computeThreshold = 100,
  }) {
    final latLngs = gpsPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return simplify(
      latLngs,
      epsilon: epsilon,
      computeThreshold: computeThreshold,
    );
  }

  static String encodePolyline(List<LatLng> gpsPoints) {
    final StringBuffer result = StringBuffer();
    int lastLat = 0;
    int lastLng = 0;

    for (final point in gpsPoints) {
      final int lat = (point.latitude * 1e5).round();
      final int lng = (point.longitude * 1e5).round();

      final dLat = lat - lastLat;
      final dLng = lng - lastLng;

      _encodeValue(dLat, result);
      _encodeValue(dLng, result);

      lastLat = lat;
      lastLng = lng;
    }

    return result.toString();
  }

  static void _encodeValue(int value, StringBuffer result) {
    int remainingValue = value < 0 ? ~(value << 1) : (value << 1);

    while (remainingValue >= 0x20) {
      result.writeCharCode((0x20 | (remainingValue & 0x1f)) + 63);
      remainingValue >>= 5;
    }

    result.writeCharCode(remainingValue + 63);
  }

  static List<LatLng> _rdp(List<LatLng> points, double epsilon) {
    if (points.length < 3) {
      return points;
    }

    int maxIndex = 0;
    double maxDist = 0.0;

    final first = points.first;
    final last = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final dist = _perpendicularDistance(points[i], first, last);

      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = i;
      }
    }

    if (maxDist > epsilon) {
      final left = _rdp(points.sublist(0, maxIndex + 1), epsilon);
      final right = _rdp(points.sublist(maxIndex), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [first, last];
    }
  }

  static double _perpendicularDistance(
    LatLng p,
    LatLng lineStart,
    LatLng lineEnd,
  ) {
    final double dx = lineEnd.longitude - lineStart.longitude;
    final double dy = lineEnd.latitude - lineStart.latitude;
    final double mag = math.sqrt(dx * dx + dy * dy);

    if (mag == 0.0) {
      final px = p.longitude - lineStart.longitude;
      final py = p.latitude - lineStart.latitude;
      return math.sqrt(px * px + py * py);
    }

    final double u =
        ((p.longitude - lineStart.longitude) * dx +
            (p.latitude - lineStart.latitude) * dy) /
        (mag * mag);

    double nearestX;
    double nearestY;

    if (u < 0.0) {
      nearestX = lineStart.longitude;
      nearestY = lineStart.latitude;
    } else if (u > 1.0) {
      nearestX = lineEnd.longitude;
      nearestY = lineEnd.latitude;
    } else {
      nearestX = lineStart.longitude + u * dx;
      nearestY = lineStart.latitude + u * dy;
    }

    final double distDx = p.longitude - nearestX;
    final double distDy = p.latitude - nearestY;

    return math.sqrt(distDx * distDx + distDy * distDy);
  }
}

List<LatLng> _simplifyRdpTask(({List<LatLng> gpsPoints, double epsilon}) params) {
  return PolylineUtils._rdp(params.gpsPoints, params.epsilon);
}
