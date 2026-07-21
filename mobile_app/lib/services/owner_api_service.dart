import 'package:property_asset_management_app/config/api_config.dart';
import 'package:property_asset_management_app/services/api_service.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';

/// استدعاءات API لتطبيق المالك — نفس مسارات Laravel في `backendApi.js`.
class OwnerApiService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getProperties({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.properties, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// يحاول `/properties` ثم `/owners/{id}/properties` عند الحاجة.
  Future<List<Map<String, dynamic>>> getMyProperties({
    Map<String, dynamic>? query,
  }) async {
    try {
      final list = await getProperties(query: query);
      if (list.isNotEmpty) return list;
    } catch (_) {}

    final profile = await UserProfileService().getCached();
    final ownerId = profile.id;
    if (ownerId == null) return [];

    final res = await _api.get(
      ApiConfig.ownerProperties(ownerId),
      queryParameters: query,
    );
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>?> getPropertyDetail(int id) async {
    final res = await _api.get(ApiConfig.propertyById(id));
    return OwnerApiMappers.unwrapObject(res.data);
  }

  Future<List<Map<String, dynamic>>> getContracts({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.contracts, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>?> getContractDetail(int id) async {
    final res = await _api.get(ApiConfig.contractById(id));
    return OwnerApiMappers.unwrapObject(res.data);
  }

  Future<void> extendContract(int id, Map<String, dynamic> body) async {
    await _api.post(ApiConfig.contractExtend(id), data: body);
  }

  Future<void> cancelContract(int id, Map<String, dynamic> body) async {
    await _api.post(ApiConfig.contractCancel(id), data: body);
  }

  Future<List<Map<String, dynamic>>> getTenants({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.tenants, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPayments({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.payments, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>?> getFinancialSummary() async {
    final res = await _api.get(ApiConfig.financialSummary);
    return OwnerApiMappers.unwrapObject(res.data);
  }

  Future<Map<String, dynamic>?> getOwnerFinancial(int ownerId) async {
    final res = await _api.get(ApiConfig.ownerFinancial(ownerId));
    return OwnerApiMappers.unwrapObject(res.data);
  }

  Future<List<Map<String, dynamic>>> getReports({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.reports, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getNotifications({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.notifications, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> markAllNotificationsRead() async {
    await _api.post(ApiConfig.notificationsReadAll);
  }

  Future<void> markNotificationRead(int id) async {
    await _api.post(ApiConfig.notificationRead(id));
  }

  Future<List<Map<String, dynamic>>> getMaintenanceRequests({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(
      ApiConfig.maintenanceRequests,
      queryParameters: query,
    );
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> searchProperties({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(
      ApiConfig.propertiesSearch,
      queryParameters: query,
    );
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> filterProperties({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(
      ApiConfig.propertiesFilter,
      queryParameters: query,
    );
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCalendarEvents({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(
      ApiConfig.calendarEvents,
      queryParameters: query,
    );
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getProjects({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.projects, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>?> getProjectDetail(int id) async {
    final res = await _api.get(ApiConfig.projectById(id));
    return OwnerApiMappers.unwrapObject(res.data);
  }

  Future<List<Map<String, dynamic>>> getTasks({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(ApiConfig.tasks, queryParameters: query);
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> updateTaskStatus(int id, String status) async {
    await _api.post(ApiConfig.taskStatus(id), data: {'status': status});
  }

  Future<List<Map<String, dynamic>>> getConversations({
    Map<String, dynamic>? query,
  }) async {
    final res = await _api.get(
      ApiConfig.conversations,
      queryParameters: query,
    );
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getConversationMessages(int id) async {
    final res = await _api.get(ApiConfig.conversationMessages(id));
    return OwnerApiMappers.extractList(res.data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>?> sendConversationMessage(
    int conversationId,
    String body,
  ) async {
    final res = await _api.post(
      ApiConfig.conversationMessages(conversationId),
      data: {'body': body},
    );
    return OwnerApiMappers.unwrapObject(res.data);
  }

  Future<Map<String, dynamic>?> getAnalyticsOverview() async {
    final res = await _api.get(ApiConfig.analyticsOverview);
    return OwnerApiMappers.unwrapObject(res.data);
  }

  /// Server-side photo analysis (local heuristics + optional OpenAI Vision).
  Future<Map<String, dynamic>?> analyzePropertyImages(List<String> filePaths) async {
    if (filePaths.isEmpty) return null;
    final res = await _api.uploadMultipleFiles(
      ApiConfig.analyticsImageAnalysis,
      filePaths,
      fieldName: 'files[]',
    );
    return OwnerApiMappers.unwrapObject(res.data);
  }

  Future<void> submitMobileRequest(Map<String, dynamic> body) async {
    await _api.post(ApiConfig.mobileRequests, data: body);
  }

  Future<List<String>> uploadImages(List<String> filePaths) async {
    if (filePaths.isEmpty) return [];
    final res = await _api.uploadMultipleFiles(
      ApiConfig.uploadMultiple,
      filePaths,
      fieldName: 'files',
    );
    return OwnerApiMappers.extractUploadUrls(res.data);
  }
}
