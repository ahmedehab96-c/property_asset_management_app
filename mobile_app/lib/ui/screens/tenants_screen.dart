import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/repositories/tenant_repository.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/ui/screens/contact_tenant_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final _repository = TenantRepository();
  bool _loading = true;
  bool _loadingMore = false;
  bool _fromDemo = true;
  bool _hasMore = false;
  int _page = 1;
  List<Map<String, dynamic>> _tenants = [];
  String _totalMonthlyRent = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTenants());
  }

  Future<void> _loadTenants({bool reset = true}) async {
    if (!mounted) return;
    if (reset) {
      setState(() {
        _loading = true;
        _page = 1;
      });
    }
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final result = await _repository.loadTenants(
      l10n: l10n,
      isArabic: isArabic,
      page: _page,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _fromDemo = result.fromDemo;
      _hasMore = result.hasMore;
      _tenants = reset ? result.tenants : [..._tenants, ...result.tenants];
      _totalMonthlyRent = result.totalMonthlyRent;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _fromDemo) return;
    setState(() => _loadingMore = true);
    _page++;
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final result = await _repository.loadTenants(
      l10n: l10n,
      isArabic: isArabic,
      page: _page,
    );
    if (!mounted) return;
    setState(() {
      _loadingMore = false;
      _hasMore = result.hasMore;
      _tenants = [..._tenants, ...result.tenants];
      _totalMonthlyRent = result.totalMonthlyRent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: context.estate.textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  l10n.tenants,
                  style: TextStyle(color: context.estate.textPrimary),
                ),
                centerTitle: true,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: _loading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.accentGold),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loadingTenants,
                        style: TextStyle(color: context.estate.textSecondary),
                      ),
                    ],
                  ),
                )
              : Column(
            children: [
              if (_fromDemo)
            const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_tenants.length}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                          Text(
                            l10n.activeTenant,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.estate.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: context.estate.textSecondary.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _totalMonthlyRent,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                            ),
                          ),
                          Text(
                            l10n.totalMonthlyRent,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.estate.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.accentGold,
                  onRefresh: () => _loadTenants(reset: true),
                  child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount:
                      _tenants.length + (_hasMore && !_fromDemo ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_hasMore && !_fromDemo && index == _tenants.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: _loadingMore
                              ? const CircularProgressIndicator(
                                  color: AppColors.accentGold,
                                )
                              : TextButton(
                                  onPressed: _loadMore,
                                  child: Text(l10n.loadMore),
                                ),
                        ),
                      );
                    }
                    final tenant = _tenants[index];
                    return _TenantCard(
                      tenant: tenant,
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: ContactTenantScreen(tenant: tenant),
                            direction: AxisDirection.left,
                          ),
                        );
                      },
                    );
                  },
                ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final Map<String, dynamic> tenant;
  final VoidCallback onTap;

  const _TenantCard({
    required this.tenant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.estate.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.darkGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: context.estate.textPrimary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant['name'] as String,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.estate.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tenant['property'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.estate.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: context.estate.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tenant['phone'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.estate.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tenant['status'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tenant['rentAmount'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
