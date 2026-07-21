import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/screens/dashboard_screen.dart';
import 'package:property_asset_management_app/ui/screens/my_properties_screen.dart';
import 'package:property_asset_management_app/ui/screens/projects_screen.dart';
import 'package:property_asset_management_app/ui/screens/services_screen.dart';
import 'package:property_asset_management_app/ui/screens/wallet_screen.dart';
import 'package:property_asset_management_app/ui/screens/profile_screen.dart';
import 'package:property_asset_management_app/ui/screens/notifications_screen.dart';
import 'package:property_asset_management_app/ui/screens/ai_assistant_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/widgets/ambient_background.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/curved_bottom_nav_bar.dart';
import 'package:property_asset_management_app/widgets/theme_mode_selector.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  void changeIndex(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  static const _screens = <Widget>[
    DashboardScreen(),
    MyPropertiesScreen(),
    ProjectsScreen(),
    WalletScreen(),
    ServicesScreen(),
  ];

  List<_ShellDest> _destinations(AppLocalizations l10n) => [
        _ShellDest(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: l10n.home,
        ),
        _ShellDest(
          icon: Icons.house_outlined,
          selectedIcon: Icons.house_rounded,
          label: l10n.myProperties,
        ),
        _ShellDest(
          icon: Icons.dashboard_customize_outlined,
          selectedIcon: Icons.dashboard_customize_rounded,
          label: l10n.myProjects,
        ),
        _ShellDest(
          icon: Icons.account_balance_wallet_outlined,
          selectedIcon: Icons.account_balance_wallet_rounded,
          label: l10n.wallet,
        ),
        _ShellDest(
          icon: Icons.miscellaneous_services_outlined,
          selectedIcon: Icons.miscellaneous_services_rounded,
          label: l10n.services,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final useBottom = ResponsiveHelper.useBottomNav(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final destinations = _destinations(l10n);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
    );
    final fabSize = ResponsiveHelper.value(
      context,
      mobile: 24.0,
      tablet: 26.0,
      desktop: 28.0,
    );

    final body = SafeArea(
      bottom: useBottom,
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return ArcTabTransition(
                animation: animation,
                goingForward: _currentIndex > _previousIndex,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: ResponsiveHelper.constrainContent(
                context: context,
                child: _screens[_currentIndex],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: useBottom ? 88 : AppSpacing.xxl,
            start: ResponsiveHelper.adaptivePadding(context),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(
                    page: const AIAssistantScreen(),
                    direction: AxisDirection.left,
                  ),
                );
              },
              backgroundColor: AppColors.gold,
              mini: useBottom,
              tooltip: l10n.smartAssistant,
              child: Icon(
                Icons.smart_toy,
                color: AppColors.royalBlue,
                size: fabSize,
              ),
            ),
          ),
        ],
      ),
    );

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        appBar: _currentIndex == 0
            ? glassAppBar(
                context: context,
                title: l10n.dashboard,
                leading: GlassIconButton(
                  margin: const EdgeInsetsDirectional.only(
                    start: 8,
                    top: 6,
                    bottom: 6,
                  ),
                  icon: Icons.notifications_none_rounded,
                  iconSize: iconSize,
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: const NotificationsScreen(),
                        direction: AxisDirection.right,
                      ),
                    );
                  },
                ),
                actions: [
                  GlassIconButton(
                    child: ThemeModeIconButton(iconSize: iconSize),
                  ),
                  GlassIconButton(
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    icon: Icons.person_outline_rounded,
                    iconSize: iconSize,
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const ProfileScreen(),
                          direction: AxisDirection.left,
                        ),
                      );
                    },
                  ),
                ],
              )
            : null,
        body: useBottom
            ? body
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AdaptiveSideNav(
                    currentIndex: _currentIndex,
                    onSelect: _onTabTap,
                    destinations: destinations,
                    extended: isDesktop,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
        bottomNavigationBar: useBottom
            ? CurvedBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabTap,
                items: destinations
                    .map(
                      (d) => CurvedNavItem(
                        icon: d.icon,
                        activeIcon: d.selectedIcon,
                        label: d.label,
                      ),
                    )
                    .toList(),
              )
            : null,
      ),
    );
  }
}

class _ShellDest {
  const _ShellDest({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _AdaptiveSideNav extends StatelessWidget {
  const _AdaptiveSideNav({
    required this.currentIndex,
    required this.onSelect,
    required this.destinations,
    required this.extended,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final List<_ShellDest> destinations;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    final destinationsWidgets = destinations
        .map(
          (d) => NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(
              d.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();

    return Material(
      color: palette.surfaceGlass.withValues(alpha: 0.55),
      child: SafeArea(
        right: false,
        child: NavigationRail(
          extended: extended,
          minExtendedWidth: 200,
          selectedIndex: currentIndex,
          onDestinationSelected: onSelect,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withValues(alpha: 0.14),
          selectedIconTheme: IconThemeData(color: AppColors.primary),
          unselectedIconTheme: IconThemeData(
            color: palette.textSecondary,
          ),
          labelType: extended
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
          destinations: destinationsWidgets,
        ),
      ),
    );
  }
}
