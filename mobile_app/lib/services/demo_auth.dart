import 'package:property_asset_management_app/services/api_service.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';

/// دخول تجريبي محلي — للتجربة بدون اتصال كامل بالباكند.
class DemoAuth {
  DemoAuth._();

  static const ownerEmail = 'demo@demo.com';
  static const ownerPassword = 'password';
  static const adminEmail = 'admin@demo.com';
  static const adminPassword = 'password';

  static const ownerNameAr = 'مستخدم تجريبي';
  static const ownerNameEn = 'Demo User';
  static const adminNameAr = 'مدير تجريبي';
  static const adminNameEn = 'Demo Admin';

  static bool matchesOwner(String email, String password) =>
      email.trim().toLowerCase() == ownerEmail &&
      password == ownerPassword;

  static bool matchesAdmin(String email, String password) =>
      email.trim().toLowerCase() == adminEmail &&
      password == adminPassword;

  static Future<void> signInAsOwner({String locale = 'ar'}) async {
    await ApiService().setToken('demo-owner-token');
    final profile = UserProfileService();
    await profile.cacheDemoUser(
      id: 9001,
      name: locale == 'ar' ? ownerNameAr : ownerNameEn,
      email: ownerEmail,
      phone: '0500000001',
    );
  }

  static Future<void> signInAsAdmin({String locale = 'ar'}) async {
    await ApiService().setToken('demo-admin-token');
    final profile = UserProfileService();
    await profile.cacheDemoUser(
      id: 9002,
      name: locale == 'ar' ? adminNameAr : adminNameEn,
      email: adminEmail,
      phone: '0500000002',
    );
  }
}
