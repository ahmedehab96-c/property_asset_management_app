import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان العلامة الثابتة — لا تتغير بين الفاتح والداكن.
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryBlue = Color(0xFF1D4ED8);
  static const Color royalBlue = Color(0xFF1E40AF);
  static const Color navy = Color(0xFF1E3A5F);

  static const Color teal = Color(0xFF3D8B7A);
  static const Color emerald = Color(0xFF2D9B6E);
  static const Color darkGreen = Color(0xFF1F4D3A);
  static const Color lightGreen = Color(0xFF5CB88A);

  static const Color violet = Color(0xFF4A6FA5);
  static const Color accentGold = Color(0xFFC9A227);
  static const Color gold = Color(0xFFD4AF37);
  static const Color terracotta = Color(0xFFB87333);

  // ─── داكن (للتوافق مع الكود القديم) ─────────────────────────────────────
  static const Color ink = Color(0xFF0C1014);
  static const Color midnight = Color(0xFF0F1C28);
  static const Color deepOcean = Color(0xFF152838);
  static const Color tealDeep = Color(0xFF1A2820);
  static const Color background = Color(0xFF0C1014);
  static const Color cardDark = Color(0xFF161E26);
  static const Color surfaceElevated = Color(0xFF1E2A34);
  static const Color stone = Color(0xFF2A343E);
  static const Color white = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF94A3B8);
  static const Color darkGrey = Color(0xFF64748B);

  static Color get cardTransparent => cardDark.withValues(alpha: 0.55);
  static Color get cardSemiTransparent => cardDark.withValues(alpha: 0.8);
  static Color get cardMoreTransparent => cardDark.withValues(alpha: 0.34);
  static Color get borderSubtle => Colors.white.withValues(alpha: 0.08);
  static Color get orbSky => primary.withValues(alpha: 0.14);
  static Color get orbGarden => teal.withValues(alpha: 0.11);
  static Color get orbGold => accentGold.withValues(alpha: 0.1);
  static Color get orbBrick => terracotta.withValues(alpha: 0.07);
  static Color get orbPrimary => orbSky;
  static Color get orbTeal => orbGarden;
  static Color get orbAccent => orbGold;

  // ─── فاتح ───────────────────────────────────────────────────────────────
  static const Color lightInk = Color(0xFF0F172A);
  static const Color lightBackground = Color(0xFFF4F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF8FAFC);
  static const Color lightGrey = Color(0xFF64748B);
  static const Color lightBorder = Color(0x1A0F172A);
}

/// ألوان دلالية حسب المظهر — استخدم `context.estate` في الواجهات.
@immutable
class EstateColors extends ThemeExtension<EstateColors> {
  const EstateColors({
    required this.pageGradient,
    required this.pageGradientStops,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceGlass,
    required this.surfaceGlassLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.appBarGlass,
    required this.orbSky,
    required this.orbGarden,
    required this.orbGold,
    required this.orbBrick,
    required this.sidebarGradient,
    required this.glassCardColors,
    required this.shadow,
  });

  final List<Color> pageGradient;
  final List<double> pageGradientStops;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceGlass;
  final Color surfaceGlassLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color appBarGlass;
  final Color orbSky;
  final Color orbGarden;
  final Color orbGold;
  final Color orbBrick;
  final List<Color> sidebarGradient;
  final List<Color> glassCardColors;
  final Color shadow;

  static const light = EstateColors(
    pageGradient: [
      Color(0xFFFBFCFE),
      Color(0xFFEEF3FF),
      Color(0xFFE6F4F0),
      Color(0xFFF8F1E4),
      Color(0xFFEFF3F8),
      Color(0xFFF7FAFD),
    ],
    pageGradientStops: [0.0, 0.2, 0.42, 0.64, 0.84, 1.0],
    background: Color(0xFFF5F8FC),
    surface: Color(0xFAFFFFFF),
    surfaceElevated: Color(0xFFF8FAFC),
    surfaceGlass: Color(0xCCFFFFFF),
    surfaceGlassLight: Color(0x80FFFFFF),
    textPrimary: AppColors.lightInk,
    textSecondary: AppColors.lightGrey,
    border: Color(0x120F172A),
    appBarGlass: Color(0xB3FFFFFF),
    orbSky: Color(0x3D2563EB),
    orbGarden: Color(0x333D8B7A),
    orbGold: Color(0x36C9A227),
    orbBrick: Color(0x24B87333),
    sidebarGradient: [
      Color(0xF5F9FBFD),
      Color(0xF0EEF4FF),
      Color(0xEBE8F5F1),
    ],
    glassCardColors: [
      Color(0xE6FFFFFF),
      Color(0xCCF8FAFC),
      Color(0x99F0FDF9),
    ],
    shadow: Color(0x100F172A),
  );

  static const dark = EstateColors(
    pageGradient: [
      Color(0xFF06090F),
      Color(0xFF0B1420),
      Color(0xFF12263A),
      Color(0xFF0E221C),
      Color(0xFF152030),
      Color(0xFF06090F),
    ],
    pageGradientStops: [0.0, 0.18, 0.4, 0.62, 0.82, 1.0],
    background: Color(0xFF080B10),
    surface: Color(0xE6161E26),
    surfaceElevated: Color(0xFF1A2430),
    surfaceGlass: Color(0x73161E26),
    surfaceGlassLight: Color(0x40161E26),
    textPrimary: AppColors.white,
    textSecondary: AppColors.grey,
    border: Color(0x0FFFFFFF),
    appBarGlass: Color(0x66161E26),
    orbSky: Color(0x3D2563EB),
    orbGarden: Color(0x303D8B7A),
    orbGold: Color(0x2EC9A227),
    orbBrick: Color(0x20B87333),
    sidebarGradient: [
      Color(0xE6080B10),
      Color(0xF00D1520),
      Color(0xE6122030),
    ],
    glassCardColors: [
      Color(0x99161E26),
      Color(0x661E2A34),
      Color(0x401A2820),
    ],
    shadow: Color(0x55080B10),
  );

