import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/viewmodels/contract_detail_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/screens/contact_tenant_screen.dart';
import 'package:property_asset_management_app/ui/screens/cancel_contract_screen.dart';
import 'package:property_asset_management_app/ui/screens/extend_contract_screen.dart';
import 'package:property_asset_management_app/ui/screens/file_lawsuit_screen.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:url_launcher/url_launcher.dart';

class ContractDetailScreen extends ConsumerStatefulWidget {
  const ContractDetailScreen({super.key, required this.contract});

  final Map<String, dynamic> contract;

  @override
  ConsumerState<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends ConsumerState<ContractDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(contractDetailProvider.notifier).load(
          seed: widget.contract,
          l10n: l10n,
          isArabic: ref.read(isArabicProvider),
        );
  }

  Map<String, dynamic> get _data =>
      ref.watch(contractDetailProvider).detail ?? widget.contract;

  bool _hasTenant(Map<String, dynamic> data) {
    final name = data['tenantName']?.toString() ?? '';
    return name.isNotEmpty && name != '-';
  }

  Map<String, dynamic> _tenantPayload(Map<String, dynamic> data) => {
        'name': data['tenantName'],
        'phone': data['tenantPhone'],
        'email': data['tenantEmail'],
        'property': data['propertyName'],
      };

  Future<void> _openPdf() async {
    final l10n = AppLocalizations.of(context);
    final noPdfMessage = l10n.noDataAvailable;
    final data = _data;
    for (final key in ['contractPdf', 'contract_pdf', 'pdfUrl', 'pdf_url']) {
      final url = data[key]?.toString();
      if (url != null && url.trim().isNotEmpty) {
        final uri = Uri.tryParse(url.trim());
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }
    }
    if (!mounted) return;
    UiFeedback.showInfo(context, noPdfMessage);
  }

  void _renewContract() {
    Navigator.push(
      context,
      SlidePageRoute(page: ExtendContractScreen(contract: _data)),
    );
  }

  void _cancelContract() {
    Navigator.push(
      context,
      SlidePageRoute(page: CancelContractScreen(contract: _data)),
    );
  }

  void _fileLawsuit() {
    Navigator.push(
      context,
      SlidePageRoute(page: FileLawsuitScreen(contract: _data)),
    );
  }

  void _contactTenant() {
    if (!_hasTenant(_data)) {
      UiFeedback.showInfo(context, AppLocalizations.of(context).noDataAvailable);
      return;
    }
    Navigator.push(
      context,
      SlidePageRoute(page: ContactTenantScreen(tenant: _tenantPayload(_data))),
    );
  }

  Color _statusColor(String? statusType) {
    switch (statusType) {
      case 'active':
        return Colors.greenAccent;
      case 'expiring':
        return Colors.orange;
      case 'ended':
        return Colors.redAccent;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final cs = ref.watch(contractDetailProvider);
    final loading = cs.status == ViewStatus.loading && cs.detail == null;
    final fromDemo = cs.fromDemo;

    if (loading) {
      return AppScaffold(
        appBar: AppBar(title: Text(l10n.contractDetails)),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
      );
    }

    final data = _data;
    final statusType = data['statusType'] as String?;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(data['title'] as String? ?? l10n.contractDetails),
      ),
      body: RefreshIndicator(
        color: AppColors.accentGold,
        onRefresh: _load,
        child: ListView(
          padding: padding,
          children: [
            if (fromDemo) const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _statusColor(statusType).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor(statusType), width: 1.5),
                ),
                child: Text(
                  data['status'] as String? ?? '-',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _statusColor(statusType),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] as String? ?? l10n.contractDetails,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['propertyName'] as String? ?? '-',
                    style: theme.textTheme.bodyLarge?.copyWith(color: context.estate.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  _InfoRow(label: l10n.startDate, value: data['startDate'] as String? ?? '-'),
                  const SizedBox(height: 12),
                  _InfoRow(label: l10n.endDate, value: data['endDate'] as String? ?? '-'),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: l10n.monthlyRentAmount,
                    value: data['monthlyRentDisplay'] as String? ??
                        '${data['monthlyRent'] ?? '-'} ${l10n.aed}',
                    valueColor: AppColors.accentGold,
                    isBold: true,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: l10n.nextPayment, value: data['nextPayment'] as String? ?? '-'),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: l10n.remainingLabel,
                    value: data['remainingDisplay'] as String? ?? '-',
                    valueColor: AppColors.accentGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_hasTenant(data))
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tenantInformation,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: l10n.labelName, value: data['tenantName'] as String),
                    const SizedBox(height: 10),
                    _InfoRow(label: l10n.mobileNumber, value: data['tenantPhone'] as String? ?? '-'),
                    const SizedBox(height: 10),
                    _InfoRow(label: l10n.email, value: data['tenantEmail'] as String? ?? '-'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _contactTenant,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: Text(l10n.contactTenantTitle),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(l10n.viewPdf),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _renewContract,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.renewContract),
                  ),
                ),
              ],
            ),
            if (statusType != 'ended') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _fileLawsuit,
                      icon: const Icon(Icons.gavel),
                      label: Text(l10n.fileLawsuit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelContract,
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(l10n.cancelContract),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue.withValues(alpha: 0.7),
                AppColors.navy.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.estate.textSecondary)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor ?? AppColors.white,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}
