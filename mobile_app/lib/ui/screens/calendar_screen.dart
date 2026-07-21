import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/calendar_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/screens/contracts_screen.dart';
import 'package:property_asset_management_app/ui/screens/maintenance_screen.dart';
import 'package:property_asset_management_app/ui/screens/wallet_screen.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

enum _CalendarViewMode { month, week, day }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  _CalendarViewMode _viewMode = _CalendarViewMode.month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  void _loadEvents() {
    final l10n = AppLocalizations.of(context);
    ref.read(calendarProvider.notifier).load(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
          month: _focusedDate.month,
          year: _focusedDate.year,
        );
  }

  List<Map<String, dynamic>> _eventsForDate(
    List<Map<String, dynamic>> events,
    DateTime date,
  ) {
    return events.where((event) {
      final eventDate = event['date'] as DateTime;
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).toList();
  }

  void _navigatePeriod(int direction) {
    setState(() {
      if (_viewMode == _CalendarViewMode.month) {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + direction);
      } else if (_viewMode == _CalendarViewMode.week) {
        _focusedDate = _focusedDate.add(Duration(days: direction * 7));
      } else {
        _selectedDate = _selectedDate.add(Duration(days: direction));
        _focusedDate = _selectedDate;
      }
    });
    _loadEvents();
  }

  void _goToday() {
    setState(() {
      _focusedDate = DateTime.now();
      _selectedDate = DateTime.now();
    });
    _loadEvents();
  }

  List<DateTime> _weekDays(DateTime anchor) {
    final start = anchor.subtract(Duration(days: anchor.weekday % 7));
    return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
  }

  List<DateTime?> _monthGridDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final startPad = first.weekday % 7;
    final days = <DateTime?>[];
    for (var i = 0; i < startPad; i++) {
      days.add(null);
    }
    for (var d = 1; d <= lastDay; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    return days;
  }

  String _monthName(AppLocalizations l10n, int month) {
    const keys = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december',
    ];
    return l10n.translate(keys[month - 1]);
  }

  String _headerTitle(AppLocalizations l10n, bool isArabic) {
    if (_viewMode == _CalendarViewMode.month) {
      return '${_monthName(l10n, _focusedDate.month)} ${_focusedDate.year}';
    }
    if (_viewMode == _CalendarViewMode.week) {
      final week = _weekDays(_focusedDate);
      return '${week.first.day}/${week.first.month} – ${week.last.day}/${week.last.month}/${week.last.year}';
    }
    return '${_selectedDate.day} ${_monthName(l10n, _selectedDate.month)} ${_selectedDate.year}';
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.estate.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.estate.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.eventDetails,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.estate.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(event['title'] as String, style: TextStyle(color: context.estate.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('${l10n.timeLabel}: ${event['time'] ?? '-'}', style: TextStyle(color: context.estate.textSecondary)),
            Text(event['property'] as String? ?? '-', style: TextStyle(color: context.estate.textSecondary)),
            if (event['amount'] != null)
              Text(event['amount'] as String, style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _goToRelated(event['type'] as String? ?? '');
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.accentGold),
              child: Text(l10n.goToRelated),
            ),
          ],
        ),
      ),
    );
  }

  void _goToRelated(String type) {
    Widget page;
    switch (type) {
      case 'payment':
        page = const WalletScreen();
        break;
      case 'contract':
        page = const ContractsScreen();
        break;
      default:
        page = const MaintenanceScreen();
    }
    Navigator.push(context, SlidePageRoute(page: page, direction: AxisDirection.left));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final cs = ref.watch(calendarProvider);
    final events = cs.events;
    final loading = cs.status == ViewStatus.loading && events.isEmpty;
    final fromDemo = cs.fromDemo;
    final theme = Theme.of(context);
    final dayEvents = _eventsForDate(events, _selectedDate);
    final weekDaysLabels = MaterialLocalizations.of(context).narrowWeekdays;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.calendar, style: TextStyle(color: context.estate.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _ViewChip(
                    label: l10n.calendarMonth,
                    selected: _viewMode == _CalendarViewMode.month,
                    onTap: () => setState(() => _viewMode = _CalendarViewMode.month),
                  ),
                  const SizedBox(width: 8),
                  _ViewChip(
                    label: l10n.calendarWeek,
                    selected: _viewMode == _CalendarViewMode.week,
                    onTap: () => setState(() => _viewMode = _CalendarViewMode.week),
                  ),
                  const SizedBox(width: 8),
                  _ViewChip(
                    label: l10n.calendarDay,
                    selected: _viewMode == _CalendarViewMode.day,
                    onTap: () => setState(() {
                      _viewMode = _CalendarViewMode.day;
                      _selectedDate = _focusedDate;
                    }),
                  ),
                ],
              ),
            ),
            if (fromDemo)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: DemoDataBanner(),
              ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
                  : Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.estate.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left, color: AppColors.accentGold),
                                    onPressed: () => _navigatePeriod(-1),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _headerTitle(l10n, isArabic),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: context.estate.textPrimary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right, color: AppColors.accentGold),
                                    onPressed: () => _navigatePeriod(1),
                                  ),
                                  TextButton(onPressed: _goToday, child: Text(l10n.calendarToday)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_viewMode == _CalendarViewMode.month) ...[
                                Row(
                                  children: weekDaysLabels
                                      .map((d) => Expanded(
                                            child: Center(
                                              child: Text(d, style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.w600)),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                  ),
                                  itemCount: _monthGridDays(_focusedDate).length,
                                  itemBuilder: (context, index) {
                                    final day = _monthGridDays(_focusedDate)[index];
                                    if (day == null) return const SizedBox.shrink();
                                    final dayEvents = _eventsForDate(events, day);
                                    final isToday = _isSameDay(day, DateTime.now());
                                    final isSelected = _isSameDay(day, _selectedDate);
                                    return InkWell(
                                      onTap: () => setState(() => _selectedDate = day),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.accentGold.withValues(alpha: 0.2)
                                              : context.estate.surface.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(8),
                                          border: isToday ? Border.all(color: AppColors.accentGold) : null,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          children: [
                                            Text('${day.day}', style: TextStyle(color: context.estate.textPrimary, fontWeight: FontWeight.w600)),
                                            if (dayEvents.isNotEmpty)
                                              Container(
                                                margin: const EdgeInsets.only(top: 4),
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(color: AppColors.accentGold, shape: BoxShape.circle),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ] else if (_viewMode == _CalendarViewMode.week) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _weekDays(_focusedDate).map((day) {
                                    final dayEvents = _eventsForDate(events, day);
                                    return Expanded(
                                      child: InkWell(
                                        onTap: () => setState(() => _selectedDate = day),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: _isSameDay(day, _selectedDate)
                                                ? AppColors.accentGold.withValues(alpha: 0.15)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text('${day.day}', style: TextStyle(color: context.estate.textPrimary, fontWeight: FontWeight.bold)),
                                              ...dayEvents.take(2).map((e) => Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Container(
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: _eventColor(e['type'] as String?),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ] else
                                Text(
                                  '${_selectedDate.day} ${_monthName(l10n, _selectedDate.month)} ${_selectedDate.year}',
                                  style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.accentGold, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.estate.surface,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.events} (${dayEvents.length})',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.estate.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: dayEvents.isEmpty
                                      ? Center(
                                          child: Text(
                                            l10n.noEventsToday,
                                            style: TextStyle(color: context.estate.textSecondary),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: dayEvents.length,
                                          itemBuilder: (context, index) {
                                            final event = dayEvents[index];
                                            return _EventCard(
                                              event: event,
                                              onTap: () => _showEventDetails(event),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _eventColor(String? type) {
    switch (type) {
      case 'payment':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'contract':
        return Colors.red;
      default:
        return AppColors.accentGold;
    }
  }
}

class _ViewChip extends StatelessWidget {
  const _ViewChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.accentGold : context.estate.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.black87 : context.estate.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onTap});

  final Map<String, dynamic> event;
  final VoidCallback onTap;

  Color _color() {
    switch (event['type']) {
      case 'payment':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'contract':
        return Colors.red;
      default:
        return AppColors.accentGold;
    }
  }

  IconData _icon() {
    switch (event['type']) {
      case 'payment':
        return Icons.payment;
      case 'maintenance':
        return Icons.build;
      case 'contract':
        return Icons.description;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(), color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.estate.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['property'] as String? ?? '',
                    style: TextStyle(color: context.estate.textSecondary, fontSize: 13),
                  ),
                  if (event['amount'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event['amount'] as String,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: context.estate.textSecondary),
          ],
        ),
      ),
    );
  }
}
