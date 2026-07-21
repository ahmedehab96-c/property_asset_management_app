import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../core/api/api_locale.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'demo_mode.dart';

/// خدمة المصادقة — تسجيل الدخول، التسجيل، نسيت/إعادة كلمة المرور. ترسل locale/language للباكند.
class AuthService {
  final ApiService _api = ApiService();

  Future<String> _loc([String? locale]) async {
    if (locale != null) return ApiLocale.forApp(locale);
    final prefs = await SharedPreferences.getInstance();
    return ApiLocale.forApp(prefs.getString('language_code'));
  }

  Future<void> _saveTokens(dynamic raw) async {
    if (raw == null) return;
    Map<String, dynamic>? payload;
    if (raw is Map<String, dynamic>) {
      payload = raw['token'] != null
          ? raw
          : (raw['data'] is Map)
              ? Map<String, dynamic>.from(raw['data'] as Map)
              : null;
    }
    final token = payload?['token'] as String?;
    if (token == null) return;
    await _api.setToken(token);
    final ref = payload?['refresh_token'] as String?;
    if (ref != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('refresh_token', ref);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    String? locale,
  }) async {
    try {
      final appLoc = await _loc(locale);
      final apiLoc = ApiLocale.forApi(appLoc);
      final res = await _api.post(ApiConfig.login, data: {
        'email': email,
        'password': password,
        'locale': apiLoc,
        'language': apiLoc,
      });
      final body = res.data;
      if (body is Map<String, dynamic>) {
        if (body['token'] != null) {
          await _saveTokens(body);
          return ApiResponse(
            success: true,
            message: (body['message'] ?? '').toString(),
            data: body,
          );
        }
        final out = ApiResponse<Map<String, dynamic>>.fromJson(
          body,
          (d) => d as Map<String, dynamic>,
        );
        if (out.success) await _saveTokens(out.data ?? body);
        return out;
      }
      return ApiResponse(success: false, message: 'Unexpected response');
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? userType,
    String? locale,
  }) async {
    try {
      final appLoc = await _loc(locale);
      final apiLoc = ApiLocale.forApi(appLoc);
      final res = await _api.post(ApiConfig.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'locale': apiLoc,
        'language': apiLoc,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (phone != null && phone.isNotEmpty) 'mobile': phone,
        if (phone != null && phone.isNotEmpty) 'phone_number': phone,
        'terms': 1,
        'user_type': ?userType,
      });
      final out = ApiResponse<Map<String, dynamic>>.fromJson(
        res.data,
        (d) => d as Map<String, dynamic>,
      );
      if (out.success) await _saveTokens(out.data ?? res.data);
      return out;
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _api.post(ApiConfig.logout);
    } catch (_) {}
    await _api.clearAuth();
    return ApiResponse(success: true, message: '');
  }

  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final res = await _api.get(ApiConfig.user);
      return ApiResponse<Map<String, dynamic>>.fromJson(res.data, (d) => d as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
    String? locale,
  }) async {
    try {
      final appLoc = await _loc(locale);
      final apiLoc = ApiLocale.forApi(appLoc);
      final res = await _api.post(ApiConfig.forgotPassword, data: {
        'email': email.trim(),
        'locale': apiLoc,
        'language': apiLoc,
      });
      return ApiResponse<Map<String, dynamic>>.fromJson(
        res.data,
        (d) => d is Map ? Map<String, dynamic>.from(d) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
    String? locale,
  }) async {
    try {
      final appLoc = await _loc(locale);
      final apiLoc = ApiLocale.forApi(appLoc);
      final res = await _api.post(ApiConfig.resetPassword, data: {
        'email': email.trim(),
        'token': token.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'locale': apiLoc,
        'language': apiLoc,
      });
      return ApiResponse<void>.fromJson(res.data, null);
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  Future<ApiResponse<void>> verifyEmail({required String token}) async {
    try {
      final res = await _api.post(ApiConfig.verifyEmail, data: {'token': token});
      return ApiResponse<void>.fromJson(res.data, null);
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  Future<ApiResponse<void>> resendVerification({String? locale}) async {
    if (DemoMode.isActive) {
      return ApiResponse(success: true, message: '');
    }
    try {
      final appLoc = await _loc(locale);
      final apiLoc = ApiLocale.forApi(appLoc);
      final res = await _api.post(ApiConfig.resendVerification, data: {
        'locale': apiLoc,
        'language': apiLoc,
      });
      return ApiResponse<void>.fromJson(res.data, null);
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (DemoMode.isActive) {
      return ApiResponse(success: true, message: '');
    }
    try {
      final res = await _api.post(ApiConfig.changePassword, data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      return ApiResponse<void>.fromJson(res.data, null);
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  static const _twoFactorKey = 'two_factor_enabled';

  Future<bool> getTwoFactorEnabled() async {
    if (!DemoMode.isActive) {
      try {
        final res = await getCurrentUser();
        final enabled = res.data?['two_factor_enabled'];
        if (enabled is bool) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_twoFactorKey, enabled);
          return enabled;
        }
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_twoFactorKey) ?? false;
  }

  Future<ApiResponse<void>> setTwoFactorEnabled(bool enabled) async {
    if (DemoMode.isActive) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_twoFactorKey, enabled);
      return ApiResponse(success: true, message: '');
    }
    try {
      final res = await _api.put(ApiConfig.twoFactor, data: {'enabled': enabled});
      final out = ApiResponse<void>.fromJson(res.data, null);
      if (out.success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_twoFactorKey, enabled);
      }
      return out;
    } catch (e) {
      return ApiResponse(success: false, message: _errMsg(e));
    }
  }

  static String _errMsg(dynamic e) {
    if (e is DioException && e.response?.data is Map) {
      final d = e.response!.data as Map;
      final err = d['error'];
      if (err is String && err.isNotEmpty) return err;
      final m = d['message'];
      if (m is String) return m;
      if (m is List && m.isNotEmpty) return m.first.toString();
      final errors = d['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final v = errors.values.first;
        if (v is List && v.isNotEmpty) return v.first.toString();
      }
    }
    return e.toString();
  }
}
