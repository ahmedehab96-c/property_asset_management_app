import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/theme/app_gradients.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/property_brand_logo.dart';

/// خلفية موحّدة: تدرج غني + هالات ضوئية ناعمة + أفق شعار شفاف.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    this.showOrbs = true,
    this.showWatermark = true,
    this.child,
  });

  final bool showOrbs;
  final bool showWatermark;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppGradients.pageDecorationFor(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showOrbs) _AmbientOrbs(palette: context.estate),
          const _SoftVignette(),
          if (showWatermark) const _BrandWatermark(),
          ?child,
        ],
      ),
    );
  }
}

class _SoftVignette extends StatelessWidget {
  const _SoftVignette();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkTheme;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.15,
            colors: [
              Colors.transparent,
              (isDark ? Colors.black : const Color(0xFF0F172A))
                  .withValues(alpha: isDark ? 0.28 : 0.06),
            ],
            stops: const [0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

class _AmbientOrbs extends StatelessWidget {
  const _AmbientOrbs({required this.palette});

  final EstateColors palette;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(top: -h * 0.14, right: -w * 0.2, child: _orb(palette.orbSky, w * 0.62, blur: 88)),
          Positioned(bottom: -h * 0.04, left: -w * 0.26, child: _orb(palette.orbGarden, w * 0.72, blur: 96)),
          Positioned(top: h * 0.06, left: w * 0.02, child: _orb(palette.orbGold, w * 0.32, blur: 64)),
          Positioned(bottom: h * 0.26, right: -w * 0.1, child: _orb(palette.orbBrick, w * 0.42, blur: 74)),
          Positioned(
            top: h * 0.38,
            left: w * 0.32,
            child: _orb(palette.orbSky.withValues(alpha: 0.45), w * 0.26, blur: 58),
          ),
          Positioned(
            top: h * 0.22,
            right: w * 0.18,
            child: _orb(palette.orbGarden.withValues(alpha: 0.4), w * 0.2, blur: 52),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color color, double size, {double blur = 72}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.4),
              color.withValues(alpha: 0.12),
              Colors.transparent,
            ],
            stops: const [0.0, 0.28, 0.58, 1.0],
          ),
        ),
      ),
    );
  }
}

class _BrandWatermark extends StatelessWidget {
  const _BrandWatermark();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = context.isDarkTheme;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: size.width * 1.2,
          height: size.height * 0.42,
          child: Opacity(
            opacity: isDark ? 0.09 : 0.055,
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: CustomPaint(
                painter: const EstateSkylinePainter(),
                size: Size(size.width * 1.2, size.height * 0.42),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
