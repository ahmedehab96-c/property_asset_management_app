import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/widgets/ambient_background.dart';

/// غلاف موحّد: خلفية متدرجة + Scaffold شفاف (فاتح/داكن).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.showOrbs = true,
    this.showWatermark = true,
    this.constrainWidth = false,
    this.safeArea = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final bool showOrbs;
  final bool showWatermark;
  final bool constrainWidth;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (constrainWidth) {
      content = ResponsiveHelper.constrainContent(
        context: context,
        child: content,
      );
    }
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return AmbientBackground(
      showOrbs: showOrbs,
      showWatermark: showWatermark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: appBar,
        body: content,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}

/// AppBar شفاف متناسق مع الخلفية.
PreferredSizeWidget glassAppBar({
  required BuildContext context,
  String? title,
  Widget? titleWidget,
  List<Widget>? actions,
  Widget? leading,
  bool centerTitle = true,
}) {
  final palette = context.estate;
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: centerTitle,
    leading: leading,
    title: titleWidget ??
        (title != null
            ? Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null),
    actions: actions,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: palette.appBarGlass,
            border: Border(
              bottom: BorderSide(color: palette.border.withValues(alpha: 0.35)),
            ),
          ),
        ),
      ),
    ),
  );
}

/// زر أيقونة زجاجي ناعم — بلا حواف صلبة، يندمج مع الخلفية.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    this.icon,
    this.onPressed,
    this.iconSize = 22,
    this.iconColor,
    this.margin,
    this.child,
    this.tooltip,
  });

  final IconData? icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    final radius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 14,
      tablet: 16,
      desktop: 18,
    );
    final content = child ??
        IconButton(
          tooltip: tooltip,
          icon: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.accentGold,
          ),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        );

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: palette.surfaceGlass.withValues(alpha: 0.45),
              border: Border.all(
                color: palette.border.withValues(alpha: 0.28),
                width: 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// شريط سفلي زجاجي ناعم للتابلت/الويب.
class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceGlass.withValues(alpha: 0.5),
            border: Border(
              top: BorderSide(
                color: palette.border.withValues(alpha: 0.35),
                width: 0.6,
              ),
            ),
          ),
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}
