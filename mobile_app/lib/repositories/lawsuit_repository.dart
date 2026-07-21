import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';

class LawsuitOperationResult {
  final bool success;
  final bool fromDemo;
  final String? message;

  const LawsuitOperationResult({
    required this.success,
    this.fromDemo = false,
    this.message,
  });
}

/// رفع دعوى قانونية عبر `/mobile-requests`.
class LawsuitRepository {
  LawsuitRepository([OwnerApiService? api]) : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  Future<LawsuitOperationResult> fileLawsuit({
    required int? contractId,
    required String typeKey,
    required String description,
  }) async {
    if (DemoMode.isActive || contractId == null) {
      return const LawsuitOperationResult(success: true, fromDemo: true);
    }

    try {
      await _api.submitMobileRequest({
        'type': 'lawsuit',
        'contract_id': contractId,
        'lawsuit_type': typeKey,
        'description': description.trim(),
      });
      return const LawsuitOperationResult(success: true);
    } catch (e) {
      return LawsuitOperationResult(success: false, message: e.toString());
    }
  }
}
