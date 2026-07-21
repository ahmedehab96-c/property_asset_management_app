import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/repository_providers.dart';
import 'package:property_asset_management_app/core/providers/service_providers.dart';
import 'package:property_asset_management_app/services/notification_preferences_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class NotificationsState {
  final ViewStatus status;
  final List<NotificationItemData> items;
  final List<NotificationItemData> allItems;
  final NotificationPreferences preferences;
  final bool fromDemo;
  final bool hasMore;
  final bool loadingMore;
  final String? errorMessage;

  const NotificationsState({
    this.status = ViewStatus.idle,
    this.items = const [],
    this.allItems = const [],
    this.preferences = const NotificationPreferences(),
    this.fromDemo = true,
    this.hasMore = false,
    this.loadingMore = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    ViewStatus? status,
    List<NotificationItemData>? items,
    List<NotificationItemData>? allItems,
    NotificationPreferences? preferences,
    bool? fromDemo,
    bool? hasMore,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      allItems: allItems ?? this.allItems,
      preferences: preferences ?? this.preferences,
      fromDemo: fromDemo ?? this.fromDemo,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  int _page = 1;

  @override
  NotificationsState build() => const NotificationsState();

  NotificationPreferencesService get _prefs =>
      ref.read(notificationPreferencesServiceProvider);

  Future<void> load({required bool isArabic, bool reset = true}) async {
    if (reset) {
      _page = 1;
      state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    }
    try {
      final preferences = await _prefs.load();
      final result = await ref.read(notificationRepositoryProvider).load(
            isArabic: isArabic,
            page: _page,
          );
      final merged =
          reset ? result.items : [...state.allItems, ...result.items];
      state = NotificationsState(
        status: ViewStatus.success,
        allItems: merged,
        items: _prefs.filterVisible(preferences, merged),
        preferences: preferences,
        fromDemo: result.fromDemo,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore({required bool isArabic}) async {
    if (state.loadingMore || !state.hasMore || state.fromDemo) return;
    state = state.copyWith(loadingMore: true);
    _page++;
    final result = await ref.read(notificationRepositoryProvider).load(
          isArabic: isArabic,
          page: _page,
        );
    final merged = [...state.allItems, ...result.items];
    state = state.copyWith(
      loadingMore: false,
      allItems: merged,
      items: _prefs.filterVisible(state.preferences, merged),
      hasMore: result.hasMore,
    );
  }

  Future<void> refreshPreferences() async {
    final preferences = await _prefs.load();
    state = state.copyWith(
      preferences: preferences,
      items: _prefs.filterVisible(preferences, state.allItems),
    );
  }

  Future<void> markRead(int index) async {
    final item = state.items[index];
    if (!item.unread) return;
    await ref.read(notificationRepositoryProvider).markRead(item.id);
    final items = [...state.items];
    items[index] = item.copyWith(unread: false);
    final allItems = [...state.allItems];
    final allIndex = allItems.indexWhere(
      (n) => n.id == item.id && n.title == item.title,
    );
    if (allIndex >= 0) {
      allItems[allIndex] = allItems[allIndex].copyWith(unread: false);
    }
    state = state.copyWith(items: items, allItems: allItems);
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    state = state.copyWith(
      allItems: state.allItems.map((e) => e.copyWith(unread: false)).toList(),
      items: state.items.map((e) => e.copyWith(unread: false)).toList(),
    );
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
