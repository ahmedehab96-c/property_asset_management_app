import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class MaintenanceLoadResult {
  final List<Map<String, dynamic>> requests;
  final bool fromDemo;
  final bool hasMore;

  const MaintenanceLoadResult({
    required this.requests,
    required this.fromDemo,
    this.hasMore = false,
  });
}

/// طلبات الصيانة: API أولاً، ثم بيانات تجريبية.
class MaintenanceRepository {
  MaintenanceRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  static const defaultPerPage = 20;

  MaintenanceLoadResult _demoRequests(AppLocalizations l10n) {
    final current = [
      {
        'id': 1,
        'title': l10n.acRepair,
        'orderNumber': '#12045',
        'date': '20 أغسطس',
        'status': l10n.inProgress,
        'statusType': 'in_progress',
        'icon': Icons.ac_unit,
        'iconColor': AppColors.accentGold,
      },
      {
        'id': 2,
        'title': l10n.kitchenSinkLeak,
        'orderNumber': '#11987',
        'date': '15 أغسطس',
        'status': l10n.completed,
        'statusType': 'completed',
        'icon': Icons.water_drop,
        'iconColor': AppColors.accentGold,
      },
    ];
    final history = [
      {
        'id': 3,
        'title': l10n.acMaintenance,
        'orderNumber': '#11950',
        'date': '10 أغسطس',
        'status': l10n.completed,
        'statusType': 'completed',
        'icon': Icons.ac_unit,
        'iconColor': AppColors.accentGold,
      },
    ];
    return MaintenanceLoadResult(
      requests: [...current, ...history],
      fromDemo: true,
    );
  }

  List<Map<String, dynamic>> splitCurrent(List<Map<String, dynamic>> all) =>
      all.where((r) => r['statusType'] == 'in_progress').toList();

  List<Map<String, dynamic>> splitHistory(List<Map<String, dynamic>> all) =>
      all.where((r) => r['statusType'] == 'completed').toList();

  Future<MaintenanceLoadResult> loadRequests({
    required AppLocalizations l10n,
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    if (DemoMode.isActive) return _demoRequests(l10n);

    try {
      final raw = await _api.getMaintenanceRequests(
        query: {'page': page, 'per_page': perPage},
      );

      final mapped = raw
          .map((r) => OwnerApiMappers.toMaintenanceRequestCard(r, l10n))
          .toList();

      return MaintenanceLoadResult(
        requests: mapped,
        fromDemo: false,
        hasMore: raw.length >= perPage,
      );
    } catch (_) {
      return const MaintenanceLoadResult(requests: [], fromDemo: false);
    }
  }
}
