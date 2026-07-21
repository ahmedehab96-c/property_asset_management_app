import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/theme_notifier.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/theme_mode_selector.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.estate;
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
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

    final options = [
      _ThemeOption(
        mode: ThemeMode.light,
        icon: '☀️',
        labelAr: 'فاتح',
        labelEn: 'Light',
      ),
      _ThemeOption(
        mode: ThemeMode.dark,
        icon: '🌙',
        labelAr: 'داكن',
        labelEn: 'Dark',
      ),
      _ThemeOption(
        mode: ThemeMode.system,
        icon: '🔄',
        labelAr: 'تلقائي',
        labelEn: 'System',
      ),
    ];

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: palette.textPrimary, size: iconSize),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.appearance,
          style: TextStyle(
            color: palette.textPrimary,
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
            const ThemeModeSelectorCard(),
            SizedBox(height: spacing * 2),
            ...options.map((option) {
              final isSelected = ref.watch(themeModeSyncProvider) == option.mode;
              final label = isArabic ? option.labelAr : option.labelEn;
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: InkWell(
                  onTap: () async {
                    await ref.read(themeModeProvider.notifier).setThemeMode(option.mode);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic
                              ? 'تم تغيير المظهر إلى $label'
                              : 'Theme changed to $label',
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
                          ? AppColors.accentGold.withValues(alpha: 0.15)
                          : palette.surfaceGlass,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : palette.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          option.icon,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 28,
                              tablet: 32,
                              desktop: 36,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing * 2),
                        Expanded(
                          child: Text(
                            label,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.accentGold : palette.textPrimary,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                            ),
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

class _ThemeOption {
  final ThemeMode mode;
  final String icon;
  final String labelAr;
  final String labelEn;

  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.labelAr,
    required this.labelEn,
  });
}
