import 'package:shared_preferences/shared_preferences.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

/// تفضيلات الإشعارات المحلية — تُطبَّق على قائمة الإشعارات من Laravel API.
class NotificationPreferences {
  final bool allNotifications;
  final bool rentReminders;
  final bool maintenanceAlerts;
  final bool contractExpiry;
  final bool paymentReminders;
  final bool projectUpdates;
  final bool marketingEmails;

  const NotificationPreferences({
    this.allNotifications = true,
    this.rentReminders = true,
    this.maintenanceAlerts = true,
    this.contractExpiry = true,
    this.paymentReminders = true,
    this.projectUpdates = true,
    this.marketingEmails = false,
  });

  NotificationPreferences copyWith({
    bool? allNotifications,
    bool? rentReminders,
    bool? maintenanceAlerts,
    bool? contractExpiry,
    bool? paymentReminders,
    bool? projectUpdates,
    bool? marketingEmails,
  }) {
    return NotificationPreferences(
      allNotifications: allNotifications ?? this.allNotifications,
      rentReminders: rentReminders ?? this.rentReminders,
      maintenanceAlerts: maintenanceAlerts ?? this.maintenanceAlerts,
      contractExpiry: contractExpiry ?? this.contractExpiry,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      marketingEmails: marketingEmails ?? this.marketingEmails,
    );
  }
}

class NotificationPreferencesService {
  static const _prefix = 'notif_pref_';

  Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      allNotifications: prefs.getBool('${_prefix}all') ?? true,
      rentReminders: prefs.getBool('${_prefix}rent') ?? true,
      maintenanceAlerts: prefs.getBool('${_prefix}maintenance') ?? true,
      contractExpiry: prefs.getBool('${_prefix}contract') ?? true,
      paymentReminders: prefs.getBool('${_prefix}payment') ?? true,
      projectUpdates: prefs.getBool('${_prefix}project') ?? true,
      marketingEmails: prefs.getBool('${_prefix}marketing') ?? false,
    );
  }

  Future<void> save(NotificationPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('${_prefix}all', prefs.allNotifications);
    await sp.setBool('${_prefix}rent', prefs.rentReminders);
    await sp.setBool('${_prefix}maintenance', prefs.maintenanceAlerts);
    await sp.setBool('${_prefix}contract', prefs.contractExpiry);
    await sp.setBool('${_prefix}payment', prefs.paymentReminders);
    await sp.setBool('${_prefix}project', prefs.projectUpdates);
    await sp.setBool('${_prefix}marketing', prefs.marketingEmails);
  }

  /// يُطبَّق على قائمة الإشعارات من Laravel API (تصفية محلية).
  bool shouldShow(NotificationPreferences prefs, String type) {
    if (!prefs.allNotifications) return false;

    final t = type.toLowerCase();
    if (t.contains('marketing')) return prefs.marketingEmails;
    if (t.contains('maintenance')) return prefs.maintenanceAlerts;
    if (t.contains('contract')) return prefs.contractExpiry;
    if (t.contains('project') || t.contains('construction')) {
      return prefs.projectUpdates;
    }
    if (t.contains('rent')) return prefs.rentReminders;
    if (t.contains('payment')) return prefs.paymentReminders;

    return true;
  }

  List<NotificationItemData> filterVisible(
    NotificationPreferences prefs,
    List<NotificationItemData> items,
  ) {
    return items.where((item) => shouldShow(prefs, item.type)).toList();
  }
}
