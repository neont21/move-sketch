// lib/utils/polyline_utils.dart
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../domain/models/session/location_point.dart';

/// GPS 경로 좌표의 Ramer-Douglas-Peucker(RDP) 단순화 및 Google Encoded Polyline 직렬화/역직렬화를 제공하는 유틸리티입니다.
abstract final class PolylineUtils {
  /// 주어진 좌표 목록([gpsPoints])에 Ramer-Douglas-Peucker 알고리즘을 적용하여 경로를 단순화합니다.
  ///
  /// 좌표 개수가 [computeThreshold] 이상인 경우 UI 스레드 블로킹을 방지하기 위해 백그라운드 Isolate([compute])에서 연산을 수행합니다.
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

  /// [LocationPoint] 목록([gpsPoints])을 [LatLng] 목록으로 변환한 뒤 [simplify]를 수행하여 반환합니다.
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

  /// 좌표 목록([gpsPoints])을 Google Encoded Polyline 포맷 문자열로 인코딩합니다.
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

  /// Google Encoded Polyline 문자열([encoded])을 역직렬화하여 [LatLng] 좌표 목록을 반환합니다.
  static List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int length = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < length) {
      int code;
      int shift = 0;
      int result = 0;

      do {
        if (index >= length) {
          break;
        }

        code = encoded.codeUnitAt(index++) - 63;
        result |= (code & 0x1f) << shift;
        shift += 5;
      } while (code >= 0x20);

      final valueLat = result >> 1;
      // 웹(JS) 환경에서 32비트 비트 연산 오버플로로 인한 부호 반전 오류를 방지하기 위해 BigInt 사용
      final int dLat = (result & 1) != 0
          ? (~BigInt.from(valueLat)).toInt()
          : valueLat;
      lat += dLat;

      shift = 0;
      result = 0;

      do {
        if (index >= length) {
          break;
        }

        code = encoded.codeUnitAt(index++) - 63;
        result |= (code & 0x1f) << shift;
        shift += 5;
      } while (code >= 0x20);

      final valueLng = result >> 1;
      final int dLng = (result & 1) != 0
          ? (~BigInt.from(valueLng)).toInt()
          : valueLng;
      lng += dLng;

      final double latitude = lat / 1e5;
      final double longitude = lng / 1e5;

      if (latitude >= -90.0 &&
          latitude <= 90.0 &&
          longitude >= -180.0 &&
          longitude <= 180.0) {
        points.add(LatLng(latitude, longitude));
      }
    }

    return points;
  }

  // Google Encoded Polyline 알고리즘에 따라 단일 정수값을 5비트 청크 ASCII 문자로 변환하여 버퍼에 기록합니다.
  static void _encodeValue(int value, StringBuffer result) {
    int remainingValue = value < 0 ? ~(value << 1) : (value << 1);

    while (remainingValue >= 0x20) {
      result.writeCharCode((0x20 | (remainingValue & 0x1f)) + 63);
      remainingValue >>= 5;
    }

    result.writeCharCode(remainingValue + 63);
  }

  // Ramer-Douglas-Peucker 재귀 알고리즘으로 최대 수직 거리가 epsilon 이하인 중간 좌표들을 제거합니다.
  static List<LatLng> _rdp(List<LatLng> points, double epsilon) {
    if (points.length < 3) {
      return points;
    }

    int maxIndex = 0;
    double maxDist = 0.0;

    final first = points.first;
    final last = points.last;

    for (int index = 1; index < points.length - 1; index++) {
      final dist = _perpendicularDistance(points[index], first, last);

      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = index;
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

  // 점 point에서 선분까지의 최단 유클리드 수직 거리를 계산합니다.
  static double _perpendicularDistance(
    LatLng point,
    LatLng lineStart,
    LatLng lineEnd,
  ) {
    final double dx = lineEnd.longitude - lineStart.longitude;
    final double dy = lineEnd.latitude - lineStart.latitude;
    final double mag = math.sqrt(dx * dx + dy * dy);

    if (mag == 0.0) {
      final px = point.longitude - lineStart.longitude;
      final py = point.latitude - lineStart.latitude;
      return math.sqrt(px * px + py * py);
    }

    final double u =
        ((point.longitude - lineStart.longitude) * dx +
            (point.latitude - lineStart.latitude) * dy) /
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

    final double distDx = point.longitude - nearestX;
    final double distDy = point.latitude - nearestY;

    return math.sqrt(distDx * distDx + distDy * distDy);
  }
}

// compute() 백그라운드 Isolate에서 RDP 단순화를 실행하기 위한 최상위 진입점 함수입니다.
List<LatLng> _simplifyRdpTask(
  ({List<LatLng> gpsPoints, double epsilon}) params,
) {
  return PolylineUtils._rdp(params.gpsPoints, params.epsilon);
}
