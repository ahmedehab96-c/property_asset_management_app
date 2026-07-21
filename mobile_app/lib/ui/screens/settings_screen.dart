import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/providers/theme_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/ui/screens/appearance_settings_screen.dart';
import 'package:property_asset_management_app/ui/screens/notification_settings_screen.dart';
import 'package:property_asset_management_app/core/providers/service_providers.dart';
import 'package:property_asset_management_app/ui/screens/language_settings_screen.dart';
import 'package:property_asset_management_app/ui/screens/login_screen.dart';
import 'package:property_asset_management_app/widgets/theme_mode_selector.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/animations/staggered_animation.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
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
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await ref.read(notificationPreferencesServiceProvider).load();
    if (!mounted) return;
    setState(() => _notificationsEnabled = prefs.allNotifications);
  }

  Future<void> _openNotificationSettings() async {
    await Navigator.push(
      context,
      SlidePageRoute(page: const NotificationSettingsScreen()),
    );
    await _loadNotificationPrefs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    return AppScaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.estate.surfaceGlass,
                        context.estate.surfaceGlassLight,
                      ],
                    ),
                  ),
                  child: AppBar(
            backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      l10n.settings,
                      style: TextStyle(color: context.estate.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Settings
                StaggeredAnimation(
                  index: 0,
                  child: Text(
                    l10n.general,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                StaggeredAnimation(
                  index: 1,
                  child: const ThemeModeSelectorCard(),
                ),
                SizedBox(height: 20),
                StaggeredAnimation(
                  index: 2,
                  child: _SettingsTile(
                    icon: Icons.language,
                    title: l10n.language,
                    subtitle: isArabic ? l10n.arabic : l10n.english,
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(page: const LanguageSettingsScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 14),
                StaggeredAnimation(
                  index: 3,
                  child: _SettingsTile(
                    icon: Icons.notifications,
                    title: l10n.notifications,
                    subtitle: _notificationsEnabled ? l10n.enabled : l10n.disabled,
                    onTap: _openNotificationSettings,
                  ),
                ),
                SizedBox(height: 14),
                StaggeredAnimation(
                  index: 4,
                  child: _SettingsTile(
                    icon: Icons.fingerprint,
                    title: l10n.biometricAuth,
                    subtitle: l10n.biometricAuthSubtitle,
                    trailing: Switch(
                      value: _biometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                      },
                      activeThumbColor: AppColors.accentGold,
                      activeTrackColor: AppColors.accentGold.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                StaggeredAnimation(
                  index: 5,
                  child: _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: AppLocalizations.of(context).appearance,
                    subtitle: isArabic
                        ? ThemeModeNotifier.labelAr(
                            ref.watch(themeModeSyncProvider),
                            Theme.of(context).brightness,
                          )
                        : ThemeModeNotifier.labelEn(
                            ref.watch(themeModeSyncProvider),
                            Theme.of(context).brightness,
                          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(page: const AppearanceSettingsScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 40),

                // Security Settings
                StaggeredAnimation(
                  index: 6,
                  child: Text(
                    l10n.security,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                StaggeredAnimation(
                  index: 7,
                  child: _SettingsTile(
                    icon: Icons.lock,
                    title: l10n.changePassword,
                    subtitle: l10n.updateCurrentPassword,
                    onTap: () {},
                  ),
                ),
                SizedBox(height: 14),
                StaggeredAnimation(
                  index: 8,
                  child: _SettingsTile(
                    icon: Icons.security,
                    title: l10n.twoFactorAuth,
                    subtitle: l10n.twoFactorAuthSubtitle,
                    onTap: () {},
                  ),
                ),
                SizedBox(height: 40),

                // Account Settings
                StaggeredAnimation(
                  index: 9,
                  child: Text(
                    l10n.account,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                StaggeredAnimation(
                  index: 10,
                  child: _SettingsTile(
                    icon: Icons.edit,
                    title: l10n.editProfile,
                    subtitle: l10n.updatePersonalInformation,
                    onTap: () {},
                  ),
                ),
                SizedBox(height: 14),
                StaggeredAnimation(
                  index: 11,
                  child: _SettingsTile(
                    icon: Icons.delete_outline,
                    title: l10n.deleteAccount,
                    subtitle: l10n.deleteAccountSubtitle,
                    isDestructive: true,
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                  ),
                ),
                SizedBox(height: 40),

                // Logout Button
                StaggeredAnimation(
                  index: 12,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 22),
                          SizedBox(width: 12),
                          Text(
                            l10n.logout,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.estate.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.logout,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                FadePageRoute(page: const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              l10n.logout,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.estate.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.deleteAccount,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTapDown: (_) {
          if (widget.onTap != null) {
            setState(() => _isPressed = true);
            _controller.forward();
          }
        },
        onTapUp: (_) {
          if (widget.onTap != null) {
            setState(() => _isPressed = false);
            _controller.reverse();
            widget.onTap?.call();
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                          AppColors.cardDark.withValues(alpha: 0.9),
                          AppColors.navy.withValues(alpha: 0.7),
                        ]
                      : [
                          AppColors.cardDark.withValues(alpha: 0.8),
                          AppColors.navy.withValues(alpha: 0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isPressed
                      ? AppColors.accentGold.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isPressed ? 1.5 : 1,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (widget.isDestructive
                              ? Colors.redAccent
                              : AppColors.accentGold)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (widget.isDestructive
                                ? Colors.redAccent
                                : AppColors.accentGold)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isDestructive
                          ? Colors.redAccent
                          : AppColors.accentGold,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: widget.isDestructive
                                ? Colors.redAccent
                                : null,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.estate.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) widget.trailing!,
                  if (widget.trailing == null && widget.onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: context.estate.textSecondary.withValues(alpha: 0.6),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
