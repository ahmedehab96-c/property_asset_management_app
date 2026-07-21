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
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );
    _startAnimation();
  }

  void _startAnimation() async {
    _fadeController.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      mobile: 130.0,
      tablet: 150.0,
      desktop: 170.0,
    );

    return AppScaffold(
      showOrbs: false,
      showWatermark: false,
      body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PropertyBrandLogo(
                    size: logoSize,
                    showAppName: true,
                    showTagline: true,
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobile: 48,
                      tablet: 60,
                      desktop: 72,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).login,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.estate.textSecondary,
                          letterSpacing: 1,
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
