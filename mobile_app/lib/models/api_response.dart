/// API Response Model
/// Standard response format from Laravel API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic)? fromJsonT,
  ) {
    final success = json['success'] == true || json['status'] == true;
    final dataJson = json['data'];
    final data = dataJson != null && fromJsonT != null
        ? fromJsonT(dataJson)
        : dataJson as T?;
    return ApiResponse<T>(
      success: success,
      message: (json['message'] ?? '').toString(),
      data: data,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };
  }

  bool get hasErrors => errors != null && errors!.isNotEmpty;
}
