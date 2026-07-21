import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class TenantsState {
  final ViewStatus status;
  final List<Map<String, dynamic>> tenants;
  final String totalMonthlyRent;
  final bool fromDemo;
  final bool hasMore;
  final bool loadingMore;
  final String? errorMessage;

  const TenantsState({
    this.status = ViewStatus.idle,
    this.tenants = const [],
    this.totalMonthlyRent = '',
    this.fromDemo = true,
    this.hasMore = false,
    this.loadingMore = false,
    this.errorMessage,
  });

  TenantsState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? tenants,
    String? totalMonthlyRent,
    bool? fromDemo,
    bool? hasMore,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return TenantsState(
      status: status ?? this.status,
      tenants: tenants ?? this.tenants,
      totalMonthlyRent: totalMonthlyRent ?? this.totalMonthlyRent,
      fromDemo: fromDemo ?? this.fromDemo,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }
}

class TenantsNotifier extends Notifier<TenantsState> {
  int _page = 1;

  @override
  TenantsState build() => const TenantsState();

  Future<void> load({
    required AppLocalizations l10n,
    required bool isArabic,
    bool reset = true,
  }) async {
    if (reset) {
      _page = 1;
      state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    }
    try {
      final result = await ref.read(tenantRepositoryProvider).loadTenants(
            l10n: l10n,
            isArabic: isArabic,
            page: _page,
          );
      final merged =
          reset ? result.tenants : [...state.tenants, ...result.tenants];
      state = TenantsState(
        status: ViewStatus.success,
        tenants: merged,
        totalMonthlyRent: result.totalMonthlyRent,
        fromDemo: result.fromDemo,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    if (state.loadingMore || !state.hasMore || state.fromDemo) return;
    state = state.copyWith(loadingMore: true);
    _page++;
    final result = await ref.read(tenantRepositoryProvider).loadTenants(
          l10n: l10n,
          isArabic: isArabic,
          page: _page,
        );
    state = state.copyWith(
      loadingMore: false,
      tenants: [...state.tenants, ...result.tenants],
      totalMonthlyRent: result.totalMonthlyRent,
      hasMore: result.hasMore,
    );
  }
}

final tenantsProvider =
    NotifierProvider<TenantsNotifier, TenantsState>(TenantsNotifier.new);
