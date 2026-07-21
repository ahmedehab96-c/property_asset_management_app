import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

void main() {
  final l10n = AppLocalizations(const Locale('en'));
  final demo = LocalizedDemoData(l10n: l10n, isArabic: false);

  group('tenantAnalysisResult', () {
    test('scores government employee with high income as low risk', () {
      final result = demo.tenantAnalysisResult(
        income: 25000,
        employmentKey: LocalizedDemoData.empGov,
        hasPreviousRentals: true,
      );
      expect(result['riskScore'] as int, greaterThanOrEqualTo(70));
      expect(result['financialScore'], 85);
      expect(result['employmentScore'], 90);
    });

    test('uses portfolio rent ratio for financial score', () {
      final strong = demo.tenantAnalysisResult(
        income: 30000,
        employmentKey: LocalizedDemoData.empPrivate,
        hasPreviousRentals: true,
        portfolioAvgRent: 8000,
      );
      expect(strong['financialScore'], 90);

      final weak = demo.tenantAnalysisResult(
        income: 10000,
        employmentKey: LocalizedDemoData.empPrivate,
        hasPreviousRentals: false,
        portfolioAvgRent: 8000,
      );
      expect(weak['financialScore'], 45);
      expect(weak['riskScore'] as int, lessThan(70));
    });

    test('boosts record score for existing tenant match', () {
      final matched = demo.tenantAnalysisResult(
        income: 18000,
        employmentKey: LocalizedDemoData.empPrivate,
        hasPreviousRentals: true,
        existingTenantMatch: true,
      );
      expect(matched['recordScore'], 95);
      expect(matched['existingTenantMatch'], isTrue);
    });
  });
}
