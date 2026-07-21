import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class PropertiesState {
  final ViewStatus status;
  final List<Map<String, dynamic>> properties;
  final bool fromDemo;
  final bool hasMore;
  final bool loadingMore;
  final String? errorMessage;

  const PropertiesState({
    this.status = ViewStatus.idle,
    this.properties = const [],
    this.fromDemo = true,
    this.hasMore = false,
    this.loadingMore = false,
    this.errorMessage,
  });

  PropertiesState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? properties,
    bool? fromDemo,
    bool? hasMore,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return PropertiesState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      fromDemo: fromDemo ?? this.fromDemo,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }
}

class PropertiesNotifier extends Notifier<PropertiesState> {
  int _page = 1;

  @override
  PropertiesState build() => const PropertiesState();

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
      final result = await ref.read(propertyRepositoryProvider).loadMyProperties(
            l10n: l10n,
            isArabic: isArabic,
            page: _page,
          );
      final merged =
          reset ? result.properties : [...state.properties, ...result.properties];
      state = PropertiesState(
        status: ViewStatus.success,
        properties: merged,
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
    final result = await ref.read(propertyRepositoryProvider).loadMyProperties(
          l10n: l10n,
          isArabic: isArabic,
          page: _page,
        );
    state = state.copyWith(
      loadingMore: false,
      properties: [...state.properties, ...result.properties],
      hasMore: result.hasMore,
    );
  }
}

final propertiesProvider =
    NotifierProvider<PropertiesNotifier, PropertiesState>(PropertiesNotifier.new);
