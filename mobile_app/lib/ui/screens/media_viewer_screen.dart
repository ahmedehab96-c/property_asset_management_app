import 'package:flutter/material.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

/// عارض صورة ملء الشاشة (أصول أو روابط).
class MediaViewerScreen extends StatelessWidget {
  const MediaViewerScreen({
    super.key,
    this.assetPath,
    this.imageUrl,
    this.title,
  }) : assert(assetPath != null || imageUrl != null);

  final String? assetPath;
  final String? imageUrl;
  final String? title;

  static Future<void> show(
    BuildContext context, {
    String? assetPath,
    String? imageUrl,
    String? title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaViewerScreen(
          assetPath: assetPath,
          imageUrl: imageUrl,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      image = Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 64),
      );
    } else {
      image = Image.asset(
        assetPath ?? imageUrl ?? '',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 64),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: AppColors.white,
        title: title != null ? Text(title!) : null,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: image,
        ),
      ),
    );
  }
}
