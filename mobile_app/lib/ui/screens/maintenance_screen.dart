import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/viewmodels/maintenance_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/screens/service_request_screen.dart';
import 'package:property_asset_management_app/ui/screens/notifications_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String _selectedTab = "current";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load({bool reset = true}) {
    final l10n = AppLocalizations.of(context);
    ref.read(maintenanceProvider.notifier).load(l10n: l10n, reset: reset);
  }

  void _loadMore() {
    final l10n = AppLocalizations.of(context);
    ref.read(maintenanceProvider.notifier).loadMore(l10n: l10n);
  }

  List<Map<String, dynamic>> _displayedRequests(MaintenanceState ms) {
    final notifier = ref.read(maintenanceProvider.notifier);
    return _selectedTab == "current"
        ? notifier.currentRequests
        : notifier.historyRequests;
  }
  
  String _getStatusText(String statusType, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (statusType) {
      case "in_progress":
        return l10n.inProgress;
      case "completed":
        return l10n.completed;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ms = ref.watch(maintenanceProvider);
    final loading = ms.status == ViewStatus.loading && ms.requests.isEmpty;
    final displayedRequests = _displayedRequests(ms);
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
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );

    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.estate.surfaceGlass,
                    context.estate.surfaceGlassLight,
                  ],
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: context.estate.textPrimary,
            size: iconSize,
          ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      final homeShellState = context.findAncestorStateOfType<HomeShellState>();
                      if (homeShellState != null) {
                        homeShellState.changeIndex(0);
                      }
                    }
                  },
        ),
        title: Text(
          AppLocalizations.of(context).maintenanceServices,
          style: TextStyle(
            color: context.estate.textPrimary,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: AppColors.accentGold,
              size: iconSize,
            ),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const NotificationsScreen(),
                  direction: AxisDirection.left,
                ),
              );
            },
          ),
        ],
      ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Service Type Selection Section
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).chooseServiceType,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  // 2x2 Grid of Services
                  ResponsiveHelper.isMobile(context)
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _ServiceTypeCard(
                                    icon: Icons.flash_on,
                                    title: AppLocalizations.of(context).electricity,
                                    subtitle: AppLocalizations.of(context).electricitySubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "electricity",
                                            serviceTitle: AppLocalizations.of(context).electricity,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: spacing * 1.5),
                                Expanded(
                                  child: _ServiceTypeCard(
                                    icon: Icons.water_drop,
                                    title: AppLocalizations.of(context).plumbing,
                                    subtitle: AppLocalizations.of(context).plumbingSubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "plumbing",
                                            serviceTitle: AppLocalizations.of(context).plumbing,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing * 1.5),
                            Row(
                              children: [
                                Expanded(
                                  child: _ServiceTypeCard(
                                    icon: Icons.cleaning_services,
                                    title: AppLocalizations.of(context).cleaning,
                                    subtitle: AppLocalizations.of(context).cleaningSubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "cleaning",
                                            serviceTitle: AppLocalizations.of(context).cleaning,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: spacing * 1.5),
                                Expanded(
                                  child: _ServiceTypeCard(
                                    icon: Icons.ac_unit,
                                    title: AppLocalizations.of(context).ac,
                                    subtitle: AppLocalizations.of(context).acSubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "ac",
                                            serviceTitle: AppLocalizations.of(context).ac,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _ServiceTypeCard(
                                    icon: Icons.flash_on,
                                    title: AppLocalizations.of(context).electricity,
                                    subtitle: AppLocalizations.of(context).electricitySubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "electricity",
                                            serviceTitle: AppLocalizations.of(context).electricity,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: spacing * 1.5),
                                  _ServiceTypeCard(
                                    icon: Icons.cleaning_services,
                                    title: AppLocalizations.of(context).cleaning,
                                    subtitle: AppLocalizations.of(context).cleaningSubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "cleaning",
                                            serviceTitle: AppLocalizations.of(context).cleaning,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: spacing * 1.5),
                            Expanded(
                              child: Column(
                                children: [
                                  _ServiceTypeCard(
                                    icon: Icons.water_drop,
                                    title: AppLocalizations.of(context).plumbing,
                                    subtitle: AppLocalizations.of(context).plumbingSubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "plumbing",
                                            serviceTitle: AppLocalizations.of(context).plumbing,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: spacing * 1.5),
                                  _ServiceTypeCard(
                                    icon: Icons.ac_unit,
                                    title: AppLocalizations.of(context).ac,
                                    subtitle: AppLocalizations.of(context).acSubtitle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: ServiceRequestScreen(
                                            serviceType: "ac",
                                            serviceTitle: AppLocalizations.of(context).ac,
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),

            SizedBox(height: spacing * 2),

            // Tabs Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding.left),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: AppLocalizations.of(context).currentRequests,
                      isSelected: _selectedTab == "current",
                      onTap: () {
                        setState(() {
                          _selectedTab = "current";
                        });
                      },
                    ),
                  ),
                  SizedBox(width: spacing * 2),
                  Expanded(
                    child: _TabButton(
                      label: AppLocalizations.of(context).requestHistory,
                      isSelected: _selectedTab == "history",
                      onTap: () {
                        setState(() {
                          _selectedTab = "history";
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing * 2),

            if (ms.fromDemo)
            const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),

            // Requests List
            Expanded(
              child: loading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.accentGold),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).loadingMaintenance,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.estate.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : displayedRequests.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).noRequests,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.estate.textSecondary,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.accentGold,
                      onRefresh: () async => _load(reset: true),
                      child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: padding.left),
                      itemCount:                           displayedRequests.length +
                              (ms.hasMore && !ms.fromDemo ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (ms.hasMore &&
                            !ms.fromDemo &&
                            index == displayedRequests.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: ms.loadingMore
                                  ? const CircularProgressIndicator(
                                      color: AppColors.accentGold,
                                    )
                                  : TextButton(
                                      onPressed: _loadMore,
                                      child: Text(
                                        AppLocalizations.of(context).loadMore,
                                      ),
                                    ),
                            ),
                          );
                        }
                        final request = displayedRequests[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                          child: _RequestCard(
                            request: request,
                            getStatusText: _getStatusText,
                          ),
                        );
                      },
                    ),
                    ),
            ),

            // Add New Request Button
            Padding(
              padding: padding,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: ServiceRequestScreen(
                          serviceType: "maintenance",
                          serviceTitle: AppLocalizations.of(context).newMaintenanceRequest,
                        ),
                        direction: AxisDirection.left,
                      ),
                    ).then((_) => _load(reset: true));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.accentGold,
                          size: 20,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 8,
                          tablet: 10,
                          desktop: 12,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).newMaintenanceRequest,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
    );
  }
}

