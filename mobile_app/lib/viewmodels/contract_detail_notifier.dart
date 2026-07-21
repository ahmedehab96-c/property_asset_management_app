import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/repositories/contract_repository.dart';

class ContractDetailState {
  final ViewStatus status;
  final Map<String, dynamic>? detail;
  final bool fromDemo;
  final String? errorMessage;

  const ContractDetailState({
    this.status = ViewStatus.idle,
    this.detail,
    this.fromDemo = true,
    this.errorMessage,
  });

  ContractDetailState copyWith({
    ViewStatus? status,
    Map<String, dynamic>? detail,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return ContractDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class ContractDetailNotifier extends Notifier<ContractDetailState> {
  @override
  ContractDetailState build() => const ContractDetailState();

  Future<void> load({
    required Map<String, dynamic> seed,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result =
          await ref.read(contractRepositoryProvider).loadContractDetailForScreen(
                seed: seed,
                l10n: l10n,
                isArabic: isArabic,
              );
      state = ContractDetailState(
        status: ViewStatus.success,
        detail: result.contract,
        fromDemo: result.fromDemo,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ContractOperationResult> extendContract({
    required int? contractId,
    required DateTime newEndDate,
    String? notes,
  }) {
    return ref.read(contractRepositoryProvider).extendContract(
          contractId: contractId,
          newEndDate: newEndDate,
          notes: notes,
        );
  }

  Future<ContractOperationResult> cancelContract({
    required int? contractId,
    required String reasonKey,
    String? details,
  }) {
    return ref.read(contractRepositoryProvider).cancelContract(
          contractId: contractId,
          reasonKey: reasonKey,
          details: details,
        );
  }
}

final contractDetailProvider =
    NotifierProvider<ContractDetailNotifier, ContractDetailState>(
  ContractDetailNotifier.new,
);
