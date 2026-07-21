import 'package:flutter_test/flutter_test.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';

void main() {
  group('DemoMode', () {
    test('detects demo token prefix', () {
      expect(DemoMode.isDemoToken('demo-abc'), isTrue);
      expect(DemoMode.isDemoToken('demo'), isFalse);
      expect(DemoMode.isDemoToken(null), isFalse);
      expect(DemoMode.isDemoToken(''), isFalse);
      expect(DemoMode.isDemoToken('Bearer-real-jwt'), isFalse);
    });
  });
}
