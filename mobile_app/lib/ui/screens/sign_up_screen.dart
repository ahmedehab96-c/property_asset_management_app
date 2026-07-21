import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/ui/screens/login_screen.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/viewmodels/auth_notifier.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/widgets/ambient_background.dart';
import 'package:property_asset_management_app/widgets/property_brand_logo.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'tenant'; // 'tenant' or 'owner'
  bool _isLoading = false;
  
  late AnimationController _titleController;
  late AnimationController _fieldsController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _title3DAnimation;
  late Animation<double> _fieldsFadeAnimation;
  late Animation<Offset> _fieldsSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _backgroundAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Title Animation
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    
    _title3DAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    
    // Fields Animation
    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fieldsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fieldsController, curve: Curves.easeOut),
    );
    
    _fieldsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fieldsController, curve: Curves.easeOutCubic),
    );
    
    // Button Animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );
    
    // Background Animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    
    // Start animations
    _startAnimations();
  }
  
  void _startAnimations() async {
    _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fieldsController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonController.forward();
  }

  Future<void> _handleRegister(BuildContext context, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final res = await ref.read(authProvider.notifier).register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        userType: _selectedUserType,
        locale: locale,
      );
      if (!context.mounted) return;
      if (res.success) {
        final hasToken = res.data != null &&
            (res.data!['token'] != null || (res.data!['data'] as Map?)?['token'] != null);
        UiFeedback.showSuccess(
          context,
          hasToken ? l10n.welcome : 'تم إنشاء الحساب. سجّل الدخول الآن.',
        );
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => hasToken ? const HomeShell() : const LoginScreen(),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        if (!context.mounted) return;
        UiFeedback.showError(
          context,
          res.message.isNotEmpty ? res.message : l10n.errorOccurred,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      UiFeedback.showError(context, l10n.errorOccurred);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _titleController.dispose();
    _fieldsController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.estate.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AmbientBackground(
        child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(8, (index) {
                  final angle = _backgroundAnimation.value * 2 * math.pi + (index * 0.8);
                  final radius = 100.0 + (index * 20.0);
                  final x = screenWidth * (0.1 + (index % 3) * 0.3) + math.cos(angle) * radius;
                  final y = screenHeight * (0.1 + (index % 2) * 0.4) + math.sin(angle) * radius;
                  
                  return Positioned(
                    left: x,
                    top: y,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_backgroundAnimation.value * 2 * math.pi * (index % 2 == 0 ? 1 : -1))
                        ..scaleByDouble(0.5 + math.sin(_backgroundAnimation.value * 2 * math.pi + index) * 0.3, 0.5 + math.sin(_backgroundAnimation.value * 2 * math.pi + index) * 0.3, 0.5 + math.sin(_backgroundAnimation.value * 2 * math.pi + index) * 0.3, 1.0),
                      alignment: Alignment.center,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentGold.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Full Screen Glass Card
                SafeArea(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
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
          padding: ResponsiveHelper.pageInsets(context),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.isMobile(context)
                    ? double.infinity
                    : 480,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                SizedBox(height: 20),
                          // Title Section with 3D Animation
                          SlideTransition(
                            position: _titleSlideAnimation,
                            child: FadeTransition(
                              opacity: _titleFadeAnimation,
                              child: AnimatedBuilder(
                                animation: _title3DAnimation,
                                builder: (context, child) {
                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(_title3DAnimation.value * 0.2)
                                      ..rotateX(_title3DAnimation.value * 0.1),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        PropertyBrandLogo(
                                          size: ResponsiveHelper.value(
                                            context,
                                            mobile: 132,
                                            tablet: 120,
                                            desktop: 110,
                                          ),
                                          showTagline: false,
                                          showAppName: true,
                                        ),
                                        SizedBox(height: 20),
                Text(
                                          AppLocalizations.of(context).signUp,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                                          AppLocalizations.of(context).signUpSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.estate.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
                SizedBox(height: 32),

                                // Form Fields
                                Column(
                                  children: [
                          // Name Field with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: _GlassTextField(
                  controller: _nameController,
                                label: l10n.name,
                                hint: l10n.nameHint,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                                    return l10n.nameRequired;
                    }
                    return null;
                  },
                              ),
                            ),
                ),
                SizedBox(height: 16),

                          // Email Field with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: _GlassTextField(
                  controller: _emailController,
                                label: l10n.email,
                                hint: l10n.emailHint,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                                    return l10n.emailRequired;
                    }
                    if (!value.contains('@')) {
                                    return l10n.emailInvalid;
                    }
                    return null;
                  },
                              ),
                            ),
                ),
                SizedBox(height: 16),

                          // Phone Field with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: _GlassTextField(
                  controller: _phoneController,
                  label: AppLocalizations.of(context).phoneNumber,
                  hint: "05xxxxxxxx",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterPhoneNumber;
                    }
                    return null;
                  },
                              ),
                            ),
                ),
                SizedBox(height: 16),

                          // National ID Field with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: _GlassTextField(
                  controller: _nationalIdController,
                  label: l10n.nationalId,
                  hint: l10n.nationalIdHint,
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.nationalIdRequired;
                    }
                    return null;
                  },
                              ),
                            ),
                ),
                SizedBox(height: 16),

                          // User Type Selection with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.cardSemiTransparent,
                                          context.estate.surfaceGlass,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline, color: AppColors.accentGold),
                                            SizedBox(width: 12),
                                            Text(
                                              l10n.userType,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _UserTypeOption(
                                                title: l10n.userTypeTenant,
                                                icon: Icons.home_outlined,
                                                isSelected: _selectedUserType == 'tenant',
                                                onTap: () {
                                                  setState(() {
                                                    _selectedUserType = 'tenant';
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: _UserTypeOption(
                                                title: l10n.userTypeOwner,
                                                icon: Icons.business_outlined,
                                                isSelected: _selectedUserType == 'owner',
                                                onTap: () {
                                                  setState(() {
                                                    _selectedUserType = 'owner';
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
                SizedBox(height: 16),

                          // Permissions Info with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.cardSemiTransparent,
                                          context.estate.surfaceGlass,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline, color: AppColors.accentGold),
                                            SizedBox(width: 12),
                                            Text(
                                              l10n.permissionsInfo,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: context.estate.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          _selectedUserType == 'tenant'
                                              ? l10n.tenantPermissions
                                              : l10n.ownerPermissions,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            color: AppColors.accentGold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          _selectedUserType == 'tenant'
                                              ? l10n.tenantPermissionsList
                                              : l10n.ownerPermissionsList,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: context.estate.textSecondary,
                                            height: 1.6,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentGold.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColors.accentGold.withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.note_outlined, color: AppColors.accentGold, size: 20),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  l10n.registrationNote,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: context.estate.textPrimary,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
                SizedBox(height: 16),

                          // Password Field with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: _GlassTextField(
                  controller: _passwordController,
                                label: l10n.password,
                                hint: l10n.passwordHint,
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: context.estate.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                                    return l10n.passwordRequired;
                    }
                    if (value.length < 6) {
                                    return l10n.passwordMinLength;
                    }
                    return null;
                  },
                              ),
                            ),
                ),
                SizedBox(height: 16),

                          // Confirm Password Field with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: _GlassTextField(
                  controller: _confirmPasswordController,
                                label: l10n.confirmPassword,
                                hint: l10n.confirmPasswordHint,
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: context.estate.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                                    return l10n.confirmPasswordRequired;
                    }
                    if (value != _passwordController.text) {
                                    return l10n.passwordsNotMatch;
                    }
                    return null;
                  },
                              ),
                            ),
                ),
                                    SizedBox(height: 24),

                          // Sign Up Button with 3D Animation
                          FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(_buttonScaleAnimation.value * 0.05),
                                alignment: Alignment.center,
                                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleRegister(context, l10n),
                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentGold,
                                    foregroundColor: AppColors.primaryBlue,
                                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                                              minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                                    elevation: 8,
                                    shadowColor: AppColors.accentGold.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                                      ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))
                                      : Text(
                                    l10n.signUp,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                                    ),
                                  ],
                ),
                SizedBox(height: 24),

                          // Login Link with Animation
                          FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                                  l10n.alreadyHaveAccount,
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                                    l10n.login,
                        style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
        ),
                ),
              ],
            ),
          );
        },
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
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardSemiTransparent,
                context.estate.surfaceGlass,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: context.estate.textSecondary,
              ),
              prefixIcon: Icon(icon, color: AppColors.accentGold),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: context.estate.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentGold.withValues(alpha: 0.3),
                    AppColors.accentGold.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accentGold : AppColors.grey,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.accentGold : AppColors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

