import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class SearchState {
  final ViewStatus status;
  final List<Map<String, dynamic>> results;
  final bool fromDemo;
  final bool searched;
  final String? errorMessage;

  const SearchState({
    this.status = ViewStatus.idle,
    this.results = const [],
    this.fromDemo = false,
    this.searched = false,
    this.errorMessage,
  });

  SearchState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? results,
    bool? fromDemo,
    bool? searched,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      fromDemo: fromDemo ?? this.fromDemo,
      searched: searched ?? this.searched,
      errorMessage: errorMessage,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  Future<void> search({
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
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(searchRepositoryProvider).search(
            l10n: l10n,
            isArabic: isArabic,
            query: query,
            typeKey: typeKey,
            cityKey: cityKey,
            minPrice: minPrice,
            maxPrice: maxPrice,
            minArea: minArea,
            maxArea: maxArea,
          );
      state = SearchState(
        status: ViewStatus.success,
        results: result.results,
        fromDemo: result.fromDemo,
        searched: result.searched,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
