import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';

class ServiceRequestResult {
  final bool success;
  final bool fromDemo;
  final String? message;

  const ServiceRequestResult({
    required this.success,
    this.fromDemo = false,
    this.message,
  });
}

/// إرسال طلبات الخدمة (صيانة، كهرباء، …) عبر `/mobile-requests`.
class ServiceRequestRepository {
  ServiceRequestRepository([OwnerApiService? api])
    : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  Future<ServiceRequestResult> submit({
    required String serviceType,
    required String description,
    String? priority,
    String? cleaningType,
    String? scheduledAt,
    String? notes,
    int? propertyId,
    List<String> imagePaths = const [],
  }) async {
    if (DemoMode.isActive) {
      return const ServiceRequestResult(success: true, fromDemo: true);
    }

    try {
      List<String> attachmentUrls = const [];
      if (imagePaths.isNotEmpty) {
        attachmentUrls = await _api.uploadImages(imagePaths);
      }

      final attachmentNote = attachmentUrls.isNotEmpty
          ? 'attachments: ${attachmentUrls.join(', ')}'
          : null;
      final mergedNotes = [
        if (notes != null && notes.trim().isNotEmpty) notes.trim(),
        ?attachmentNote,
      ].join('\n');

      await _api.submitMobileRequest({
        'type': serviceType,
        'description': description.trim(),
        if (priority != null && priority.isNotEmpty) 'priority': priority,
        if (cleaningType != null && cleaningType.isNotEmpty)
          'cleaning_type': cleaningType,
        if (scheduledAt != null && scheduledAt.isNotEmpty)
          'scheduled_at': scheduledAt,
        if (mergedNotes.isNotEmpty) 'notes': mergedNotes,
        'property_id': ?propertyId,
        if (attachmentUrls.isNotEmpty) 'attachments': attachmentUrls,
      });
      return const ServiceRequestResult(success: true);
    } catch (e) {
      return ServiceRequestResult(success: false, message: e.toString());
    }
  }
}
