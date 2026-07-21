import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class SearchLoadResult {
  final List<Map<String, dynamic>> results;
  final bool fromDemo;
  final bool searched;

  const SearchLoadResult({
    required this.results,
    required this.fromDemo,
    required this.searched,
  });
}

/// بحث العقارات: `/properties/search` ثم `/properties/filter` ثم تصفية محلية.
class SearchRepository {
  SearchRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  static const cityKeys = {
    'riyadh': ['riyadh', 'الرياض'],
    'jeddah': ['jeddah', 'جدة'],
    'dammam': ['dammam', 'الدمام'],
    'madina': ['madina', 'medina', 'المدينة'],
  };

  static const typeKeys = {
    'apartment': ['apartment', 'شقة'],
    'villa': ['villa', 'فيلا'],
    'commercial': ['commercial', 'تجاري'],
    'land': ['land', 'أرض'],
  };

  Map<String, dynamic> _demoResult(
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    return Map<String, dynamic>.from(demo.searchResultProperty());
  }

  Map<String, dynamic> _buildQuery({
    required String query,
    required String typeKey,
    required String cityKey,
    required double minPrice,
    required double maxPrice,
    required double minArea,
    required double maxArea,
  }) {
    final params = <String, dynamic>{
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (query.trim().isNotEmpty) 'search': query.trim(),
      if (typeKey != 'all') 'type': typeKey,
      if (cityKey != 'all') 'city': cityKey,
      if (minPrice > 0) 'min_price': minPrice.round(),
      if (maxPrice < 100000) 'max_price': maxPrice.round(),
      if (minArea > 0) 'min_area': minArea.round(),
      if (maxArea < 1000) 'max_area': maxArea.round(),
    };
    return params;
  }

  bool _matchesCity(String location, String cityKey) {
    if (cityKey == 'all') return true;
    final needles = cityKeys[cityKey] ?? [cityKey];
    final haystack = location.toLowerCase();
    return needles.any((n) => haystack.contains(n.toLowerCase()));
  }

  bool _matchesType(Map<String, dynamic> raw, String typeKey) {
    if (typeKey == 'all') return true;
    final needles = typeKeys[typeKey] ?? [typeKey];
    final rawType =
        '${raw['type'] ?? ''} ${raw['property_type'] ?? ''} ${raw['propertyType'] ?? ''}'
            .toLowerCase();
    return needles.any((n) => rawType.contains(n.toLowerCase()));
  }

  double? _numeric(dynamic value) {
    if (value == null) return null;
    final cleaned = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  double? _rentAmount(Map<String, dynamic> raw) {
    return _numeric(
      raw['rentAmount'] ??
          raw['rent_amount'] ??
          raw['monthlyRevenue'] ??
          raw['monthly_revenue'],
    );
  }

  double? _areaValue(Map<String, dynamic> raw) => _numeric(raw['area']);

  List<Map<String, dynamic>> _filterClientSide(
    List<Map<String, dynamic>> raw, {
    required String query,
    required String typeKey,
    required String cityKey,
    required double minPrice,
    required double maxPrice,
    required double minArea,
    required double maxArea,
  }) {
    final q = query.trim().toLowerCase();
    return raw.where((item) {
      final name = '${item['name'] ?? item['title'] ?? ''}'.toLowerCase();
      final location =
          '${item['location'] ?? item['address'] ?? ''}'.toLowerCase();
      if (q.isNotEmpty && !name.contains(q) && !location.contains(q)) {
        return false;
      }
      if (!_matchesCity(location, cityKey)) return false;
      if (!_matchesType(item, typeKey)) return false;

      final rent = _rentAmount(item);
      if (rent != null) {
        if (minPrice > 0 && rent < minPrice) return false;
        if (maxPrice < 100000 && rent > maxPrice) return false;
      }

      final area = _areaValue(item);
      if (area != null) {
        if (minArea > 0 && area < minArea) return false;
        if (maxArea < 1000 && area > maxArea) return false;
      }
      return true;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchRaw(
    Map<String, dynamic> params, {
    required String query,
    required String typeKey,
    required String cityKey,
    required double minPrice,
    required double maxPrice,
    required double minArea,
    required double maxArea,
  }) async {
    try {
      final searched = await _api.searchProperties(query: params);
      if (searched.isNotEmpty) return searched;
    } catch (_) {}

    try {
      final filtered = await _api.filterProperties(query: params);
      if (filtered.isNotEmpty) return filtered;
    } catch (_) {}

    final all = await _api.getMyProperties();
    return _filterClientSide(
      all,
      query: query,
      typeKey: typeKey,
      cityKey: cityKey,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minArea: minArea,
      maxArea: maxArea,
    );
  }

  Future<SearchLoadResult> search({
    required AppLocalizations l10n,
    required bool isArabic,
    required String query,
    String typeKey = 'all',
    String cityKey = 'all',
    double minPrice = 0,
    double maxPrice = 100000,
    double minArea = 0,
    double maxArea = 1000,
  }) async {
    if (DemoMode.isActive) {
      return SearchLoadResult(
        results: [_demoResult(l10n, isArabic)],
        fromDemo: true,
        searched: true,
      );
    }

    final params = _buildQuery(
      query: query,
      typeKey: typeKey,
      cityKey: cityKey,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minArea: minArea,
      maxArea: maxArea,
    );

    try {
      final raw = await _fetchRaw(
        params,
        query: query,
        typeKey: typeKey,
        cityKey: cityKey,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minArea: minArea,
        maxArea: maxArea,
      );
      final mapped = raw
          .map(
            (r) => OwnerApiMappers.toSearchResultCard(
              r,
              l10n,
              isArabic: isArabic,
            ),
          )
          .toList();
      return SearchLoadResult(
        results: mapped,
        fromDemo: false,
        searched: true,
      );
    } catch (_) {
      return const SearchLoadResult(
        results: [],
        fromDemo: false,
        searched: true,
      );
    }
  }
}
