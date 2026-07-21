import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/auth_service.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/ui/screens/login_screen.dart';
import 'package:property_asset_management_app/ui/screens/reset_password_screen.dart';
import 'package:property_asset_management_app/widgets/ambient_background.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;
  late AnimationController _iconController;
  late AnimationController _fieldsController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _icon3DAnimation;
  late Animation<double> _fieldsFadeAnimation;
  late Animation<Offset> _fieldsSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _backgroundAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Icon Animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    
    _iconRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
    );
    
    _icon3DAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOut),
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
    _iconController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fieldsController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _iconController.dispose();
    _fieldsController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
                ...List.generate(6, (index) {
                  final angle = _backgroundAnimation.value * 2 * math.pi + (index * 1.0);
                  final radius = 80.0 + (index * 15.0);
                  final x = screenWidth * (0.15 + (index % 2) * 0.35) + math.cos(angle) * radius;
                  final y = screenHeight * (0.2 + (index % 3) * 0.25) + math.sin(angle) * radius;
                  
                  return Positioned(
                    left: x,
                    top: y,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_backgroundAnimation.value * 2 * math.pi * (index % 2 == 0 ? 1 : -1))
                        ..scaleByDouble(0.4 + math.sin(_backgroundAnimation.value * 2 * math.pi + index) * 0.2, 0.4 + math.sin(_backgroundAnimation.value * 2 * math.pi + index) * 0.2, 0.4 + math.sin(_backgroundAnimation.value * 2 * math.pi + index) * 0.2, 1.0),
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentGold.withValues(alpha: 0.15),
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: ResponsiveHelper.adaptiveSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                          // Icon with 3D Animation
                          AnimatedBuilder(
                            animation: _iconController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _iconScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _iconRotationAnimation.value,
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(_icon3DAnimation.value * 0.5)
                                      ..rotateX(_icon3DAnimation.value * 0.2),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: ResponsiveHelper.value(context, mobile: 88.0, tablet: 96.0, desktop: 100.0),
                                      height: ResponsiveHelper.value(context, mobile: 88.0, tablet: 96.0, desktop: 100.0),
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.accentGold.withValues(alpha: 0.3),
                                            AppColors.accentGold.withValues(alpha: 0.1),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.accentGold,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accentGold.withValues(alpha: 0.5),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.lock_reset,
                                        size: 50,
                                        color: AppColors.accentGold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 32),
                          Text(
                            AppLocalizations.of(context).forgotPasswordTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).forgotPasswordSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.estate.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 48),

                                // Form Fields
                                Column(
                                  children: [
                          // Email Field with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: _GlassTextField(
                                controller: _emailController,
                                label: AppLocalizations.of(context).email,
                                hint: AppLocalizations.of(context).emailHint,
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
                              ),
                            ),
                          ),
                                    SizedBox(height: 24),

                          // Send Button with 3D Animation
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
                                  onPressed: _submitting
                                      ? null
                                      : () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    final l10n = AppLocalizations.of(context);
                                    final locale = Localizations.localeOf(context).languageCode;
                                    setState(() => _submitting = true);
                                    final result = await AuthService().forgotPassword(
                                      email: _emailController.text.trim(),
                                      locale: locale,
                                    );
                                    if (!context.mounted) return;
                                    setState(() => _submitting = false);
                                    if (result.success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result.message.isNotEmpty ? result.message : l10n.resetLinkSent),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      final token = result.data?['reset_token']?.toString();
                                      final email = _emailController.text.trim();
                                      if (token != null && token.isNotEmpty) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResetPasswordScreen(
                                              email: email,
                                              initialToken: token,
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResetPasswordScreen(
                                              email: email,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result.message.isNotEmpty ? result.message : l10n.forgotPasswordTitle),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
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
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primaryBlue,
                                          ),
                                        )
                                      : Text(
                                    AppLocalizations.of(context).resetPassword,
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

                          // Back to Login with Animation
                          FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context).backToLogin,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.accentGold,
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
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
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

