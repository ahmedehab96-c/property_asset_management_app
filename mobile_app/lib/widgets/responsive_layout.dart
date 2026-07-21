import 'package:flutter/material.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/widgets/ambient_background.dart';

/// Centers content, applies adaptive padding, SafeArea, and keyboard insets.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = false,
    this.safeArea = true,
    this.constrainWidth = true,
    this.physics,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool safeArea;
  final bool constrainWidth;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final insets = padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.adaptivePadding(context),
          vertical: AppSpacing.md,
        );

    Widget content = Padding(padding: insets, child: child);

    if (constrainWidth) {
      content = ResponsiveHelper.constrainContent(
        context: context,
        child: content,
      );
    }

    if (scrollable) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: content,
            ),
          );
        },
      );
    } else {
      content = Padding(
        padding: EdgeInsets.only(
          bottom: ResponsiveHelper.viewInsetsOf(context).bottom,
        ),
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}

/// Ambient background + scaffold with keyboard-aware body.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.scrollable = false,
    this.padding,
    this.constrainWidth = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final bool constrainWidth;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: ResponsivePage(
          scrollable: scrollable,
          padding: padding,
          constrainWidth: constrainWidth,
          child: body,
        ),
      ),
    );
  }
}

/// Adaptive grid using max cross-axis extent (preferred over fixed column counts).
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxCrossAxisExtent,
    this.childAspectRatio = 1.15,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? maxCrossAxisExtent;
  final double childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final gap = crossAxisSpacing ?? AppSpacing.gap(context);
    final mainGap = mainAxisSpacing ?? AppSpacing.gap(context);
    final extent =
        maxCrossAxisExtent ?? ResponsiveHelper.adaptiveGridExtent(context);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ??
          (shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics()),
      padding: padding,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: extent,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainGap,
        crossAxisSpacing: gap,
      ),
      itemBuilder: itemBuilder,
    );
  }
}

/// Text that never overflows its bounds.
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Full-width button with minimum touch target.
class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.expanded = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveHelper.getResponsiveButtonHeight(context);
    final button = SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: FilledButton(
        onPressed: onPressed,
        child: child,
      ),
    );
    return button;
  }
}

/// Shows a scrollable, width-capped dialog on all devices.
Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final width = ResponsiveHelper.screenWidth(context);
  final maxWidth = width < 600 ? width * 0.92 : (width < 1024 ? 480.0 : 560.0);

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.adaptivePadding(ctx),
          vertical: AppSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: ResponsiveHelper.screenHeight(ctx) * 0.85,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.viewInsetsOf(ctx).bottom,
            ),
            child: builder(ctx),
          ),
        ),
      );
    },
  );
}

Future<T?> showResponsiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      final bottom = ResponsiveHelper.viewInsetsOf(ctx).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: ResponsiveHelper.screenHeight(ctx) * 0.9,
          ),
          child: builder(ctx),
        ),
      );
    },
  );
}
