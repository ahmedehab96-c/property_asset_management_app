import 'package:flutter_test/flutter_test.dart';
import 'package:property_asset_management_app/repositories/service_request_repository.dart';
import 'package:property_asset_management_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiService().initialize();
    await ApiService().setToken('demo-test-token');
  });

  tearDown(() async {
    await ApiService().clearAuth();
  });

  test('submit succeeds in demo mode without API call', () async {
    final repo = ServiceRequestRepository();
    final result = await repo.submit(
      serviceType: 'repair',
      description: 'Water leak',
      priority: 'medium',
    );

    expect(result.success, isTrue);
    expect(result.fromDemo, isTrue);
    expect(result.message, isNull);
  });
}
