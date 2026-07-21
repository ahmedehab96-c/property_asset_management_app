import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class PaymentsState {
  final ViewStatus status;
  final List<Map<String, dynamic>> payments;
  final String totalPaidDisplay;
  final String pendingDisplay;
  final bool fromDemo;
  final String? errorMessage;

  const PaymentsState({
    this.status = ViewStatus.idle,
    this.payments = const [],
    this.totalPaidDisplay = '',
    this.pendingDisplay = '',
    this.fromDemo = true,
    this.errorMessage,
  });
}

class PaymentsNotifier extends Notifier<PaymentsState> {
  @override
  PaymentsState build() => const PaymentsState();

  Future<void> load({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = const PaymentsState(status: ViewStatus.loading);
    try {
      final result = await ref.read(paymentsRepositoryProvider).load(
            l10n: l10n,
            isArabic: isArabic,
          );
      state = PaymentsState(
        status: ViewStatus.success,
        payments: result.payments,
        totalPaidDisplay: result.totalPaidDisplay,
        pendingDisplay: result.pendingDisplay,
        fromDemo: result.fromDemo,
      );
    } catch (e) {
      state = PaymentsState(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final paymentsProvider =
    NotifierProvider<PaymentsNotifier, PaymentsState>(PaymentsNotifier.new);
