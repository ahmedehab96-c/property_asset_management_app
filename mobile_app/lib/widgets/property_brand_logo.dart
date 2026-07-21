import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

/// شعار العلامة العقارية — أيقونة احترافية للمباني + هوية ذهبية.
class PropertyBrandLogo extends StatelessWidget {
  const PropertyBrandLogo({
    super.key,
    this.size = 120,
    this.showTagline = true,
    this.showAppName = false,
    this.compact = false,
  });

  final double size;
  final bool showTagline;
  final bool showAppName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final markSize = compact ? size * 0.88 : size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EstateBrandMark(size: markSize),
        if (showAppName) ...[
          SizedBox(height: size * 0.16),
          Text(
            l10n.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.estate.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        if (showTagline) ...[
          SizedBox(height: size * 0.1),
          Text(
            l10n.welcomeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// علامة دائرية فاخرة: مبنى + سقف منزل + لمسة ذهبية.
class _EstateBrandMark extends StatelessWidget {
  const _EstateBrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient glow
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: size * 0.12,
              sigmaY: size * 0.12,
            ),
            child: Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.28),
                    AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Outer ring
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  AppColors.accentGold.withValues(alpha: 0.95),
                  AppColors.primaryBlue.withValues(alpha: 0.85),
                  AppColors.teal.withValues(alpha: 0.9),
                  AppColors.accentGold.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.35, 0.7, 1.0],
                transform: const GradientRotation(-math.pi / 5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.18),
                  blurRadius: size * 0.18,
                  offset: Offset(0, size * 0.06),
                ),
              ],
            ),
            padding: EdgeInsets.all(size * 0.035),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF152536),
                          Color(0xFF0F1C28),
                          Color(0xFF1A3348),
                        ]
                      : const [
                          Color(0xFF1E3A5F),
                          Color(0xFF2563EB),
                          Color(0xFF1A4A6E),
                        ],
                ),
              ),
              child: CustomPaint(
                painter: const EstateEmblemPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// رسم الشعار الداخلي — منزل + برج عقاري + مفتاح خفيف.
class EstateEmblemPainter extends CustomPainter {
  const EstateEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.shortestSide;

    // Soft highlight arc
    final highlight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.85,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(Offset(cx, cy), s * 0.42, highlight);

    final gold = AppColors.accentGold;
    final goldBright = const Color(0xFFE8C547);
    final cream = Colors.white.withValues(alpha: 0.95);

    // Left tower
    final towerPaint = Paint()..color = cream.withValues(alpha: 0.88);
    final leftTower = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx - s * 0.16, cy + s * 0.04),
        width: s * 0.16,
        height: s * 0.38,
      ),
      Radius.circular(s * 0.02),
    );
    canvas.drawRRect(leftTower, towerPaint);

    // Center building (taller)
    final centerBuilding = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + s * 0.02),
        width: s * 0.2,
        height: s * 0.48,
      ),
      Radius.circular(s * 0.025),
    );
    canvas.drawRRect(centerBuilding, Paint()..color = cream);

    // Right wing / house body
    final rightWing = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx + s * 0.17, cy + s * 0.08),
        width: s * 0.18,
        height: s * 0.3,
      ),
      Radius.circular(s * 0.02),
    );
    canvas.drawRRect(rightWing, Paint()..color = cream.withValues(alpha: 0.9));

    // Roof over right wing (house cue)
    final roof = Path()
      ..moveTo(cx + s * 0.05, cy - s * 0.02)
      ..lineTo(cx + s * 0.17, cy - s * 0.16)
      ..lineTo(cx + s * 0.29, cy - s * 0.02)
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [goldBright, gold],
        ).createShader(Rect.fromLTWH(cx, cy - s * 0.18, s * 0.3, s * 0.18)),
    );

    // Center crown tip
    final tip = Path()
      ..moveTo(cx - s * 0.05, cy - s * 0.2)
      ..lineTo(cx, cy - s * 0.32)
      ..lineTo(cx + s * 0.05, cy - s * 0.2)
      ..close();
    canvas.drawPath(tip, Paint()..color = gold);

    // Windows — gold lights
    final winPaint = Paint()..color = gold.withValues(alpha: 0.92);
    void windows(Offset origin, int rows, int cols, double cell) {
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              origin.dx + c * cell * 1.7,
              origin.dy + r * cell * 1.55,
              cell * 0.7,
              cell * 0.85,
            ),
            Radius.circular(cell * 0.15),
          );
          canvas.drawRRect(rect, winPaint);
        }
      }
    }

    windows(Offset(cx - s * 0.205, cy - s * 0.06), 3, 1, s * 0.035);
    windows(Offset(cx - s * 0.055, cy - s * 0.12), 4, 2, s * 0.032);
    windows(Offset(cx + s * 0.115, cy + s * 0.0), 2, 2, s * 0.03);

    // Door (center base)
    final door = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + s * 0.18),
        width: s * 0.07,
        height: s * 0.1,
      ),
      Radius.circular(s * 0.015),
    );
    canvas.drawRRect(
      door,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [goldBright, gold.withValues(alpha: 0.85)],
        ).createShader(door.outerRect),
    );

    // Ground line
    canvas.drawLine(
      Offset(cx - s * 0.28, cy + s * 0.26),
      Offset(cx + s * 0.3, cy + s * 0.26),
      Paint()
        ..color = gold.withValues(alpha: 0.55)
        ..strokeWidth = s * 0.012
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// أفق مباني مبسّط — للخلفيات والعناصر الصغيرة.
class EstateSkylinePainter extends CustomPainter {
  const EstateSkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawBuilding({
      required double left,
      required double width,
      required double heightFactor,
      required Color fill,
      int windowRows = 3,
      int windowCols = 2,
    }) {
      final bh = h * heightFactor;
      final top = h - bh;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, bh),
        Radius.circular(width * 0.1),
      );
      canvas.drawRRect(rect, Paint()..color = fill);

      final winW = width / (windowCols * 2 + 1);
      final winH = bh / (windowRows * 2 + 1);
      final winPaint = Paint()..color = AppColors.accentGold.withValues(alpha: 0.8);
      for (var row = 0; row < windowRows; row++) {
        for (var col = 0; col < windowCols; col++) {
          final wx = left + winW + col * (winW * 2);
          final wy = top + winH + row * (winH * 2);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(wx, wy, winW, winH * 0.7),
              const Radius.circular(1.5),
            ),
            winPaint,
          );
        }
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(0, h - 2, w, 2),
      Paint()..color = AppColors.accentGold.withValues(alpha: 0.45),
    );

    drawBuilding(
      left: 0,
      width: w * 0.28,
      heightFactor: 0.62,
      fill: AppColors.navy,
      windowRows: 2,
      windowCols: 1,
    );
    drawBuilding(
      left: w * 0.31,
      width: w * 0.36,
      heightFactor: 0.92,
      fill: AppColors.primaryBlue,
      windowRows: 4,
      windowCols: 2,
    );
    drawBuilding(
      left: w * 0.7,
      width: w * 0.3,
      heightFactor: 0.72,
      fill: AppColors.violet,
      windowRows: 3,
      windowCols: 1,
    );

    final crown = Path()
      ..moveTo(w * 0.42, h * 0.1)
      ..lineTo(w * 0.49, h * 0.02)
      ..lineTo(w * 0.56, h * 0.1);
    canvas.drawPath(
      crown,
      Paint()
        ..color = AppColors.accentGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// شعار مصغّر للقوائم والأشرطة.
class PropertyBrandIcon extends StatelessWidget {
  const PropertyBrandIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _EstateBrandMark(size: size);
  }
}
