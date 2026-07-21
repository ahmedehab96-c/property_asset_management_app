/// Shared helpers to unwrap Laravel API list/object payloads.
class ApiResponseMappers {
  ApiResponseMappers._();

  static const _listKeys = [
    'data',
    'items',
    'results',
    'list',
    'properties',
    'tenants',
    'contracts',
    'owners',
    'users',
    'notifications',
    'payments',
  ];

  static List<dynamic> extractList(dynamic res) {
    if (res == null) return [];
    if (res is List) return res;
    if (res is Map) {
      final raw = res['data'] ?? res;
      if (raw is List) return raw;
      if (raw is Map) {
        if (raw['data'] is List) return raw['data'] as List;
        for (final key in _listKeys) {
          if (raw[key] is List) return raw[key] as List;
        }
      }
    }
    return [];
  }

  static Map<String, dynamic>? unwrapObject(dynamic res) {
    if (res == null) return null;
    if (res is Map && res['data'] is Map) {
      return Map<String, dynamic>.from(res['data'] as Map);
    }
    if (res is Map) return Map<String, dynamic>.from(res);
    return null;
  }
}
