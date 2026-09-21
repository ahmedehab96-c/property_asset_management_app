import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class MarketAnalysisScreen extends ConsumerStatefulWidget {
  final String? propertyLocation;
  final String? propertyType;

  const MarketAnalysisScreen({
    super.key,
    this.propertyLocation,
    this.propertyType,
  });

  @override
  ConsumerState<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends ConsumerState<MarketAnalysisScreen> {
  String? _selectedCity;
  String? _selectedType;
  bool _isAnalyzing = false;
  bool _hasResult = false;
  Locale? _lastLocale;
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _aiResult;

  List<String> _cities(AppLocalizations l10n) =>
      [l10n.riyadh, l10n.jeddah, l10n.dammam, l10n.abuDhabi];

  List<String> _types(AppLocalizations l10n) =>
      [l10n.apartment, l10n.villa, l10n.commercialShop, l10n.landPlot];

  Future<void> _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _hasResult = false;
      _aiResult = null;
    });
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.read(isArabicProvider);
    final city = _selectedCity ?? _cities(l10n).first;
    final type = _selectedType ?? _types(l10n).first;

    Map<String, dynamic>? data;
    Map<String, dynamic>? aiData;
    try {
      data = await OwnerApiService().getAnalyticsOverview();
    } catch (_) {}
    try {
      aiData = await OwnerApiService().aiMarketAnalysis(
        city: city,
        propertyType: type,
        locale: isArabic ? 'ar' : 'en',
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _analytics = data;
      _aiResult = aiData;
      _isAnalyzing = false;
      _hasResult = true;
    });
  }

  String _money(num? value, AppLocalizations l10n) {
    final amount = (value ?? 8500).round();
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted ${l10n.aed}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);
    final cities = _cities(l10n);
    final types = _types(l10n);
    if (_lastLocale != locale) {
      _lastLocale = locale;
      _selectedCity = cities.first;
      _selectedType = types.first;
    } else {
      _selectedCity ??= cities.first;
      _selectedType ??= types.first;
    }
  }

  List<String> _marketRecommendations(AppLocalizations l10n) {
    final raw = _aiResult?['recommendations'];
    if (raw is List) {
      final items = raw
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
      if (items.isNotEmpty) {
        return items;
      }
    }
    return [l10n.marketRec1, l10n.marketRec2, l10n.marketRec3];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final cities = _cities(l10n);
    final types = _types(l10n);
    final selectedCity = _selectedCity ?? cities.first;
    final selectedType = _selectedType ?? types.first;

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
        title: Text(
          l10n.realEstateMarketAnalysis,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectRegionType,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20),
                    // City Selection
                    Text(
                      l10n.city,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.estate.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cities.map((city) {
                        final isSelected = selectedCity == city;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCity = city),
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
                              city,
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
                    // Property Type Selection
                    Text(
                      l10n.propertyType,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.estate.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: types.map((type) {
                        final isSelected = selectedType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
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
                              type,
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
                    // Analyze Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAnalyzing ? null : _runAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isAnalyzing
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
                                l10n.analyzeMarket,
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

              // Market Analysis Results
              if (!_isAnalyzing && _hasResult) ...[
                // Average Price Card
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
                              color: AppColors.accentGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.analytics,
                              color: AppColors.accentGold,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.avgRentPrice,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: context.estate.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${_money((_aiResult?['avg_rent'] as num?) ?? (_analytics?['monthly_revenue'] as num?), l10n)}/${l10n.perMonth}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        isArabic
                            ? 'بناءً على محفظتك و$selectedCity - $selectedType · إشغال ${_analytics?['occupancy_rate'] ?? '-'}%'
                            : 'Based on your portfolio & $selectedCity - $selectedType · Occupancy ${_analytics?['occupancy_rate'] ?? '-'}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.estate.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Price Range Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.priceRangeLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.estate.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _PriceRangeBox(
                              label: l10n.minimum,
                              value: _money(
                                (_aiResult?['min_rent'] as num?) ??
                                    (((_analytics?['monthly_revenue'] as num?) ?? 8500) * 0.6),
                                l10n,
                              ),
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _PriceRangeBox(
                              label: l10n.average,
                              value: _money(
                                (_aiResult?['avg_rent'] as num?) ??
                                    (_analytics?['monthly_revenue'] as num?),
                                l10n,
                              ),
                              color: AppColors.accentGold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _PriceRangeBox(
                              label: l10n.maximum,
                              value: _money(
                                (_aiResult?['max_rent'] as num?) ??
                                    (((_analytics?['monthly_revenue'] as num?) ?? 8500) * 1.4),
                                l10n,
                              ),
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              if (!_isAnalyzing && _hasResult) ...[
                // Market Trends Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.marketTrends,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.estate.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      _TrendItem(
                        label: l10n.monthlyChange,
                        value: (_aiResult?['monthly_change'] ?? '+3.2%').toString(),
                        isPositive: true,
                      ),
                      SizedBox(height: 12),
                      _TrendItem(
                        label: l10n.yearlyChange,
                        value: (_aiResult?['yearly_change'] ?? '+12.5%').toString(),
                        isPositive: true,
                      ),
                      SizedBox(height: 12),
                      _TrendItem(
                        label: l10n.occupancyRate,
                        value: '${_aiResult?['occupancy_rate'] ?? _analytics?['occupancy_rate'] ?? 85}%',
                        isPositive: true,
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
                            l10n.recommendationsTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ..._marketRecommendations(l10n).map(
                        (text) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecommendationItem(text: text),
                        ),
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

class _PriceRangeBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PriceRangeBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.estate.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _TrendItem({
    required this.label,
    required this.value,
    required this.isPositive,
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
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
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

