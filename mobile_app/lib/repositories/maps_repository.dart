import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class MapsLoadResult {
  final List<Map<String, dynamic>> properties;
  final bool fromDemo;

  const MapsLoadResult({
    required this.properties,
    required this.fromDemo,
  });
}

/// عقارات الخريطة: API أولاً، ثم بيانات تجريبية.
class MapsRepository {
  MapsRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  List<Map<String, dynamic>> _demoProperties(
    AppLocalizations l10n,
    bool isArabic,
  ) =>
      LocalizedDemoData(l10n: l10n, isArabic: isArabic).mapProperties();

  Future<MapsLoadResult> loadMapProperties({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    if (DemoMode.isActive) {
      return MapsLoadResult(
        properties: _demoProperties(l10n, isArabic),
        fromDemo: true,
      );
    }

    try {
      final raw = await _api.getMyProperties();
      final mapped =
          raw.map((p) => OwnerApiMappers.toMapPropertyPin(p, l10n)).toList();
      return MapsLoadResult(properties: mapped, fromDemo: false);
    } catch (_) {
      return const MapsLoadResult(properties: [], fromDemo: false);
    }
  }
}
