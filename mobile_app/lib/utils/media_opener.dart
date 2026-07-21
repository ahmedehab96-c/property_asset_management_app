import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/ui/screens/media_viewer_screen.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:url_launcher/url_launcher.dart';

/// فتح صور/فيديو من الشاشات.
class MediaOpener {
  MediaOpener._();

  static Future<void> openImage(
    BuildContext context, {
    required String source,
    String? title,
  }) async {
    if (source.isEmpty) {
      UiFeedback.showInfo(context, AppLocalizations.of(context).noDataAvailable);
      return;
    }
    await MediaViewerScreen.show(
      context,
      assetPath: source.startsWith('http') ? null : source,
      imageUrl: source.startsWith('http') ? source : null,
      title: title,
    );
  }

  static Future<void> openVideo(
    BuildContext context, {
    String? url,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (url == null || url.isEmpty) {
      UiFeedback.showInfo(context, l10n.noDataAvailable);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    UiFeedback.showInfo(context, l10n.noDataAvailable);
  }
}
