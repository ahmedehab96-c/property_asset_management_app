import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/viewmodels/auth_notifier.dart';
import 'package:property_asset_management_app/widgets/ambient_background.dart';
import 'package:property_asset_management_app/widgets/auth_language_switcher.dart';
import 'package:property_asset_management_app/widgets/auth_login_loader.dart';
import 'package:property_asset_management_app/widgets/property_brand_logo.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/ui/screens/forgot_password_screen.dart';
import 'package:property_asset_management_app/ui/screens/sign_up_screen.dart';
import 'package:property_asset_management_app/services/demo_auth.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.successScreen});

  /// بعد نجاح الدخول — افتراضي HomeShell؛ للأدمن استخدم AdminShell.
  final Widget? successScreen;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  late AnimationController _titleController;
  late AnimationController _fieldsController;
  late AnimationController _buttonController;
  
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _title3DAnimation;
  late Animation<double> _fieldsFadeAnimation;
  late Animation<Offset> _fieldsSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  
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
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _titleController.dispose();
    _fieldsController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  bool get _isAdminEntry => widget.successScreen != null;

  Future<void> _handleDemoLogin(BuildContext context, AppLocalizations l10n) async {
    final locale = Localizations.localeOf(context).languageCode;
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);
    final ok = await ref.read(authProvider.notifier).demoLogin(
          locale: locale,
          adminEntry: _isAdminEntry,
        );
    if (!mounted) return;
    if (ok) {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => widget.successScreen ?? const HomeShell(),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      if (!context.mounted) return;
      UiFeedback.showError(context, l10n.errorOccurred);
    }
  }

  void _fillDemoCredentials() {
    if (_isAdminEntry) {
      _emailController.text = DemoAuth.adminEmail;
      _passwordController.text = DemoAuth.adminPassword;
    } else {
      _emailController.text = DemoAuth.ownerEmail;
      _passwordController.text = DemoAuth.ownerPassword;
    }
  }

  Future<void> _handleLogin(BuildContext context, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final locale = Localizations.localeOf(context).languageCode;
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);
    final ok = await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
          locale: locale,
          adminEntry: _isAdminEntry,
        );
    if (!mounted) return;
    if (ok) {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => widget.successScreen ?? const HomeShell(),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      if (!context.mounted) return;
      final msg = ref.read(authProvider).errorMessage;
      UiFeedback.showError(
        context,
        msg != null && msg.isNotEmpty ? msg : l10n.errorOccurred,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AmbientBackground(
        child: Stack(
          children: [
            SafeArea(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.estate.surfaceGlass.withValues(alpha: 0.55),
                          context.estate.surfaceGlassLight.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.pageInsets(context),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
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
                          SizedBox(height: 16),
                          const AuthLanguageSwitcher(),
                          SizedBox(height: 24),
                          // Logo/Title Section with 3D Animation
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
                                          l10n.login,
                                          style: theme.textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          l10n.loginSubtitle,
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
                          SizedBox(height: 20),

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
                          SizedBox(height: 12),

                          // Forgot Password with Animation
                          SlideTransition(
                            position: _fieldsSlideAnimation,
                            child: FadeTransition(
                              opacity: _fieldsFadeAnimation,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                                    SizedBox(height: 24),

                          // Login Button with 3D Animation
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
                                  onPressed: _isLoading ? null : () => _handleLogin(context, l10n),
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
                                  child: Text(l10n.login, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                                    ),
                                  ],
                          ),

                          SizedBox(height: 16),

                          // Demo login
                          FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.estate.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: context.estate.border),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _isAdminEntry ? l10n.demoAdminAccount : l10n.demoAppAccount,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: context.estate.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isAdminEntry
                                        ? '${DemoAuth.adminEmail}  •  ${DemoAuth.adminPassword}'
                                        : '${DemoAuth.ownerEmail}  •  ${DemoAuth.ownerPassword}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _isLoading ? null : _fillDemoCredentials,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: context.estate.textPrimary,
                                            side: BorderSide(color: context.estate.border),
                                          ),
                                          child: Text(l10n.fillDemo),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: OutlinedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => _handleDemoLogin(context, l10n),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.navy,
                                            backgroundColor: AppColors.accentGold.withValues(alpha: 0.25),
                                            side: const BorderSide(color: AppColors.accentGold),
                                          ),
                                          child: Text(
                                            l10n.demoLogin,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Sign Up Link with Animation
                          FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.noAccount,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    l10n.createAccount,
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
            if (_isLoading)
              Positioned.fill(
                child: AuthLoginLoader(message: l10n.signingIn),
              ),
          ],
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

