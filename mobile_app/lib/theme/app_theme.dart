import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان العلامة الثابتة — لا تتغير بين الفاتح والداكن.
class AppColors {
  static const Color primary = Color(0xFF1F5C8B);
  static const Color primaryBlue = Color(0xFF184A70);
  static const Color royalBlue = Color(0xFF123A5A);
  static const Color navy = Color(0xFF15324A);

  static const Color teal = Color(0xFF2E8B6F);
  static const Color emerald = Color(0xFF22815A);
  static const Color darkGreen = Color(0xFF1B3F2F);
  static const Color lightGreen = Color(0xFF63B98C);

  static const Color violet = Color(0xFF52678F);
  static const Color accentGold = Color(0xFFC68A2E);
  static const Color gold = Color(0xFFD1A23E);
  static const Color terracotta = Color(0xFFB2592E);

  // ─── داكن (للتوافق مع الكود القديم) ─────────────────────────────────────
  static const Color ink = Color(0xFF0D1210);
  static const Color midnight = Color(0xFF101D29);
  static const Color deepOcean = Color(0xFF16293A);
  static const Color tealDeep = Color(0xFF1C2B22);
  static const Color background = Color(0xFF0D1210);
  static const Color cardDark = Color(0xFF242F3B);
  static const Color surfaceElevated = Color(0xFF2B3744);
  static const Color stone = Color(0xFF36414D);
  static const Color white = Color(0xFFF6F4EF);
  static const Color grey = Color(0xFFB4BCC2);
  static const Color darkGrey = Color(0xFF7B8087);

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
  static const Color lightInk = Color(0xFF1C2B3A);
  static const Color lightBackground = Color(0xFFF7F4EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFBF9F5);
  static const Color lightGrey = Color(0xFF6B6F76);
  static const Color lightBorder = Color(0x1A1C2B3A);
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
      Color(0xFFFBFAF6),
      Color(0xFFEEF1F7),
      Color(0xFFE7F5F0),
      Color(0xFFF9F1E2),
      Color(0xFFF1F0EC),
      Color(0xFFF8F6F1),
    ],
    pageGradientStops: [0.0, 0.2, 0.42, 0.64, 0.84, 1.0],
    background: Color(0xFFF7F4EE),
    surface: Color(0xFAFFFFFF),
    surfaceElevated: Color(0xFFFBF9F5),
    surfaceGlass: Color(0xCCFFFFFF),
    surfaceGlassLight: Color(0x80FFFFFF),
    textPrimary: AppColors.lightInk,
    textSecondary: AppColors.lightGrey,
    border: Color(0x1F1C2B3A),
    appBarGlass: Color(0xB3FFFFFF),
    orbSky: Color(0x3D1F5C8B),
    orbGarden: Color(0x332E8B6F),
    orbGold: Color(0x36C68A2E),
    orbBrick: Color(0x24B2592E),
    sidebarGradient: [
      Color(0xF5FAF8F4),
      Color(0xF0EEF1F7),
      Color(0xEBE9F5F0),
    ],
    glassCardColors: [
      Color(0xE6FFFFFF),
      Color(0xCCFBF9F5),
      Color(0x99EFFBF4),
    ],
    shadow: Color(0x101C2B3A),
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
    surface: Color(0xE6242F3B),
    surfaceElevated: Color(0xFF2B3744),
    surfaceGlass: Color(0x80242F3B),
    surfaceGlassLight: Color(0x4D242F3B),
    textPrimary: AppColors.white,
    textSecondary: AppColors.grey,
    border: Color(0x24FFFFFF),
    appBarGlass: Color(0x75242F3B),
    orbSky: Color(0x3D1F5C8B),
    orbGarden: Color(0x302E8B6F),
    orbGold: Color(0x2EC68A2E),
    orbBrick: Color(0x20B2592E),
    sidebarGradient: [
      Color(0xE6080B10),
      Color(0xF00D1520),
      Color(0xE6122030),
    ],
    glassCardColors: [
      Color(0xB3242F3B),
      Color(0x802B3744),
      Color(0x401C2B22),
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
