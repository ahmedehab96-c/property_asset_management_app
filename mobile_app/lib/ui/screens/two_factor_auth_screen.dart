import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/viewmodels/auth_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class TwoFactorAuthScreen extends ConsumerStatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  ConsumerState<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends ConsumerState<TwoFactorAuthScreen> {
  bool _isEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final enabled = await ref.read(authProvider.notifier).loadTwoFactorEnabled();
    if (!mounted) return;
    setState(() {
      _isEnabled = enabled;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
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

    if (_loading) {
      return AppScaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.estate.textPrimary,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.twoFactorAuth,
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
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing * 2),
              Container(
                padding: EdgeInsets.all(spacing * 2),
                decoration: BoxDecoration(
                  color: context.estate.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: context.estate.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.enableTwoFactor,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          Text(
                            l10n.enableTwoFactorDesc,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.estate.textSecondary,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isEnabled,
                      onChanged: (value) async {
                        setState(() => _isEnabled = value);
                        final result =
                            await ref.read(authProvider.notifier).setTwoFactorEnabled(value);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.success
                                  ? (value ? l10n.twoFactorEnabledMsg : l10n.twoFactorDisabledMsg)
                                  : (result.message.isNotEmpty
                                      ? result.message
                                      : l10n.errorOccurred),
                            ),
                            backgroundColor: result.success ? Colors.green : Colors.red,
                          ),
                        );
                        if (!result.success) {
                          setState(() => _isEnabled = !value);
                        }
                      },
                      activeThumbColor: AppColors.accentGold,
                      inactiveThumbColor: AppColors.grey,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 3),
              Text(
                l10n.twoFactorHow,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              _InfoCard(
                icon: Icons.lock_outline,
                title: l10n.twoFactorExtraLayer,
                content: l10n.twoFactorExtraLayerDesc,
                spacing: spacing,
                borderRadius: borderRadius,
              ),
              SizedBox(height: spacing),
              _InfoCard(
                icon: Icons.security,
                title: l10n.twoFactorBreach,
                content: l10n.twoFactorBreachDesc,
                spacing: spacing,
                borderRadius: borderRadius,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final double spacing;
  final double borderRadius;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.spacing,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(spacing * 2),
      decoration: BoxDecoration(
        color: context.estate.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: context.estate.border,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Icon(icon, color: AppColors.accentGold, size: 24),
          ),
          SizedBox(width: spacing * 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing / 2),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.estate.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
