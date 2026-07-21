import 'package:flutter/material.dart';
import 'package:property_asset_management_app/core/repositories/repository_mixin.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

class NotificationsLoadResult {
  final List<NotificationItemData> items;
  final bool fromDemo;
  final bool hasMore;

  const NotificationsLoadResult({
    required this.items,
    required this.fromDemo,
    this.hasMore = false,
  });
}

class NotificationRepository with RepositoryMixin {
  NotificationRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  static const defaultPerPage = 20;

  NotificationsLoadResult _demo(bool isArabic) {
    if (isArabic) {
      return NotificationsLoadResult(
        fromDemo: true,
        items: const [
          NotificationItemData(
            type: 'payment',
            title: 'تم إضافة دفعة إيجار جديدة',
            subtitle: 'تم استلام دفعة إيجار بقيمة 15,000 د.إ لشقة رقم 12',
            time: 'منذ ساعتين',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.green,
          ),
          NotificationItemData(
            type: 'contract',
            title: 'عقد سينتهي خلال 10 أيام',
            subtitle: 'عقد إيجار فيلا - شارع الملك فهد سينتهي قريباً',
            time: 'منذ 5 ساعات',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange,
          ),
          NotificationItemData(
            type: 'project',
            title: 'تحديث على مشروع تحت الإنشاء',
            subtitle: 'تم تحديث نسبة الإنجاز لمشروع فيلا سكنية إلى 65%',
            time: 'منذ يوم',
            icon: Icons.construction,
            iconColor: AppColors.accentGold,
          ),
          NotificationItemData(
            type: 'legal',
            title: 'طلب استشارة قانونية جديد',
            subtitle: 'تم استلام طلب استشارة قانونية جديد',
            time: 'منذ يومين',
            icon: Icons.gavel,
            iconColor: Colors.blue,
          ),
        ],
      );
    }

    return const NotificationsLoadResult(
      fromDemo: true,
      items: [
        NotificationItemData(
          type: 'payment',
          title: 'New rent payment received',
          subtitle: 'Rent payment of AED 15,000 received for unit #12',
          time: '2 hours ago',
          icon: Icons.account_balance_wallet,
          iconColor: Colors.green,
        ),
        NotificationItemData(
          type: 'contract',
          title: 'Contract expiring in 10 days',
          subtitle: 'Villa lease on King Fahd St. is ending soon',
          time: '5 hours ago',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        ),
        NotificationItemData(
          type: 'project',
          title: 'Construction project update',
          subtitle: 'Villa project progress updated to 65%',
          time: '1 day ago',
          icon: Icons.construction,
          iconColor: AppColors.accentGold,
        ),
        NotificationItemData(
          type: 'legal',
          title: 'New legal consultation request',
          subtitle: 'A new legal consultation request was received',
          time: '2 days ago',
          icon: Icons.gavel,
          iconColor: Colors.blue,
        ),
      ],
    );
  }

  Future<NotificationsLoadResult> load({
    required bool isArabic,
    int page = 1,
    int perPage = defaultPerPage,
  }) {
    return withApiFallback(
      demo: () => _demo(isArabic),
      onError: () => const NotificationsLoadResult(
        items: [],
        fromDemo: false,
      ),
      api: () async {
        final raw = await _api.getNotifications(
          query: {'page': page, 'per_page': perPage},
        );
        return NotificationsLoadResult(
          items: raw.map(OwnerApiMappers.toNotificationItem).toList(),
          fromDemo: false,
          hasMore: raw.length >= perPage,
        );
      },
    );
  }

  Future<void> markAllRead() async {
    if (isDemoActive) return;
    try {
      await _api.markAllNotificationsRead();
    } catch (_) {}
  }

  Future<void> markRead(int? id) async {
    if (isDemoActive || id == null) return;
    try {
      await _api.markNotificationRead(id);
    } catch (_) {}
  }
}
