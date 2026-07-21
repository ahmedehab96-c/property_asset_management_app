import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/reports_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReportTypeKey = 'revenue';
  DateTime _startDate = DateTime(2024, 1, 1);
  DateTime _endDate = DateTime(2024, 6, 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReports());
  }

  void _loadReports() {
    final l10n = AppLocalizations.of(context);
    ref.read(reportsProvider.notifier).load(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  String _reportTypeLabel(LocalizedDemoData demo) {
    return demo
        .reportTypes()
        .firstWhere((t) => t['key'] == _selectedReportTypeKey)['label']!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final rs = ref.watch(reportsProvider);
    final loading = rs.status == ViewStatus.loading && rs.transactions.isEmpty;
    final fromDemo = rs.fromDemo;
    final totalExpensesDisplay = rs.totalExpensesDisplay;
    final revenuesDisplay = rs.revenuesDisplay;
    final netProfitDisplay = rs.netProfitDisplay;
    final transactions = rs.transactions;
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final reportTypes = demo.reportTypes();
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

    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
            size: iconSize,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              final homeShellState = context.findAncestorStateOfType<HomeShellState>();
              if (homeShellState != null) {
                homeShellState.changeIndex(0);
              }
            }
          },
        ),
        title: Text(
          l10n.reports,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.download,
              color: context.estate.textPrimary,
              size: iconSize,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.loadingReport),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.accentGold),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loadingReports,
                    style: TextStyle(color: context.estate.textSecondary),
                  ),
                ],
              ),
            )
          : SafeArea(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                height: double.infinity,
          padding: padding,
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
                child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fromDemo)
            const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
              // Filter Reports Card
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.filterReports,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 2.5),
                    // Report Type Dropdown
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: context.estate.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (sheetContext) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.selectReportType,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: context.estate.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...reportTypes.map(
                                  (type) => ListTile(
                                    title: Text(
                                      type['label']!,
                                      style: TextStyle(
                                        color: context.estate.textPrimary,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedReportTypeKey = type['key']!;
                                      });
                                      Navigator.pop(sheetContext);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.estate.textSecondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _reportTypeLabel(demo),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: context.estate.textPrimary,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: context.estate.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 2),
                    // Date Fields
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: l10n.from,
                            date: _startDate,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: spacing * 1.5),
                        Expanded(
                          child: _DateField(
                            label: l10n.to,
                            date: _endDate,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 2.5),
                    // View Report Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveBorderRadius(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.viewReport,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
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
              ),
              SizedBox(height: spacing * 3),

              // Income and Expense Summary Card
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.revenueExpenseSummary,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      '${l10n.from} ${_formatDate(_startDate)} ${l10n.to} ${_formatDate(_endDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.estate.textSecondary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 13,
                          tablet: 14,
                          desktop: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 2.5),
                    // Summary Boxes
                    ResponsiveHelper.isMobile(context)
                        ? Column(
                            children: [
                              _SummaryBox(
                                title: l10n.totalExpenses,
                                value: totalExpensesDisplay,
                                color: Colors.purple,
                                isFullWidth: true,
                              ),
                              SizedBox(height: spacing * 1.5),
                              _SummaryBox(
                                title: l10n.revenues,
                                value: revenuesDisplay,
                                color: Colors.green,
                                isFullWidth: true,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _SummaryBox(
                                  title: l10n.totalExpenses,
                                  value: totalExpensesDisplay,
                                  color: Colors.purple,
                                ),
                              ),
                              SizedBox(width: spacing * 1.5),
                              Expanded(
                                child: _SummaryBox(
                                  title: l10n.revenues,
                                  value: revenuesDisplay,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: spacing * 1.5),
                    _SummaryBox(
                      title: l10n.netProfit,
                      value: netProfitDisplay,
                      color: AppColors.accentGold,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 3),

              // Cash Flow Analysis Card
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cashFlowAnalysis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 2.5),
                    // Empty state - placeholder
                    Container(
                      height: ResponsiveHelper.getResponsiveImageHeight(
                        context,
                        mobile: 100.0,
                        tablet: 120.0,
                        desktop: 140.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveBorderRadius(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l10n.noDataAvailable,
                          style: theme.textTheme.bodyMedium?.copyWith(
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
                  ],
                ),
              ),
              SizedBox(height: spacing * 3),

              // Latest Transactions Card
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.latestTransactions,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.estate.textPrimary,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 18,
                              tablet: 20,
                              desktop: 22,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            l10n.viewAll,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 2),
                    ...transactions.map((transaction) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing * 1.5),
                        child: _TransactionItem(
                          title: transaction['title'] as String,
                          amount: transaction['amount'] as String,
                          date: transaction['date'] as String,
                          isIncome: transaction['isIncome'] as bool,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: spacing * 2.5),
            ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          border: Border.all(
            color: context.estate.textSecondary.withValues(alpha: 0.3),
            width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 5,
                    desktop: 6,
                  ),
                ),
                Text(
                  "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.estate.textPrimary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              color: context.estate.textSecondary,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isFullWidth;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.estate.textSecondary,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 15,
              ),
            ),
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final bool isIncome;

  const _TransactionItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveBorderRadius(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.estate.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 5,
                    desktop: 6,
                  ),
                ),
                Text(
                  date,
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
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
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
    );
  }
}

