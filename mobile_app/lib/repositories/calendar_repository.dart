import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class CalendarLoadResult {
  final List<Map<String, dynamic>> events;
  final bool fromDemo;

  const CalendarLoadResult({
    required this.events,
    required this.fromDemo,
  });
}

/// أحداث التقويم: API أولاً، ثم بيانات تجريبية.
class CalendarRepository {
  CalendarRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  List<Map<String, dynamic>> _demoEvents(
    AppLocalizations l10n,
    bool isArabic,
  ) =>
      LocalizedDemoData(l10n: l10n, isArabic: isArabic).calendarEvents();

  Future<CalendarLoadResult> loadEvents({
    required AppLocalizations l10n,
    required bool isArabic,
    required int month,
    required int year,
  }) async {
    if (DemoMode.isActive) {
      return CalendarLoadResult(
        events: _demoEvents(l10n, isArabic),
        fromDemo: true,
      );
    }

    try {
      final raw = await _api.getCalendarEvents(
        query: {'month': month, 'year': year},
      );
      final mapped =
          raw.map((e) => OwnerApiMappers.toCalendarEvent(e, l10n)).toList();
      return CalendarLoadResult(events: mapped, fromDemo: false);
    } catch (_) {
      return const CalendarLoadResult(events: [], fromDemo: false);
    }
  }
}
