import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class MapsState {
  final ViewStatus status;
  final List<Map<String, dynamic>> properties;
  final bool fromDemo;
  final String? errorMessage;

  const MapsState({
    this.status = ViewStatus.idle,
    this.properties = const [],
    this.fromDemo = true,
    this.errorMessage,
  });

  MapsState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? properties,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return MapsState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class MapsNotifier extends Notifier<MapsState> {
  @override
  MapsState build() => const MapsState();

  Future<void> load({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(mapsRepositoryProvider).loadMapProperties(
            l10n: l10n,
            isArabic: isArabic,
          );
      state = MapsState(
        status: ViewStatus.success,
        properties: result.properties,
        fromDemo: result.fromDemo,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final mapsProvider =
    NotifierProvider<MapsNotifier, MapsState>(MapsNotifier.new);
