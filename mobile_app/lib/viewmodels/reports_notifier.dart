import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class ReportsState {
  final ViewStatus status;
  final String totalExpensesDisplay;
  final String revenuesDisplay;
  final String netProfitDisplay;
  final List<Map<String, dynamic>> transactions;
  final bool fromDemo;
  final String? errorMessage;

  const ReportsState({
    this.status = ViewStatus.idle,
    this.totalExpensesDisplay = '',
    this.revenuesDisplay = '',
    this.netProfitDisplay = '',
    this.transactions = const [],
    this.fromDemo = true,
    this.errorMessage,
  });

  ReportsState copyWith({
    ViewStatus? status,
    String? totalExpensesDisplay,
    String? revenuesDisplay,
    String? netProfitDisplay,
    List<Map<String, dynamic>>? transactions,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      totalExpensesDisplay: totalExpensesDisplay ?? this.totalExpensesDisplay,
      revenuesDisplay: revenuesDisplay ?? this.revenuesDisplay,
      netProfitDisplay: netProfitDisplay ?? this.netProfitDisplay,
      transactions: transactions ?? this.transactions,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class ReportsNotifier extends Notifier<ReportsState> {
  @override
  ReportsState build() => const ReportsState();

  Future<void> load({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(reportRepositoryProvider).load(
            l10n: l10n,
            isArabic: isArabic,
          );
      state = ReportsState(
        status: ViewStatus.success,
        totalExpensesDisplay: result.totalExpensesDisplay,
        revenuesDisplay: result.revenuesDisplay,
        netProfitDisplay: result.netProfitDisplay,
        transactions: result.transactions,
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

final reportsProvider =
    NotifierProvider<ReportsNotifier, ReportsState>(ReportsNotifier.new);
