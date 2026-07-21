import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class WalletState {
  final ViewStatus status;
  final double balance;
  final String monthlyIncomeDisplay;
  final String totalExpensesDisplay;
  final List<WalletTransactionData> transactions;
  final bool fromDemo;
  final String? errorMessage;

  const WalletState({
    this.status = ViewStatus.idle,
    this.balance = 125000,
    this.monthlyIncomeDisplay = '',
    this.totalExpensesDisplay = '',
    this.transactions = const [],
    this.fromDemo = true,
    this.errorMessage,
  });

  WalletState copyWith({
    ViewStatus? status,
    double? balance,
    String? monthlyIncomeDisplay,
    String? totalExpensesDisplay,
    List<WalletTransactionData>? transactions,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      monthlyIncomeDisplay: monthlyIncomeDisplay ?? this.monthlyIncomeDisplay,
      totalExpensesDisplay: totalExpensesDisplay ?? this.totalExpensesDisplay,
      transactions: transactions ?? this.transactions,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  Future<void> load({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(walletRepositoryProvider).load(
            l10n: l10n,
            isArabic: isArabic,
          );
      state = WalletState(
        status: ViewStatus.success,
        balance: result.balance,
        monthlyIncomeDisplay: result.monthlyIncomeDisplay,
        totalExpensesDisplay: result.totalExpensesDisplay,
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

final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
