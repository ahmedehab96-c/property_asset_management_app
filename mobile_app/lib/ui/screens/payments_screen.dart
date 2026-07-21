import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/viewmodels/payments_notifier.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String _selectedFilter = LocalizedDemoData.filterAll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final l10n = AppLocalizations.of(context);
    ref.read(paymentsProvider.notifier).load(
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final ps = ref.watch(paymentsProvider);
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final payments = ps.payments.isNotEmpty ? ps.payments : demo.payments();
    final fromDemo = ps.fromDemo || ps.payments.isEmpty;

    final filtered = switch (_selectedFilter) {
      LocalizedDemoData.filterPaid =>
        payments.where((p) => p['statusType'] == LocalizedDemoData.filterPaid).toList(),
      LocalizedDemoData.filterPending =>
        payments.where((p) => p['statusType'] == LocalizedDemoData.filterPending).toList(),
      _ => payments,
    };

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.payments, style: TextStyle(color: context.estate.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (fromDemo)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: DemoDataBanner(),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: l10n.totalPaid,
                      value: ps.totalPaidDisplay.isNotEmpty
                          ? ps.totalPaidDisplay
                          : '58,000 ${l10n.aed}',
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: l10n.pendingPayments,
                      value: ps.pendingDisplay.isNotEmpty
                          ? ps.pendingDisplay
                          : '25,000 ${l10n.aed}',
                      color: Colors.orange,
                      icon: Icons.pending,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.all,
                      isSelected: _selectedFilter == LocalizedDemoData.filterAll,
                      onTap: () => setState(() => _selectedFilter = LocalizedDemoData.filterAll),
                    ),
                    const SizedBox(width: 12),
                    _FilterChip(
                      label: l10n.paidStatus,
                      isSelected: _selectedFilter == LocalizedDemoData.filterPaid,
                      onTap: () => setState(() => _selectedFilter = LocalizedDemoData.filterPaid),
                    ),
                    const SizedBox(width: 12),
                    _FilterChip(
                      label: l10n.pending,
                      isSelected: _selectedFilter == LocalizedDemoData.filterPending,
                      onTap: () => setState(() => _selectedFilter = LocalizedDemoData.filterPending),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _PaymentCard(
                  payment: filtered[index],
                  demo: demo,
                  l10n: l10n,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.estate.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.estate.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: context.estate.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGold : context.estate.surfaceGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.accentGold : context.estate.border),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.primaryBlue : context.estate.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.demo, required this.l10n});

  final Map<String, dynamic> payment;
  final LocalizedDemoData demo;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusType = payment['statusType'] as String;
    final statusColor = statusType == LocalizedDemoData.filterPaid ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.estate.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.estate.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment['property'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment['tenant'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(color: context.estate.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  demo.paymentStatusLabel(statusType),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.amountLabel, style: theme.textTheme.bodySmall?.copyWith(color: context.estate.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    '${payment['amount']} ${l10n.aed}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.dateLabel, style: theme.textTheme.bodySmall?.copyWith(color: context.estate.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    payment['date'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.estate.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
