import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/viewmodels/maintenance_notifier.dart';
import 'package:property_asset_management_app/viewmodels/service_request_notifier.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';

class RepairRequestScreen extends ConsumerStatefulWidget {
  const RepairRequestScreen({super.key});

  @override
  ConsumerState<RepairRequestScreen> createState() => _RepairRequestScreenState();
}

class _RepairRequestScreenState extends ConsumerState<RepairRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedProblemType;
  final List<XFile> _selectedImages = [];
  bool _submitting = false;

  static const _serviceTypeKeys = [
    'plumbing',
    'electricity',
    'ac',
    'cleaning',
    'repair',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      ref.read(maintenanceProvider.notifier).load(l10n: l10n);
    });
  }

  List<Map<String, dynamic>> _getPreviousRequests(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ms = ref.read(maintenanceProvider);
    if (ms.requests.isNotEmpty) {
      return ms.requests
          .where((r) => r['statusType'] == 'in_progress')
          .take(5)
          .map((r) => {
                'id': r['id'],
                'title': r['title'],
                'orderNumber': r['orderNumber'],
                'status': r['status'],
                'statusType': r['statusType'],
                'icon': r['icon'] ?? Icons.build,
                'iconColor': r['iconColor'] ?? AppColors.accentGold,
              })
          .toList();
    }
    return [
      {
        "id": 1,
        "title": l10n.kitchenPlumbingProblem,
        "orderNumber": "#12034",
        "status": l10n.inProgress,
        "statusType": "in_progress",
        "icon": Icons.water_drop,
        "iconColor": AppColors.accentGold,
      },
    ];
  }

  List<String> _getProblemTypes(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.plumbingProblem,
      l10n.electricityProblem,
      l10n.acProblem,
      l10n.cleaningProblem,
      l10n.otherProblem,
    ];
  }

  Future<void> _pickImages(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("${l10n.errorOccurred}: ${l10n.errorSelectingImages} $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _serviceTypeForSelection(List<String> problemTypes) {
    if (_selectedProblemType == null) return null;
    final index = problemTypes.indexOf(_selectedProblemType!);
    if (index < 0 || index >= _serviceTypeKeys.length) return 'repair';
    return _serviceTypeKeys[index];
  }

  Future<void> _submitRequest() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedProblemType == null) {
      UiFeedback.showError(context, l10n.pleaseSelectProblemType);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final problemTypes = _getProblemTypes(context);
    final result = await ref.read(serviceRequestProvider.notifier).submit(
          serviceType: _serviceTypeForSelection(problemTypes) ?? 'repair',
          description: '${_selectedProblemType!}: ${_descriptionController.text.trim()}',
          priority: l10n.medium,
          imagePaths: _selectedImages.map((f) => f.path).toList(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      UiFeedback.showSuccess(
        context,
        result.fromDemo
            ? '${l10n.requestSubmittedSuccessfully} (${l10n.demoDataBanner})'
            : l10n.requestSubmittedSuccessfully,
      );
      Navigator.pop(context);
    } else {
      UiFeedback.showError(context, result.message ?? l10n.errorOccurred);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

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
    final previousRequests = _getPreviousRequests(context);
    final problemTypes = _getProblemTypes(context);

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
            Icons.notifications_none,
            color: context.estate.textPrimary,
            size: iconSize,
          ),
          onPressed: () {},
        ),
        title: Text(
          AppLocalizations.of(context).repairRequest,
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
              Icons.arrow_forward_ios,
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
        ],
      ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Submit New Request Card
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.submitNewRequest,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 2.5),

                      // Problem Type Selection
                      Text(
                        l10n.problemType,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.estate.textPrimary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 1.5),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: context.estate.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  ResponsiveHelper.getResponsiveBorderRadius(
                                    context,
                                    mobile: 20,
                                    tablet: 24,
                                    desktop: 28,
                                  ),
                                ),
                              ),
                            ),
                            builder: (context) => Container(
                              padding: padding,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: problemTypes.map((type) {
                                  return ListTile(
                                    title: Text(
                                      type,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: context.estate.textPrimary,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedProblemType = type;
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                            ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
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
                              Text(
                                _selectedProblemType ?? l10n.selectProblemType,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _selectedProblemType != null
                                      ? AppColors.white
                                      : AppColors.grey,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 14,
                                    tablet: 16,
                                    desktop: 18,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: context.estate.textSecondary,
                                size: iconSize,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 2.5),

                      // Problem Description
                      Text(
                        l10n.problemDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.estate.textPrimary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 1.5),
                      Container(
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
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: context.estate.textPrimary,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.problemDescriptionHint,
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: context.estate.textSecondary,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 13,
                                tablet: 14,
                                desktop: 15,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(
                              ResponsiveHelper.getResponsiveSpacing(
                                context,
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterProblemDescription;
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: spacing * 2.5),
                    ],
                  ),
                ),
              ),

              SizedBox(height: spacing * 2),

              // Attach Photos Section - Full Width
              Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding.left),
                      child: Text(
                        l10n.attachPhotos,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.estate.textPrimary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 1.5),
                    if (_selectedImages.isEmpty)
                      GestureDetector(
                        onTap: () => _pickImages(context),
                        child: Container(
                          width: double.infinity,
                          height: ResponsiveHelper.getResponsiveImageHeight(
                            context,
                            mobile: 150.0,
                            tablet: 180.0,
                            desktop: 200.0,
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
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppColors.accentGold,
                                size: ResponsiveHelper.getResponsiveIconSize(
                                  context,
                                  mobile: 40,
                                  tablet: 48,
                                  desktop: 56,
                                ),
                              ),
                              SizedBox(height: spacing),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: padding.left),
                                child: Text(
                                  l10n.clickToAttach,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: context.estate.textPrimary,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 13,
                                      tablet: 14,
                                      desktop: 15,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveImageHeight(
                          context,
                          mobile: 120.0,
                          tablet: 140.0,
                          desktop: 160.0,
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedImages.length) {
                              // Add more button
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: spacing,
                                  left: index == 0 ? 0 : spacing,
                                ),
                                child: GestureDetector(
                                  onTap: () => _pickImages(context),
                                  child: Container(
                                    width: ResponsiveHelper.getResponsiveImageHeight(
                                      context,
                                      mobile: 120.0,
                                      tablet: 140.0,
                                      desktop: 160.0,
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
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.accentGold,
                                      size: ResponsiveHelper.getResponsiveIconSize(
                                        context,
                                        mobile: 32,
                                        tablet: 36,
                                        desktop: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            // Image thumbnail
                            return Padding(
                              padding: EdgeInsets.only(
                                right: spacing,
                                left: index == 0 ? 0 : spacing,
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveHelper.getResponsiveBorderRadius(
                                        context,
                                        mobile: 12,
                                        tablet: 14,
                                        desktop: 16,
                                      ),
                                    ),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: ResponsiveHelper.getResponsiveImageHeight(
                                        context,
                                        mobile: 120.0,
                                        tablet: 140.0,
                                        desktop: 160.0,
                                      ),
                                      height: ResponsiveHelper.getResponsiveImageHeight(
                                        context,
                                        mobile: 120.0,
                                        tablet: 140.0,
                                        desktop: 160.0,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(spacing / 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: context.estate.textPrimary,
                                          size: ResponsiveHelper.getResponsiveIconSize(
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
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: spacing * 2),

              // Submit Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding.left),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveBorderRadius(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      l10n.submitRequest,
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
              ),

              SizedBox(height: spacing * 3),

              // Previous Requests Section
              Text(
                l10n.previousRequests,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),

              // Previous Requests List
              ...previousRequests.map((request) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  child: _PreviousRequestCard(request: request),
                );
              }),
            ],
          ),
          ),
        ),
    );
  }
}

class _PreviousRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const _PreviousRequestCard({required this.request});

  Color _getStatusColor() {
    switch (request["statusType"]) {
      case "in_progress":
        return AppColors.accentGold;
      case "completed":
        return Colors.green;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.estate.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveBorderRadius(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 14,
              ),
              vertical: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 6,
                tablet: 8,
                desktop: 10,
              ),
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveBorderRadius(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
            child: Text(
              request["status"],
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 11,
                  tablet: 12,
                  desktop: 13,
                ),
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
          // Request Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request["title"],
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
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 5,
                    desktop: 6,
                  ),
                ),
                Text(
                  "${AppLocalizations.of(context).orderNumber}: ${request["orderNumber"]}",
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
          // Icon
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
              color: context.estate.surface,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveBorderRadius(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
            child: Icon(
              request["icon"] as IconData,
              color: request["iconColor"] as Color,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}

