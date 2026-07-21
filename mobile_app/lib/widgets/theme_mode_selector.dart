import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/providers/theme_notifier.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

/// زر سريع في الشريط العلوي للتبديل بين الفاتح والداكن.
class ThemeModeIconButton extends ConsumerWidget {
  const ThemeModeIconButton({super.key, this.iconSize = 22});

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: l10n.changeBackgroundTheme,
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: AppColors.accentGold,
        size: iconSize,
      ),
      onPressed: () => _showThemeSheet(context),
    );
  }
}

/// بطاقة واضحة بخيارات فاتح / داكن / تلقائي.
class ThemeModeSelectorCard extends ConsumerWidget {
  const ThemeModeSelectorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.estate;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentMode = ref.watch(themeModeSyncProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

    final options = [
      (ThemeMode.light, Icons.wb_sunny_rounded, l10n.themeLight),
      (ThemeMode.dark, Icons.nights_stay_rounded, l10n.themeDark),
      (ThemeMode.system, Icons.settings_brightness_rounded, l10n.themeAuto),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing * 2),
      decoration: BoxDecoration(
        color: palette.surfaceGlass,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: AppColors.accentGold, size: 22),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  l10n.appearance,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing / 2),
          Text(
            l10n.chooseAppAppearance,
            style: theme.textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
          SizedBox(height: spacing * 1.5),
          Row(
            children: [
              for (final (mode, icon, label) in options) ...[
                Expanded(
                  child: _ThemeChip(
                    icon: icon,
                    label: label,
                    selected: currentMode == mode,
                    onTap: () => notifier.setThemeMode(mode),
                  ),
                ),
                if (mode != ThemeMode.system) SizedBox(width: spacing),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, mobile: 12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentGold.withValues(alpha: 0.15)
                : palette.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: selected ? AppColors.accentGold : palette.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.accentGold : palette.textPrimary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? AppColors.accentGold : palette.textPrimary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showThemeSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.estate.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.estate.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.backgroundTheme,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ThemeModeSelectorCard(),
          ],
        ),
      );
    },
  );
}
