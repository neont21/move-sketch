import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PathTrackerView extends StatefulWidget {
  const PathTrackerView({super.key});

  @override
  State<PathTrackerView> createState() => _PathTrackerViewState();
}

class _PathTrackerViewState extends State<PathTrackerView> {
  final List<LatLng> _gpsRoute = [
    // sample data
    LatLng(37.5285, 126.9330),
    LatLng(37.5290, 126.9350),
    LatLng(37.5298, 126.9372),
    LatLng(37.5305, 126.9395),
    LatLng(37.5312, 126.9418),
    LatLng(37.5320, 126.9440),
    LatLng(37.5332, 126.9465),
    LatLng(37.5340, 126.9490),
    LatLng(37.5348, 126.9515),
    LatLng(37.5352, 126.9540),
    LatLng(37.5358, 126.9568),
    LatLng(37.5362, 126.9595),
  ];

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

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
            options: MapOptions(
              initialCenter: _gpsRoute.last,
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
              children: [
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _gpsRoute,
                      color: colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _gpsRoute.first,
                      width: 14,
                      height: 14,
                      child: Icon(
                        Icons.circle,
                        color: colorScheme.primary,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _gpsRoute.last,
                      width: 26,
                      height: 26,
                      child: Transform.rotate(
                        angle: 1,
                        child: Icon(
                          Icons.navigation,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        )
      ),
    );
  }
}
