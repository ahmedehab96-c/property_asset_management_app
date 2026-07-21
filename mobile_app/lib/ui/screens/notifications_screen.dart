import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/animations/staggered_animation.dart';
import 'package:property_asset_management_app/ui/screens/notification_settings_screen.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/viewmodels/notifications_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load({bool reset = true}) {
    ref.read(notificationsProvider.notifier).load(
          isArabic: ref.read(isArabicProvider),
          reset: reset,
        );
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      SlidePageRoute(page: const NotificationSettingsScreen()),
    );
    if (!mounted) return;
    await ref.read(notificationsProvider.notifier).refreshPreferences();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _headerCount(bool fromDemo) {
    var count = 0;
    if (fromDemo) count++;
    if (!fromDemo) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final ns = ref.watch(notificationsProvider);
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);
    final loading = ns.status == ViewStatus.loading && ns.items.isEmpty;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notifications,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: context.estate.textPrimary, size: iconSize),
            tooltip: l10n.notificationSettings,
            onPressed: _openSettings,
          ),
          IconButton(
            icon: Icon(Icons.done_all,
                color: context.estate.textPrimary, size: iconSize),
            tooltip: l10n.markAllRead,
            onPressed: ns.items.isEmpty
                ? null
                : () => ref.read(notificationsProvider.notifier).markAllRead(),
          ),
        ],
      ),
      body: SafeArea(
        child: loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.accentGold),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadingNotifications,
                      style: TextStyle(color: context.estate.textSecondary),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  color: AppColors.accentGold,
                  onRefresh: () async => _load(reset: true),
                  child: ns.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: padding,
                          children: [
                            if (ns.fromDemo) const DemoDataBanner(),
                            if (!ns.fromDemo)
                              _ApiInfoBanner(
                                l10n: l10n,
                                borderRadius: borderRadius,
                              ),
                            SizedBox(height: spacing * 3),
                            _EmptyNotifications(
                              message: ns.allItems.isEmpty
                                  ? l10n.noNotifications
                                  : l10n.notificationsFilteredEmpty,
                              onOpenSettings: _openSettings,
                              l10n: l10n,
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: padding,
                          itemCount: ns.items.length +
                              _headerCount(ns.fromDemo) +
                              (ns.hasMore && !ns.fromDemo ? 1 : 0),
                          separatorBuilder: (_, index) =>
                              SizedBox(height: spacing * 1.5),
                          itemBuilder: (context, index) {
                            if (ns.fromDemo && index == 0) {
                              return const DemoDataBanner();
                            }
                            if (!ns.fromDemo && index == (ns.fromDemo ? 1 : 0)) {
                              return _ApiInfoBanner(
                                l10n: l10n,
                                borderRadius: borderRadius,
                              );
                            }

                            final adjusted = index - _headerCount(ns.fromDemo);
                            if (ns.hasMore &&
                                !ns.fromDemo &&
                                adjusted == ns.items.length) {
                              return Center(
                                child: ns.loadingMore
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          color: AppColors.accentGold,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () => ref
                                            .read(notificationsProvider.notifier)
                                            .loadMore(isArabic: isArabic),
                                        child: Text(l10n.loadMore),
                                      ),
                              );
                            }

                            final item = ns.items[adjusted];
                            return StaggeredAnimation(
                              index: adjusted,
                              child: _NotificationTile(
                                data: item,
                                onTap: () => ref
                                    .read(notificationsProvider.notifier)
                                    .markRead(adjusted),
                              ),
                            );
                          },
                        ),
                ),
              ),
      ),
    );
  }
}

class _ApiInfoBanner extends StatelessWidget {
  const _ApiInfoBanner({required this.l10n, required this.borderRadius});

  final AppLocalizations l10n;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.accentGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.pushNotificationsNote,
              style: TextStyle(color: context.estate.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({
    required this.message,
    required this.onOpenSettings,
    required this.l10n,
  });

  final String message;
  final VoidCallback onOpenSettings;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: context.estate.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.estate.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined, color: AppColors.accentGold),
            label: Text(
              l10n.notificationSettings,
              style: const TextStyle(color: AppColors.accentGold),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.data, this.onTap});

  final NotificationItemData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    final theme = Theme.of(context);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.glassCardColors,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: data.iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        if (data.unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
