import 'package:property_asset_management_app/services/api_service.dart';

/// يحدد ما إذا كان التطبيق يعمل بحساب/توكن تجريبي محلي.
class DemoMode {
  DemoMode._();

  static bool isDemoToken(String? token) {
    if (token == null || token.isEmpty) return false;
    return token.startsWith('demo-');
  }

  static bool get isActive => isDemoToken(ApiService().token);
}
