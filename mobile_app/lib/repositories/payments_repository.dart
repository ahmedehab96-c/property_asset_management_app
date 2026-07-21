import 'package:property_asset_management_app/core/repositories/repository_mixin.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class PaymentsLoadResult {
  final List<Map<String, dynamic>> payments;
  final String totalPaidDisplay;
  final String pendingDisplay;
  final bool fromDemo;

  const PaymentsLoadResult({
    required this.payments,
    required this.totalPaidDisplay,
    required this.pendingDisplay,
    required this.fromDemo,
  });
}

class PaymentsRepository with RepositoryMixin {
  PaymentsRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  PaymentsLoadResult _demo(AppLocalizations l10n, bool isArabic) {
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final payments = demo.payments();
    return PaymentsLoadResult(
      payments: payments,
      totalPaidDisplay: '58,000 ${l10n.aed}',
      pendingDisplay: '25,000 ${l10n.aed}',
      fromDemo: true,
    );
  }

  Future<PaymentsLoadResult> load({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    return withApiFallback(
      demo: () => _demo(l10n, isArabic),
      onError: () => PaymentsLoadResult(
        payments: const [],
        totalPaidDisplay: OwnerApiMappers.formatMoney(0, l10n),
        pendingDisplay: OwnerApiMappers.formatMoney(0, l10n),
        fromDemo: false,
      ),
      api: () async {
        final raw = await _api.getPayments();
        final mapped = raw
            .map((p) => OwnerApiMappers.toPaymentCard(p, l10n, isArabic: isArabic))
            .toList();
        var paidTotal = 0.0;
        var pendingTotal = 0.0;
        for (final p in mapped) {
          final amount = (p['amountRaw'] as num?)?.toDouble() ?? 0;
          if (p['statusType'] == LocalizedDemoData.filterPaid) {
            paidTotal += amount;
          } else {
            pendingTotal += amount;
          }
        }
        return PaymentsLoadResult(
          payments: mapped,
          totalPaidDisplay: OwnerApiMappers.formatMoney(paidTotal, l10n),
          pendingDisplay: OwnerApiMappers.formatMoney(pendingTotal, l10n),
          fromDemo: false,
        );
      },
    );
  }
}
