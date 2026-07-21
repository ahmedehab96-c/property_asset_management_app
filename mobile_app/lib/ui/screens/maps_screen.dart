import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/maps_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:property_asset_management_app/widgets/property_map_view.dart';

class MapsScreen extends ConsumerStatefulWidget {
  const MapsScreen({super.key});

  @override
  ConsumerState<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends ConsumerState<MapsScreen> {
  String _selectedFilter = LocalizedDemoData.filterAll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProperties());
  }

  void _loadProperties() {
    final l10n = AppLocalizations.of(context);
    ref.read(mapsProvider.notifier).load(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  Future<void> _openInMaps(double latitude, double longitude, String name) async {
    final mapsError = AppLocalizations.of(context).mapsOpenError;
    final mapsFailedPrefix = AppLocalizations.of(context).mapsOpenFailed;
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=$latitude,$longitude&ll=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        UiFeedback.showError(context, mapsError);
      }
    } catch (e) {
      if (!mounted) return;
      UiFeedback.showError(context, '$mapsFailedPrefix: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final ms = ref.watch(mapsProvider);
    final properties = ms.properties;
    final loading = ms.status == ViewStatus.loading && properties.isEmpty;
    final fromDemo = ms.fromDemo;
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final filteredProperties = switch (_selectedFilter) {
      LocalizedDemoData.filterRented =>
        properties.where((p) => p['statusType'] == LocalizedDemoData.filterRented).toList(),
      LocalizedDemoData.filterVacant =>
        properties.where((p) => p['statusType'] == LocalizedDemoData.filterVacant).toList(),
      _ => properties,
    };

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
    final mapHeight = ResponsiveHelper.getResponsiveImageHeight(
      context,
      mobile: 200,
      tablet: 280,
      desktop: 360,
    );
    final carouselHeight = ResponsiveHelper.getResponsiveImageHeight(
      context,
      mobile: 200,
      tablet: 250,
      desktop: 280,
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
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
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
          l10n.maps,
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
      ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          children: [
            // Filter Tabs
            Padding(
              padding: padding,
              child: ResponsiveHelper.isMobile(context)
                  ? Column(
                      children: [
                        _FilterTab(
                          label: l10n.all,
                          isSelected: _selectedFilter == LocalizedDemoData.filterAll,
                          onTap: () {
                            setState(() {
                              _selectedFilter = LocalizedDemoData.filterAll;
                            });
                          },
                        ),
                        SizedBox(height: spacing),
                        _FilterTab(
                          label: l10n.rented,
                          isSelected: _selectedFilter == LocalizedDemoData.filterRented,
                          onTap: () {
                            setState(() {
                              _selectedFilter = LocalizedDemoData.filterRented;
                            });
                          },
                        ),
                        SizedBox(height: spacing),
                        _FilterTab(
                          label: l10n.vacant,
                          isSelected: _selectedFilter == LocalizedDemoData.filterVacant,
                          onTap: () {
                            setState(() {
                              _selectedFilter = LocalizedDemoData.filterVacant;
                            });
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _FilterTab(
                            label: l10n.all,
                            isSelected: _selectedFilter == LocalizedDemoData.filterAll,
                            onTap: () {
                              setState(() {
                                _selectedFilter = LocalizedDemoData.filterAll;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: spacing * 1.5),
                        Expanded(
                          child: _FilterTab(
                            label: l10n.rented,
                            isSelected: _selectedFilter == LocalizedDemoData.filterRented,
                            onTap: () {
                              setState(() {
                                _selectedFilter = LocalizedDemoData.filterRented;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: spacing * 1.5),
                        Expanded(
                          child: _FilterTab(
                            label: l10n.vacant,
                            isSelected: _selectedFilter == LocalizedDemoData.filterVacant,
                            onTap: () {
                              setState(() {
                                _selectedFilter = LocalizedDemoData.filterVacant;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
            ),

            if (fromDemo)
            const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),

            // Map
            SizedBox(
              height: mapHeight,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: padding.left),
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                  ),
                  child: Stack(
                    children: [
                      PropertyMapView(
                        properties: filteredProperties,
                        onMarkerTap: (property) {
                          _openInMaps(
                            property['latitude'],
                            property['longitude'],
                            property['name'],
                          );
                        },
                      ),
                      if (loading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.accentGold,
                                ),
                                SizedBox(height: spacing * 2),
                                Text(
                                  l10n.loadingMaps,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: context.estate.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: spacing * 2),

            // Properties List
            Container(
              height: carouselHeight,
              padding: EdgeInsets.symmetric(horizontal: padding.left),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: Text(
                      '${l10n.propertiesCount} (${filteredProperties.length})',
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
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, index) {
                        final property = filteredProperties[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: ResponsiveHelper.isMobile(context) ? 12 : 16,
                          ),
                          child: _PropertyCard(
                            property: property,
                            demo: demo,
                            l10n: l10n,
                            onTap: () {
                              _openInMaps(
                                property["latitude"],
                                property["longitude"],
                                property["name"],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing * 2),
          ],
        ),
        ),
        ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getResponsiveBorderRadius(
          context,
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
      ),
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
          color: isSelected
              ? AppColors.accentGold.withValues(alpha: 0.2)
              : AppColors.cardDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : Colors.white.withValues(alpha: 0.1),
            width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accentGold : AppColors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final LocalizedDemoData demo;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _PropertyCard({
    required this.property,
    required this.demo,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = ResponsiveHelper.screenWidth(context);
    final cardWidth = ResponsiveHelper.value(
      context,
      mobile: (screenWidth * 0.55).clamp(180.0, 220.0),
      tablet: (screenWidth * 0.35).clamp(240.0, 300.0),
      desktop: (screenWidth * 0.28).clamp(260.0, 320.0),
    );
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: padding,
        decoration: BoxDecoration(
          color: context.estate.surface.withValues(alpha: 0.8),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobile: 6,
                      tablet: 8,
                      desktop: 10,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: property["statusColor"].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: property["statusColor"],
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property["name"],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
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
                        property["location"],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.estate.textSecondary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 11,
                            tablet: 12,
                            desktop: 13,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    color: property["statusColor"].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                  ),
                  child: Text(
                    demo.propertyStatusLabel(property['statusType'] as String),
                    style: TextStyle(
                      color: property["statusColor"],
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 10,
                        tablet: 11,
                        desktop: 12,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  property["rentAmount"],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w600,
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
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onTap,
                icon: Icon(
                  Icons.map_outlined,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  color: AppColors.accentGold,
                ),
                label: Text(
                  l10n.openInMaps,
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 11,
                      tablet: 12,
                      desktop: 13,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

