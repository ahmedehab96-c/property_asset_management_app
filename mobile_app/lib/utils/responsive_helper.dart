import 'package:flutter/material.dart';

/// Breakpoints (shortest logical width):
/// - Mobile:  < 600
/// - Tablet:  600 – 1024
/// - Desktop: > 1024
enum DeviceType { mobile, tablet, desktop }

/// Shared spacing scale — prefer these over magic numbers.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static double page(BuildContext context) =>
      ResponsiveHelper.adaptivePadding(context);

  static double section(BuildContext context) =>
      ResponsiveHelper.adaptiveSpacing(context, mobile: 16, tablet: 20, desktop: 24);

  static double gap(BuildContext context) =>
      ResponsiveHelper.adaptiveSpacing(context, mobile: 8, tablet: 10, desktop: 12);
}

class ResponsiveHelper {
  ResponsiveHelper._();

  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static double screenWidth(BuildContext context) => sizeOf(context).width;

  static double screenHeight(BuildContext context) => sizeOf(context).height;

  static EdgeInsets viewPaddingOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context);

  static EdgeInsets viewInsetsOf(BuildContext context) =>
      MediaQuery.viewInsetsOf(context);

  static DeviceType getDeviceType(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width <= desktopBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// Phone-sized layout (includes narrow foldables / split view).
  static bool useBottomNav(BuildContext context) =>
      screenWidth(context) < mobileBreakpoint;

  /// Side rail / permanent sidebar.
  static bool useSideNav(BuildContext context) =>
      screenWidth(context) >= mobileBreakpoint;

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  static double adaptivePadding(BuildContext context) => value(
        context,
        mobile: 12,
        tablet: 20,
        desktop: 28,
      );

  static double adaptiveSpacing(
    BuildContext context, {
    double mobile = 8,
    double? tablet,
    double? desktop,
  }) =>
      value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  static double adaptiveFont(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) =>
      value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  /// Max cross-axis extent for adaptive grids (phone ~2 cols, tablet 3–4, desktop 5–6).
  static double adaptiveGridExtent(BuildContext context) => value(
        context,
        mobile: 180,
        tablet: 220,
        desktop: 260,
      );

  static int adaptiveGridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 5,
  }) =>
      value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  static double getResponsiveWidth(
    BuildContext context, {
    double mobile = 1.0,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    return screenWidth *
        value(context, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    final padding = value(
      context,
      mobile: mobile,
      tablet: tablet ?? 20,
      desktop: desktop ?? 28,
    );
    return EdgeInsets.all(padding);
  }

  static EdgeInsets getResponsiveHorizontalPadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    final padding = value(
      context,
      mobile: mobile,
      tablet: tablet ?? 20,
      desktop: desktop ?? 28,
    );
    return EdgeInsets.symmetric(horizontal: padding);
  }

  static EdgeInsets getResponsiveVerticalPadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    final padding = value(
      context,
      mobile: mobile,
      tablet: tablet ?? 20,
      desktop: desktop ?? 24,
    );
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Page padding that also lifts content above the keyboard.
  static EdgeInsets pageInsets(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    bool includeKeyboard = true,
  }) {
    final h = horizontal ?? adaptivePadding(context);
    final v = vertical ?? adaptivePadding(context);
    final bottomInset =
        includeKeyboard ? viewInsetsOf(context).bottom : 0.0;
    return EdgeInsets.fromLTRB(h, v, h, v + bottomInset);
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) =>
      adaptiveFont(context, mobile: mobile, tablet: tablet, desktop: desktop);

  static double getResponsiveIconSize(
    BuildContext context, {
    double mobile = 24.0,
    double? tablet,
    double? desktop,
  }) =>
      value(
        context,
        mobile: mobile,
        tablet: tablet ?? mobile + 2,
        desktop: desktop ?? mobile + 4,
      );

  static double getResponsiveBorderRadius(
    BuildContext context, {
    double mobile = 12.0,
    double? tablet,
    double? desktop,
  }) =>
      value(
        context,
        mobile: mobile,
        tablet: tablet ?? 14,
        desktop: desktop ?? 16,
      );

  static double getResponsiveSpacing(
    BuildContext context, {
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) =>
      adaptiveSpacing(context, mobile: mobile, tablet: tablet, desktop: desktop);

  static double getResponsiveCardWidth(
    BuildContext context, {
    int mobileColumns = 1,
    int? tabletColumns,
    int? desktopColumns,
  }) {
    final width = screenWidth(context);
    final padding = adaptivePadding(context) * 2;
    final columns = value(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );
    final gap = AppSpacing.gap(context) * (columns - 1);
    return (width - padding - gap) / columns;
  }

  static double getMaxContentWidth(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return 1280;
      case DeviceType.tablet:
        return 900;
      case DeviceType.mobile:
        return double.infinity;
    }
  }

  static double getResponsiveImageHeight(
    BuildContext context, {
    double mobile = 200.0,
    double? tablet,
    double? desktop,
  }) =>
      value(
        context,
        mobile: mobile,
        tablet: tablet ?? mobile * 1.15,
        desktop: desktop ?? mobile * 1.3,
      );

  static double getResponsiveButtonHeight(
    BuildContext context, {
    double mobile = 48.0,
    double? tablet,
    double? desktop,
  }) =>
      value(
        context,
        mobile: mobile.clamp(44, 56),
        tablet: tablet ?? 50,
        desktop: desktop ?? 52,
      );

  static EdgeInsets getResponsiveButtonPadding(
    BuildContext context, {
    EdgeInsets mobile =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) =>
      value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  /// Constrains child to [getMaxContentWidth] and centers it.
  static Widget constrainContent({
    required BuildContext context,
    required Widget child,
  }) {
    final maxWidth = getMaxContentWidth(context);
    if (!maxWidth.isFinite) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
