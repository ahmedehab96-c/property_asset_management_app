import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/screens/property_detail_screen.dart';
import 'package:property_asset_management_app/ui/screens/maps_screen.dart';
import 'package:property_asset_management_app/ui/screens/profile_screen.dart';
import 'package:property_asset_management_app/ui/screens/extend_contract_screen.dart';
import 'package:property_asset_management_app/ui/screens/cancel_contract_screen.dart';
import 'package:property_asset_management_app/ui/screens/file_lawsuit_screen.dart';
import 'package:property_asset_management_app/ui/screens/filter_properties_screen.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/properties_notifier.dart';
import 'package:property_asset_management_app/ui/animations/staggered_animation.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/screens/contact_tenant_screen.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class MyPropertiesScreen extends ConsumerStatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  ConsumerState<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends ConsumerState<MyPropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load({bool reset = true}) {
    final l10n = AppLocalizations.of(context);
    ref.read(propertiesProvider.notifier).load(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
          reset: reset,
        );
  }

  void _loadMore() {
    final l10n = AppLocalizations.of(context);
    ref.read(propertiesProvider.notifier).loadMore(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  Map<String, dynamic>? _contractFromProperty(Map<String, dynamic> property) {
    if (property['isVacant'] == true) return null;
    final detail = property['detail'] as Map<String, dynamic>?;
    return {
      'id': property['contractId'] ?? property['contract_id'],
      'property': property['name'],
      'tenant': property['tenantName'],
      'endDate': detail?['rentEndDate'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ps = ref.watch(propertiesProvider);
    final loading = ps.status == ViewStatus.loading && ps.properties.isEmpty;
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final padding = EdgeInsets.all(ResponsiveHelper.adaptivePadding(context));
    
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
                  icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary, size: iconSize),
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
          l10n.myProperties,
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
                    icon: Icon(Icons.filter_list, color: context.estate.textPrimary, size: iconSize),
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const FilterPropertiesScreen(),
                          direction: AxisDirection.left,
                        ),
                      );
                    },
                  ),
          IconButton(
            icon: Icon(Icons.map_outlined, color: context.estate.textPrimary, size: iconSize),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const MapsScreen(),
                  direction: AxisDirection.left,
            ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: context.estate.textPrimary, size: iconSize),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const ProfileScreen(),
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
      child: loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.accentGold),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loadingProperties,
                    style: TextStyle(color: context.estate.textSecondary),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.accentGold,
              onRefresh: () async => _load(reset: true),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useGrid = constraints.maxWidth >=
                      ResponsiveHelper.mobileBreakpoint;

                  if (useGrid) {
                    return CustomScrollView(
                      slivers: [
                        if (ps.fromDemo)
                          SliverPadding(
                            padding: padding,
                            sliver: const SliverToBoxAdapter(
                              child: DemoDataBanner(
                                margin: EdgeInsets.only(bottom: 16),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            padding.left,
                            0,
                            padding.right,
                            padding.bottom,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: ResponsiveHelper.value(
                                context,
                                mobile: 400,
                                tablet: 420,
                                desktop: 480,
                              ),
                              mainAxisSpacing: AppSpacing.gap(context),
                              crossAxisSpacing: AppSpacing.gap(context),
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, i) {
                                return StaggeredAnimation(
                                  index: i,
                                  child: _PropertyCard(
                                    name: ps.properties[i]['name'] as String,
                                    location:
                                        ps.properties[i]['location'] as String,
                                    status: ps.properties[i]['statusLabel']
                                        as String,
                                    statusColor: ps.properties[i]['statusColor']
                                        as Color,
                                    tenantName: ps.properties[i]['tenantDisplay']
                                        as String,
                                    contractEnd:
                                        ps.properties[i]['contractEnd'] as String,
                                    isVacant: ps.properties[i]['isVacant']
                                            as bool? ??
                                        false,
                                    imagePaths: List<String>.from(
                                      ps.properties[i]['imagePaths'] as List,
                                    ),
                                    contract: _contractFromProperty(
                                      ps.properties[i],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlidePageRoute(
                                          page: PropertyDetailScreen(
                                            property: Map<String, dynamic>.from(
                                              ps.properties[i]['detail'] as Map,
                                            ),
                                          ),
                                          direction: AxisDirection.left,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: ps.properties.length,
                            ),
                          ),
                        ),
                        if (ps.hasMore && !ps.fromDemo)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: ps.loadingMore
                                    ? const CircularProgressIndicator(
                                        color: AppColors.accentGold,
                                      )
                                    : TextButton(
                                        onPressed: _loadMore,
                                        child: Text(l10n.loadMore),
                                      ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  return ListView(
                    padding: padding,
                    children: [
                      if (ps.fromDemo)
                        const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
                      for (var i = 0; i < ps.properties.length; i++) ...[
                        if (i > 0)
                          SizedBox(
                            height: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                        StaggeredAnimation(
                          index: i,
                          child: _PropertyCard(
                            name: ps.properties[i]['name'] as String,
                            location: ps.properties[i]['location'] as String,
                            status: ps.properties[i]['statusLabel'] as String,
                            statusColor:
                                ps.properties[i]['statusColor'] as Color,
                            tenantName:
                                ps.properties[i]['tenantDisplay'] as String,
                            contractEnd:
                                ps.properties[i]['contractEnd'] as String,
                            isVacant:
                                ps.properties[i]['isVacant'] as bool? ?? false,
                            imagePaths: List<String>.from(
                              ps.properties[i]['imagePaths'] as List,
                            ),
                            contract: _contractFromProperty(ps.properties[i]),
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: PropertyDetailScreen(
                                    property: Map<String, dynamic>.from(
                                      ps.properties[i]['detail'] as Map,
                                    ),
                                  ),
                                  direction: AxisDirection.left,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (ps.hasMore && !ps.fromDemo)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: ps.loadingMore
                                ? const CircularProgressIndicator(
                                    color: AppColors.accentGold,
                                  )
                                : TextButton(
                                    onPressed: _loadMore,
                                    child: Text(l10n.loadMore),
                                  ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ),
    );
  }
}

class _PropertyCard extends StatefulWidget {
  final String name;
  final String location;
  final String status;
  final Color statusColor;
  final String tenantName;
  final String contractEnd;
  final bool isVacant;
  final List<String> imagePaths;
  final Map<String, dynamic>? contract;
  final VoidCallback onTap;

  const _PropertyCard({
    required this.name,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.tenantName,
    required this.contractEnd,
    this.isVacant = false,
    required this.imagePaths,
    this.contract,
    required this.onTap,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  int _currentImageIndex = 0;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
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
    final imageHeight = ResponsiveHelper.getResponsiveImageHeight(
      context,
      mobile: 180.0,
      tablet: 220.0,
      desktop: 260.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    
    return GestureDetector(
      onTap: widget.onTap,
        onTapDown: (_) {
            setState(() => _isPressed = true);
        _animationController.forward();
        },
        onTapUp: (_) {
            setState(() => _isPressed = false);
        _animationController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        _animationController.reverse();
        },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..scaleByDouble(_scaleAnimation.value, _scaleAnimation.value, _scaleAnimation.value, 1.0)
              ..rotateY(_rotationAnimation.value)
              ..rotateX(_rotationAnimation.value * 0.5),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                          AppColors.cardDark.withValues(alpha: 0.95),
                          AppColors.navy.withValues(alpha: 0.85),
                        ]
                      : [
                          AppColors.cardDark,
                          AppColors.cardDark.withValues(alpha: 0.9),
                        ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: _isPressed
                      ? AppColors.accentGold.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                        BoxShadow(
                    color: _isPressed
                        ? AppColors.accentGold.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    blurRadius: _isPressed ? 25 : 15,
                    spreadRadius: _isPressed ? 3 : 1,
                    offset: Offset(0, _isPressed ? 8 : 5),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Image Carousel
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius),
                        ),
                        child: SizedBox(
                          height: imageHeight,
                          width: double.infinity,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemCount: widget.imagePaths.length,
                            itemBuilder: (context, index) {
                              return Image.asset(
                                widget.imagePaths[index],
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: imageHeight,
                                    width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                                          AppColors.primaryBlue,
                              AppColors.navy,
                            ],
                          ),
                                    ),
                                    child: Icon(
                                      Icons.home,
                                      size: ResponsiveHelper.isMobile(context) ? 70 : 
                                            ResponsiveHelper.isTablet(context) ? 90 : 110,
                                      color: AppColors.accentGold,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      // Status Tag (Oval shape)
                      Positioned(
                        top: spacing * 2,
                        right: spacing * 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing * 2,
                            vertical: spacing * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.statusColor,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveBorderRadius(
                                context,
                                mobile: 20,
                                tablet: 24,
                                desktop: 28,
                          ),
                            ),
                          ),
                          child: Text(
                            widget.status,
                            style: TextStyle(
                              color: context.estate.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Page Indicator Dots
                      if (widget.imagePaths.length > 1)
                        Positioned(
                          bottom: spacing * 2,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.imagePaths.length,
                              (index) => Container(
                                width: ResponsiveHelper.isMobile(context) ? 6 : 8,
                                height: ResponsiveHelper.isMobile(context) ? 6 : 8,
                                margin: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    mobile: 3,
                                    tablet: 4,
                                    desktop: 5,
                        ),
                      ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? AppColors.accentGold
                                      : AppColors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Property Details
                  Padding(
                    padding: padding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                      color: context.estate.textPrimary,
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
                  SizedBox(height: spacing * 1.5),
                            Row(
                              children: [
                                Icon(
                        widget.isVacant ? Icons.cancel_outlined : Icons.person_outline,
                        size: iconSize,
                        color: context.estate.textSecondary,
                                ),
                      SizedBox(width: spacing),
                                Expanded(
                                  child: Text(
                          widget.tenantName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.estate.textSecondary,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                            ),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                  SizedBox(height: spacing),
                  Row(
                    children: [
                      Icon(
                        widget.isVacant ? Icons.check_circle_outline : Icons.calendar_today,
                        size: iconSize,
                        color: context.estate.textSecondary,
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: Text(
                          widget.contractEnd,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.estate.textSecondary,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 2.5),
                  // Action Buttons
                  Row(
                    children: [
                      // Three dots button (always first)
                      _ActionButton(
                        icon: Icons.more_vert,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: context.estate.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  ResponsiveHelper.getResponsiveBorderRadius(
                                    context,
                                    mobile: 20,
                                    tablet: 24,
                                    desktop: 28,
                                  ),
                                ),
                              ),
                            ),
                            builder: (context) => Container(
                              padding: EdgeInsets.all(
                                ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  mobile: 16,
                                  tablet: 20,
                                  desktop: 24,
                        ),
                      ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                        children: [
                                  ListTile(
                                    leading: Icon(Icons.edit, color: AppColors.accentGold),
                                    title: Text(
                                      AppLocalizations.of(context).edit,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: context.estate.textPrimary,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      UiFeedback.showInfo(
                                        context,
                                        AppLocalizations.of(context).webOnlyAction,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.share, color: AppColors.accentGold),
                                    title: Text(
                                      AppLocalizations.of(context).share,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: context.estate.textPrimary,
                                ),
                              ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      UiFeedback.showInfo(
                                        context,
                                        AppLocalizations.of(context).webOnlyAction,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red),
                                    title: Text(
                                      AppLocalizations.of(context).deleteItem,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      UiFeedback.showInfo(
                                        context,
                                        AppLocalizations.of(context).webOnlyAction,
                                      );
                                    },
                              ),
                            ],
                          ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: spacing * 1.5),
                      // Chat button (only for rented properties)
                      if (!widget.isVacant)
                        _ActionButton(
                          icon: Icons.chat_bubble_outline,
                          onTap: () {
                            final name = widget.tenantName;
                            if (name.isEmpty || name == AppLocalizations.of(context).noTenant) {
                              UiFeedback.showInfo(
                                context,
                                AppLocalizations.of(context).noDataAvailable,
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                page: ContactTenantScreen(
                                  tenant: {
                                    'name': name,
                                    'property': widget.name,
                                  },
                                ),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                        ),
                      if (!widget.isVacant) SizedBox(width: spacing * 1.5),
                      // View Details button (always present)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: AppColors.primaryBlue,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveBorderRadius(
                                  context,
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context).viewDetailsProperty,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Add button (only for rented properties)
                      if (!widget.isVacant) ...[
                        SizedBox(width: spacing * 1.5),
                        _ActionButton(
                          icon: Icons.add,
                          color: AppColors.accentGold,
                          isCircular: true,
                          onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: context.estate.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                          ResponsiveHelper.getResponsiveBorderRadius(
                                            context,
                                            mobile: 20,
                                            tablet: 24,
                                            desktop: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                    builder: (context) {
                                      final sheetL10n = AppLocalizations.of(context);
                                      return Container(
                                      padding: EdgeInsets.all(
                                        ResponsiveHelper.getResponsivePadding(
                                          context,
                                          mobile: 20.0,
                                          tablet: 24.0,
                                          desktop: 28.0,
                                        ).left,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(
                                              Icons.update,
                                              color: AppColors.accentGold,
                                            ),
                                            title: Text(
                                              sheetL10n.extendContract,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                color: context.estate.textPrimary,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                page: ExtendContractScreen(contract: widget.contract),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                                          ),
                                          ListTile(
                                            leading: Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.red,
                                            ),
                                            title: Text(
                                              sheetL10n.cancelContract,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                color: context.estate.textPrimary,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                SlidePageRoute(
                                                  page: CancelContractScreen(contract: widget.contract),
                                                  direction: AxisDirection.left,
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(
                                              Icons.gavel,
                                              color: Colors.orange,
                                            ),
                                            title: Text(
                                              sheetL10n.fileLawsuit,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                color: context.estate.textPrimary,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                SlidePageRoute(
                                                  page: FileLawsuitScreen(contract: widget.contract),
                                                  direction: AxisDirection.left,
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            height: ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              mobile: 20,
                                              tablet: 24,
                                              desktop: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                          },
                        ),
                        ],
                    ],
                    ),
                ],
              ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final bool isCircular;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    this.isCircular = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.isMobile(context)
        ? (isCircular ? 56.0 : 40.0)
        : (isCircular ? 64.0 : 44.0);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: isCircular ? 28.0 : 20.0,
      tablet: isCircular ? 32.0 : 22.0,
      desktop: isCircular ? 36.0 : 24.0,
    );
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );
    
    return GestureDetector(
      onTap: onTap,
        child: Container(
        width: size,
        height: size,
          decoration: BoxDecoration(
          color: color ?? AppColors.primaryBlue,
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: !isCircular ? BorderRadius.circular(borderRadius) : null,
                ),
        child: Icon(
          icon,
          color: context.estate.textPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}
