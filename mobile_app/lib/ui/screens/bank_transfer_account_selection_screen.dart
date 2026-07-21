import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';

class BankTransferAccountSelectionScreen extends StatefulWidget {
  const BankTransferAccountSelectionScreen({super.key});

  @override
  State<BankTransferAccountSelectionScreen> createState() =>
      _BankTransferAccountSelectionScreenState();
}

class _BankTransferAccountSelectionScreenState
    extends State<BankTransferAccountSelectionScreen> {
  String? _selectedAccountTypeKey;
  String? _selectedBankKey;
  final _accountNumberController = TextEditingController();
  final _ibanController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _ibanController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  LocalizedDemoData _demo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return LocalizedDemoData(l10n: l10n, isArabic: isArabic);
  }

  Future<void> _submitTransfer(AppLocalizations l10n) async {
    if (_selectedAccountTypeKey == null) {
      UiFeedback.showError(context, l10n.pleaseSelectAccountType);
      return;
    }
    if (_selectedAccountTypeKey == LocalizedDemoData.accountTypeOther &&
        (_selectedBankKey == null ||
            _accountNumberController.text.isEmpty ||
            _accountNameController.text.isEmpty)) {
      UiFeedback.showError(context, l10n.pleaseEnterRequiredTransferData);
      return;
    }

    setState(() => _submitting = true);
    var ok = true;
    if (!DemoMode.isActive) {
      try {
        final demo = _demo(context);
        await OwnerApiService().submitMobileRequest({
          'type': 'bank_transfer',
          'title': 'Bank transfer request',
          'description': l10n.transferRequestSent,
          'payload': {
            'account_type': _selectedAccountTypeKey,
            'bank': _selectedBankKey == null
                ? null
                : demo.transferBankLabel(_selectedBankKey!),
            'account_number': _accountNumberController.text.trim(),
            'iban': _ibanController.text.trim(),
            'account_name': _accountNameController.text.trim(),
          },
        });
      } catch (_) {
        ok = false;
      }
    }
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.pop(context);
      UiFeedback.showSuccess(context, l10n.transferRequestSent);
    } else {
      UiFeedback.showError(context, l10n.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demo = _demo(context);
    final accountTypes = demo.bankAccountTypes();
    final banks = demo.transferBanks();
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 24.0,
      tablet: 32.0,
      desktop: 40.0,
    );

    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.estate.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.bankTransferAccountSelection,
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
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.accountType,
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
                        const SizedBox(height: 16),
                        ...accountTypes.map((type) {
                          final key = type['key']!;
                          final label = type['label']!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAccountTypeKey = key;
                                  if (key == LocalizedDemoData.accountTypeCurrent) {
                                    _selectedBankKey = null;
                                    _accountNumberController.clear();
                                    _ibanController.clear();
                                    _accountNameController.clear();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedAccountTypeKey == key
                                      ? AppColors.accentGold.withValues(alpha: 0.3)
                                      : AppColors.primaryBlue.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedAccountTypeKey == key
                                        ? AppColors.accentGold
                                        : Colors.white.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _selectedAccountTypeKey == key
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: _selectedAccountTypeKey == key
                                          ? AppColors.accentGold
                                          : AppColors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      label,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: context.estate.textPrimary,
                                        fontWeight: _selectedAccountTypeKey == key
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 32),
                        if (_selectedAccountTypeKey ==
                            LocalizedDemoData.accountTypeOther) ...[
                          Text(
                            l10n.selectBank,
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
                          const SizedBox(height: 16),
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
                                    children: banks.map((bank) {
                                      return ListTile(
                                        title: Text(
                                          bank['label']!,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: context.estate.textPrimary,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedBankKey = bank['key'];
                                          });
                                          Navigator.pop(sheetContext);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedBankKey != null
                                        ? demo.transferBankLabel(_selectedBankKey!)
                                        : l10n.selectBank,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: _selectedBankKey != null
                                          ? AppColors.white
                                          : AppColors.grey,
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
                          const SizedBox(height: 24),
                          Text(
                            l10n.accountNumber,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _accountNumberController,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.enterAccountNumber,
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: context.estate.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.primaryBlue,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.ibanOptional,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _ibanController,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.ibanHint,
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: context.estate.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.primaryBlue,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.accountHolderName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _accountNameController,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.estate.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.enterAccountHolderName,
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: context.estate.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.primaryBlue,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitting
                                ? null
                                : () => _submitTransfer(l10n),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
                              foregroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                              l10n.confirm,
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
                ),
              ),
            ),
          ),
        ),
    );
  }
}
