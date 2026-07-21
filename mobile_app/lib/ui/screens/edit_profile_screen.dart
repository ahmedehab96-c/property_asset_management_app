import 'dart:io';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/services/profile_image_store.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';
import 'package:property_asset_management_app/ui/screens/change_profile_picture_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final UserProfileService _profileService = UserProfileService();

  String? _profileImagePath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.load();
    final imagePath = await ProfileImageStore.getPath();
    if (!mounted) return;
    setState(() {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _addressController.text = profile.address;
      _profileImagePath = imagePath;
      _loading = false;
    });
  }

  Future<void> _openChangeProfilePicture() async {
    await Navigator.push(
      context,
      SlidePageRoute(
        page: const ChangeProfilePictureScreen(),
        direction: AxisDirection.left,
      ),
    );
    final imagePath = await ProfileImageStore.getPath();
    if (!mounted) return;
    setState(() => _profileImagePath = imagePath);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final result = await _profileService.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success || result.message.isEmpty
              ? AppLocalizations.of(context).changesSaved
              : result.message,
        ),
        backgroundColor: result.success || result.message.isEmpty
            ? Colors.green
            : Colors.orange,
      ),
    );

    if (result.success || result.message.isEmpty) {
      Navigator.pop(context);
    }
  }

  Widget _buildAvatar() {
    final imagePath = _profileImagePath;
    if (imagePath != null && File(imagePath).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(imagePath),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }
    return Icon(
      Icons.person,
      size: 60,
      color: AppColors.accentGold,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context).editProfile,
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
        child: _loading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.accentGold),
              )
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              children: [
                SizedBox(height: spacing * 2),
                GestureDetector(
                  onTap: _openChangeProfilePicture,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
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
                        child: _buildAvatar(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(spacing),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.primaryBlue,
                            size: iconSize * 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing * 3),

                _GlassTextField(
                  controller: _nameController,
                  label: AppLocalizations.of(context).fullName,
                  hint: AppLocalizations.of(context).enterFullName,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).nameRequired;
                    }
                    return null;
                  },
                  borderRadius: borderRadius,
                  spacing: spacing,
                ),
                SizedBox(height: spacing * 2),

                _GlassTextField(
                  controller: _emailController,
                  label: AppLocalizations.of(context).email,
                  hint: "example@email.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).emailRequired;
                      }
                      if (!value.contains('@')) {
                      return AppLocalizations.of(context).emailInvalid;
                    }
                    return null;
                  },
                  borderRadius: borderRadius,
                  spacing: spacing,
                ),
                SizedBox(height: spacing * 2),

                _GlassTextField(
                  controller: _phoneController,
                  label: AppLocalizations.of(context).phoneNumber,
                  hint: AppLocalizations.of(context).enterPhone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  borderRadius: borderRadius,
                  spacing: spacing,
                ),
                SizedBox(height: spacing * 2),

                _GlassTextField(
                  controller: _addressController,
                  label: AppLocalizations.of(context).address,
                  hint: AppLocalizations.of(context).enterAddress,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  borderRadius: borderRadius,
                  spacing: spacing,
                ),
                SizedBox(height: spacing * 4),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: spacing * 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : Text(
                      AppLocalizations.of(context).saveChanges,
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

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final double borderRadius;
  final double spacing;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    required this.borderRadius,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardDark.withValues(alpha: 0.8),
              AppColors.navy.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(color: context.estate.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(color: context.estate.textSecondary.withValues(alpha: 0.8)),
            hintStyle: TextStyle(color: context.estate.textSecondary.withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, color: AppColors.accentGold),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: spacing * 2,
              vertical: spacing * 2,
            ),
          ),
        ),
      ),
    );
  }
}
