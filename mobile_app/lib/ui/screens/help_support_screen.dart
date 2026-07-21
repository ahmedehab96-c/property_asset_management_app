import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  List<Map<String, dynamic>> _getFaqs(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {
        "question": l10n.faqQuestion1,
        "answer": l10n.faqAnswer1,
      },
      {
        "question": l10n.faqQuestion2,
        "answer": l10n.faqAnswer2,
      },
      {
        "question": l10n.faqQuestion3,
        "answer": l10n.faqAnswer3,
      },
      {
        "question": l10n.faqQuestion4,
        "answer": l10n.faqAnswer4,
      },
    ];
  }

  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
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
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary, size: iconSize),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).helpSupport,
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
              // Contact Section
              Text(
                AppLocalizations.of(context).contactUs,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              _ContactCard(
                icon: Icons.phone,
                title: AppLocalizations.of(context).callUs,
                subtitle: "+966 50 123 4567",
                onTap: () async {
                  final uri = Uri.parse("tel:+966501234567");
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                borderRadius: borderRadius,
                spacing: spacing,
              ),
              SizedBox(height: spacing),
              _ContactCard(
                icon: Icons.email,
                title: AppLocalizations.of(context).emailLabel,
                subtitle: "support@example.com",
                onTap: () async {
                  final uri = Uri.parse("mailto:support@example.com");
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                borderRadius: borderRadius,
                spacing: spacing,
              ),
              SizedBox(height: spacing),
              _ContactCard(
                icon: Icons.chat_bubble_outline,
                title: AppLocalizations.of(context).liveChat,
                subtitle: AppLocalizations.of(context).liveChatSubtitle,
                onTap: () {
                  UiFeedback.showInfo(
                    context,
                    AppLocalizations.of(context).liveChatComingSoon,
                  );
                },
                borderRadius: borderRadius,
                spacing: spacing,
              ),
              SizedBox(height: spacing * 3),

              // FAQ Section
              Text(
                AppLocalizations.of(context).faq,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              ..._getFaqs(context).asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                final isExpanded = _expandedIndex == index;
                return Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded ? -1 : index;
                      });
                    },
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Container(
                      padding: EdgeInsets.all(spacing * 2),
                      decoration: BoxDecoration(
                        color: context.estate.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq["question"],
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 15,
                                      tablet: 17,
                                      desktop: 19,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.accentGold,
                                size: iconSize,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            SizedBox(height: spacing),
                            Divider(color: context.estate.textSecondary.withValues(alpha: 0.3)),
                            SizedBox(height: spacing),
                            Text(
                              faq["answer"],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: context.estate.textSecondary,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double borderRadius;
  final double spacing;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.borderRadius,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.all(spacing * 2),
        decoration: BoxDecoration(
          color: context.estate.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(spacing * 1.5),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(borderRadius / 1.5),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.estate.textSecondary,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 13,
                        tablet: 14,
                        desktop: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.accentGold,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

