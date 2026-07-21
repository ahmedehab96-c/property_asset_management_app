import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class ProjectsLoadResult {
  final List<Map<String, dynamic>> projects;
  final bool fromDemo;

  const ProjectsLoadResult({
    required this.projects,
    required this.fromDemo,
  });
}

/// مشاريع قيد الإنشاء: API أولاً، ثم بيانات تجريبية.
class ProjectRepository {
  ProjectRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  List<Map<String, dynamic>> _demoProjects(
    AppLocalizations l10n,
    bool isArabic,
  ) =>
      LocalizedDemoData(l10n: l10n, isArabic: isArabic).projects();

  Future<List<Map<String, dynamic>>> _fetchFromApi() async {
    try {
      final projects = await _api.getProjects();
      if (projects.isNotEmpty) return projects;
    } catch (_) {}

    try {
      final constructionProps = await _api.getProperties(
        query: {'status': 'under_construction'},
      );
      if (constructionProps.isNotEmpty) return constructionProps;
    } catch (_) {}

    final properties = await _api.getMyProperties();
    final filtered = properties
        .where(OwnerApiMappers.isUnderConstructionProject)
        .toList();
    if (filtered.isNotEmpty) return filtered;

    try {
      final reports = await _api.getReports(query: {'type': 'project'});
      final projectReports =
          reports.where(OwnerApiMappers.isProjectReport).toList();
      if (projectReports.isNotEmpty) return projectReports;
    } catch (_) {}

    return [];
  }

  Future<ProjectsLoadResult> loadProjects({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    if (DemoMode.isActive) {
      return ProjectsLoadResult(
        projects: _demoProjects(l10n, isArabic),
        fromDemo: true,
      );
    }

    try {
      final raw = await _fetchFromApi();
      final mapped =
          raw.map((p) => OwnerApiMappers.toProjectCard(p, l10n)).toList();
      return ProjectsLoadResult(projects: mapped, fromDemo: false);
    } catch (_) {
      return const ProjectsLoadResult(projects: [], fromDemo: false);
    }
  }

  Future<ProjectDetailLoadResult> loadProjectDetail({
    required Map<String, dynamic> project,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    if (DemoMode.isActive || project['id'] == null) {
      return ProjectDetailLoadResult(
        project: demo.enrichProjectDetail(
          project,
          fillMissingWithDemo: true,
        ),
        fromDemo: true,
      );
    }

    try {
      final id = (project['id'] as num).toInt();
      Map<String, dynamic>? raw;
      try {
        raw = await _api.getProjectDetail(id);
      } catch (_) {
        raw = await _api.getPropertyDetail(id);
      }
      if (raw != null) {
        final mapped = OwnerApiMappers.toProjectCard(raw, l10n);
        return ProjectDetailLoadResult(
          project: demo.enrichProjectDetail(
            mapped,
            fillMissingWithDemo: false,
          ),
          fromDemo: false,
        );
      }
    } catch (_) {}

    return ProjectDetailLoadResult(
      project: demo.enrichProjectDetail(
        project,
        fillMissingWithDemo: false,
      ),
      fromDemo: false,
    );
  }
}

class ProjectDetailLoadResult {
  final Map<String, dynamic> project;
  final bool fromDemo;

  const ProjectDetailLoadResult({
    required this.project,
    required this.fromDemo,
  });
}
