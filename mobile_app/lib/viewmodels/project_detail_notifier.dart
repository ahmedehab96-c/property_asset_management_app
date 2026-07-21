import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class ProjectDetailState {
  final ViewStatus status;
  final Map<String, dynamic>? project;
  final bool fromDemo;
  final String? errorMessage;

  const ProjectDetailState({
    this.status = ViewStatus.idle,
    this.project,
    this.fromDemo = true,
    this.errorMessage,
  });

  ProjectDetailState copyWith({
    ViewStatus? status,
    Map<String, dynamic>? project,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return ProjectDetailState(
      status: status ?? this.status,
      project: project ?? this.project,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class ProjectDetailNotifier extends Notifier<ProjectDetailState> {
  @override
  ProjectDetailState build() => const ProjectDetailState();

  Future<void> load({
    required Map<String, dynamic> seed,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(projectRepositoryProvider).loadProjectDetail(
            project: seed,
            l10n: l10n,
            isArabic: isArabic,
          );
      state = ProjectDetailState(
        status: ViewStatus.success,
        project: result.project,
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

final projectDetailProvider = NotifierProvider<ProjectDetailNotifier, ProjectDetailState>(
  ProjectDetailNotifier.new,
);
