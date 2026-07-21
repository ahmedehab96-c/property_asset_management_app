import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class TenantsLoadResult {
  final List<Map<String, dynamic>> tenants;
  final String totalMonthlyRent;
  final bool fromDemo;
  final bool hasMore;

  const TenantsLoadResult({
    required this.tenants,
    required this.totalMonthlyRent,
    required this.fromDemo,
    this.hasMore = false,
  });
}

/// مستأجرو المالك: API أولاً، ثم بيانات تجريبية عند الفشل أو الوضع التجريبي.
class TenantRepository {
  TenantRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  static const defaultPerPage = 20;

  TenantsLoadResult _demoResult(AppLocalizations l10n, bool isArabic) {
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    return TenantsLoadResult(
      tenants: demo.tenants(),
      totalMonthlyRent: demo.tenantsTotalMonthlyRent,
      fromDemo: true,
    );
  }

  Future<TenantsLoadResult> loadTenants({
    required AppLocalizations l10n,
    required bool isArabic,
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    if (DemoMode.isActive) return _demoResult(l10n, isArabic);

    try {
      final raw = await _api.getTenants(
        query: {'page': page, 'per_page': perPage},
      );

      final mapped =
          raw.map((t) => OwnerApiMappers.toTenantCard(t, l10n)).toList();
      return TenantsLoadResult(
        tenants: mapped,
        totalMonthlyRent: OwnerApiMappers.formatTenantsTotalRent(mapped, l10n),
        fromDemo: false,
        hasMore: raw.length >= perPage,
      );
    } catch (_) {
      return TenantsLoadResult(
        tenants: const [],
        totalMonthlyRent: OwnerApiMappers.formatMoney(0, l10n),
        fromDemo: false,
      );
    }
  }
}
