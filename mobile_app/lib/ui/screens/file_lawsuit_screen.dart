import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/data/localized_demo_data.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/repositories/lawsuit_repository.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';

class FileLawsuitScreen extends StatefulWidget {
  const FileLawsuitScreen({super.key, this.contract});

  final Map<String, dynamic>? contract;

  @override
  State<FileLawsuitScreen> createState() => _FileLawsuitScreenState();
}

class _FileLawsuitScreenState extends State<FileLawsuitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _repository = LawsuitRepository();
  String? _selectedTypeKey;
  bool _submitting = false;

  int? get _contractId => (widget.contract?['id'] as num?)?.toInt();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  LocalizedDemoData _demo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return LocalizedDemoData(l10n: l10n, isArabic: isArabic);
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context);

    if (_selectedTypeKey == null) {
      UiFeedback.showError(context, l10n.pleaseSelectLawsuitType);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final result = await _repository.fileLawsuit(
      contractId: _contractId,
      typeKey: _selectedTypeKey!,
      description: _descriptionController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      UiFeedback.showSuccess(
        context,
        result.fromDemo
            ? '${l10n.lawsuitFiledSuccess} (${l10n.demoDataBanner})'
            : l10n.lawsuitFiledSuccess,
      );
      Navigator.pop(context);
    } else {
      UiFeedback.showError(context, result.message ?? l10n.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lawsuitTypes = _demo(context).lawsuitTypes();
    final fromDemo = _contractId == null;
    final contract = widget.contract;
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
                      if (homeShellState != null) {
                        homeShellState.changeIndex(0);
                      }
                    }
                  },
                ),
                title: Text(
                  l10n.fileLawsuit,
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
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            mobile: 20,
                            tablet: 30,
                            desktop: 40,
                          ),
                        ),
                        if (fromDemo)
                          const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
                        if (contract != null &&
                            (contract['property'] != null ||
                                contract['tenant'] != null)) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: context.estate.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (contract['property'] != null)
                                  Text(
                                    contract['property'].toString(),
                                    style: TextStyle(
                                      color: context.estate.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (contract['tenant'] != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${l10n.tenantLabel}${contract['tenant']}',
                                    style: TextStyle(
                                      color: context.estate.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        Text(
                          l10n.lawsuitType,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: context.estate.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                        ),
                        ...lawsuitTypes.map(
                          (type) => Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                mobile: 8,
                                tablet: 10,
                                desktop: 12,
                              ),
                            ),
                            child: RadioListTile<String>(
                              title: Text(
                                type['label']!,
                                style:
                                    TextStyle(color: context.estate.textPrimary),
                              ),
                              // ignore: deprecated_member_use
                              value: type['key']!,
                              // ignore: deprecated_member_use
                              groupValue: _selectedTypeKey,
                              // ignore: deprecated_member_use
                              onChanged: (value) {
                                setState(() {
                                  _selectedTypeKey = value;
                                });
                              },
                              activeColor: AppColors.accentGold,
                              tileColor:
                                  AppColors.cardDark.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            mobile: 24,
                            tablet: 30,
                            desktop: 36,
                          ),
                        ),
                        Text(
                          l10n.lawsuitDescription,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: context.estate.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 8,
                          style: TextStyle(color: context.estate.textPrimary),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterLawsuitDescription;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: l10n.lawsuitDescriptionHint,
                            hintStyle:
                                TextStyle(color: context.estate.textSecondary),
                            filled: true,
                            fillColor: AppColors.cardDark.withValues(alpha: 0.5),
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
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            mobile: 40,
                            tablet: 50,
                            desktop: 60,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _submitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                            l10n.submitLawsuit,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                              fontWeight: FontWeight.bold,
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
