import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

class FinancialPredictionsScreen extends ConsumerStatefulWidget {
  const FinancialPredictionsScreen({super.key});

  @override
  ConsumerState<FinancialPredictionsScreen> createState() =>
      _FinancialPredictionsScreenState();
}

class _FinancialPredictionsScreenState
    extends ConsumerState<FinancialPredictionsScreen> {
  String _selectedPeriod = 'three';
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final periods = [
      ('three', l10n.threeMonths),
      ('six', l10n.sixMonths),
      ('twelve', l10n.twelveMonths),
    ];
    final periodLabel = periods.firstWhere((e) => e.$1 == _selectedPeriod).$2;
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.financialPredictions, style: TextStyle(color: context.estate.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.choosePeriod, style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: periods.map((entry) {
                        final (key, label) = entry;
                        final isSelected = _selectedPeriod == key;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPeriod = key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : context.estate.surfaceGlass,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentGold
                                    : context.estate.border,
                              ),
                            ),
                            child: Text(
                              label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : context.estate.textPrimary,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _isGenerating = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() => _isGenerating = false);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isGenerating
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryBlue,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.generatePredictions,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              if (!_isGenerating) ...[
                // Income Prediction Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.revenueForecast,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.estate.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${l10n.forNextPeriod} ($periodLabel)",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.estate.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _PredictionItem(
                        label: AppLocalizations.of(context).firstMonth,
                        value: "83,000 د.إ",
                        trend: "+2.5%",
                        isPositive: true,
                      ),
                      SizedBox(height: 12),
                      _PredictionItem(
                        label: AppLocalizations.of(context).secondMonth,
                        value: "85,000 د.إ",
                        trend: "+2.4%",
                        isPositive: true,
                      ),
                      SizedBox(height: 12),
                      _PredictionItem(
                        label: AppLocalizations.of(context).thirdMonth,
                        value: "87,500 د.إ",
                        trend: "+2.9%",
                        isPositive: true,
                      ),
                      SizedBox(height: 16),
                      const Divider(color: AppColors.darkGrey),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).expectedTotal,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                            ),
                          ),
                          Text(
                            "255,500 د.إ",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Expenses Prediction Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_down,
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).expenseForecast,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.estate.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${l10n.forNextPeriod} ($periodLabel)",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.estate.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _PredictionItem(
                        label: AppLocalizations.of(context).expectedMaintenance,
                        value: "15,000 د.إ",
                        trend: AppLocalizations.of(context).stable,
                        isPositive: null,
                      ),
                      SizedBox(height: 12),
                      _PredictionItem(
                        label: AppLocalizations.of(context).taxesFees,
                        value: "8,000 د.إ",
                        trend: AppLocalizations.of(context).stable,
                        isPositive: null,
                      ),
                      SizedBox(height: 12),
                      _PredictionItem(
                        label: AppLocalizations.of(context).otherExpenses,
                        value: "5,000 د.إ",
                        trend: AppLocalizations.of(context).stable,
                        isPositive: null,
                      ),
                      SizedBox(height: 16),
                      const Divider(color: AppColors.darkGrey),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).expectedTotal,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                            ),
                          ),
                          Text(
                            "84,000 د.إ",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Net Profit Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentGold.withValues(alpha: 0.3),
                        AppColors.accentGold.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.expectedNetProfit,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.estate.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "171,500 د.إ",
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "${l10n.expectedGrowth} +5.2%",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Recommendations Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: AppColors.accentGold,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context).financialRecommendations,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _RecommendationItem(
                        text: l10n.revenueGrowthRecommendation,
                      ),
                      SizedBox(height: 12),
                      _RecommendationItem(
                        text: l10n.expenseStableRecommendation,
                      ),
                      SizedBox(height: 12),
                      _RecommendationItem(
                        text: l10n.netProfitPositiveRecommendation,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PredictionItem extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool? isPositive;

  const _PredictionItem({
    required this.label,
    required this.value,
    required this.trend,
    this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: context.estate.textPrimary,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.estate.textPrimary,
              ),
            ),
            SizedBox(width: 12),
            if (isPositive != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive!
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive! ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isPositive! ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      trend,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPositive! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                trend,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.estate.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;

  const _RecommendationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.accentGold,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.estate.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

