import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/viewmodels/property_detail_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/screens/contact_tenant_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/utils/media_opener.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  final int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProperty());
  }

  void _loadProperty() {
    final l10n = AppLocalizations.of(context);
    ref.read(propertyDetailProvider.notifier).load(
          seed: widget.property,
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  bool get _loadingApi {
    final ps = ref.watch(propertyDetailProvider);
    return ps.status == ViewStatus.loading && ps.property == null;
  }

  bool get _fromDemo => ref.watch(propertyDetailProvider).fromDemo;

  bool _hasTenant(Map<String, dynamic> property) {
    if (property['isVacant'] == true) return false;
    final name = property['tenantName']?.toString() ?? '';
    return name.isNotEmpty && name != '-';
  }

  String? _resolveContractPdfUrl() {
    final property = widget.property;
    for (final key in ['contractPdf', 'contract_pdf', 'pdfUrl', 'pdf_url']) {
      final value = property[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  Future<void> _openContractPdf() async {
    final l10n = AppLocalizations.of(context);
    final property = _resolvedProperty(context);
    final pdfUrl = _resolveContractPdfUrl();

    if (pdfUrl != null) {
      final uri = Uri.tryParse(pdfUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.estate.surface,
        title: Text(
          l10n.contracts,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Text(
            _buildContractSummary(property, l10n),
            style: TextStyle(color: context.estate.textSecondary, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.confirm, style: TextStyle(color: AppColors.accentGold)),
          ),
        ],
      ),
    );
  }

  String _buildContractSummary(Map<String, dynamic> property, AppLocalizations l10n) {
    final lines = <String>[
      if (property['name'] != null)
        l10n.contractSummaryProperty(property['name'] as String),
      if (property['tenantName'] != null)
        l10n.contractSummaryTenant(property['tenantName'] as String),
      if (property['rentAmount'] != null)
        l10n.contractSummaryRent(
          property['rentAmount'] as String,
          l10n.aed,
        ),
      if (property['rentEndDate'] != null)
        l10n.contractSummaryEndDate(property['rentEndDate'] as String),
      if (property['nextDueDate'] != null)
        l10n.contractSummaryNextDue(property['nextDueDate'] as String),
      if (property['status'] != null)
        l10n.contractSummaryStatus(property['status'] as String),
    ];
    if (lines.isEmpty) {
      return l10n.noContractDataAvailable;
    }
    return '${lines.join('\n')}\n\n${l10n.contractPdfServerNote}';
  }

  Map<String, dynamic> _resolvedProperty(BuildContext context) {
    final ps = ref.read(propertyDetailProvider);
    if (ps.property != null) return ps.property!;
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.read(isArabicProvider);
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final fallback = demo.propertyDetailFallback();
    final property = Map<String, dynamic>.from(widget.property);
    for (final entry in fallback.entries) {
      property.putIfAbsent(entry.key, () => entry.value);
    }
    return property;
  }

  List<String> _galleryImages(Map<String, dynamic> property) {
    final paths = <String>[];
    final main = property['imagePath']?.toString();
    if (main != null && main.isNotEmpty) paths.add(main);
    final raw = property['imagePaths'];
    if (raw is List) {
      for (final item in raw) {
        final s = item.toString();
        if (s.isNotEmpty && !paths.contains(s)) paths.add(s);
      }
    }
    if (paths.isEmpty) paths.add('assetss/images/home1.jpg');
    return paths;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final property = _resolvedProperty(context);
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
          l10n.propertyDetailsScreen,
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
              Icons.more_vert,
              color: context.estate.textPrimary,
              size: iconSize,
            ),
            onPressed: () {
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
                        title: Text(l10n.editProperty, style: Theme.of(context).textTheme.bodyLarge),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.share, color: AppColors.accentGold),
                        title: Text(l10n.shareProperty, style: Theme.of(context).textTheme.bodyLarge),
                        onTap: () {
                          Navigator.pop(context);
                          UiFeedback.showInfo(context, l10n.webOnlyAction);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text(l10n.deleteProperty, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          UiFeedback.showInfo(context, l10n.webOnlyAction);
                        },
                      ),
                    ],
                  ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingApi)
                const LinearProgressIndicator(color: AppColors.accentGold, minHeight: 2),
              if (_fromDemo)
                Padding(
                  padding: EdgeInsets.fromLTRB(padding.left, padding.top, padding.right, 0),
                  child: const DemoDataBanner(),
                ),
              // Image Carousel
              Stack(
                children: [
              ClipRRect(
                    child: Image.asset(
                      property["imagePath"] ?? "assetss/images/home1.jpg",
                      height: ResponsiveHelper.getResponsiveImageHeight(
                        context,
                        mobile: 280.0,
                        tablet: 320.0,
                        desktop: 360.0,
                      ),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: ResponsiveHelper.getResponsiveImageHeight(
                            context,
                            mobile: 280.0,
                            tablet: 320.0,
                            desktop: 360.0,
                          ),
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
                            size: ResponsiveHelper.isMobile(context) ? 100 : 120,
                            color: AppColors.accentGold,
                          ),
                        );
                      },
                    ),
                  ),
                  // Property Name Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: padding,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing * 2,
                              vertical: spacing,
                            ),
                            decoration: BoxDecoration(
                    color: AppColors.accentGold,
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveBorderRadius(
                                  context,
                                  mobile: 18,
                                  tablet: 20,
                                  desktop: 22,
                  ),
                ),
              ),
                            child: Text(
                              property['status'] as String? ?? l10n.rented,
                              style: theme.textTheme.bodyMedium?.copyWith(
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
                          SizedBox(height: spacing),
                          Text(
                            property["name"] as String,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 24,
                                tablet: 28,
                                desktop: 32,
                              ),
                            ),
                          ),
                          SizedBox(height: spacing / 2),
                          Text(
                            property["location"] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.estate.textPrimary,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pagination Dots
                  Positioned(
                    bottom: spacing * 2.5,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
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
                                : AppColors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacing * 3),

                    // Property Description Card
                    Container(
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
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                            l10n.propertyDescriptionDetail,
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
                          ),
                          SizedBox(height: spacing * 1.5),
                          Text(
                            property["description"] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textPrimary,
                              height: 1.6,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing * 2.5),

                    // Property Features Cards
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.square_foot,
                            value: l10n.areaDisplay(property['area'] as String),
                            color: AppColors.accentGold,
                          ),
                        ),
                        SizedBox(width: spacing * 1.5),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.bathtub_outlined,
                            value: l10n.bathroomsCount(property['bathrooms'] as int),
                            color: AppColors.accentGold,
                          ),
                        ),
                        SizedBox(width: spacing * 1.5),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.bed_outlined,
                            value: l10n.bedroomsCount(property['bedrooms'] as int),
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 2.5),

                    // Tenant Details Card
                    Container(
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
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tenantDataProperty,
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
                          ),
                          SizedBox(height: spacing * 2),
                          Row(
                            children: [
                              Container(
                                width: ResponsiveHelper.isMobile(context) ? 50 : 60,
                                height: ResponsiveHelper.isMobile(context) ? 50 : 60,
                                decoration: BoxDecoration(
                                  color: AppColors.darkGrey,
                                  shape: BoxShape.circle,
                    ),
                                child: Icon(
                                  Icons.person,
                                  color: context.estate.textPrimary,
                                  size: ResponsiveHelper.getResponsiveIconSize(
                                    context,
                                    mobile: 28,
                                    tablet: 32,
                                    desktop: 36,
                                  ),
                                ),
                              ),
                              SizedBox(width: spacing * 2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      property["tenantName"] as String,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.estate.textPrimary,
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 18,
                                          tablet: 20,
                                          desktop: 22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: spacing / 2),
                                    Text(
                                      '${l10n.contractEndsOn} ${property["rentEndDate"]}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: context.estate.textSecondary,
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 13,
                                          tablet: 14,
                                          desktop: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing * 2.5),

                    // Rental Details Card
                    Container(
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
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rentDetailsProperty,
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
                          ),
                          SizedBox(height: spacing * 2.5),
                          _RentalDetailRow(
                            label: l10n.monthlyRentAmountLabel,
                            value: '${property["rentAmount"]} ${l10n.aedCurrency}',
                          ),
                          SizedBox(height: spacing * 2),
                          _RentalDetailRow(
                            label: l10n.currentPaymentStatus,
                            value: l10n.paidStatus,
                            valueColor: Colors.green,
                            icon: Icons.check_circle,
                          ),
                          SizedBox(height: spacing * 2),
                          _RentalDetailRow(
                            label: l10n.nextDueDateProperty,
                            value: property["nextDueDate"] as String,
                    ),
                  ],
                ),
              ),
                    SizedBox(height: spacing * 3),

                    // Media Gallery Section
              Row(
                children: [
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
                            color: AppColors.accentGold.withValues(alpha: 0.2),
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
                            Icons.photo_library,
                            color: AppColors.accentGold,
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              mobile: 22,
                              tablet: 24,
                              desktop: 26,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing * 1.5),
                  Expanded(
                          child: Text(
                            l10n.mediaGallery,
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 2),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveImageHeight(
                        context,
                        mobile: 110.0,
                        tablet: 130.0,
                        desktop: 150.0,
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var i = 0; i < _galleryImages(property).take(3).length; i++) ...[
                            if (i > 0) SizedBox(width: spacing * 1.5),
                            _MediaThumbnail(
                              isVideo: false,
                              imagePath: _galleryImages(property).elementAt(i),
                              onTap: () => MediaOpener.openImage(
                                context,
                                source: _galleryImages(property).elementAt(i),
                                title: property['name']?.toString(),
                              ),
                              spacing: spacing,
                            ),
                          ],
                          if (property['videoUrl'] != null) ...[
                            SizedBox(width: spacing * 1.5),
                            _MediaThumbnail(
                              isVideo: true,
                              onTap: () => MediaOpener.openVideo(
                                context,
                                url: property['videoUrl']?.toString(),
                              ),
                              spacing: spacing,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: spacing * 3),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.chat_bubble_outline,
                          color: _hasTenant(property) ? AppColors.accentGold : context.estate.textSecondary,
                          onTap: () {
                            if (!_hasTenant(property)) {
                              UiFeedback.showInfo(context, l10n.noTenant);
                              return;
                            }
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                page: ContactTenantScreen(
                                  tenant: {
                                    "name": property["tenantName"],
                                    "property": property["name"],
                                  },
                                ),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: spacing * 2),
                        _ActionButton(
                          icon: Icons.picture_as_pdf,
                          color: AppColors.darkGrey,
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.loadingPdf),
                                backgroundColor: Colors.green,
                              ),
                            );
                            await _openContractPdf();
                          },
                      ),
                      ],
                    ),
                    SizedBox(height: spacing * 2.5),
                ],
                ),
              ),
            ],
          ),
          ),
        ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.value,
    required this.color,
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
    return Container(
      padding: padding,
          decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
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
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: context.estate.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
            ),
          ),
            textAlign: TextAlign.center,
        ),
        ],
      ),
    );
  }
}

class _RentalDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const _RentalDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: context.estate.textPrimary,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
          ),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: valueColor ?? AppColors.white,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
          ),
        ),
              SizedBox(width: spacing),
            ],
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: valueColor ?? AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
          ),
          ],
        ),
      ],
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final bool isVideo;
  final VoidCallback onTap;
  final double spacing;
  final String? imagePath;

  const _MediaThumbnail({
    required this.isVideo,
    required this.onTap,
    required this.spacing,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveHelper.isMobile(context) ? 110.0 : 130.0;
    final radius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: width,
          height: width * 0.75,
          color: context.estate.surface,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (imagePath != null && !isVideo)
                Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.navy],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.navy],
                    ),
                  ),
                ),
              if (isVideo)
                Icon(
                  Icons.play_circle_filled,
                  color: AppColors.white.withValues(alpha: 0.9),
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 36,
                    tablet: 40,
                    desktop: 44,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.isMobile(context) ? 56.0 : 64.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: context.estate.textPrimary,
          size: ResponsiveHelper.getResponsiveIconSize(
            context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
          ),
        ),
      ),
    );
  }
}

