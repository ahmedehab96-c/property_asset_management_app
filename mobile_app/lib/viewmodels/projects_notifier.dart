import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class ProjectsState {
  final ViewStatus status;
  final List<Map<String, dynamic>> projects;
  final bool fromDemo;
  final String? errorMessage;

  const ProjectsState({
    this.status = ViewStatus.idle,
    this.projects = const [],
    this.fromDemo = true,
    this.errorMessage,
  });

  ProjectsState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? projects,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class ProjectsNotifier extends Notifier<ProjectsState> {
  @override
  ProjectsState build() => const ProjectsState();

  Future<void> load({
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(projectRepositoryProvider).loadProjects(
            l10n: l10n,
            isArabic: isArabic,
          );
      state = ProjectsState(
        status: ViewStatus.success,
        projects: result.projects,
        fromDemo: result.fromDemo,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final projectsProvider =
    NotifierProvider<ProjectsNotifier, ProjectsState>(ProjectsNotifier.new);
