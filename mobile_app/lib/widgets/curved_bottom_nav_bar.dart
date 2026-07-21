import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

class CurvedNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CurvedNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// شريط تنقّل سفلي بقوس متحرك — للهاتف.
class CurvedBottomNavBar extends StatefulWidget {
  const CurvedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.height = 78,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CurvedNavItem> items;
  final double height;

  @override
  State<CurvedBottomNavBar> createState() => _CurvedBottomNavBarState();
}

class _CurvedBottomNavBarState extends State<CurvedBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;
  double _fromX = 0;
  double _toX = 0;

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _arcAnimation = CurvedAnimation(
      parent: _arcController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fromX = _tabCenterX(widget.currentIndex);
    _toX = _fromX;
  }

  @override
  void didUpdateWidget(CurvedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _fromX = _tabCenterX(oldWidget.currentIndex);
      _toX = _tabCenterX(widget.currentIndex);
      _arcController.forward(from: 0);
    }
  }

  double _tabCenterX(int index) {
    final count = widget.items.length;
    if (count == 0) return 0;
    return (index + 0.5) / count;
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;
    final isDark = context.isDarkTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: widget.height + bottomInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final highlightX = _arcController.isAnimating || _arcController.value > 0
              ? lerpDouble(_fromX, _toX, _arcAnimation.value)!
              : _tabCenterX(widget.currentIndex);

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: Size(width, widget.height + bottomInset),
                painter: _CurvedNavPainter(
                  highlightFraction: highlightX,
                  background: palette.surfaceGlass,
                  border: palette.border,
                  arcGlow: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.25),
                  isDark: isDark,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomInset,
                height: widget.height,
                child: Row(
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final selected = index == widget.currentIndex;
                    return Expanded(
                      child: _NavTab(
                        item: item,
                        selected: selected,
                        onTap: () => widget.onTap(index),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final CurvedNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.estate;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.accentGold.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, selected ? -10 : 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  size: selected ? 26 : 22,
                  color: selected ? AppColors.accentGold : palette.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 280),
                style: TextStyle(
                  fontSize: selected ? 11.5 : 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.accentGold : palette.textSecondary,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedNavPainter extends CustomPainter {
  _CurvedNavPainter({
    required this.highlightFraction,
    required this.background,
    required this.border,
    required this.arcGlow,
    required this.isDark,
  });

  final double highlightFraction;
  final Color background;
  final Color border;
  final Color arcGlow;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = highlightFraction * w;
    const arcHalf = 42.0;
    const topY = 14.0;
    const peakY = -6.0;

    final path = Path()
      ..moveTo(0, topY + 8)
      ..quadraticBezierTo(0, topY, 8, topY)
      ..lineTo((cx - arcHalf).clamp(8.0, w - 8), topY);

    if (cx - arcHalf > 8) {
      path.quadraticBezierTo(cx - arcHalf * 0.55, topY, cx - arcHalf * 0.35, topY - 2);
      path.quadraticBezierTo(cx, peakY, cx + arcHalf * 0.35, topY - 2);
      path.quadraticBezierTo(cx + arcHalf * 0.55, topY, cx + arcHalf, topY);
    }

    path
      ..lineTo(w - 8, topY)
      ..quadraticBezierTo(w, topY, w, topY + 8)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: isDark ? 0.35 : 0.12), 14, false);

    final fill = Paint()..color = background;
    canvas.drawPath(path, fill);

    final glow = Paint()
      ..color = arcGlow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(cx, topY - 4), 22, glow);

    final borderPaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);

    final arcStroke = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accentGold.withValues(alpha: 0.0),
          AppColors.accentGold.withValues(alpha: 0.85),
          AppColors.gold,
          AppColors.accentGold.withValues(alpha: 0.85),
          AppColors.accentGold.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(cx - arcHalf, peakY, arcHalf * 2, topY - peakY + 4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final arcPath = Path();
    if (cx - arcHalf > 8) {
      arcPath.moveTo(cx - arcHalf * 0.7, topY - 1);
      arcPath.quadraticBezierTo(cx, peakY + 2, cx + arcHalf * 0.7, topY - 1);
      canvas.drawPath(arcPath, arcStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedNavPainter oldDelegate) {
    return oldDelegate.highlightFraction != highlightFraction ||
        oldDelegate.background != background ||
        oldDelegate.isDark != isDark;
  }
}

/// انتقال الصفحة بمسار قوسي خفيف بين التبويبات.
class ArcTabTransition extends StatelessWidget {
  const ArcTabTransition({
    super.key,
    required this.animation,
    required this.child,
    required this.goingForward,
  });

  final Animation<double> animation;
  final Widget child;
  final bool goingForward;

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final dx = goingForward ? 0.22 : -0.22;

    return AnimatedBuilder(
      animation: curve,
      child: child,
      builder: (context, child) {
        final t = curve.value;
        final arcY = -0.06 * (1 - (2 * t - 1) * (2 * t - 1));
        final scale = 0.94 + t * 0.06;
        return Transform(
          transform: Matrix4.identity()
            ..translateByDouble((1 - t) * dx * MediaQuery.sizeOf(context).width, arcY * 80, 0, 1)
            ..scaleByDouble(scale, scale, 1, 1),
          alignment: Alignment.center,
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
