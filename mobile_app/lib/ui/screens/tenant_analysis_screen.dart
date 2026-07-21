import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

class TenantAnalysisScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? tenantData;

  const TenantAnalysisScreen({
    super.key,
    this.tenantData,
  });

  @override
  ConsumerState<TenantAnalysisScreen> createState() => _TenantAnalysisScreenState();
}

class _TenantAnalysisScreenState extends ConsumerState<TenantAnalysisScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final OwnerApiService _api = OwnerApiService();
  String _employmentKey = LocalizedDemoData.empGov;
  bool _hasPreviousRentals = true;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  Locale? _lastLocale;
  bool _didPrefill = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_lastLocale != locale) {
      _lastLocale = locale;
      _employmentKey = LocalizedDemoData.empGov;
    }
    if (!_didPrefill && widget.tenantData != null) {
      _didPrefill = true;
      final data = widget.tenantData!;
      _nameController.text =
          '${data['name'] ?? data['full_name'] ?? data['fullName'] ?? ''}';
      _phoneController.text = '${data['phone'] ?? data['mobile'] ?? ''}';
      final income = data['income'] ?? data['monthly_income'] ?? data['rent'];
      if (income != null) {
        _incomeController.text = '$income'.replaceAll(RegExp(r'[^0-9.]'), '');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis(LocalizedDemoData demo) async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    double? avgRent;
    var existingMatch = false;
    try {
      final analytics = await _api.getAnalyticsOverview();
      final props = (analytics?['properties_count'] as num?)?.toDouble() ?? 0;
      final revenue = (analytics?['monthly_revenue'] as num?)?.toDouble() ?? 0;
      if (props > 0 && revenue > 0) {
        avgRent = revenue / props;
      }

      final phone = _phoneController.text.trim();
      if (phone.isNotEmpty) {
        final tenants = await _api.getTenants();
        final digits = phone.replaceAll(RegExp(r'\D'), '');
        existingMatch = tenants.any((t) {
          final tPhone = '${t['phone'] ?? t['mobile'] ?? ''}'
              .replaceAll(RegExp(r'\D'), '');
          return tPhone.isNotEmpty &&
              (tPhone == digits ||
                  tPhone.endsWith(digits) ||
                  digits.endsWith(tPhone));
        });
      }
    } catch (_) {}

    final result = demo.tenantAnalysisResult(
      income: double.tryParse(_incomeController.text) ?? 0,
      employmentKey: _employmentKey,
      hasPreviousRentals: _hasPreviousRentals || existingMatch,
      portfolioAvgRent: avgRent,
      existingTenantMatch: existingMatch,
    );

    try {
      await _api.submitMobileRequest({
        'type': 'tenant_analysis',
        'title': 'Tenant risk analysis',
        'description': _nameController.text.trim().isEmpty
            ? 'Tenant analysis'
            : 'Tenant analysis: ${_nameController.text.trim()}',
        'payload': {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'income': double.tryParse(_incomeController.text) ?? 0,
          'employment': _employmentKey,
          'has_previous_rentals': _hasPreviousRentals,
          'risk_score': result['riskScore'],
          'portfolio_avg_rent': avgRent,
          'existing_tenant_match': existingMatch,
        },
      });
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _analysisResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final demo = LocalizedDemoData(l10n: l10n, isArabic: isArabic);
    final employmentOptions = demo.employmentOptions();

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
        title: Text(
          l10n.tenantAnalysis,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tenantData,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.estate.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InputField(
                      controller: _nameController,
                      label: l10n.fullName,
                      hint: l10n.enterFullName,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _phoneController,
                      label: l10n.phoneNumber,
                      hint: l10n.enterPhone,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _incomeController,
                      label: '${l10n.monthlyIncome} (${l10n.aed})',
                      hint: l10n.monthlyIncome,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.employmentStatus,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.estate.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: employmentOptions.map((option) {
                        final key = option['key']!;
                        final label = option['label']!;
                        final isSelected = _employmentKey == key;
                        return GestureDetector(
                          onTap: () => setState(() => _employmentKey = key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : context.estate.surfaceGlass,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentGold
                                    : context.estate.border,
                              ),
                            ),
                            child: Text(
                              label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : context.estate.textPrimary,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _hasPreviousRentals,
                          onChanged: (value) {
                            setState(() => _hasPreviousRentals = value ?? false);
                          },
                          activeColor: AppColors.accentGold,
                        ),
                        Expanded(
                          child: Text(
                            l10n.hasPreviousRentalRecord,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.estate.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isAnalyzing ? null : () => _runAnalysis(demo),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isAnalyzing
                            ? Text(
                                l10n.analyzing,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              )
                            : Text(
                                l10n.analyzeTenantAction,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_analysisResult != null && !_isAnalyzing) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.riskScore,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.estate.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: _analysisResult!['riskScore'] / 100,
                              strokeWidth: 12,
                              backgroundColor: AppColors.darkGrey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getRiskColor(_analysisResult!['riskScore']),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${_analysisResult!['riskScore']}',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getRiskColor(
                                    _analysisResult!['riskScore'],
                                  ),
                                ),
                              ),
                              Text(
                                _getRiskLabel(
                                  _analysisResult!['riskScore'],
                                  demo,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: context.estate.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.estate.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.analysisDetails,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.estate.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AnalysisDetailItem(
                        label: l10n.financialCapacity,
                        value: _analysisResult!['financialCapacity'],
                        score: _analysisResult!['financialScore'],
                      ),
                      const SizedBox(height: 12),
                      _AnalysisDetailItem(
                        label: l10n.employmentStability,
                        value: _analysisResult!['employmentStability'],
                        score: _analysisResult!['employmentScore'],
                      ),
                      const SizedBox(height: 12),
                      _AnalysisDetailItem(
                        label: l10n.previousRecord,
                        value: _analysisResult!['previousRecord'],
                        score: _analysisResult!['recordScore'],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getRiskColor(_analysisResult!['riskScore'])
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getRiskColor(_analysisResult!['riskScore'])
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _analysisResult!['riskScore'] < 50
                                ? Icons.warning_amber_rounded
                                : Icons.verified_user_outlined,
                            color: _getRiskColor(_analysisResult!['riskScore']),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.recommendationsTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.estate.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _analysisResult!['recommendation'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.estate.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(int score) {
    if (score < 50) return Colors.red;
    if (score < 70) return Colors.orange;
    return Colors.green;
  }

  String _getRiskLabel(int score, LocalizedDemoData demo) =>
      demo.riskLabel(score);
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.estate.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: context.estate.textSecondary,
              ),
              prefixIcon: Icon(icon, color: AppColors.accentGold),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final int score;

  const _AnalysisDetailItem({
    required this.label,
    required this.value,
    required this.score,
  });

  Color _getScoreColor() {
    if (score < 50) return Colors.red;
    if (score < 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.estate.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.estate.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scoreColor, width: 1),
            ),
            child: Text(
              '$score%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
