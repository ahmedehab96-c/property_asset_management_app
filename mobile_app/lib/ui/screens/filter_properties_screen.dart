import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class FilterPropertiesScreen extends StatefulWidget {
  const FilterPropertiesScreen({super.key});

  @override
  State<FilterPropertiesScreen> createState() => _FilterPropertiesScreenState();
}

class _FilterPropertiesScreenState extends State<FilterPropertiesScreen> {
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
          icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary, size: iconSize),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.filterProperties,
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
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing * 2),
              
              // Status Filter
              Text(
                l10n.propertyStatus,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _FilterChip(
                    label: l10n.all,
                    isSelected: _selectedStatus == null,
                    onTap: () => setState(() => _selectedStatus = null),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.rented,
                    isSelected: _selectedStatus == l10n.rented,
                    onTap: () => setState(() => _selectedStatus = l10n.rented),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.vacant,
                    isSelected: _selectedStatus == l10n.vacant,
                    onTap: () => setState(() => _selectedStatus = l10n.vacant),
                    borderRadius: borderRadius,
                  ),
                ],
              ),
              SizedBox(height: spacing * 3),

              // Type Filter
              Text(
                l10n.propertyType,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _FilterChip(
                    label: l10n.all,
                    isSelected: _selectedType == null,
                    onTap: () => setState(() => _selectedType = null),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.villa,
                    isSelected: _selectedType == l10n.villa,
                    onTap: () => setState(() => _selectedType = l10n.villa),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.apartment,
                    isSelected: _selectedType == l10n.apartment,
                    onTap: () => setState(() => _selectedType = l10n.apartment),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.office,
                    isSelected: _selectedType == l10n.office,
                    onTap: () => setState(() => _selectedType = l10n.office),
                    borderRadius: borderRadius,
                  ),
                ],
              ),
              SizedBox(height: spacing * 3),

              // Location Filter
              Text(
                l10n.location,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _FilterChip(
                    label: l10n.all,
                    isSelected: _selectedLocation == null,
                    onTap: () => setState(() => _selectedLocation = null),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.riyadh,
                    isSelected: _selectedLocation == l10n.riyadh,
                    onTap: () => setState(() => _selectedLocation = l10n.riyadh),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.jeddah,
                    isSelected: _selectedLocation == l10n.jeddah,
                    onTap: () => setState(() => _selectedLocation = l10n.jeddah),
                    borderRadius: borderRadius,
                  ),
                  _FilterChip(
                    label: l10n.dammam,
                    isSelected: _selectedLocation == l10n.dammam,
                    onTap: () => setState(() => _selectedLocation = l10n.dammam),
                    borderRadius: borderRadius,
                  ),
                ],
              ),
              SizedBox(height: spacing * 4),

              // Apply and Reset Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = null;
                          _selectedType = null;
                          _selectedLocation = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.accentGold, width: 2),
                        padding: EdgeInsets.symmetric(vertical: spacing * 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                      child: Text(
                        l10n.reset,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: spacing * 1.5),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.filterApplied),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: spacing * 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.applyFilter,
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
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing * 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double borderRadius;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 10, tablet: 12, desktop: 14),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGold
              : AppColors.cardDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSelected ? AppColors.primaryBlue : AppColors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
          ),
        ),
      ),
    );
  }
}

