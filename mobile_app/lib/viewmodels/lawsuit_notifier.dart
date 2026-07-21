import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/repositories/lawsuit_repository.dart';

class LawsuitState {
  final ViewStatus status;
  final String? errorMessage;

  const LawsuitState({
    this.status = ViewStatus.idle,
    this.errorMessage,
  });

  LawsuitState copyWith({
    ViewStatus? status,
    String? errorMessage,
  }) {
    return LawsuitState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class LawsuitNotifier extends Notifier<LawsuitState> {
  @override
  LawsuitState build() => const LawsuitState();

  Future<LawsuitOperationResult> fileLawsuit({
    required int? contractId,
    required String typeKey,
    required String description,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    final result = await ref.read(lawsuitRepositoryProvider).fileLawsuit(
          contractId: contractId,
          typeKey: typeKey,
          description: description,
        );
    state = state.copyWith(
      status: result.success ? ViewStatus.success : ViewStatus.error,
      errorMessage: result.success ? null : result.message,
    );
    return result;
  }
}

final lawsuitProvider =
    NotifierProvider<LawsuitNotifier, LawsuitState>(LawsuitNotifier.new);
