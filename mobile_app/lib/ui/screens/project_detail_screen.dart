import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/project_detail_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/media_opener.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProject());
  }

  void _loadProject() {
    final l10n = AppLocalizations.of(context);
    ref.read(projectDetailProvider.notifier).load(
          seed: widget.project,
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ps = ref.watch(projectDetailProvider);
    final loading = ps.status == ViewStatus.loading || ps.project == null;
    final data = ps.project;
    final fromDemo = ps.fromDemo;
    if (loading || data == null) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.projectsUnderConstruction,
            style: TextStyle(color: context.estate.textPrimary),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accentGold),
              const SizedBox(height: 16),
              Text(
                l10n.loadingProjects,
                style: TextStyle(color: context.estate.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final progress = data['progress'] as double? ?? 0.75;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: context.estate.textPrimary,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.projectsUnderConstruction,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fromDemo)
            const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
              Stack(
                children: [
                  ClipRRect(
                    child: Image.asset(
                      data['imagePath'] as String,
                      height: ResponsiveHelper.getResponsiveImageHeight(
                        context,
                        mobile: 300.0,
                        tablet: 360.0,
                        desktop: 420.0,
                      ),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: ResponsiveHelper.getResponsiveImageHeight(
                            context,
                            mobile: 300.0,
                            tablet: 360.0,
                            desktop: 420.0,
                          ),
                          width: double.infinity,
                          decoration: const BoxDecoration(
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
                            Icons.construction,
                            size:
                                ResponsiveHelper.isMobile(context) ? 100 : 120,
                            color: AppColors.accentGold,
                          ),
                        );
                      },
                    ),
                  ),
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
                          Text(
                            data['name'] as String,
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
                            data['location'] as String,
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
                        ],
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
                    SizedBox(height: spacing * 2.5),
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
                          Row(
                            children: [
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGold,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 32,
                                    tablet: 36,
                                    desktop: 40,
                                  ),
                                ),
                              ),
                              SizedBox(width: spacing * 1.5),
                              Expanded(
                                child: Text(
                                  l10n.completionRate,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.estate.textPrimary,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveBorderRadius(
                                context,
                                mobile: 8,
                                tablet: 10,
                                desktop: 12,
                              ),
                            ),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.darkGrey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accentGold,
                              ),
                              minHeight:
                                  ResponsiveHelper.isMobile(context) ? 10 : 12,
                            ),
                          ),
                          SizedBox(height: spacing * 1.5),
                          Text(
                            data['lastUpdate'] as String,
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
                    SizedBox(height: spacing * 2.5),
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
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: AppColors.accentGold,
                                size: ResponsiveHelper.getResponsiveIconSize(
                                  context,
                                  mobile: 22,
                                  tablet: 24,
                                  desktop: 26,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: ResponsiveHelper.isMobile(context)
                                      ? 6
                                      : 8,
                                  height: ResponsiveHelper.isMobile(context)
                                      ? 6
                                      : 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
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
                          _MediaThumbnail(
                            isVideo: false,
                            imagePath: data['imagePath'] as String?,
                            onTap: () => MediaOpener.openImage(
                              context,
                              source: data['imagePath']?.toString() ??
                                  'assetss/images/home1.jpg',
                              title: data['name']?.toString(),
                            ),
                          ),
                          SizedBox(width: spacing * 1.5),
                          _MediaThumbnail(
                            isVideo: true,
                            onTap: () => MediaOpener.openVideo(
                              context,
                              url: data['videoUrl']?.toString(),
                            ),
                          ),
                          SizedBox(width: spacing * 1.5),
                          _MediaThumbnail(
                            isVideo: false,
                            imagePath: 'assetss/images/home2.jpg',
                            onTap: () => MediaOpener.openImage(
                              context,
                              source: 'assetss/images/home2.jpg',
                              title: data['name']?.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing * 2.5),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final image = data['imagePath']?.toString() ??
                              data['planUrl']?.toString() ??
                              '';
                          if (image.isEmpty) {
                            UiFeedback.showInfo(context, l10n.webOnlyAction);
                            return;
                          }
                          MediaOpener.openImage(
                            context,
                            source: image,
                            title: l10n.viewEngineeringPlans,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
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
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_view,
                              size: ResponsiveHelper.getResponsiveIconSize(
                                context,
                                mobile: 22,
                                tablet: 24,
                                desktop: 26,
                              ),
                            ),
                            SizedBox(width: spacing * 1.5),
                            Text(
                              l10n.viewEngineeringPlans,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
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
                    SizedBox(height: spacing * 1.5),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final modelUrl = data['modelUrl']?.toString() ??
                              data['videoUrl']?.toString();
                          if (modelUrl != null && modelUrl.startsWith('http')) {
                            MediaOpener.openVideo(context, url: modelUrl);
                          } else {
                            UiFeedback.showInfo(context, l10n.webOnlyAction);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: BorderSide(
                            color: AppColors.accentGold,
                            width: ResponsiveHelper.isMobile(context) ? 2 : 2.5,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
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
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.view_in_ar,
                              size: ResponsiveHelper.getResponsiveIconSize(
                                context,
                                mobile: 22,
                                tablet: 24,
                                desktop: 26,
                              ),
                            ),
                            SizedBox(width: spacing * 1.5),
                            Text(
                              l10n.view3dModel,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.estate.textPrimary,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
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
                    SizedBox(height: spacing * 2.5),
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
                        children: [
                          _ProjectDetailRow(
                            icon: Icons.calendar_today,
                            label: l10n.expectedCompletionDate,
                            value: data['expectedDate'] as String,
                          ),
                          SizedBox(height: spacing * 2),
                          Divider(
                            color: AppColors.darkGrey,
                            thickness: 1,
                          ),
                          SizedBox(height: spacing * 2),
                          _ProjectDetailRow(
                            icon: Icons.person,
                            label: l10n.projectManager,
                            value: data['manager'] as String,
                          ),
                          SizedBox(height: spacing * 2),
                          Divider(
                            color: AppColors.darkGrey,
                            thickness: 1,
                          ),
                          SizedBox(height: spacing * 2),
                          _ProjectDetailRow(
                            icon: Icons.update,
                            label: l10n.lastSiteUpdate,
                            value: data['lastSiteUpdate'] as String,
                          ),
                        ],
                      ),
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

class _MediaThumbnail extends StatelessWidget {
  final bool isVideo;
  final VoidCallback onTap;
  final String? imagePath;

  const _MediaThumbnail({
    required this.isVideo,
    required this.onTap,
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
        child: SizedBox(
          width: width,
          height: width * 0.75,
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
                  size: 40,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProjectDetailRow({
    required this.icon,
    required this.label,
    required this.value,
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
      children: [
        Icon(
          icon,
          color: AppColors.accentGold,
          size: ResponsiveHelper.getResponsiveIconSize(
            context,
            mobile: 22,
            tablet: 24,
            desktop: 26,
          ),
        ),
        SizedBox(width: spacing * 2),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
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
        ),
      ],
    );
  }
}
