import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

/// بانر موحّد عند عرض بيانات تجريبية (مطابق لويب DemoDataBanner).
class DemoDataBanner extends StatelessWidget {
  const DemoDataBanner({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.accentGold, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.demoDataBanner,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.estate.textPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