  @override
  EstateColors copyWith({
    List<Color>? pageGradient,
    List<double>? pageGradientStops,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceGlass,
    Color? surfaceGlassLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? appBarGlass,
    Color? orbSky,
    Color? orbGarden,
    Color? orbGold,
    Color? orbBrick,
    List<Color>? sidebarGradient,
    List<Color>? glassCardColors,
    Color? shadow,
  }) {
    return EstateColors(
      pageGradient: pageGradient ?? this.pageGradient,
      pageGradientStops: pageGradientStops ?? this.pageGradientStops,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      surfaceGlassLight: surfaceGlassLight ?? this.surfaceGlassLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      appBarGlass: appBarGlass ?? this.appBarGlass,
      orbSky: orbSky ?? this.orbSky,
      orbGarden: orbGarden ?? this.orbGarden,
      orbGold: orbGold ?? this.orbGold,
      orbBrick: orbBrick ?? this.orbBrick,
      sidebarGradient: sidebarGradient ?? this.sidebarGradient,
      glassCardColors: glassCardColors ?? this.glassCardColors,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  EstateColors lerp(ThemeExtension<EstateColors>? other, double t) {
    if (other is! EstateColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension EstateThemeX on BuildContext {
  EstateColors get estate =>
      Theme.of(this).extension<EstateColors>() ?? EstateColors.light;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}

ThemeData buildLightTheme(BuildContext context) =>
    _buildTheme(context, brightness: Brightness.light, palette: EstateColors.light);

ThemeData buildDarkTheme(BuildContext context) =>
    _buildTheme(context, brightness: Brightness.dark, palette: EstateColors.dark);

/// للتوافق — يُفضّل استخدام theme/darkTheme في MaterialApp.
ThemeData buildAppTheme(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? buildDarkTheme(context)
      : buildLightTheme(context);
}

ThemeData _buildTheme(
  BuildContext context, {
  required Brightness brightness,
  required EstateColors palette,
}) {
  final isDark = brightness == Brightness.dark;
  final base = isDark ? ThemeData.dark() : ThemeData.light();
  final screenWidth = MediaQuery.sizeOf(context).width;

  final double displayLargeSize = screenWidth < 600 ? 28 : (screenWidth <= 1024 ? 36 : 42);
  final double displayMediumSize = screenWidth < 600 ? 22 : (screenWidth <= 1024 ? 28 : 32);
  final double headlineMediumSize = screenWidth < 600 ? 18 : (screenWidth <= 1024 ? 22 : 26);
  final double titleLargeSize = screenWidth < 600 ? 16 : (screenWidth <= 1024 ? 20 : 24);
  final double bodyLargeSize = screenWidth < 600 ? 14 : (screenWidth <= 1024 ? 16 : 18);
  final double bodyMediumSize = screenWidth < 600 ? 12 : (screenWidth <= 1024 ? 14 : 16);
  final double bodySmallSize = screenWidth < 600 ? 10 : (screenWidth <= 1024 ? 12 : 14);

  final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.cairo(
      fontSize: displayLargeSize,
      fontWeight: FontWeight.bold,
      color: palette.textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.cairo(
      fontSize: displayMediumSize,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    ),
    headlineMedium: GoogleFonts.cairo(
      fontSize: headlineMediumSize,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    ),
    titleLarge: GoogleFonts.cairo(
      fontSize: titleLargeSize,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    ),
    bodyLarge: GoogleFonts.cairo(
      fontSize: bodyLargeSize,
      color: palette.textPrimary,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: bodyMediumSize,
      color: palette.textSecondary,
    ),
    bodySmall: GoogleFonts.cairo(
      fontSize: bodySmallSize,
      color: palette.textSecondary,
    ),
  );

  final colorScheme = isDark
      ? base.colorScheme.copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accentGold,
          tertiary: AppColors.teal,
          surface: palette.surface,
          onSurface: palette.textPrimary,
          onSurfaceVariant: palette.textSecondary,
        )
      : ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accentGold,
          tertiary: AppColors.teal,
          surface: palette.surface,
          onSurface: palette.textPrimary,
          onSurfaceVariant: palette.textSecondary,
        );

  return base.copyWith(
    brightness: brightness,
    scaffoldBackgroundColor: palette.background,
    primaryColor: AppColors.primary,
    colorScheme: colorScheme,
    extensions: [palette],
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: palette.textPrimary,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: palette.textPrimary, size: 24),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: palette.surfaceGlass,
      selectedItemColor: AppColors.accentGold,
      unselectedItemColor: palette.textSecondary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
    ),
    cardTheme: CardThemeData(
      color: palette.surfaceGlass,
      elevation: isDark ? 0 : 1,
      shadowColor: palette.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: palette.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? palette.surfaceGlassLight : palette.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
      ),
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentGold,
        foregroundColor: isDark ? AppColors.ink : AppColors.lightInk,
        elevation: isDark ? 0 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentGold,
      foregroundColor: isDark ? AppColors.ink : AppColors.lightInk,
      elevation: 6,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerColor: palette.border,
  );
}
