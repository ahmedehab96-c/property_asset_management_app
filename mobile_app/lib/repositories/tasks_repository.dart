import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';

class TasksLoadResult {
  final List<Map<String, dynamic>> tasks;
  final bool fromDemo;

  const TasksLoadResult({required this.tasks, required this.fromDemo});
}

class TasksRepository {
  TasksRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  List<Map<String, dynamic>> _demo(AppLocalizations l10n) => [
        {
          'id': 1,
          'title': l10n.tasks,
          'status': 'pending',
          'priority': 'high',
          'due_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          'description': l10n.noTasks,
        },
      ];

  Future<TasksLoadResult> load({required AppLocalizations l10n}) async {
    if (DemoMode.isActive) {
      return TasksLoadResult(tasks: _demo(l10n), fromDemo: true);
    }

    try {
      final tasks = await _api.getTasks();
      return TasksLoadResult(tasks: tasks, fromDemo: false);
    } catch (_) {
      return const TasksLoadResult(tasks: [], fromDemo: false);
    }
  }

  Future<bool> markDone(int id) async {
    if (DemoMode.isActive) return true;
    try {
      await _api.updateTaskStatus(id, 'completed');
      return true;
    } catch (_) {
      return false;
    }
  }
}
