import 'package:flutter/material.dart';
import 'app_theme.dart';

/// تدرجات موحّدة — فاتحة أو داكنة حسب المظهر.
class AppGradients {
  AppGradients._();

  static const List<Color> backgroundColors = [
    AppColors.ink,
    AppColors.midnight,
    AppColors.deepOcean,
    AppColors.tealDeep,
    Color(0xFF152030),
    AppColors.ink,
  ];

  static const List<double> backgroundStops = [0.0, 0.18, 0.4, 0.62, 0.82, 1.0];

  static BoxDecoration pageDecorationFor(BuildContext context) {
    final e = context.estate;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: e.pageGradient,
        stops: e.pageGradientStops,
      ),
    );
  }

  @Deprecated('Use pageDecorationFor(context)')
  static BoxDecoration get pageDecoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundColors,
          stops: backgroundStops,
        ),
      );

  static const LinearGradient cardShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x22FFFFFF),
      Color(0x05FFFFFF),
      Color(0x0CC9A227),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient goldButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentGold, AppColors.gold, Color(0xFFB8941F)],
    stops: [0.0, 0.45, 1.0],
  );

  static LinearGradient sidebarFor(BuildContext context) {
    final e = context.estate;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: e.sidebarGradient,
      stops: const [0.0, 0.55, 1.0],
    );
  }

  @Deprecated('Use sidebarFor(context)')
  static LinearGradient get sidebar => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.ink.withValues(alpha: 0.97),
          AppColors.midnight.withValues(alpha: 0.99),
          AppColors.deepOcean.withValues(alpha: 0.95),
        ],
      );

  static BoxDecoration glassCardFor(BuildContext context) {
    final e = context.estate;
    final isDark = context.isDarkTheme;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: e.glassCardColors,
        stops: const [0.0, 0.55, 1.0],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: e.border.withValues(alpha: isDark ? 0.65 : 0.85)),
      boxShadow: [
        BoxShadow(
          color: e.shadow,
          blurRadius: isDark ? 28 : 18,
          offset: Offset(0, isDark ? 10 : 6),
          spreadRadius: isDark ? 0 : -2,
        ),
      ],
    );
  }

  @Deprecated('Use glassCardFor(context)')
  static BoxDecoration get glassCard => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardDark.withValues(alpha: 0.72),
            AppColors.surfaceElevated.withValues(alpha: 0.5),
            AppColors.tealDeep.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get estateAccentStrip => const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentGold, AppColors.gold, AppColors.accentGold],
        ),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      );
}
