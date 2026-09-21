import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../core/api/api_locale.dart';

/// API Service
/// This service handles all API calls to Laravel backend
/// Ready for integration - just update the base URL in .env file
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  /// Initialize the API service
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.getHeaders(null),
    ));

    // Load saved token
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    
    if (_token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_token';
    }

    // Add interceptors for error handling and token refresh
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to all requests
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        // لغة التطبيق حتى يرجع الباكند الرسائل (تسجيل الدخول، التسجيل، التحقق) مترجمة
        final prefs = await SharedPreferences.getInstance();
        final lang = ApiLocale.forApi(prefs.getString('language_code') ?? 'ar');
        options.headers['Accept-Language'] = lang;
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - Token expired
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $_token';
            final response = await _dio.request(
              opts.path,
              options: Options(method: opts.method),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );
            return handler.resolve(response);
          } else {
            // Refresh failed, clear token and redirect to login
            await clearAuth();
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// Set authentication token
  Future<void> setToken(String token) async {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear authentication token
  Future<void> clearAuth() async {
    _token = null;
    _dio.options.headers.remove('Authorization');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Refresh authentication token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConfig.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newToken = response.data['data']['token'];
        await setToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generic GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: receiveTimeout != null
            ? Options(receiveTimeout: receiveTimeout)
            : null,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file
  Future<Response> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData();
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(filePath),
      ));

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: ApiConfig.getMultipartHeaders(_token),
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload multiple files
  Future<Response> uploadMultipleFiles(
    String endpoint,
    List<String> filePaths, {
    String fieldName = 'files',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData();
      
      for (var filePath in filePaths) {
        formData.files.add(MapEntry(
          fieldName,
          await MultipartFile.fromFile(filePath),
        ));
      }

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: ApiConfig.getMultipartHeaders(_token),
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Error: ${error.response?.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else {
      return 'Network error. Please try again.';
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _token != null;

  /// Get current token
  String? get token => _token;
}
