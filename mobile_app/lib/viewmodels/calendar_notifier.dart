import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';

class CalendarState {
  final ViewStatus status;
  final List<Map<String, dynamic>> events;
  final bool fromDemo;
  final String? errorMessage;

  const CalendarState({
    this.status = ViewStatus.idle,
    this.events = const [],
    this.fromDemo = true,
    this.errorMessage,
  });

  CalendarState copyWith({
    ViewStatus? status,
    List<Map<String, dynamic>>? events,
    bool? fromDemo,
    String? errorMessage,
  }) {
    return CalendarState(
      status: status ?? this.status,
      events: events ?? this.events,
      fromDemo: fromDemo ?? this.fromDemo,
      errorMessage: errorMessage,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() => const CalendarState();

  Future<void> load({
    required AppLocalizations l10n,
    required bool isArabic,
    required int month,
    required int year,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final result = await ref.read(calendarRepositoryProvider).loadEvents(
            l10n: l10n,
            isArabic: isArabic,
            month: month,
            year: year,
          );
      state = CalendarState(
        status: ViewStatus.success,
        events: result.events,
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

final calendarProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);
