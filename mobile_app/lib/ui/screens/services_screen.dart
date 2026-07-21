import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/widgets/responsive_layout.dart';
import 'package:property_asset_management_app/ui/screens/service_request_screen.dart';
import 'package:property_asset_management_app/ui/screens/maintenance_screen.dart';
import 'package:property_asset_management_app/ui/screens/repair_request_screen.dart';
import 'package:property_asset_management_app/ui/screens/calendar_screen.dart';
import 'package:property_asset_management_app/ui/animations/staggered_animation.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    return AppScaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header Section with padding
              Padding(
                padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StaggeredAnimation(
                  index: 0,
                  child: Text(
                    AppLocalizations.of(context).servicesCenter,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                    ),
                  ),
                ),
                    SizedBox(height: spacing),
                StaggeredAnimation(
                  index: 1,
                  child: Text(
                    AppLocalizations.of(context).chooseServiceYouNeed,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.estate.textSecondary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 3.5),
              // Services List
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: padding.left,
                    right: padding.right,
                    bottom: padding.bottom,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final services = _serviceItems(context);
                      final useGrid =
                          constraints.maxWidth >= ResponsiveHelper.mobileBreakpoint;

                      if (useGrid) {
                        return AdaptiveGrid(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: services.length,
                          maxCrossAxisExtent: ResponsiveHelper.value(
                            context,
                            mobile: 180,
                            tablet: 320,
                            desktop: 380,
                          ),
                          childAspectRatio: ResponsiveHelper.value(
                            context,
                            mobile: 2.4,
                            tablet: 2.6,
                            desktop: 2.8,
                          ),
                          itemBuilder: (context, index) {
                            final item = services[index];
                            return StaggeredAnimation(
                              index: index + 2,
                              child: _ServiceCard(
                                icon: item.icon,
                                title: item.title,
                                subtitle: item.subtitle,
                                onTap: item.onTap,
                              ),
                            );
                          },
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < services.length; i++) ...[
                            if (i > 0) SizedBox(height: spacing * 2),
                            StaggeredAnimation(
                              index: i + 2,
                              child: _ServiceCard(
                                icon: services[i].icon,
                                title: services[i].title,
                                subtitle: services[i].subtitle,
                                onTap: services[i].onTap,
                              ),
                            ),
                          ],
                          SizedBox(height: spacing * 2.5),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
    );
  }

  List<_ServiceItem> _serviceItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _ServiceItem(
        icon: Icons.gavel,
        title: l10n.legalConsultations,
        subtitle: l10n.legalConsultationsSubtitle,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: ServiceRequestScreen(
                serviceType: 'legal',
                serviceTitle: l10n.legalConsultation,
              ),
              direction: AxisDirection.left,
            ),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.engineering,
        title: l10n.engineeringConsultations,
        subtitle: l10n.engineeringConsultationsSubtitle,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: ServiceRequestScreen(
                serviceType: 'engineering',
                serviceTitle: l10n.engineeringConsultation,
              ),
              direction: AxisDirection.left,
            ),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.build,
        title: l10n.maintenance,
        subtitle: l10n.maintenanceSubtitle,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: const MaintenanceScreen(),
              direction: AxisDirection.left,
            ),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.construction,
        title: l10n.repairRequest,
        subtitle: l10n.repairRequestSubtitle,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: const RepairRequestScreen(),
              direction: AxisDirection.left,
            ),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.calendar_month_outlined,
        title: l10n.calendar,
        subtitle: l10n.calendarSubtitle,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: const CalendarScreen(),
              direction: AxisDirection.left,
            ),
          );
        },
      ),
    ];
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _ServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final spacing = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 18,
      tablet: 20,
      desktop: 24,
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                          AppColors.cardDark.withValues(alpha: 0.9),
                          AppColors.navy.withValues(alpha: 0.7),
                        ]
                      : [
                          AppColors.cardDark.withValues(alpha: 0.8),
                          AppColors.navy.withValues(alpha: 0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: _isPressed
                      ? AppColors.accentGold.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isPressed
                      ? (ResponsiveHelper.isMobile(context) ? 1.5 : 2)
                      : (ResponsiveHelper.isMobile(context) ? 1 : 1.5),
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.25),
                          blurRadius: ResponsiveHelper.isMobile(context) ? 15 : 22,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: ResponsiveHelper.isMobile(context) ? 10 : 15,
                          offset: Offset(0, ResponsiveHelper.isMobile(context) ? 5 : 8),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsiveSpacing(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.3),
                        width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.accentGold,
                      size: ResponsiveHelper.getResponsiveIconSize(
                        context,
                        mobile: 30,
                        tablet: 34,
                        desktop: 38,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing * 2.5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 18,
                              tablet: 20,
                              desktop: 22,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: spacing / 2),
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.estate.textSecondary,
                            height: 1.4,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    color: AppColors.accentGold.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
