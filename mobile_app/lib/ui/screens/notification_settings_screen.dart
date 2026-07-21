import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/providers/service_providers.dart';
import 'package:property_asset_management_app/services/notification_preferences_service.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _loading = true;
  bool _allNotifications = true;
  bool _rentReminders = true;
  bool _maintenanceAlerts = true;
  bool _contractExpiry = true;
  bool _paymentReminders = true;
  bool _projectUpdates = true;
  bool _marketingEmails = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(notificationPreferencesServiceProvider).load();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _allNotifications = prefs.allNotifications;
      _rentReminders = prefs.rentReminders;
      _maintenanceAlerts = prefs.maintenanceAlerts;
      _contractExpiry = prefs.contractExpiry;
      _paymentReminders = prefs.paymentReminders;
      _projectUpdates = prefs.projectUpdates;
      _marketingEmails = prefs.marketingEmails;
    });
  }

  Future<void> _persist() async {
    final savedMessage = AppLocalizations.of(context).settingsSaved;
    await ref.read(notificationPreferencesServiceProvider).save(
      NotificationPreferences(
        allNotifications: _allNotifications,
        rentReminders: _rentReminders,
        maintenanceAlerts: _maintenanceAlerts,
        contractExpiry: _contractExpiry,
        paymentReminders: _paymentReminders,
        projectUpdates: _projectUpdates,
        marketingEmails: _marketingEmails,
      ),
    );
    if (!mounted) return;
    UiFeedback.showSuccess(context, savedMessage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
    final spacing = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

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
          l10n.notificationSettings,
          style: TextStyle(
            color: context.estate.textPrimary,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accentGold),
              )
            : ListView(
                padding: padding,
                children: [
                  SizedBox(height: spacing * 2),
                  Container(
                    padding: EdgeInsets.all(spacing * 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.accentGold),
                        SizedBox(width: spacing * 1.5),
                        Expanded(
                          child: Text(
                            l10n.pushNotificationsNote,
                            style: TextStyle(color: context.estate.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  _NotificationSwitch(
                    title: l10n.enableAllNotifications,
                    subtitle: l10n.enableAllNotificationsSubtitle,
                    value: _allNotifications,
                    onChanged: (value) {
                      setState(() {
                        _allNotifications = value;
                        if (!value) {
                          _rentReminders = false;
                          _maintenanceAlerts = false;
                          _contractExpiry = false;
                          _paymentReminders = false;
                          _projectUpdates = false;
                        } else {
                          _rentReminders = true;
                          _maintenanceAlerts = true;
                          _contractExpiry = true;
                          _paymentReminders = true;
                          _projectUpdates = true;
                        }
                      });
                      _persist();
                    },
                    borderRadius: borderRadius,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing * 2),
                  _NotificationSwitch(
                    title: l10n.rentReminders,
                    subtitle: l10n.rentRemindersSubtitle,
                    value: _rentReminders && _allNotifications,
                    onChanged: _allNotifications
                        ? (value) {
                            setState(() => _rentReminders = value);
                            _persist();
                          }
                        : null,
                    borderRadius: borderRadius,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing),
                  _NotificationSwitch(
                    title: l10n.maintenanceAlerts,
                    subtitle: l10n.maintenanceAlertsSubtitle,
                    value: _maintenanceAlerts && _allNotifications,
                    onChanged: _allNotifications
                        ? (value) {
                            setState(() => _maintenanceAlerts = value);
                            _persist();
                          }
                        : null,
                    borderRadius: borderRadius,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing),
                  _NotificationSwitch(
                    title: l10n.contractExpiry,
                    subtitle: l10n.contractExpirySubtitle,
                    value: _contractExpiry && _allNotifications,
                    onChanged: _allNotifications
                        ? (value) {
                            setState(() => _contractExpiry = value);
                            _persist();
                          }
                        : null,
                    borderRadius: borderRadius,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing),
                  _NotificationSwitch(
                    title: l10n.paymentReminders,
                    subtitle: l10n.paymentRemindersSubtitle,
                    value: _paymentReminders && _allNotifications,
                    onChanged: _allNotifications
                        ? (value) {
                            setState(() => _paymentReminders = value);
                            _persist();
                          }
                        : null,
                    borderRadius: borderRadius,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing),
                  _NotificationSwitch(
                    title: l10n.projectUpdates,
                    subtitle: l10n.projectUpdatesSubtitle,
                    value: _projectUpdates && _allNotifications,
                    onChanged: _allNotifications
                        ? (value) {
                            setState(() => _projectUpdates = value);
                            _persist();
                          }
                        : null,
                    borderRadius: borderRadius,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing),
                  _NotificationSwitch(
                    title: l10n.marketingEmails,
                    subtitle: l10n.marketingEmailsSubtitle,
                    value: _marketingEmails,
                    onChanged: (value) {
                      setState(() => _marketingEmails = value);
                      _persist();
                    },
                    borderRadius: borderRadius,
                    spacing: spacing,
                  ),
                ],
              ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double borderRadius;
  final double spacing;

  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    required this.borderRadius,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(spacing * 2),
      decoration: BoxDecoration(
        color: context.estate.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
                SizedBox(height: spacing / 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.estate.textSecondary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentGold,
            inactiveThumbColor: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
