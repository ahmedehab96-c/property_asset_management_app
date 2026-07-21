import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/repositories/contract_repository.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';

class CancelContractScreen extends StatefulWidget {
  const CancelContractScreen({super.key, this.contract});

  final Map<String, dynamic>? contract;

  @override
  State<CancelContractScreen> createState() => _CancelContractScreenState();
}

class _CancelContractScreenState extends State<CancelContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ContractRepository();
  final _reasonController = TextEditingController();
  String? _selectedReasonKey;
  bool _submitting = false;

  int? get _contractId => (widget.contract?['id'] as num?)?.toInt();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  LocalizedDemoData _demo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return LocalizedDemoData(l10n: l10n, isArabic: isArabic);
  }

  Future<void> _confirmCancel() async {
    final l10n = AppLocalizations.of(context);

    if (_selectedReasonKey == null) {
      UiFeedback.showError(context, l10n.pleaseSelectCancelReason);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.estate.surface,
        title: Text(
          l10n.confirmCancelContractTitle,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        content: Text(
          l10n.cancelContractIrreversible,
          style: TextStyle(color: context.estate.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel, style: TextStyle(color: context.estate.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final result = await _repository.cancelContract(
      contractId: _contractId,
      reasonKey: _selectedReasonKey!,
      details: _reasonController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      UiFeedback.showSuccess(
        context,
        result.fromDemo ? '${l10n.contractCancelled} (${l10n.demoDataBanner})' : l10n.contractCancelled,
      );
      Navigator.pop(context, true);
    } else {
      UiFeedback.showError(context, result.message ?? l10n.operationFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demo = _demo(context);
    final reasons = demo.contractCancelReasons();
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    final fromDemo = _contractId == null;

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
                    size: iconSize,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      final homeShellState =
                          context.findAncestorStateOfType<HomeShellState>();
                      homeShellState?.changeIndex(0);
                    }
                  },
                ),
                title: Text(
                  l10n.cancelContract,
                  style: TextStyle(color: context.estate.textPrimary),
                ),
                centerTitle: true,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: 20.0,
                  tablet: 24.0,
                  desktop: 28.0,
                ).left,
              ),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      if (fromDemo) const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
                      if (widget.contract?['propertyName'] != null)
                        Text(
                          widget.contract!['propertyName'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.cancelReason,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.estate.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...reasons.map(
                        (reason) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RadioListTile<String>(
                            title: Text(
                              reason['label']!,
                              style: TextStyle(color: context.estate.textPrimary),
                            ),
                            // ignore: deprecated_member_use
                            value: reason['key']!,
                            // ignore: deprecated_member_use
                            groupValue: _selectedReasonKey,
                            // ignore: deprecated_member_use
                            onChanged: (value) => setState(() => _selectedReasonKey = value),
                            activeColor: AppColors.accentGold,
                            tileColor: AppColors.cardDark.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.additionalDetailsOptional,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.estate.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 5,
                        style: TextStyle(color: context.estate.textPrimary),
                        decoration: InputDecoration(
                          hintText: l10n.addAdditionalDetailsHint,
                          hintStyle: TextStyle(color: context.estate.textSecondary),
                          filled: true,
                          fillColor: AppColors.cardDark.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.accentGold, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _submitting ? null : _confirmCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                l10n.cancelContract,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