class _ServiceTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 32.0,
      tablet: 36.0,
      desktop: 40.0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.estate.surface,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.accentGold,
              size: iconSize,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
              textAlign: TextAlign.center,
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
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.estate.textSecondary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 10,
            tablet: 12,
            desktop: 14,
          ),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.accentGold : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isSelected ? AppColors.accentGold : AppColors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String Function(String, BuildContext) getStatusText;

  const _RequestCard({
    required this.request,
    required this.getStatusText,
  });

  Color _getStatusColor() {
    switch (request["statusType"]) {
      case "completed":
        return Colors.green;
      case "in_progress":
        return AppColors.accentGold;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.estate.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              vertical: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 4,
                tablet: 5,
                desktop: 6,
              ),
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveBorderRadius(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 5,
                    desktop: 6,
                  ),
                ),
                Text(
                  getStatusText(request["statusType"], context),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 11,
                      tablet: 12,
                      desktop: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          // Request Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request["title"],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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
                  "${AppLocalizations.of(context).requestNumber}${request["orderNumber"]} - ${request["date"]}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.estate.textSecondary,
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
          // Icon
          Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            decoration: BoxDecoration(
              color: context.estate.surface,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveBorderRadius(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
            child: Icon(
              request["icon"] as IconData,
              color: request["iconColor"] as Color,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}
