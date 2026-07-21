import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class MaintenanceState {
  final ViewStatus status;
  final List<Map<String, dynamic>> requests;
  final bool fromDemo;
  final bool hasMore;
  final bool loadingMore;
  final String? errorMessage;

  const MaintenanceState({
    this.status = ViewStatus.idle,
    this.requests = const [],
    this.fromDemo = true,
    this.hasMore = false,
    this.loadingMore = false,
    this.errorMessage,
  });

  MaintenanceState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? requests,
    bool? fromDemo,
    bool? hasMore,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return MaintenanceState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      fromDemo: fromDemo ?? this.fromDemo,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }
}

class MaintenanceNotifier extends Notifier<MaintenanceState> {
  int _page = 1;

  @override
  MaintenanceState build() => const MaintenanceState();

  List<Map<String, dynamic>> get currentRequests =>
      ref.read(maintenanceRepositoryProvider).splitCurrent(state.requests);

  List<Map<String, dynamic>> get historyRequests =>
      ref.read(maintenanceRepositoryProvider).splitHistory(state.requests);

  Future<void> load({
    required AppLocalizations l10n,
    bool reset = true,
  }) async {
    if (reset) {
      _page = 1;
      state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    }
    try {
      final result =
          await ref.read(maintenanceRepositoryProvider).loadRequests(
                l10n: l10n,
                page: _page,
              );
      final merged =
          reset ? result.requests : [...state.requests, ...result.requests];
      state = MaintenanceState(
        status: ViewStatus.success,
        requests: merged,
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

  Future<void> loadMore({required AppLocalizations l10n}) async {
    if (state.loadingMore || !state.hasMore || state.fromDemo) return;
    state = state.copyWith(loadingMore: true);
    _page++;
    final result =
        await ref.read(maintenanceRepositoryProvider).loadRequests(
              l10n: l10n,
              page: _page,
            );
    state = state.copyWith(
      loadingMore: false,
      requests: [...state.requests, ...result.requests],
      hasMore: result.hasMore,
    );
  }
}

final maintenanceProvider =
    NotifierProvider<MaintenanceNotifier, MaintenanceState>(
  MaintenanceNotifier.new,
);
