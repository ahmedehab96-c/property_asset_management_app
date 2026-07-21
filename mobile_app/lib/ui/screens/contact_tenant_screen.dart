import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/contact_actions.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class ContactTenantScreen extends StatelessWidget {
  final Map<String, dynamic> tenant;

  const ContactTenantScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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

    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
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
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: context.estate.textPrimary,
                    size: iconSize,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  l10n.contactTenantTitle,
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
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              children: [
                SizedBox(height: spacing * 2.5),
                // Profile Picture
                Container(
                  width: ResponsiveHelper.isMobile(context) ? 100 : 120,
                  height: ResponsiveHelper.isMobile(context) ? 100 : 120,
                  decoration: BoxDecoration(
                    color: context.estate.surface.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: ResponsiveHelper.isMobile(context) ? 50 : 60,
                    color: context.estate.textPrimary,
                  ),
                ),
              SizedBox(height: spacing * 2.5),
              // Tenant Name
              Text(
                tenant["name"] ?? l10n.name,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.estate.textPrimary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),
              ),
              SizedBox(height: spacing),
              // Tenant Role
              Text(
                l10n.contactTenantOf(tenant["property"] ?? "—"),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: context.estate.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
              SizedBox(height: spacing * 5),

              // Contact Information Card
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: context.estate.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: ResponsiveHelper.isMobile(context) ? 1 : 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Phone Number
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                l10n.phoneNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context.estate.textPrimary,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 13,
                                    tablet: 14,
                                    desktop: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing / 2),
                              Text(
                                tenant["phone"] ?? "+971 50 123 4567",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.estate.textPrimary,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 18,
                                    tablet: 20,
                                    desktop: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: spacing * 2),
                        Icon(
                          Icons.phone,
                          color: AppColors.accentGold,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 3),
                    Divider(
                      color: AppColors.darkGrey,
                      thickness: 1,
                    ),
                    SizedBox(height: spacing * 3),
                    // Email Address
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                l10n.emailLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context.estate.textPrimary,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 13,
                                    tablet: 14,
                                    desktop: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing / 2),
                              Text(
                                tenant["email"] ?? "a.alamri@email.com",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.estate.textPrimary,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 18,
                                    desktop: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: spacing * 2),
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.accentGold,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 4),

              // WhatsApp Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await ContactActions.openWhatsApp(tenant['phone']?.toString());
                    if (!ok && context.mounted) {
                      ContactActions.showLaunchFailed(context, l10n.errorOccurred);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp green
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        l10n.contactViaWhatsapp,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.estate.textPrimary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing * 1.5),
                      // WhatsApp icon - using chat_bubble_outlined as closest match
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                          color: context.estate.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await ContactActions.openEmail(tenant['email']?.toString());
                    if (!ok && context.mounted) {
                      ContactActions.showLaunchFailed(context, l10n.errorOccurred);
                    }
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: Text(l10n.contactViaEmail),
                ),
              ),
              SizedBox(height: spacing * 2),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await ContactActions.openSms(tenant['phone']?.toString());
                    if (!ok && context.mounted) {
                      ContactActions.showLaunchFailed(context, l10n.errorOccurred);
                    }
                  },
                  icon: const Icon(Icons.sms_outlined),
                  label: Text(l10n.contactViaSms),
                ),
              ),
              SizedBox(height: spacing * 2),

              // Call Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await ContactActions.openPhone(tenant['phone']?.toString());
                    if (!ok && context.mounted) {
                      ContactActions.showLaunchFailed(context, l10n.errorOccurred);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        l10n.phoneCall,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing * 1.5),
                      Icon(
                        Icons.phone,
                        size: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing * 2.5),
            ],
          ),
        ),
      ),
    );
  }
}

