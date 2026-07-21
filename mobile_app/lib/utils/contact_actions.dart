import 'package:flutter/material.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:url_launcher/url_launcher.dart';

/// إجراءات تواصل موحّدة (واتساب، اتصال، بريد، رسائل).
class ContactActions {
  ContactActions._();

  static String normalizePhone(String? phone) {
    final digits = (phone ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return '+971501234567';
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('00')) return '+${digits.substring(2)}';
    if (digits.startsWith('0')) return '+971${digits.substring(1)}';
    if (digits.length == 9 && digits.startsWith('5')) return '+971$digits';
    return '+$digits';
  }

  static String phoneDigits(String? phone) =>
      normalizePhone(phone).replaceAll(RegExp(r'[^0-9]'), '');

  static Future<bool> openWhatsApp(String? phone, {String? message}) async {
    final digits = phoneDigits(phone);
    final text = message != null ? Uri.encodeComponent(message) : '';
    final uri = Uri.parse('https://wa.me/$digits${text.isNotEmpty ? '?text=$text' : ''}');
    return _launch(uri);
  }

  static Future<bool> openPhone(String? phone) async {
    return _launch(Uri.parse('tel:${normalizePhone(phone)}'));
  }

  static Future<bool> openEmail(String? email, {String? subject, String? body}) async {
    final addr = (email ?? '').trim();
    if (addr.isEmpty) return false;
    final params = <String, String>{};
    if (subject != null && subject.isNotEmpty) params['subject'] = subject;
    if (body != null && body.isNotEmpty) params['body'] = body;
    final uri = Uri(scheme: 'mailto', path: addr, queryParameters: params.isEmpty ? null : params);
    return _launch(uri);
  }

  static Future<bool> openSms(String? phone, {String? body}) async {
    final digits = phoneDigits(phone);
    final uri = Uri(
      scheme: 'sms',
      path: digits,
      queryParameters: body != null && body.isNotEmpty ? {'body': body} : null,
    );
    return _launch(uri);
  }

  static Future<bool> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static void showLaunchFailed(BuildContext context, String message) {
    UiFeedback.showError(context, message);
  }
}
