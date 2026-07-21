import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/viewmodels/contracts_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/screens/contract_detail_screen.dart';
import 'package:property_asset_management_app/ui/screens/extend_contract_screen.dart';
import 'package:property_asset_management_app/ui/screens/cancel_contract_screen.dart';
import 'package:property_asset_management_app/ui/screens/file_lawsuit_screen.dart';
import 'package:property_asset_management_app/ui/home_shell.dart' show HomeShellState;
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  String _selectedFilter = "active";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load({bool reset = true}) {
    final l10n = AppLocalizations.of(context);
    ref.read(contractsProvider.notifier).load(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
          reset: reset,
        );
  }

  void _loadMore() {
    final l10n = AppLocalizations.of(context);
    ref.read(contractsProvider.notifier).loadMore(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  List<Map<String, dynamic>> _filteredContracts(
    List<Map<String, dynamic>> contracts,
  ) {
    final searchQuery = _searchController.text.toLowerCase();
    return contracts.where((contract) {
      bool matchesFilter = false;
      if (_selectedFilter == "active") {
        matchesFilter = contract["statusType"] == "active";
      } else if (_selectedFilter == "expiring") {
        matchesFilter = contract["statusType"] == "expiring";
      } else if (_selectedFilter == "ended") {
        matchesFilter = contract["statusType"] == "ended";
      }

      if (!matchesFilter) return false;

      if (searchQuery.isEmpty) return true;
      return contract["propertyName"]
              .toString()
              .toLowerCase()
              .contains(searchQuery) ||
          contract["tenantName"]
              .toString()
              .toLowerCase()
              .contains(searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = ref.watch(contractsProvider);
    final loading = cs.status == ViewStatus.loading && cs.contracts.isEmpty;
    final filteredContracts = _filteredContracts(cs.contracts);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    
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
              icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary, size: iconSize),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // If part of bottom navigation, navigate to dashboard
                  final homeShellState = context.findAncestorStateOfType<HomeShellState>();
                  if (homeShellState != null) {
                    homeShellState.changeIndex(0);
                  }
                }
              },
            ),
            title: Text(
              l10n.contractsArchive,
              style: TextStyle(
                color: context.estate.textPrimary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            centerTitle: true,
                    actions: [],
                    ),
                ),
              ),
            ),
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
                      l10n.loadingContracts,
                      style: TextStyle(color: context.estate.textSecondary),
                    ),
                  ],
                ),
              )
            : Center(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxContentWidth(context),
            ),
          child: Column(
            children: [
                if (cs.fromDemo)
            const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
                // Search Bar
                Padding(
                  padding: padding,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.estate.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        color: context.estate.textPrimary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                ),
              ),
                      decoration: InputDecoration(
                        hintText: l10n.searchPropertyOrTenant,
                        hintStyle: TextStyle(
                          color: context.estate.textSecondary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                  color: context.estate.textSecondary,
                          size: iconSize,
              ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: padding.left,
                          vertical: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter Tabs
                Padding(
                  padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
                  child: ResponsiveHelper.isMobile(context)
                      ? Column(
                  children: [
                            _FilterTab(
                              label: l10n.active,
                              isSelected: _selectedFilter == "active",
                              onTap: () {
                                setState(() {
                                  _selectedFilter = "active";
                                });
                              },
                            ),
                            SizedBox(height: padding.top / 2),
                            _FilterTab(
                              label: l10n.expiring,
                              isSelected: _selectedFilter == "expiring",
                              onTap: () {
                                setState(() {
                                  _selectedFilter = "expiring";
                                });
                              },
                            ),
                            SizedBox(height: padding.top / 2),
                            _FilterTab(
                              label: l10n.ended,
                              isSelected: _selectedFilter == "ended",
                      onTap: () {
                        setState(() {
                                  _selectedFilter = "ended";
                        });
                      },
                    ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _FilterTab(
                                label: l10n.active,
                                isSelected: _selectedFilter == "active",
                      onTap: () {
                        setState(() {
                                    _selectedFilter = "active";
                        });
                      },
                    ),
                            ),
                            SizedBox(width: padding.left / 2),
                            Expanded(
                              child: _FilterTab(
                                label: l10n.expiring,
                                isSelected: _selectedFilter == "expiring",
                      onTap: () {
                        setState(() {
                                    _selectedFilter = "expiring";
                        });
                      },
                    ),
                            ),
                            SizedBox(width: padding.left / 2),
                            Expanded(
                              child: _FilterTab(
                                label: l10n.ended,
                                isSelected: _selectedFilter == "ended",
                      onTap: () {
                        setState(() {
                                    _selectedFilter = "ended";
                        });
                      },
                              ),
                    ),
                  ],
                ),
              ),

                SizedBox(height: padding.top),

              // Contracts List
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.accentGold,
                    onRefresh: () async => _load(reset: true),
                    child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
                    itemCount: filteredContracts.length +
                        (cs.hasMore && !cs.fromDemo ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (cs.hasMore && !cs.fromDemo && index == filteredContracts.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: cs.loadingMore
                                ? const CircularProgressIndicator(color: AppColors.accentGold)
                                : TextButton(
                                    onPressed: _loadMore,
                                    child: Text(l10n.loadMore),
                                  ),
                          ),
                        );
                      }
                      final contract = filteredContracts[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                        ),
                    child: _ContractCard(
                          contract: contract,
                      onTap: () {
                        Navigator.push(
                          context,
                              SlidePageRoute(
                                page: ContractDetailScreen(
                                  contract: contract,
                                ),
                                direction: AxisDirection.left,
                            ),
                            );
                          },
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getResponsiveBorderRadius(
          context,
          mobile: 8,
          tablet: 10,
          desktop: 12,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 10,
            tablet: 12,
            desktop: 14,
          ),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGold.withValues(alpha: 0.2)
              : AppColors.cardDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : Colors.white.withValues(alpha: 0.1),
            width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
          ),
        ),
        child: Center(
        child: Text(
          label,
            style: TextStyle(
                color: isSelected ? AppColors.accentGold : AppColors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 11,
                tablet: 12,
                desktop: 13,
              ),
            ),
            textAlign: TextAlign.center,
              ),
        ),
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  final Map<String, dynamic> contract;
  final VoidCallback? onTap;

  const _ContractCard({required this.contract, this.onTap});

  Color _getStatusColor() {
    switch (contract["statusType"]) {
      case "active":
        return Colors.greenAccent;
      case "expiring":
        return Colors.orange;
      case "ended":
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  Color _getStatusBgColor() {
    switch (contract["statusType"]) {
      case "active":
        return Colors.greenAccent.withValues(alpha: 0.1);
      case "expiring":
        return Colors.orange.withValues(alpha: 0.1);
      case "ended":
        return AppColors.grey.withValues(alpha: 0.1);
      default:
        return AppColors.grey.withValues(alpha: 0.1);
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (contract["statusType"]) {
      case "active":
        return l10n.active;
      case "expiring":
        return l10n.expiring;
      case "ended":
        return l10n.ended;
      default:
        return "";
    }
  }

  String _getDaysText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final daysRemaining = contract["daysRemaining"] as int? ?? 0;
    if (daysRemaining > 0) {
      return daysRemaining == 1 ? l10n.endsInDay(daysRemaining) : l10n.endsInDays(daysRemaining);
    } else {
      return l10n.endedDaysAgo(daysRemaining.abs());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _getStatusColor();
    final statusBgColor = _getStatusBgColor();
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final spacing = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 16,
      tablet: 18,
      desktop: 20,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
        padding: padding,
          decoration: BoxDecoration(
          color: context.estate.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
              ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Status Tag
              Row(
                children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing * 1.25,
                    vertical: spacing / 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(
                        context,
                        mobile: 10,
                        tablet: 12,
                        desktop: 14,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Container(
                        width: ResponsiveHelper.isMobile(context) ? 6 : 8,
                        height: ResponsiveHelper.isMobile(context) ? 6 : 8,
                    decoration: BoxDecoration(
                        color: statusColor,
                          shape: BoxShape.circle,
                      ),
                    ),
                      SizedBox(width: spacing / 2),
                      Text(
                      _getStatusText(context),
                        style: TextStyle(
                        color: statusColor,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 10,
                            tablet: 11,
                            desktop: 12,
                          ),
                        fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    ),
                  ),
                ],
              ),
            SizedBox(height: spacing * 1.5),

            // Property Name
            Text(
              contract["propertyName"],
              style: TextStyle(
                color: context.estate.textPrimary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: spacing),

            // Status Text
            Text(
              _getDaysText(context),
              style: TextStyle(
                color: context.estate.textSecondary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                    ),
                  ),
              ),
            SizedBox(height: spacing * 1.5),

            // Tenant Info
              Row(
                children: [
                Text(
                  l10n.tenantLabel,
                  style: TextStyle(
                    color: context.estate.textSecondary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                  ),
                ),
                  Text(
                  contract["tenantName"],
                  style: TextStyle(
                    color: context.estate.textPrimary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                  ),
                ],
              ),
            SizedBox(height: spacing),

            // End Date
              Row(
                      children: [
                        Text(
                  l10n.endDateLabel,
                  style: TextStyle(
                            color: context.estate.textSecondary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                          ),
                        ),
                ),
                        Text(
                          contract["endDate"],
                  style: TextStyle(
                    color: context.estate.textPrimary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            SizedBox(height: spacing * 2),

            // Action Buttons
            _buildActionButtons(context, contract["statusType"]),
          ],
        ),
      ),
    );
  }

  void _openExtend(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: ExtendContractScreen(contract: contract),
        direction: AxisDirection.left,
      ),
    );
  }

  void _openCancel(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: CancelContractScreen(contract: contract),
        direction: AxisDirection.left,
      ),
    );
  }

  void _openLawsuit(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: FileLawsuitScreen(contract: contract),
        direction: AxisDirection.left,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String statusType) {
    final l10n = AppLocalizations.of(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 6.0,
      tablet: 8.0,
      desktop: 10.0,
    );
    
    if (statusType == "expiring") {
      return ResponsiveHelper.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActionButton(
                  label: l10n.extendContract,
                  color: AppColors.accentGold,
                  isPrimary: true,
                  onPressed: () => _openExtend(context),
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: l10n.fileLawsuit,
                            color: context.estate.textSecondary,
                        onPressed: () => _openLawsuit(context),
                        ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: _ActionButton(
                        label: l10n.cancel,
                        color: Colors.redAccent,
                        onPressed: () => _openCancel(context),
                            ),
                          ),
                        ],
                      ),
                  ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  label: l10n.cancel,
                  color: Colors.redAccent,
                  onPressed: () => _openCancel(context),
                ),
                SizedBox(width: spacing),
                _ActionButton(
                  label: l10n.fileLawsuit,
                  color: context.estate.textSecondary,
                  onPressed: () => _openLawsuit(context),
                ),
                SizedBox(width: spacing),
                _ActionButton(
                  label: l10n.extendContract,
                  color: AppColors.accentGold,
                  isPrimary: true,
                  onPressed: () => _openExtend(context),
                ),
              ],
            );
    } else if (statusType == "active") {
      return ResponsiveHelper.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActionButton(
                  label: l10n.extendContract,
                  color: context.estate.textSecondary,
                  textColor: AppColors.accentGold,
                  onPressed: () => _openExtend(context),
                ),
                SizedBox(height: spacing),
                Row(
                children: [
                    Expanded(
                      child: _ActionButton(
                        label: l10n.fileLawsuit,
                        color: context.estate.textSecondary,
                        onPressed: () => _openLawsuit(context),
                    ),
                  ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: _ActionButton(
                        label: l10n.cancel,
                        color: Colors.redAccent,
                      onPressed: () => _openCancel(context),
                      ),
                    ),
                ],
              ),
            ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  label: l10n.fileLawsuit,
                  color: context.estate.textSecondary,
                  onPressed: () => _openLawsuit(context),
                ),
                SizedBox(width: spacing),
                _ActionButton(
                  label: l10n.cancel,
                  color: Colors.redAccent,
                  onPressed: () => _openCancel(context),
                ),
                SizedBox(width: spacing),
                _ActionButton(
                  label: l10n.extendContract,
                  color: context.estate.textSecondary,
                  textColor: AppColors.accentGold,
                  onPressed: () => _openExtend(context),
                ),
              ],
            );
    } else {
      // Ended
      return ResponsiveHelper.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActionButton(
                  label: l10n.viewDetails,
                  color: context.estate.textSecondary,
                  onPressed: () {
                    if (onTap != null) onTap!();
                  },
                ),
                SizedBox(height: spacing),
                _ActionButton(
                  label: l10n.fileLawsuit,
                  color: context.estate.textSecondary,
                  onPressed: () => _openLawsuit(context),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  label: l10n.fileLawsuit,
                  color: context.estate.textSecondary,
                  onPressed: () => _openLawsuit(context),
                ),
                SizedBox(width: spacing),
                _ActionButton(
                  label: l10n.viewDetails,
                  color: context.estate.textSecondary,
                  onPressed: () {
                    if (onTap != null) onTap!();
                  },
                ),
              ],
            );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    this.textColor,
    this.isPrimary = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(
      context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );
    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 11,
      tablet: 12,
      desktop: 13,
    );
    final horizontalPadding = ResponsiveHelper.isMobile(context)
        ? (isPrimary ? 16 : 10)
        : (isPrimary ? 20 : 14);
    final verticalPadding = ResponsiveHelper.isMobile(context) ? 8 : 10;
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding.toDouble(),
          vertical: verticalPadding.toDouble(),
        ),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isPrimary
              ? null
              : Border.all(
                  color: color,
                  width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary
                ? AppColors.primaryBlue
                : (textColor ?? color),
            fontSize: fontSize,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
      ),
      ),
    );
  }
}

