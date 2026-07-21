import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/screens/reports_screen.dart';
import 'package:property_asset_management_app/ui/screens/market_analysis_screen.dart';
import 'package:property_asset_management_app/ui/screens/image_analysis_screen.dart';
import 'package:property_asset_management_app/ui/screens/tenant_analysis_screen.dart';
import 'package:property_asset_management_app/ui/screens/financial_predictions_screen.dart';
import 'package:property_asset_management_app/ui/screens/maps_screen.dart';
import 'package:property_asset_management_app/viewmodels/dashboard_notifier.dart';
import 'package:property_asset_management_app/ui/animations/staggered_animation.dart';
import 'package:property_asset_management_app/ui/screens/calendar_screen.dart';
import 'package:property_asset_management_app/ui/screens/tasks_screen.dart';
import 'package:property_asset_management_app/ui/screens/messages_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _balanceAnimation;
  double _targetBalance = 2450000;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _balanceAnimation = Tween<double>(begin: 0.0, end: _targetBalance).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).load();
    });
  }

  void _syncBalanceAnimation(double balance) {
    if (_targetBalance == balance) return;
    _targetBalance = balance;
    _balanceAnimation = Tween<double>(begin: 0.0, end: _targetBalance).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _animationController
      ..reset()
      ..forward();
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
      tablet: 12.0,
      desktop: 16.0,
    );
    
    final l10n = AppLocalizations.of(context);
    final dash = ref.watch(dashboardProvider);
    _syncBalanceAnimation(dash.totalBalance);

    if (dash.status == ViewStatus.loading) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accentGold),
              SizedBox(height: spacing * 2),
              Text(
                l10n.loadingDashboard,
                style: TextStyle(color: context.estate.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          color: AppColors.accentGold,
          onRefresh: () => ref.read(dashboardProvider.notifier).load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
                    padding: padding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  if (dash.fromDemo)
                    DemoDataBanner(margin: EdgeInsets.only(bottom: spacing * 2)),
                  StaggeredAnimation(
                    index: 0,
                    child: Text(
                      l10n.overview,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: context.estate.textSecondary,
                        letterSpacing: 0.3,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 3.5),

                            // Main Balance Card (Glassmorphism) with 3D animation
                            StaggeredAnimation(
                              index: 1,
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(_fadeAnimation.value * 0.1)
                                      ..rotateX(_fadeAnimation.value * 0.05),
                                    alignment: Alignment.center,
                                    child: _GlassCard(
                                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.totalBalance,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.greenAccent.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: Colors.greenAccent,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  dash.growthPercent,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _balanceAnimation,
                        builder: (context, child) {
                          final formattedBalance =
                              (_balanceAnimation.value).toStringAsFixed(0);
                          final displayBalance = formattedBalance
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              );
                          return Text(
                            "$displayBalance ${l10n.aed}",
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                              letterSpacing: 1,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Icon(
                            Icons.update,
                            size: 16,
                            color: context.estate.textSecondary.withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 6),
                          Text(
                            l10n.lastUpdate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.estate.textSecondary,
                            ),
                          ),
                        ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                            SizedBox(height: spacing * 3.5),

                  // Quick Stats — adaptive wrap/grid
                  StaggeredAnimation(
                    index: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 700
                            ? 4
                            : (constraints.maxWidth >= 480 ? 2 : 2);
                        final cardWidth =
                            (constraints.maxWidth - spacing * 1.75 * (cols - 1)) /
                                cols;
                        final stats = [
                          _StatCard(
                            icon: Icons.house,
                            label: l10n.rentedProperties,
                            value: dash.rentedPropertiesCount,
                            color: AppColors.accentGold,
                          ),
                          _StatCard(
                            icon: Icons.description,
                            label: l10n.activePortfolio,
                            value: dash.activeContractsCount,
                            color: Colors.greenAccent,
                          ),
                        ];
                        return Wrap(
                          spacing: spacing * 1.75,
                          runSpacing: spacing * 1.75,
                          children: stats
                              .map(
                                (card) => SizedBox(
                                  width: cardWidth,
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing * 4.5),

              // Reports Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              StaggeredAnimation(
                index: 3,
                child: Text(
                  l10n.reports,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const ReportsScreen(),
                          direction: AxisDirection.left,
                        ),
                      );
                    },
                    child: Text(
                      l10n.viewAll,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
                  SizedBox(height: spacing * 2.5),
                  StaggeredAnimation(
                    index: 4,
                    child: _ReportTile(
                      title: l10n.revenueExpenseReport,
                      subtitle: l10n.revenueExpenseSubtitle,
                      icon: Icons.account_balance_wallet,
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const ReportsScreen(),
                            direction: AxisDirection.left,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing * 1.75),
                  StaggeredAnimation(
                    index: 5,
                    child: _ReportTile(
                      title: l10n.rentedPropertiesReport,
                      subtitle: l10n.rentedPropertiesSubtitle,
                      icon: Icons.house,
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const ReportsScreen(),
                            direction: AxisDirection.left,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing * 1.75),
                  StaggeredAnimation(
                    index: 6,
                    child: _ReportTile(
                      title: l10n.constructionProjectsReport,
                      subtitle: l10n.constructionProjectsSubtitle,
                      icon: Icons.construction,
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const ReportsScreen(),
                            direction: AxisDirection.left,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing * 2.5),

              // Maps Section
              StaggeredAnimation(
                index: 7,
                child: _ReportTile(
                  title: l10n.maps,
                  subtitle: l10n.mapsSubtitle,
                  icon: Icons.map_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: const MapsScreen(),
                        direction: AxisDirection.left,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: spacing * 1.75),

              StaggeredAnimation(
                index: 7,
                child: _ReportTile(
                  title: l10n.calendar,
                  subtitle: l10n.calendarSubtitle,
                  icon: Icons.calendar_month_outlined,
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
              ),
              SizedBox(height: spacing * 1.75),

              StaggeredAnimation(
                index: 8,
                child: _ReportTile(
                  title: l10n.tasks,
                  subtitle: l10n.noTasks,
                  icon: Icons.task_alt_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: const TasksScreen(),
                        direction: AxisDirection.left,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: spacing * 1.75),

              StaggeredAnimation(
                index: 9,
                child: _ReportTile(
                  title: l10n.messages,
                  subtitle: l10n.noMessages,
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: const MessagesScreen(),
                        direction: AxisDirection.left,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: spacing * 1.75),

              // AI Features Section
              StaggeredAnimation(
                index: 10,
                child: Text(
                  l10n.aiFeatures,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
                  SizedBox(height: spacing * 2.5),
                  // AI Features — adaptive wrap
                  StaggeredAnimation(
                    index: 11,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 900
                            ? 4
                            : (constraints.maxWidth >= 520 ? 2 : 2);
                        final gap = spacing * 1.5;
                        final cardWidth =
                            (constraints.maxWidth - gap * (cols - 1)) / cols;
                        final features = [
                          _AIFeatureCard(
                            icon: Icons.analytics,
                            title: l10n.marketAnalysis,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const MarketAnalysisScreen(),
                                  direction: AxisDirection.left,
                                ),
                              );
                            },
                          ),
                          _AIFeatureCard(
                            icon: Icons.camera_alt,
                            title: l10n.imageAnalysis,
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const ImageAnalysisScreen(),
                                  direction: AxisDirection.left,
                                ),
                              );
                            },
                          ),
                          _AIFeatureCard(
                            icon: Icons.person_search,
                            title: l10n.tenantAnalysis,
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const TenantAnalysisScreen(),
                                  direction: AxisDirection.left,
                                ),
                              );
                            },
                          ),
                          _AIFeatureCard(
                            icon: Icons.trending_up,
                            title: l10n.financialPredictions,
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const FinancialPredictionsScreen(),
                                  direction: AxisDirection.left,
                                ),
                              );
                            },
                          ),
                        ];
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: features
                              .map(
                                (card) => SizedBox(
                                  width: cardWidth,
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                            SizedBox(height: spacing * 2.5),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}

class _AIFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AIFeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AIFeatureCard> createState() => _AIFeatureCardState();
}

class _AIFeatureCardState extends State<_AIFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    final palette = context.estate;
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 28.0,
      tablet: 32.0,
      desktop: 36.0,
    );
    final iconPadding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..scaleByDouble(_scaleAnimation.value, _scaleAnimation.value, _scaleAnimation.value, 1.0)
              ..rotateY(_rotationAnimation.value)
              ..rotateX(_rotationAnimation.value * 0.5),
            alignment: Alignment.center,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.glassCardColors,
                  stops: const [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveBorderRadius(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
                border: Border.all(
                  color: widget.color.withValues(alpha: _isHovered ? 0.5 : 0.3),
                  width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: _isHovered ? 0.4 : 0.2),
                    blurRadius: _isHovered ? 20 : 10,
                    spreadRadius: _isHovered ? 2 : 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_rotationAnimation.value * 2),
                    alignment: Alignment.center,
                    child: Container(
                      padding: iconPadding,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            widget.color.withValues(alpha: 0.3),
                            widget.color.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveBorderRadius(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: widget.color, size: iconSize),
                    ),
                  ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 14,
              ),
            ),
                  Text(
                    widget.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.estate.textPrimary,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 32.0,
    );
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 20,
      tablet: 24,
      desktop: 28,
    );
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette.glassCardColors,
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: palette.border,
            width: ResponsiveHelper.isMobile(context) ? 1.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: ResponsiveHelper.isMobile(context) ? 20 : 30,
              offset: Offset(0, ResponsiveHelper.isMobile(context) ? 10 : 15),
              spreadRadius: ResponsiveHelper.isMobile(context) ? 1 : 2,
            ),
            BoxShadow(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              blurRadius: ResponsiveHelper.isMobile(context) ? 15 : 25,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.estate;
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 18,
      tablet: 20,
      desktop: 24,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final iconPadding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 10.0,
      tablet: 12.0,
      desktop: 14.0,
    );
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.glassCardColors,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: palette.border,
              width: ResponsiveHelper.isMobile(context) ? 1.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: ResponsiveHelper.isMobile(context) ? 12 : 18,
                offset: Offset(0, ResponsiveHelper.isMobile(context) ? 6 : 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: iconPadding,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                  ),
                ),
                child: Icon(widget.icon, color: widget.color, size: iconSize),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
              Text(
                widget.value,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                  letterSpacing: 0.5,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 22,
                    tablet: 26,
                    desktop: 30,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobile: 4,
                  tablet: 5,
                  desktop: 6,
                ),
              ),
              Text(
                widget.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.estate.textSecondary,
                  height: 1.3,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<_ReportTile>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    final palette = context.estate;
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
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 24,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 24,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: 16.0,
              tablet: 20.0,
              desktop: 24.0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette.glassCardColors,
                stops: const [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveBorderRadius(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              border: Border.all(
                color: _isPressed
                    ? AppColors.accentGold.withValues(alpha: 0.3)
                    : palette.border,
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
                        color: palette.shadow,
                        blurRadius: ResponsiveHelper.isMobile(context) ? 10 : 15,
                        offset: Offset(0, ResponsiveHelper.isMobile(context) ? 5 : 8),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    mobile: 12.0,
                    tablet: 14.0,
                    desktop: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
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
                      mobile: 22,
                      tablet: 26,
                      desktop: 30,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
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
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.estate.textSecondary,
                          height: 1.4,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  color: AppColors.accentGold.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
