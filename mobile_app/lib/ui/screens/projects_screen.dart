import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/projects_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/ui/screens/project_detail_screen.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProjects());
  }

  Future<void> _loadProjects() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(projectsProvider.notifier).load(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ps = ref.watch(projectsProvider);
    final loading = ps.status == ViewStatus.loading && ps.projects.isEmpty;
    final projects = ps.projects;
    final fromDemo = ps.fromDemo;

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
                        size: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          mobile: 20.0,
                          tablet: 24.0,
                          desktop: 28.0,
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
          l10n.projectsUnderConstruction,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        centerTitle: true,
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
                        const CircularProgressIndicator(
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.loadingProjects,
                          style: TextStyle(color: context.estate.textSecondary),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.accentGold,
                    onRefresh: _loadProjects,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final pagePadding = EdgeInsets.all(
                          ResponsiveHelper.adaptivePadding(context),
                        );
                        final useGrid = constraints.maxWidth >=
                            ResponsiveHelper.mobileBreakpoint;

                        if (useGrid) {
                          return CustomScrollView(
                            slivers: [
                              if (fromDemo)
                                SliverPadding(
                                  padding: pagePadding,
                                  sliver: const SliverToBoxAdapter(
                                    child: DemoDataBanner(
                                      margin: EdgeInsets.only(bottom: 16),
                                    ),
                                  ),
                                ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  pagePadding.left,
                                  fromDemo ? 0 : pagePadding.top,
                                  pagePadding.right,
                                  pagePadding.bottom,
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
                                    childAspectRatio: 0.85,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final project = projects[index];
                                      return _ProjectCard(
                                        project: project,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            SlidePageRoute(
                                              page: ProjectDetailScreen(
                                                project: project,
                                              ),
                                              direction: AxisDirection.left,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: projects.length,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView(
                          padding: pagePadding,
                          children: [
                            if (fromDemo)
                              const DemoDataBanner(
                                margin: EdgeInsets.only(bottom: 16),
                              ),
                            ...projects.map(
                              (project) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _ProjectCard(
                                  project: project,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlidePageRoute(
                                        page: ProjectDetailScreen(
                                          project: project,
                                        ),
                                        direction: AxisDirection.left,
                                      ),
                                    );
                                  },
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

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = project['progress'] as double? ?? 0.0;
    final totalCost = project['totalCostDisplay'] as String? ??
        '${project['totalCost'] ?? '0'} ${l10n.aed}';
    final imageHeight = ResponsiveHelper.getResponsiveImageHeight(
      context,
      mobile: 180,
      tablet: 220,
      desktop: 260,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project['imagePath'] != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    project['imagePath'] ?? 'assetss/images/home3.jpg',
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
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
                        child: const Icon(
                          Icons.construction,
                          color: AppColors.accentGold,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue.withValues(alpha: 0.7),
                      AppColors.navy.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: project['imagePath'] != null
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        )
                      : BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.construction,
                            color: AppColors.accentGold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project['name'] ?? l10n.projectName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      project['location'] ?? l10n.projectLocation,
                                      style: theme.textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.completionRate,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.darkGrey,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accentGold,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.totalCost,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            Text(
                              totalCost,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.deliveryDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            Text(
                              project['expectedDate'] ?? '-',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
