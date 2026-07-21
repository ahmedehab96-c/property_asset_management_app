import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/viewmodels/service_request_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';

class ServiceRequestScreen extends ConsumerStatefulWidget {
  final String serviceType;
  final String serviceTitle;

  const ServiceRequestScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
  });

  @override
  ConsumerState<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends ConsumerState<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCleaningType;
  final List<XFile> _selectedImages = [];
  bool _submitting = false;

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

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _needsAppointment => widget.serviceType == "ac" || widget.serviceType == "cleaning";
  bool get _isCleaning => widget.serviceType == "cleaning";

  List<String> _priorityOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (widget.serviceType) {
      case "electricity":
        return [l10n.urgent, l10n.medium, l10n.normal];
      case "plumbing":
        return [l10n.high, l10n.medium, l10n.low];
      default:
        return [l10n.urgent, l10n.medium, l10n.normal];
    }
  }

  Color _getPriorityColor(String priority, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (priority == l10n.urgent || priority == l10n.high) {
      return Colors.red;
    } else if (priority == l10n.medium) {
      return AppColors.accentGold;
    } else {
      return Colors.green;
    }
  }

  String _getServiceTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (widget.serviceType) {
      case "electricity":
        return l10n.electricity;
      case "plumbing":
        return l10n.plumbing;
      case "cleaning":
        return l10n.cleaning;
      case "ac":
        return l10n.ac;
      case "maintenance":
        return l10n.newMaintenanceRequest;
      case "legal":
        return l10n.legalConsultation;
      case "engineering":
        return l10n.engineeringConsultation;
      default:
        return l10n.repairRequest;
    }
  }

  Future<void> _submitRequest() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPriority == null) {
      UiFeedback.showError(context, l10n.pleaseSelectPriorityLevel);
      return;
    }
    if (_isCleaning && _selectedCleaningType == null) {
      UiFeedback.showError(context, l10n.pleaseSelectCleaningType);
      return;
    }

    String? scheduledAt;
    if (_selectedDate != null) {
      final time = _selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        time.hour,
        time.minute,
      );
      scheduledAt = dt.toIso8601String();
    }

    setState(() => _submitting = true);
    final result = await ref.read(serviceRequestProvider.notifier).submit(
      serviceType: widget.serviceType,
      description: _descriptionController.text,
      priority: _selectedPriority,
      cleaningType: _selectedCleaningType,
      scheduledAt: scheduledAt,
      notes: _notesController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      UiFeedback.showSuccess(
        context,
        result.fromDemo
            ? '${_isCleaning ? l10n.requestConfirmed : l10n.requestSubmitted} (${l10n.demoDataBanner})'
            : (_isCleaning ? l10n.requestConfirmed : l10n.requestSubmitted),
      );
      Navigator.pop(context);
    } else {
      UiFeedback.showError(context, result.message ?? l10n.errorOccurred);
    }
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
                      final homeShellState = context.findAncestorStateOfType<HomeShellState>();
                      if (homeShellState != null) {
                        homeShellState.changeIndex(0);
                      }
                    }
                  },
        ),
        title: Text(
          _getServiceTitle(context),
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
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: Form(
            key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content with padding
                Padding(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Problem Description Section
                Text(
                  l10n.problemDescription,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                  ),
                ),
                ),
                SizedBox(height: spacing * 1.5),
                Container(
                  decoration: BoxDecoration(
                    color: context.estate.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                    ),
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: _isCleaning ? 3 : 5,
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
                      hintText: _isCleaning
                          ? l10n.problemDescriptionHint
                          : l10n.problemDetailsRequired,
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
                      if (!_isCleaning && (value == null || value.isEmpty)) {
                        return l10n.pleaseEnterProblemDescription;
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: spacing * 3),

                // Cleaning Type Selection (only for cleaning)
                if (_isCleaning) ...[
                  Text(
                    l10n.chooseCleaningType,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 1.5),
                  Row(
                    children: [
                      Expanded(
                        child: _CleaningTypeCard(
                          icon: Icons.cleaning_services,
                          title: l10n.deepCleaning,
                          isSelected: _selectedCleaningType == "deep",
                          onTap: () {
                    setState(() {
                              _selectedCleaningType = "deep";
                    });
                  },
                        ),
                      ),
                      SizedBox(width: spacing * 1.5),
                      Expanded(
                        child: _CleaningTypeCard(
                          icon: Icons.calendar_today,
                          title: l10n.periodicCleaning,
                          isSelected: _selectedCleaningType == "regular",
                          onTap: () {
                            setState(() {
                              _selectedCleaningType = "regular";
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 3),
                ],
                    ],
                  ),
                ),

                // Attach Photos Section - Full Width
                Padding(
                  padding: EdgeInsets.only(
                    left: padding.left,
                    right: padding.right,
                    bottom: spacing * 1.5,
                  ),
                  child: Text(
                    _isCleaning ? l10n.attachImagesOptional : l10n.attachImages,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                  ),
                ),
                // Image Attachment Section
                if (_selectedImages.isEmpty)
                  GestureDetector(
                    onTap: () => _pickImages(context),
                    child: Container(
                      height: ResponsiveHelper.getResponsiveImageHeight(
                        context,
                        mobile: 150.0,
                        tablet: 180.0,
                        desktop: 200.0,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.estate.surface.withValues(alpha: 0.6),
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
                          Text(
                            _isCleaning
                                ? l10n.clickToAddOrDragImages
                                : l10n.addProblemImages,
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
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                      color: context.estate.surface.withValues(alpha: 0.6),
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
                SizedBox(height: spacing * 3),

                // Rest of content with padding
                Padding(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                // Appointment Section (for AC and Cleaning)
                if (_needsAppointment) ...[
                  Text(
                    l10n.suitableAppointment,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 1.5),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeField(
                          label: l10n.chooseDay,
                          value: _selectedDate != null
                              ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                              : null,
                          icon: Icons.calendar_today,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              locale: Localizations.localeOf(context),
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.accentGold,
                                      onPrimary: AppColors.primaryBlue,
                                      surface: AppColors.white,
                                      onSurface: AppColors.primaryBlue,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: spacing * 1.5),
                      Expanded(
                        child: _DateTimeField(
                          label: l10n.chooseTime,
                          value: _selectedTime != null
                              ? "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
                              : null,
                          icon: Icons.access_time,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 3),
                ],

                // Additional Notes (for cleaning)
                if (_isCleaning) ...[
                  Text(
                    l10n.additionalNotes,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 1.5),
                  Container(
                    decoration: BoxDecoration(
                      color: context.estate.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                      ),
                    ),
                    child: TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: context.estate.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.notesOptional,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: context.estate.textSecondary,
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
                    ),
                  ),
                  SizedBox(height: spacing * 3),
                ],

                // Priority Level Section
                Text(
                  l10n.priorityLevel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                ),
                SizedBox(height: spacing * 1.5),
                ResponsiveHelper.isMobile(context)
                    ? Column(
                        children: _priorityOptions(context).map((priority) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: spacing),
                            child: _PriorityButton(
                              label: priority,
                              isSelected: _selectedPriority == priority,
                              color: _getPriorityColor(priority, context),
                              onTap: () {
                                setState(() {
                                  _selectedPriority = priority;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      )
                    : Builder(
                        builder: (context) {
                          final options = _priorityOptions(context);
                          return Row(
                            children: options.map((priority) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: options.indexOf(priority) <
                                            options.length - 1
                                        ? spacing
                                        : 0,
                                  ),
                                  child: _PriorityButton(
                                    label: priority,
                                    isSelected: _selectedPriority == priority,
                                    color: _getPriorityColor(priority, context),
                                    onTap: () {
                                      setState(() {
                                        _selectedPriority = priority;
                                      });
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                SizedBox(height: spacing * 4),

                // Submit Button
                SizedBox(
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
                    child: _submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : Text(
                      _isCleaning ? l10n.confirmRequest : l10n.submitRequest,
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
                SizedBox(height: spacing * 2),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    this.value,
    required this.icon,
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
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
          decoration: BoxDecoration(
          color: context.estate.textPrimary,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: value != null ? AppColors.primaryBlue : AppColors.grey,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
            ),
            Icon(
              icon,
              color: AppColors.accentGold,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
              ],
            ),
      ),
    );
  }
}

class _PriorityButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.cardDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
              ),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.5),
            width: ResponsiveHelper.isMobile(context) ? 1.5 : 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isSelected && color == AppColors.accentGold
                  ? AppColors.primaryBlue
                  : AppColors.white,
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
      ),
    );
  }
}

class _CleaningTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CleaningTypeCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
        child: Container(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsivePadding(
            context,
            mobile: 20.0,
            tablet: 24.0,
            desktop: 28.0,
          ).left,
        ),
          decoration: BoxDecoration(
          color: context.estate.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
            border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
            ),
          ),
        child: Column(
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
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accentGold.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.accentGold : AppColors.grey,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            Icon(
              icon,
              color: AppColors.accentGold,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 32,
                tablet: 36,
                desktop: 40,
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
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.estate.textPrimary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
          ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
