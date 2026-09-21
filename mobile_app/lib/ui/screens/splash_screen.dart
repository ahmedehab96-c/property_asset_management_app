import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/ui/screens/login_screen.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/widgets/property_brand_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _progressController;
  late final AnimationController _loopController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _progressSectionFade;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _nameFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.32, 0.72, curve: Curves.easeOut),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.32, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _progressSectionFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _progressValue = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _startAnimation();
  }

  void _startAnimation() {
    _entranceController.forward();
    Future.delayed(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      try {
        await _progressController.forward().orCancel;
      } on TickerCanceled {
        return;
      }
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(_fadeScaleRoute(const LoginScreen()));
    });
  }

  Route<T> _fadeScaleRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 550),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logoSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 130.0,
      tablet: 150.0,
      desktop: 170.0,
    );
    final barWidth = ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 200,
      tablet: 240,
      desktop: 260,
    );

    return AppScaffold(
      showOrbs: true,
      showWatermark: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _OrbitingLogo(
              size: logoSize,
              fade: _logoFade,
              scale: _logoScale,
              loop: _loopController,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
            ),
            FadeTransition(
              opacity: _nameFade,
              child: SlideTransition(
                position: _nameSlide,
                child: Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.estate.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: logoSize * 0.1),
            FadeTransition(
              opacity: _taglineFade,
              child: SlideTransition(
                position: _taglineSlide,
                child: Text(
                  l10n.welcomeSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 48,
                tablet: 60,
                desktop: 72,
              ),
            ),
            FadeTransition(
              opacity: _progressSectionFade,
              child: _LoadingBar(
                width: barWidth,
                progress: _progressValue,
                shimmer: _loopController,
                label: l10n.splashLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شعار مركزي + حلقة ذهبية دوّارة + نبضة تنفّس ناعمة.
class _OrbitingLogo extends StatelessWidget {
  const _OrbitingLogo({
    required this.size,
    required this.fade,
    required this.scale,
    required this.loop,
  });

  final double size;
  final Animation<double> fade;
  final Animation<double> scale;
  final AnimationController loop;

  @override
  Widget build(BuildContext context) {
    final ringSize = size * 1.32;

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: AnimatedBuilder(
          animation: loop,
          builder: (context, child) {
            final breathe = 1.0 + 0.03 * math.sin(loop.value * 2 * math.pi * 2);
            return Transform.scale(
              scale: breathe,
              child: SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.square(ringSize),
                      painter: _OrbitRingPainter(
                        progress: loop.value,
                        color: AppColors.accentGold,
                      ),
                    ),
                    child!,
                  ],
                ),
              ),
            );
          },
          child: PropertyBrandLogo(
            size: size,
            showAppName: false,
            showTagline: false,
          ),
        ),
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  const _OrbitRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - size.shortestSide * 0.02;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.02
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.85),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6, 0.82, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// شريط تحميل متدرّج بلمعة متحركة، يعكس تقدّم التهيئة الفعلي.
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.width,
    required this.progress,
    required this.shimmer,
    required this.label,
  });

  final double width;
  final Animation<double> progress;
  final Animation<double> shimmer;
  final String label;

  @override
  Widget build(BuildContext context) {
    final trackColor = context.estate.textSecondary.withValues(alpha: 0.16);

    return SizedBox(
      width: width,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 5,
              color: trackColor,
              child: AnimatedBuilder(
                animation: Listenable.merge([progress, shimmer]),
                builder: (context, _) {
                  return FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: progress.value.clamp(0.0, 1.0),
                    child: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (rect) {
                        final dx = (shimmer.value * 3) - 1;
                        return LinearGradient(
                          begin: Alignment(dx - 0.4, 0),
                          end: Alignment(dx + 0.4, 0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ).createShader(rect);
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentGold,
                              Color(0xFFE8C547),
                              AppColors.accentGold,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.estate.textSecondary,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
    );
  }
}
