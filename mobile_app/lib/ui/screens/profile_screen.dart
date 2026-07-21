import 'dart:io';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/screens/edit_profile_screen.dart';
import 'package:property_asset_management_app/ui/screens/change_profile_picture_screen.dart';
import 'package:property_asset_management_app/ui/screens/change_password_screen.dart';
import 'package:property_asset_management_app/ui/screens/two_factor_auth_screen.dart';
import 'package:property_asset_management_app/ui/screens/privacy_policy_screen.dart';
import 'package:property_asset_management_app/ui/screens/language_settings_screen.dart';
import 'package:property_asset_management_app/ui/screens/currency_settings_screen.dart';
import 'package:property_asset_management_app/ui/screens/appearance_settings_screen.dart';
import 'package:property_asset_management_app/ui/screens/notification_settings_screen.dart';
import 'package:property_asset_management_app/ui/screens/help_support_screen.dart';
import 'package:property_asset_management_app/ui/screens/login_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/core/providers/service_providers.dart';
import 'package:property_asset_management_app/viewmodels/auth_notifier.dart';
import 'package:property_asset_management_app/services/profile_image_store.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/providers/theme_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/theme_mode_selector.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  CachedUserProfile _profile = const CachedUserProfile();
  String? _profileImagePath;
  bool _loadingProfile = true;

  late AnimationController _profileController;
  late AnimationController _itemsController;
  
  late Animation<double> _profileScaleAnimation;
  late Animation<double> _profile3DAnimation;
  late Animation<double> _itemsFadeAnimation;
  late Animation<Offset> _itemsSlideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Profile Picture Animation
    _profileController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _profileScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _profileController, curve: Curves.elasticOut),
    );
    
    _profile3DAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _profileController, curve: Curves.easeOut),
    );
    
    // Items Animation
    _itemsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _itemsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _itemsController, curve: Curves.easeOut),
    );
    
    _itemsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _itemsController, curve: Curves.easeOutCubic),
    );
    
    // Start animations
    _startAnimations();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ref.read(userProfileServiceProvider).load();
    final imagePath = await ProfileImageStore.getPath();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _profileImagePath = imagePath;
      _loadingProfile = false;
    });
  }

  Future<void> _openChangeProfilePicture() async {
    await Navigator.push(
      context,
      SlidePageRoute(
        page: const ChangeProfilePictureScreen(),
        direction: AxisDirection.left,
      ),
    );
    await _loadProfileData();
  }

  Widget _buildProfileAvatar() {
    final imagePath = _profileImagePath;
    if (imagePath != null && File(imagePath).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(imagePath),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }
    return Icon(
      Icons.person,
      size: 60,
      color: AppColors.accentGold,
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    await ProfileImageStore.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
  
  void _startAnimations() async {
    _profileController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _itemsController.forward();
  }
  
  @override
  void dispose() {
    _profileController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(
        context: context,
        title: l10n.accountSettings,
        leading: IconButton(
          icon: Icon(Icons.person_outline, color: palette.textPrimary, size: iconSize),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: palette.textPrimary, size: iconSize),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                final homeShellState = context.findAncestorStateOfType<HomeShellState>();
                homeShellState?.changeIndex(0);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            children: [
              SizedBox(height: spacing * 2),
                        // Profile Picture with 3D Animation
                        GestureDetector(
                          onTap: _openChangeProfilePicture,
                          child: AnimatedBuilder(
                          animation: _profileController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _profileScaleAnimation.value,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(_profile3DAnimation.value * 0.3)
                                  ..rotateX(_profile3DAnimation.value * 0.1),
                                alignment: Alignment.center,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primaryBlue,
                                        AppColors.navy,
                                        AppColors.accentGold.withValues(alpha: 0.3),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: AppColors.accentGold,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentGold.withValues(alpha: 0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: _loadingProfile
                                      ? Padding(
                                          padding: EdgeInsets.all(36),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.accentGold,
                                          ),
                                        )
                                      : _buildProfileAvatar(),
                                ),
                              ),
                            );
                          },
                        ),
                        ),
                        SizedBox(height: spacing * 2),
                        // Name with Animation
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: Text(
                              _profile.name.isNotEmpty ? _profile.name : '—',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 22,
                                  tablet: 24,
                                  desktop: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        // Email with Animation
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: Text(
                              _profile.email.isNotEmpty ? _profile.email : '—',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: context.estate.textSecondary,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 14,
                                  tablet: 16,
                                  desktop: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing * 2),
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: const ThemeModeSelectorCard(),
                          ),
                        ),
                        SizedBox(height: spacing * 3),

                        // Personal Profile Section with Animation
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: _SectionHeader(
                              title: l10n.profile,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: _ProfileMenuItem(
                              icon: Icons.person_outline,
                              title: l10n.editProfile,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: const EditProfileScreen(),
                                    direction: AxisDirection.left,
                                  ),
                                );
                                await _loadProfileData();
                              },
                              borderRadius: borderRadius,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: _ProfileMenuItem(
                              icon: Icons.camera_alt_outlined,
                              title: l10n.changeProfilePicture,
                              onTap: _openChangeProfilePicture,
                              borderRadius: borderRadius,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing * 2),

                        // Security and Privacy Section with Animation
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: _SectionHeader(
                              title: l10n.securityPrivacy,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        ...List.generate(3, (index) {
                          final items = [
                            {'icon': Icons.lock_outline, 'title': l10n.changePassword, 'screen': const ChangePasswordScreen()},
                            {'icon': Icons.verified_user, 'title': l10n.twoFactorAuth, 'screen': const TwoFactorAuthScreen()},
                            {'icon': Icons.shield_outlined, 'title': l10n.privacyPolicy, 'screen': const PrivacyPolicyScreen()},
                          ];
                          return Padding(
                            padding: EdgeInsets.only(bottom: spacing),
                            child: FadeTransition(
                              opacity: _itemsFadeAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0, 0.3 + index * 0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _itemsController,
                                    curve: Interval(0.0 + index * 0.1, 1.0, curve: Curves.easeOutCubic),
                                  ),
                                ),
                                child: _ProfileMenuItem(
                                  icon: items[index]['icon'] as IconData,
                                  title: items[index]['title'] as String,
                                  subtitle: null,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlidePageRoute(
                                        page: items[index]['screen'] as Widget,
                                        direction: AxisDirection.left,
                                      ),
                                    );
                                  },
                                  borderRadius: borderRadius,
                                  spacing: spacing,
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: spacing * 2),

                        // Preferences Section with Animation
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: _SectionHeader(
                              title: l10n.preferences,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        ...List.generate(4, (index) {
                          final items = [
                            {'icon': Icons.language, 'title': l10n.language, 'subtitle': ref.watch(isArabicProvider) ? l10n.arabic : l10n.english, 'screen': const LanguageSettingsScreen()},
                            {'icon': Icons.attach_money, 'title': l10n.currency, 'subtitle': l10n.aed, 'screen': const CurrencySettingsScreen()},
                            {'icon': Icons.dark_mode_outlined, 'title': l10n.appearance, 'subtitle': ref.watch(isArabicProvider) ? ThemeModeNotifier.labelAr(ref.watch(themeModeSyncProvider), Theme.of(context).brightness) : ThemeModeNotifier.labelEn(ref.watch(themeModeSyncProvider), Theme.of(context).brightness), 'screen': const AppearanceSettingsScreen()},
                            {'icon': Icons.notifications_outlined, 'title': l10n.notificationSettings, 'subtitle': l10n.pushNotificationsNote, 'screen': const NotificationSettingsScreen()},
                          ];
                          return Padding(
                            padding: EdgeInsets.only(bottom: spacing),
                            child: FadeTransition(
                              opacity: _itemsFadeAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0, 0.3 + index * 0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _itemsController,
                                    curve: Interval(0.0 + index * 0.1, 1.0, curve: Curves.easeOutCubic),
                                  ),
                                ),
                                child: _ProfileMenuItem(
                                  icon: items[index]['icon'] as IconData,
                                  title: items[index]['title'] as String,
                                  subtitle: items[index]['subtitle'] as String?,
                                  showArrow: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlidePageRoute(
                                        page: items[index]['screen'] as Widget,
                                        direction: AxisDirection.left,
                                      ),
                                    );
                                  },
                                  borderRadius: borderRadius,
                                  spacing: spacing,
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: spacing * 2),

                        // Help Section with Animation
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: _SectionHeader(
                              title: l10n.help,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: SlideTransition(
                            position: _itemsSlideAnimation,
                            child: _ProfileMenuItem(
                              icon: Icons.headset_mic_outlined,
                              title: l10n.technicalSupport,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: const HelpSupportScreen(),
                                    direction: AxisDirection.left,
                                  ),
                                );
                              },
                              borderRadius: borderRadius,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing * 3),

                        // Logout Button with 3D Animation
                        FadeTransition(
                          opacity: _itemsFadeAnimation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _itemsController,
                                curve: Curves.elasticOut,
                              ),
                            ),
                            child: Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateX(0.02),
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: context.estate.surface,
                        title: Text(
                          l10n.logout,
                          style: theme.textTheme.titleLarge,
                        ),
                        content: Text(
                          l10n.logoutConfirmation,
                          style: theme.textTheme.bodyLarge,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(color: context.estate.textSecondary),
                  ),
                ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _logout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: AppColors.white,
                            ),
                            child: Text(l10n.logout),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: spacing * 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: iconSize * 0.8),
                      SizedBox(width: spacing),
                      Text(
                        l10n.logout,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: spacing * 2),
      ],
    ),
  ),
),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final double spacing;

  const _SectionHeader({
    required this.title,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.accentGold,
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;
  final double borderRadius;
  final double spacing;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showArrow = false,
    required this.borderRadius,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.all(spacing * 2),
              decoration: BoxDecoration(
          color: context.estate.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
            color: context.estate.border,
            width: 1,
                        ),
              ),
              child: Row(
                children: [
            Icon(
              icon,
              color: AppColors.accentGold,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
                    ),
                  ),
            SizedBox(width: spacing * 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                          ),
                        ),
                  if (subtitle != null) ...[
                    SizedBox(height: spacing / 2),
                        Text(
                      subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.estate.textSecondary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 13,
                          tablet: 14,
                          desktop: 15,
                        ),
                  ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              showArrow ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: context.estate.textSecondary,
              size: 16,
          ),
          ],
        ),
      ),
    );
  }
}
