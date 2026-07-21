import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

void main() {
  final l10n = AppLocalizations(const Locale('ar'));

  group('OwnerApiMappers.extractUploadUrls', () {
    test('reads top-level url', () {
      final urls = OwnerApiMappers.extractUploadUrls({
        'data': {'url': 'https://cdn.example.com/a.jpg'},
      });
      expect(urls, ['https://cdn.example.com/a.jpg']);
    });

    test('reads files list with maps', () {
      final urls = OwnerApiMappers.extractUploadUrls({
        'files': [
          {'url': 'https://cdn.example.com/1.jpg'},
          {'path': 'https://cdn.example.com/2.jpg'},
        ],
      });
      expect(urls, [
        'https://cdn.example.com/1.jpg',
        'https://cdn.example.com/2.jpg',
      ]);
    });

    test('returns empty list for unknown shape', () {
      expect(OwnerApiMappers.extractUploadUrls(null), isEmpty);
      expect(OwnerApiMappers.extractUploadUrls({'ok': true}), isEmpty);
    });
  });

  group('OwnerApiMappers.toMapPropertyPin', () {
    test('maps coordinates and rent', () {
      final pin = OwnerApiMappers.toMapPropertyPin({
        'id': 7,
        'name': 'Villa A',
        'location': 'Riyadh',
        'latitude': 24.7,
        'longitude': 46.6,
        'rent_amount': 12000,
        'status': 'rented',
      }, l10n);

      expect(pin['id'], 7);
      expect(pin['name'], 'Villa A');
      expect(pin['latitude'], 24.7);
      expect(pin['longitude'], 46.6);
      expect(pin['statusType'], isNotEmpty);
      expect(pin['statusColor'], isA<Color>());
    });

    test('falls back to default coordinates when missing', () {
      final pin = OwnerApiMappers.toMapPropertyPin({
        'name': 'Office',
        'status': 'vacant',
      }, l10n);

      expect(pin['latitude'], 24.7136);
      expect(pin['longitude'], 46.6753);
    });
  });
}
