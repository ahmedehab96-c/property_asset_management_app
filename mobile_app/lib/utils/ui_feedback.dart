import 'package:flutter/material.dart';

/// رسائل موحّدة عبر SnackBar (بديل الحوارات للأخطاء البسيطة).
class UiFeedback {
  UiFeedback._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.red);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, null);
  }

  static void _show(BuildContext context, String message, Color? background) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
      ),
    );
  }
}
