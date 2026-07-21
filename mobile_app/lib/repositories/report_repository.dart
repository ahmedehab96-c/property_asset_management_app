import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class ReportsLoadResult {
  final String totalExpensesDisplay;
  final String revenuesDisplay;
  final String netProfitDisplay;
  final List<Map<String, dynamic>> transactions;
  final bool fromDemo;

  const ReportsLoadResult({
    required this.totalExpensesDisplay,
    required this.revenuesDisplay,
    required this.netProfitDisplay,
    required this.transactions,
    required this.fromDemo,
  });
}

class ReportRepository {
  ReportRepository([OwnerApiService? api, UserProfileService? profile])
      : _api = api ?? OwnerApiService(),
        _profile = profile ?? UserProfileService();

  final OwnerApiService _api;
  final UserProfileService _profile;

  ReportsLoadResult _demo(AppLocalizations l10n, bool isArabic) {
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    return ReportsLoadResult(
      totalExpensesDisplay: OwnerApiMappers.formatMoney(120000, l10n),
      revenuesDisplay: OwnerApiMappers.formatMoney(350000, l10n),
      netProfitDisplay: OwnerApiMappers.formatMoney(230000, l10n),
      transactions: demo.reportTransactions(),
      fromDemo: true,
    );
  }

  Future<ReportsLoadResult> load({
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

      final revenue = OwnerApiMappers.parseRevenue(summary) ?? 0;
      final expenses = OwnerApiMappers.parseExpenses(summary) ?? 0;
      final net = revenue - expenses;
      final transactions = payments
          .map((p) => OwnerApiMappers.toReportTransaction(p, l10n, isArabic))
          .toList();

      return ReportsLoadResult(
        totalExpensesDisplay: OwnerApiMappers.formatMoney(expenses, l10n),
        revenuesDisplay: OwnerApiMappers.formatMoney(revenue, l10n),
        netProfitDisplay: OwnerApiMappers.formatMoney(net, l10n),
        transactions: transactions,
        fromDemo: false,
      );
    } catch (_) {
      return ReportsLoadResult(
        totalExpensesDisplay: OwnerApiMappers.formatMoney(0, l10n),
        revenuesDisplay: OwnerApiMappers.formatMoney(0, l10n),
        netProfitDisplay: OwnerApiMappers.formatMoney(0, l10n),
        transactions: const [],
        fromDemo: false,
      );
    }
  }
}
