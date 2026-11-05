import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../../../utils/polyline_utils.dart';
import 'sketch_signature_painter.dart';

class SketchSignatureView extends StatelessWidget {
  final String? routePolyline;
  final List<LatLng>? points;
  final double size;
  final Color? inkColor;

  const SketchSignatureView({
    super.key,
    this.routePolyline,
    this.points,
    this.size = 80,
    this.inkColor,
  }) : assert(
         routePolyline != null || points != null,
         'routePolyline 또는 points 중 하나는 반드시 제공되어야 합니다.',
       );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final List<LatLng> resolvedPoints =
        points ??
        (routePolyline != null && routePolyline!.isNotEmpty
            ? PolylineUtils.decodePolyline(routePolyline!)
            : const <LatLng>[]);

    if (resolvedPoints.length < 2) {
      return const SizedBox.shrink();
    }

    final Color effectiveInkColor = inkColor ?? colorScheme.primary;
    final Color effectiveHaloColor = colorScheme.surface;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: SketchSignaturePainter(
          points: resolvedPoints,
          inkColor: effectiveInkColor,
          haloColor: effectiveHaloColor,
          strokeWidth: 2.8,
        ),
      ),
    );
  }
}
