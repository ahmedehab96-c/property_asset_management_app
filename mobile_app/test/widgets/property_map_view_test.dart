import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_asset_management_app/widgets/property_map_view.dart';

void main() {
  testWidgets('PropertyMapView renders map and marker', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyMapView(
            properties: const [
              {
                'latitude': 24.7136,
                'longitude': 46.6753,
                'statusColor': Colors.green,
                'name': 'Test',
              },
            ],
            onMarkerTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });
}
