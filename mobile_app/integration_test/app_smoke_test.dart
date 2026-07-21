import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/widgets/app_root.dart';
import 'package:property_asset_management_app/ui/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke integration test — run with a device/emulator:
/// `flutter test integration_test/app_smoke_test.dart`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'language_code': 'ar'});
  });

  testWidgets('app shell boots to splash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AppRoot(
          title: 'Property Management App',
          home: SplashScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
