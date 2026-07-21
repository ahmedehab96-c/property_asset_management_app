import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class PropertyDetailState {
  final ViewStatus status;
  final Map<String, dynamic>? property;
  final bool fromDemo;
  final String? errorMessage;

  const PropertyDetailState({
    this.status = ViewStatus.idle,
    this.property,
    this.fromDemo = true,
    this.errorMessage,
  });

  PropertyDetailState copyWith({
    ViewStatus? status,
    Map<String, dynamic>? property,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return PropertyDetailState(
      status: status ?? this.status,
      property: property ?? this.property,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class PropertyDetailNotifier extends Notifier<PropertyDetailState> {
  @override
  PropertyDetailState build() => const PropertyDetailState();

  Future<void> load({
    required Map<String, dynamic> seed,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result =
          await ref.read(propertyRepositoryProvider).loadPropertyDetailForScreen(
                seed: seed,
                l10n: l10n,
                isArabic: isArabic,
              );
      state = PropertyDetailState(
        status: ViewStatus.success,
        property: result.property,
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

final propertyDetailProvider =
    NotifierProvider<PropertyDetailNotifier, PropertyDetailState>(
  PropertyDetailNotifier.new,
);
