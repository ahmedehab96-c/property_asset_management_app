import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends ConsumerState<LanguageSettingsScreen> {
  List<Map<String, String>> _getLanguages(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {"name": l10n.arabic, "code": "ar", "flag": "🇸🇦"},
      {"name": l10n.english, "code": "en", "flag": "🇬🇧"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.estate;
    final l10n = AppLocalizations.of(context);
    final languages = _getLanguages(context);
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
            ref.watch(isArabicProvider) ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: palette.textPrimary,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.language,
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
            ...languages.map((language) {
              final isSelected = ref.watch(localeSyncProvider).languageCode == language["code"];
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: InkWell(
                  onTap: () async {
                    final newLocale = Locale(language["code"]!);
                    final languageName = language["name"]!;
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final l10nForMessage = AppLocalizations.of(context);
                    await ref.read(localeProvider.notifier).setLocale(newLocale);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          "${l10nForMessage.languageChangedTo} $languageName",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    if (mounted) {
                      navigator.pop();
                    }
                  },
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    padding: EdgeInsets.all(spacing * 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentGold.withValues(alpha: 0.18)
                          : palette.surface,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : palette.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? null
                          : [
                              BoxShadow(
                                color: palette.shadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          language["flag"]!,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 24,
                              tablet: 28,
                              desktop: 32,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing * 2),
                        Expanded(
                          child: Text(
                            language["name"]!,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.accentGold : palette.textPrimary,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
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
