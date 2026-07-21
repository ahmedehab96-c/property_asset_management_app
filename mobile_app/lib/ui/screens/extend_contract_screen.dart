import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/repositories/contract_repository.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';

class ExtendContractScreen extends StatefulWidget {
  const ExtendContractScreen({super.key, this.contract});

  final Map<String, dynamic>? contract;

  @override
  State<ExtendContractScreen> createState() => _ExtendContractScreenState();
}

class _ExtendContractScreenState extends State<ExtendContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ContractRepository();
  DateTime? _newEndDate;
  final _notesController = TextEditingController();
  bool _submitting = false;

  int? get _contractId => (widget.contract?['id'] as num?)?.toInt();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _newEndDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentGold,
              onPrimary: AppColors.primaryBlue,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _newEndDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context);

    if (_newEndDate == null) {
      UiFeedback.showError(context, l10n.pleaseSelectEndDate);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final result = await _repository.extendContract(
      contractId: _contractId,
      newEndDate: _newEndDate!,
      notes: _notesController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      UiFeedback.showSuccess(
        context,
        result.fromDemo ? '${l10n.contractExtendedSuccess} (${l10n.demoDataBanner})' : l10n.contractExtendedSuccess,
      );
      Navigator.pop(context, true);
    } else {
      UiFeedback.showError(context, result.message ?? l10n.operationFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  l10n.extendContract,
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
                        l10n.newContractEndDate,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.estate.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.estate.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.accentGold),
                              const SizedBox(width: 12),
                              Text(
                                _newEndDate == null
                                    ? l10n.selectContractEndDate
                                    : _formatDate(_newEndDate!),
                                style: TextStyle(
                                  color: _newEndDate == null ? AppColors.grey : AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.additionalNotesOptional,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.estate.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 5,
                        style: TextStyle(color: context.estate.textPrimary),
                        decoration: InputDecoration(
                          hintText: l10n.extendContractNotesHint,
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
                        onPressed: _submitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                l10n.extendContract,
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
