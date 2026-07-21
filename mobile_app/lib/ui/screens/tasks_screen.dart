import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/repositories/tasks_repository.dart';
import 'package:property_asset_management_app/theme/app_gradients.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = TasksRepository();
  bool _loading = true;
  bool _fromDemo = false;
  List<Map<String, dynamic>> _tasks = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    final result = await _repo.load(l10n: l10n);
    if (!mounted) return;
    setState(() {
      _tasks = result.tasks;
      _fromDemo = result.fromDemo;
      _loading = false;
    });
  }

  Future<void> _complete(Map<String, dynamic> task) async {
    final id = (task['id'] as num?)?.toInt();
    if (id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final doneLabel = AppLocalizations.of(context).completed;
    final ok = await _repo.markDone(id);
    if (!mounted) return;
    if (ok) {
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(doneLabel)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.estate;

    return AppScaffold(
      appBar: glassAppBar(context: context, title: l10n.tasks),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_fromDemo) const DemoDataBanner(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(l10n.noTasks, style: TextStyle(color: palette.textSecondary)),
                ),
              )
            else
              ..._tasks.map((task) {
                final status = (task['status'] ?? '').toString();
                final done = status.contains('complete') || status.contains('done');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DecoratedBox(
                    decoration: AppGradients.glassCardFor(context),
                    child: ListTile(
                      title: Text((task['title'] ?? '-').toString()),
                      subtitle: Text(
                        [
                          if (task['priority'] != null) task['priority'].toString(),
                          if (task['due_date'] != null) task['due_date'].toString(),
                          status,
                        ].where((e) => e.isNotEmpty).join(' · '),
                      ),
                      trailing: done
                          ? Icon(Icons.check_circle, color: AppColors.teal)
                          : IconButton(
                              icon: const Icon(Icons.check),
                              color: AppColors.accentGold,
                              onPressed: () => _complete(task),
                            ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      ),
    );
  }
}
