import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class WalletLoadResult {
  final double balance;
  final String monthlyIncomeDisplay;
  final String totalExpensesDisplay;
  final List<WalletTransactionData> transactions;
  final bool fromDemo;

  const WalletLoadResult({
    required this.balance,
    required this.monthlyIncomeDisplay,
    required this.totalExpensesDisplay,
    required this.transactions,
    required this.fromDemo,
  });
}

class WalletRepository {
  WalletRepository([OwnerApiService? api, UserProfileService? profile])
      : _api = api ?? OwnerApiService(),
        _profile = profile ?? UserProfileService();

  final OwnerApiService _api;
  final UserProfileService _profile;

  WalletLoadResult _demo(AppLocalizations l10n, bool isArabic) {
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final now = DateTime.now();
    final transactions = [
      WalletTransactionData(
        title: l10n.rentUnit101,
        amount: '+ 5,000 ${l10n.aed}',
        dateLabel: demo.formatDateLabel(15, 6, now.year),
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 5)),
        isIncome: true,
      ),
      WalletTransactionData(
        title: l10n.maintenanceFees,
        amount: '- 500 ${l10n.aed}',
        dateLabel: demo.formatDateLabel(12, 6, now.year),
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 8)),
        isIncome: false,
      ),
      WalletTransactionData(
        title: l10n.profitWithdrawal,
        amount: '- 10,000 ${l10n.aed}',
        dateLabel: demo.formatDateLabel(10, 6, now.year),
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 10)),
        isIncome: false,
      ),
      WalletTransactionData(
        title: l10n.rentUnit205,
        amount: '+ 4,500 ${l10n.aed}',
        dateLabel: demo.formatDateLabel(8, 6, now.year),
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 12)),
        isIncome: true,
      ),
      WalletTransactionData(
        title: l10n.rentUnit101,
        amount: '+ 4,000 ${l10n.aed}',
        dateLabel: demo.formatDateLabel(15, 1, now.year - 1),
        date: DateTime(now.year - 1, 1, 15),
        isIncome: true,
      ),
    ];

    return WalletLoadResult(
      balance: 125000,
      monthlyIncomeDisplay: OwnerApiMappers.formatMoney(25000, l10n, signed: true),
      totalExpensesDisplay: OwnerApiMappers.formatMoney(-3500, l10n, signed: true),
      transactions: transactions,
      fromDemo: true,
    );
  }

  Future<WalletLoadResult> load({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    if (DemoMode.isActive) return _demo(l10n, isArabic);

    try {
      Map<String, dynamic>? summary = await _api.getFinancialSummary();
      final profile = await _profile.getCached();
      if (profile.id != null) {
        final ownerFin = await _api.getOwnerFinancial(profile.id!);
        summary = {...?summary, ...?ownerFin};
      }

      final payments = await _api.getPayments();

      final balance = OwnerApiMappers.parseBalance(summary) ??
          OwnerApiMappers.parseRevenue(summary) ??
          0;
      final revenue = OwnerApiMappers.parseRevenue(summary) ?? 0;
      final expenses = OwnerApiMappers.parseExpenses(summary) ?? 0;
      final transactions = payments
          .map((p) => OwnerApiMappers.toWalletTransaction(p, l10n, isArabic))
          .toList();

      return WalletLoadResult(
        balance: balance,
        monthlyIncomeDisplay: OwnerApiMappers.formatMoney(revenue, l10n, signed: true),
        totalExpensesDisplay: OwnerApiMappers.formatMoney(-expenses.abs(), l10n, signed: true),
        transactions: transactions,
        fromDemo: false,
      );
    } catch (_) {
      return WalletLoadResult(
        balance: 0,
        monthlyIncomeDisplay: OwnerApiMappers.formatMoney(0, l10n, signed: true),
        totalExpensesDisplay: OwnerApiMappers.formatMoney(0, l10n, signed: true),
        transactions: const [],
        fromDemo: false,
      );
    }
  }
}
