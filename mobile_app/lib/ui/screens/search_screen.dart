import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/search_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/ui/screens/property_detail_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTypeKey = 'all';
  String _selectedCityKey = 'all';
  double _minPrice = 0;
  double _maxPrice = 100000;
  double _minArea = 0;
  double _maxArea = 1000;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final l10n = AppLocalizations.of(context);
    ref.read(searchProvider.notifier).search(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
          query: _searchController.text,
          typeKey: _selectedTypeKey,
          cityKey: _selectedCityKey,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minArea: _minArea,
          maxArea: _maxArea,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final ss = ref.watch(searchProvider);
    final loading = ss.status == ViewStatus.loading;
    final searched = ss.searched;
    final fromDemo = ss.fromDemo;
    final results = ss.results;

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
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      final homeShellState =
                          context.findAncestorStateOfType<HomeShellState>();
                      if (homeShellState != null) {
                        homeShellState.changeIndex(0);
                      }
                    }
                  },
                ),
                title: Text(
                  l10n.advancedSearch,
                  style: TextStyle(color: context.estate.textPrimary),
                ),
                centerTitle: true,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: theme.textTheme.bodyLarge,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: l10n.searchProperty,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: context.estate.textSecondary,
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.accentGold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: context.estate.textSecondary,
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.filters,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.estate.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: l10n.propertyType,
                options: [
                  _FilterOption(key: 'all', label: l10n.all),
                  _FilterOption(key: 'apartment', label: l10n.apartment),
                  _FilterOption(key: 'villa', label: l10n.villa),
                  _FilterOption(key: 'commercial', label: l10n.commercial),
                  _FilterOption(key: 'land', label: l10n.land),
                ],
                selectedKey: _selectedTypeKey,
                onChanged: (value) => setState(() => _selectedTypeKey = value),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: l10n.city,
                options: [
                  _FilterOption(key: 'all', label: l10n.all),
                  _FilterOption(key: 'riyadh', label: l10n.riyadh),
                  _FilterOption(key: 'jeddah', label: l10n.jeddah),
                  _FilterOption(key: 'dammam', label: l10n.dammam),
                  _FilterOption(key: 'madina', label: l10n.madina),
                ],
                selectedKey: _selectedCityKey,
                onChanged: (value) => setState(() => _selectedCityKey = value),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.priceRange,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.estate.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RangeField(
                      label: l10n.from,
                      value: _minPrice.toInt(),
                      onChanged: (value) {
                        setState(() => _minPrice = value.toDouble());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RangeField(
                      label: l10n.to,
                      value: _maxPrice.toInt(),
                      onChanged: (value) {
                        setState(() => _maxPrice = value.toDouble());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.areaRange,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.estate.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RangeField(
                      label: l10n.from,
                      value: _minArea.toInt(),
                      onChanged: (value) {
                        setState(() => _minArea = value.toDouble());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RangeField(
                      label: l10n.to,
                      value: _maxArea.toInt(),
                      onChanged: (value) {
                        setState(() => _maxArea = value.toDouble());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : Text(
                          l10n.search,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.results,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.estate.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (fromDemo && searched)
                const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
              if (loading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.loadingSearch,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.estate.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!searched)
                Text(
                  l10n.searchProperty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.estate.textSecondary,
                  ),
                )
              else if (results.isEmpty)
                Text(
                  l10n.noSearchResults,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.estate.textSecondary,
                  ),
                )
              else
                ...results.map((result) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SearchResultCard(
                      name: result['name'] as String,
                      location: result['location'] as String,
                      price: result['price'] as String,
                      area: result['area'] as String,
                      onTap: () {
                        final detail = result['detail'];
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: PropertyDetailScreen(
                              property: detail is Map<String, dynamic>
                                  ? detail
                                  : {
                                      'name': result['name'],
                                      'location': result['fullLocation'] ??
                                          result['location'],
                                    },
                            ),
                            direction: AxisDirection.left,
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOption {
  final String key;
  final String label;

  const _FilterOption({required this.key, required this.label});
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<_FilterOption> options;
  final String selectedKey;
  final ValueChanged<String> onChanged;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: context.estate.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedKey == option.key;
            return GestureDetector(
              onTap: () => onChanged(option.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentGold : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentGold
                        : AppColors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  option.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.primaryBlue : AppColors.white,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RangeField extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const _RangeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.estate.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.estate.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.estate.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String area;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.name,
    required this.location,
    required this.price,
    required this.area,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.estate.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.estate.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: context.estate.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.estate.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
                Text(
                  area,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.estate.textPrimary,
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
