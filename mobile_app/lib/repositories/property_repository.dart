import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class PropertiesLoadResult {
  final List<Map<String, dynamic>> properties;
  final bool fromDemo;
  final bool hasMore;

  const PropertiesLoadResult({
    required this.properties,
    required this.fromDemo,
    this.hasMore = false,
  });
}

/// عقارات المالك: API أولاً، ثم بيانات تجريبية عند الفشل أو الوضع التجريبي.
class PropertyRepository {
  PropertyRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  static const defaultPerPage = 20;

  List<Map<String, dynamic>> _demoProperties(
    AppLocalizations l10n,
    bool isArabic,
  ) =>
      LocalizedDemoData(l10n: l10n, isArabic: isArabic).myProperties();

  Future<PropertiesLoadResult> loadMyProperties({
    required AppLocalizations l10n,
    required bool isArabic,
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    if (DemoMode.isActive) {
      return PropertiesLoadResult(
        properties: _demoProperties(l10n, isArabic),
        fromDemo: true,
      );
    }

    try {
      final raw = await _api.getMyProperties(
        query: {'page': page, 'per_page': perPage},
      );
      final mapped = raw
          .map((p) => OwnerApiMappers.toMyPropertyCard(p, l10n))
          .toList();
      return PropertiesLoadResult(
        properties: mapped,
        fromDemo: false,
        hasMore: raw.length >= perPage,
      );
    } catch (_) {
      return const PropertiesLoadResult(properties: [], fromDemo: false);
    }
  }

  Future<Map<String, dynamic>?> loadPropertyDetail({
    required int id,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    if (DemoMode.isActive) return null;

    try {
      final raw = await _api.getPropertyDetail(id);
      if (raw == null) return null;
      return OwnerApiMappers.toMyPropertyCard(raw, l10n)['detail']
          as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<PropertyDetailLoadResult> loadPropertyDetailForScreen({
    required Map<String, dynamic> seed,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    final id = (seed['id'] as num?)?.toInt();
    if (DemoMode.isActive || id == null) {
      final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
      final merged = Map<String, dynamic>.from(seed);
      for (final entry in demo.propertyDetailFallback().entries) {
        merged.putIfAbsent(entry.key, () => entry.value);
      }
      return PropertyDetailLoadResult(property: merged, fromDemo: true);
    }

    try {
      final raw = await _api.getPropertyDetail(id);
      if (raw != null) {
        final card = OwnerApiMappers.toMyPropertyCard(raw, l10n);
        final detail = card['detail'] as Map<String, dynamic>? ?? {};
        return PropertyDetailLoadResult(
          property: {...seed, ...card, ...detail, ...raw},
          fromDemo: false,
        );
      }
    } catch (_) {}

    return PropertyDetailLoadResult(
      property: Map<String, dynamic>.from(seed),
      fromDemo: false,
    );
  }
}

class PropertyDetailLoadResult {
  final Map<String, dynamic> property;
  final bool fromDemo;

  const PropertyDetailLoadResult({
    required this.property,
    required this.fromDemo,
  });
}
