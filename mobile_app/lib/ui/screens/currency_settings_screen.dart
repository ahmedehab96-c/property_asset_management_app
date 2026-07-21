import 'package:flutter/material.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  String _selectedCurrency = 'AED';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final currencies = demo.supportedCurrencies();
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
    final spacing = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: context.estate.textPrimary,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.currency,
          style: TextStyle(
            color: context.estate.textPrimary,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: padding,
          children: [
            SizedBox(height: spacing * 2),
            ...currencies.map((currency) {
              final isSelected = _selectedCurrency == currency['code'];
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCurrency = currency['code']!;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${l10n.currencyChangedTo} ${currency['name']}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    padding: EdgeInsets.all(spacing * 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentGold.withValues(alpha: 0.2)
                          : AppColors.cardDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentGold
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          currency['symbol']!,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 24,
                              tablet: 28,
                              desktop: 32,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: spacing * 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency['code']!,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.accentGold
                                      : context.estate.textPrimary,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 18,
                                    tablet: 20,
                                    desktop: 22,
                                  ),
                                ),
                              ),
                              Text(
                                currency['name']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context.estate.textSecondary,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 14,
                                    tablet: 15,
                                    desktop: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.accentGold,
                            size: iconSize,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
