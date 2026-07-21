import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/profile_image_store.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class ChangeProfilePictureScreen extends StatefulWidget {
  const ChangeProfilePictureScreen({super.key});

  @override
  State<ChangeProfilePictureScreen> createState() => _ChangeProfilePictureScreenState();
}

class _ChangeProfilePictureScreenState extends State<ChangeProfilePictureScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final path = await ProfileImageStore.getPath();
    if (path == null || !mounted) return;
    final file = File(path);
    if (!await file.exists()) {
      await ProfileImageStore.clear();
      return;
    }
    setState(() => _selectedImage = file);
  }

  Future<void> _saveImage() async {
    if (_selectedImage == null) return;
    await ProfileImageStore.savePath(_selectedImage!.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).imageSaved),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).imageSelected),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppLocalizations.of(context).errorOccurred}: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).imageCaptured),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppLocalizations.of(context).errorOccurred}: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage() async {
    await ProfileImageStore.clear();
    setState(() {
      _selectedImage = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).imageDeleted),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    final spacing = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
    final theme = Theme.of(context);

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
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: spacing * 2),
              decoration: BoxDecoration(
                color: context.estate.textSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.accentGold, size: 28),
              title: Text(
                AppLocalizations.of(context).chooseFromGallery,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: context.estate.textPrimary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            SizedBox(height: spacing),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.accentGold, size: 28),
              title: Text(
                AppLocalizations.of(context).takePhoto,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: context.estate.textPrimary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            SizedBox(height: spacing * 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary, size: iconSize),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).changeProfilePicture,
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
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            children: [
              SizedBox(height: spacing * 4),
              // Profile Picture Preview
              GestureDetector(
                onTap: _showImageSourceBottomSheet,
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.navy,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.accentGold,
                          width: 4,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 75,
                              color: AppColors.accentGold,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(spacing * 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: AppColors.primaryBlue,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 3),
              // Hint Text
              Text(
                AppLocalizations.of(context).tapToChange,
                style: TextStyle(
                  color: context.estate.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
              SizedBox(height: spacing * 3),
              // Delete Option (only if image is selected)
              if (_selectedImage != null) ...[
                _OptionCard(
                  icon: Icons.delete,
                  title: AppLocalizations.of(context).deleteCurrentImage,
                  onTap: _deleteImage,
                  isDestructive: true,
                  borderRadius: borderRadius,
                  spacing: spacing,
                ),
                SizedBox(height: spacing * 2),
              ],
              // Save Button
              if (_selectedImage != null) ...[
                SizedBox(height: spacing * 3),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: spacing * 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).saveImage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final double borderRadius;
  final double spacing;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    required this.borderRadius,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.all(spacing * 2),
        decoration: BoxDecoration(
          color: context.estate.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.accentGold,
              size: 28,
            ),
            SizedBox(width: spacing * 2),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDestructive ? Colors.red : AppColors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.estate.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

