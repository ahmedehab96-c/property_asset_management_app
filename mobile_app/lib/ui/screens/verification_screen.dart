import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/viewmodels/auth_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/widgets/ambient_background.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _iconController.dispose();
    _fieldsController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40),
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
                                    width: 100,
                                    height: 100,
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
                                      Icons.security,
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
                          AppLocalizations.of(context).verification,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).verificationSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.estate.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "example@email.com",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 48),

                              // OTP Fields
                              Column(
                                children: [
                        // OTP Input Fields with Animation
                        SlideTransition(
                          position: _fieldsSlideAnimation,
                          child: FadeTransition(
                            opacity: _fieldsFadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(6, (index) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(milliseconds: 300 + (index * 100)),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Transform(
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(value * 0.2)
                                        ..scaleByDouble(value, value, value, 1.0),
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 50,
                                        height: 60,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
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
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                            color: Colors.white.withValues(alpha: 0.2),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.accentGold.withValues(alpha: 0.3 * value),
                                                    blurRadius: 10 * value,
                                                    spreadRadius: 2 * value,
                                                  ),
                                                ],
                                              ),
                                              child: TextField(
                                                controller: _controllers[index],
                                                focusNode: _focusNodes[index],
                                                textAlign: TextAlign.center,
                                                keyboardType: TextInputType.number,
                                                maxLength: 1,
                                                style: theme.textTheme.headlineMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.accentGold,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                ],
                                                decoration: const InputDecoration(
                                                  counterText: "",
                                                  border: InputBorder.none,
                                                ),
                                                onChanged: (value) => _onCodeChanged(index, value),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        ),
                                  SizedBox(height: 24),

                        // Resend Code with Animation
                        SlideTransition(
                          position: _fieldsSlideAnimation,
                          child: FadeTransition(
                            opacity: _fieldsFadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${AppLocalizations.of(context).didntReceiveCode} ",
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: _submitting
                                      ? null
                                      : () async {
                                          final locale =
                                              Localizations.localeOf(context).languageCode;
                                          final result = await ref
                                              .read(authProvider.notifier)
                                              .resendVerification(locale: locale);
                                          if (!context.mounted) return;
                                          UiFeedback.showSuccess(
                                            context,
                                            result.message.isNotEmpty
                                                ? result.message
                                                : AppLocalizations.of(context).resendCode,
                                          );
                                        },
                                  child: Text(
                                    AppLocalizations.of(context).resendCode,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                                  SizedBox(height: 24),

                        // Verify Button with 3D Animation
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
                                        final code =
                                            _controllers.map((c) => c.text).join();
                                        if (code.length != 6) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(context).codeRequired,
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        setState(() => _submitting = true);
                                        final result = await ref
                                            .read(authProvider.notifier)
                                            .verifyEmailCode(code);
                                        if (!context.mounted) return;
                                        setState(() => _submitting = false);
                                        if (result.success) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const HomeShell(),
                                            ),
                                          );
                                        } else {
                                          UiFeedback.showError(
                                            context,
                                            result.message.isNotEmpty
                                                ? result.message
                                                : AppLocalizations.of(context).errorOccurred,
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
                                child: Text(
                                  AppLocalizations.of(context).verify,
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
                            ],
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

