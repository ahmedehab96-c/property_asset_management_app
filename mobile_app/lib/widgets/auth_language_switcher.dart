import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

/// مبدّل اللغة لشاشات الدخول والتسجيل ونسيت كلمة المرور.
class AuthLanguageSwitcher extends ConsumerWidget {
  const AuthLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.estate;
    final isAr = ref.watch(isArabicProvider);
    final notifier = ref.read(localeProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LangChip(
          label: 'العربية',
          selected: isAr,
          onTap: () => notifier.setLocale(const Locale('ar')),
          palette: palette,
        ),
        const SizedBox(width: 12),
        _LangChip(
          label: 'English',
          selected: !isAr,
          onTap: () => notifier.setLocale(const Locale('en')),
          palette: palette,
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EstateColors palette;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentGold.withValues(alpha: 0.35)
                : palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.accentGold : palette.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? null
                : [
                    BoxShadow(
                      color: palette.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.navy : palette.textPrimary,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
