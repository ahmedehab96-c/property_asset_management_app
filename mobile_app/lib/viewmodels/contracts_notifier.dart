import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class ContractsState {
  final ViewStatus status;
  final List<Map<String, dynamic>> contracts;
  final bool fromDemo;
  final bool hasMore;
  final bool loadingMore;
  final String? errorMessage;

  const ContractsState({
    this.status = ViewStatus.idle,
    this.contracts = const [],
    this.fromDemo = true,
    this.hasMore = false,
    this.loadingMore = false,
    this.errorMessage,
  });

  ContractsState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? contracts,
    bool? fromDemo,
    bool? hasMore,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return ContractsState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      fromDemo: fromDemo ?? this.fromDemo,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }
}

class ContractsNotifier extends Notifier<ContractsState> {
  int _page = 1;

  @override
  ContractsState build() => const ContractsState();

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
      final result = await ref.read(contractRepositoryProvider).loadContracts(
            l10n: l10n,
            isArabic: isArabic,
            page: _page,
          );
      final merged =
          reset ? result.contracts : [...state.contracts, ...result.contracts];
      state = ContractsState(
        status: ViewStatus.success,
        contracts: merged,
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
    final result = await ref.read(contractRepositoryProvider).loadContracts(
          l10n: l10n,
          isArabic: isArabic,
          page: _page,
        );
    state = state.copyWith(
      loadingMore: false,
      contracts: [...state.contracts, ...result.contracts],
      hasMore: result.hasMore,
    );
  }
}

final contractsProvider =
    NotifierProvider<ContractsNotifier, ContractsState>(ContractsNotifier.new);
