import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// ملف المستخدم المحفوظ محلياً للعرض السريع.
class CachedUserProfile {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String address;

  const CachedUserProfile({
    this.id,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
  });

  bool get hasData => name.isNotEmpty || email.isNotEmpty;
}

/// تحميل وتحديث بيانات المستخدم من API مع تخزين محلي.
class UserProfileService {
  static const _idKey = 'user_profile_id';
  static const _nameKey = 'user_profile_name';
  static const _emailKey = 'user_profile_email';
  static const _phoneKey = 'user_profile_phone';
  static const _addressKey = 'user_profile_address';

  final AuthService _auth = AuthService();
  final ApiService _api = ApiService();

  static String _field(Map<String, dynamic> map, String camel, [String? snake]) {
    final s = snake ?? camel.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    );
    final value = map[camel] ?? map[s];
    return value?.toString() ?? '';
  }

  static Map<String, dynamic> _unwrapUser(Map<String, dynamic>? data) {
    if (data == null) return {};
    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }
    return data;
  }

  Future<CachedUserProfile> getCached() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_idKey);
    return CachedUserProfile(
      id: id,
      name: prefs.getString(_nameKey) ?? '',
      email: prefs.getString(_emailKey) ?? '',
      phone: prefs.getString(_phoneKey) ?? '',
      address: prefs.getString(_addressKey) ?? '',
    );
  }

  Future<void> _cache(CachedUserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    if (profile.id != null) await prefs.setInt(_idKey, profile.id!);
    await prefs.setString(_nameKey, profile.name);
    await prefs.setString(_emailKey, profile.email);
    await prefs.setString(_phoneKey, profile.phone);
    await prefs.setString(_addressKey, profile.address);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_addressKey);
  }

  Future<void> cacheDemoUser({
    required int id,
    required String name,
    required String email,
    String phone = '',
    String address = '',
  }) async {
    await _cache(CachedUserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
    ));
  }

  CachedUserProfile _fromMap(Map<String, dynamic> user) {
    final idRaw = user['id'];
    return CachedUserProfile(
      id: idRaw is int ? idRaw : int.tryParse('$idRaw'),
      name: _field(user, 'name', 'full_name'),
      email: _field(user, 'email'),
      phone: _field(user, 'phone', 'mobile'),
      address: _field(user, 'address'),
    );
  }

  Future<CachedUserProfile> load({bool refresh = true}) async {
    if (!refresh) {
      final cached = await getCached();
      if (cached.hasData) return cached;
    }

    if (!_api.isAuthenticated) return getCached();

    final response = await _auth.getCurrentUser();
    if (!response.success || response.data == null) {
      return getCached();
    }

    final profile = _fromMap(_unwrapUser(response.data));
    await _cache(profile);
    return profile;
  }

  Future<ApiResponse<void>> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final cached = await getCached();
    final userId = cached.id;
    if (userId == null) {
      return ApiResponse(success: false, message: 'User ID not available');
    }

    try {
      final res = await _api.put(
        ApiConfig.userProfile(userId),
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'mobile': phone,
          'address': address,
        },
      );
      final out = ApiResponse<void>.fromJson(res.data as Map<String, dynamic>, null);
      if (out.success) {
        await _cache(CachedUserProfile(
          id: userId,
          name: name,
          email: email,
          phone: phone,
          address: address,
        ));
      }
      return out;
    } catch (e) {
      await _cache(CachedUserProfile(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        address: address,
      ));
      return ApiResponse(success: true, message: '');
    }
  }
}
