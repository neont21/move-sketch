import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/models/session/location_point.dart';

class PathTrackerView extends StatefulWidget {
  final List<LatLng> gpsPoints;
  final LatLng? initialCenter;
  final double initialZoom;
  final bool isTracking;
  final double? heading;

  const PathTrackerView({
    super.key,
    this.gpsPoints = const [],
    this.initialCenter,
    this.initialZoom = 15.0,
    this.isTracking = false,
    this.heading,
  });

  factory PathTrackerView.fromLocationPoints({
    Key? key,
    required List<LocationPoint> points,
    LatLng? initialCenter,
    double initialZoom = 15.0,
    bool isTracking = true,
  }) {
    return PathTrackerView(
      key: key,
      gpsPoints: points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
      initialCenter: initialCenter,
      initialZoom: initialZoom,
      isTracking: isTracking,
      heading: points.lastOrNull?.heading,
    );
  }

  @override
  State<PathTrackerView> createState() => _PathTrackerViewState();
}

class _PathTrackerViewState extends State<PathTrackerView> {
  late MapController _mapController;
  bool _isMapReady = false;
  double _currentBearing = 0.0;

  static const LatLng _defaultCenterSeoul = LatLng(37.5665, 126.9780);

  double _calculateBearing(LatLng start, LatLng end) {
    const degToRad = math.pi / 180.0;
    final lat1 = start.latitude * degToRad;
    final lat2 = end.latitude * degToRad;
    final dLon = (end.longitude - start.longitude) * degToRad;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return math.atan2(y, x);
  }

  void _updateBearing() {
    if (widget.heading != null && widget.heading! > 0) {
      _currentBearing = widget.heading! * (math.pi / 180.0);
      return;
    }
    if (widget.gpsPoints.length >= 2) {
      final last = widget.gpsPoints.last;
      final prev = widget.gpsPoints[widget.gpsPoints.length - 2];
      if (last.latitude != prev.latitude || last.longitude != prev.longitude) {
        _currentBearing = _calculateBearing(prev, last);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _mapController = MapController();
    _updateBearing();
  }

  @override
  void dispose() {
    _mapController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PathTrackerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateBearing();
    if (_isMapReady && widget.isTracking && widget.gpsPoints.isNotEmpty) {
      final lastestPoint = widget.gpsPoints.last;
      final oldLastPoint = oldWidget.gpsPoints.lastOrNull;
      if (oldLastPoint == null || lastestPoint != oldLastPoint) {
        _mapController.move(lastestPoint, _mapController.camera.zoom);
      }
    }
  }

  LatLng get _resolvedCenter {
    if (widget.gpsPoints.isNotEmpty) {
      return widget.gpsPoints.last;
    }
    return widget.initialCenter ?? _defaultCenterSeoul;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final markers = <Marker>[];
    if (widget.gpsPoints.isNotEmpty) {
      markers.add(
        Marker(
          point: widget.gpsPoints.first,
          width: 14,
          height: 14,
          child: Icon(Icons.circle, color: colorScheme.primary, size: 12),
        ),
      );
    }
    if (widget.gpsPoints.length > 1) {
      markers.add(
        Marker(
          point: widget.gpsPoints.last,
          child: widget.isTracking
              ? Transform.rotate(
                  angle: _currentBearing,
                  child: Icon(
                    Icons.navigation,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                )
              : Icon(Icons.location_on, color: colorScheme.secondary, size: 24),
        ),
      );
    }

    return FractionallySizedBox(
      widthFactor: 1,
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline),
          ),
          clipBehavior: Clip.hardEdge,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _resolvedCenter,
              initialZoom: widget.initialZoom,
              onMapReady: () {
                _isMapReady = true;
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              if (widget.gpsPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.gpsPoints,
                      color: colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              if (markers.isNotEmpty) MarkerLayer(markers: markers),
            ],
          ),
        ),
      ),
    );
  }
}
