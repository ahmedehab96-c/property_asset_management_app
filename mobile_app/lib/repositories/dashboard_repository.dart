import 'package:property_asset_management_app/core/repositories/repository_mixin.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class DashboardLoadResult {
  final double totalBalance;
  final String growthPercent;
  final String rentedPropertiesCount;
  final String activeContractsCount;
  final bool fromDemo;

  const DashboardLoadResult({
    required this.totalBalance,
    required this.growthPercent,
    required this.rentedPropertiesCount,
    required this.activeContractsCount,
    required this.fromDemo,
  });
}

class DashboardRepository with RepositoryMixin {
  DashboardRepository([OwnerApiService? api, UserProfileService? profile])
      : _api = api ?? OwnerApiService(),
        _profile = profile ?? UserProfileService();

  final OwnerApiService _api;
  final UserProfileService _profile;

  DashboardLoadResult _demo() => const DashboardLoadResult(
        totalBalance: 2450000,
        growthPercent: '+12%',
        rentedPropertiesCount: '8',
        activeContractsCount: '12',
        fromDemo: true,
      );

  Future<DashboardLoadResult> load() {
    return withApiFallback(
      demo: _demo,
      onError: () => const DashboardLoadResult(
        totalBalance: 0,
        growthPercent: '+0%',
        rentedPropertiesCount: '0',
        activeContractsCount: '0',
        fromDemo: false,
      ),
      api: () async {
        Map<String, dynamic>? analytics;
        try {
          analytics = await _api.getAnalyticsOverview();
        } catch (_) {}

        Map<String, dynamic>? summary = await _api.getFinancialSummary();
        final profile = await _profile.getCached();
        if (profile.id != null) {
          final ownerFin = await _api.getOwnerFinancial(profile.id!);
          summary = {...?summary, ...?ownerFin};
        }

        final properties = await _api.getMyProperties();
        final contracts = await _api.getContracts();

        final balance = OwnerApiMappers.parseBalance(summary) ??
            OwnerApiMappers.parseRevenue(summary) ??
            _asDouble(analytics?['monthly_revenue']) ??
            0;
        final growth = OwnerApiMappers.parseGrowthPercent(summary) ??
            (_asDouble(analytics?['occupancy_rate']) != null
                ? '${_asDouble(analytics?['occupancy_rate'])!.toStringAsFixed(0)}%'
                : '+0%');

        final rented = analytics?['occupied_count']?.toString() ??
            '${OwnerApiMappers.countRentedProperties(properties)}';
        final active = analytics?['active_contracts']?.toString() ??
            '${OwnerApiMappers.countActiveContracts(contracts)}';

        return DashboardLoadResult(
          totalBalance: balance,
          growthPercent: growth.startsWith('+') || growth.startsWith('-')
              ? growth
              : '+$growth',
          rentedPropertiesCount: rented,
          activeContractsCount: active,
          fromDemo: false,
        );
      },
    );
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
