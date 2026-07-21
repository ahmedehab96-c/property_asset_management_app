import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

/// خريطة OpenStreetMap مع علامات العقارات.
class PropertyMapView extends StatelessWidget {
  const PropertyMapView({
    super.key,
    required this.properties,
    required this.onMarkerTap,
  });

  final List<Map<String, dynamic>> properties;
  final void Function(Map<String, dynamic> property) onMarkerTap;

  LatLng _center() {
    if (properties.isEmpty) return const LatLng(24.7136, 46.6753);
    double latSum = 0;
    double lngSum = 0;
    var count = 0;
    for (final p in properties) {
      final lat = p['latitude'];
      final lng = p['longitude'];
      if (lat is num && lng is num) {
        latSum += lat.toDouble();
        lngSum += lng.toDouble();
        count++;
      }
    }
    if (count == 0) return const LatLng(24.7136, 46.6753);
    return LatLng(latSum / count, lngSum / count);
  }

  @override
  Widget build(BuildContext context) {
    final center = _center();
    final markers = <Marker>[];

    for (final property in properties) {
      final lat = property['latitude'];
      final lng = property['longitude'];
      if (lat is! num || lng is! num) continue;

      final color = property['statusColor'] is Color
          ? property['statusColor'] as Color
          : AppColors.accentGold;

      markers.add(
        Marker(
          point: LatLng(lat.toDouble(), lng.toDouble()),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => onMarkerTap(property),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 22),
            ),
          ),
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 11,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.property.asset.management',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
