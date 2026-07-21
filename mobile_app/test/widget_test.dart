import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_asset_management_app/core/widgets/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'language_code': 'ar'});
  });

  testWidgets('AppRoot renders localized home', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AppRoot(
          title: 'Property Management App',
          home: Scaffold(body: Text('إدارة ممتلكاتك بكل سهولة')),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('إدارة ممتلكاتك بكل سهولة'), findsOneWidget);
  });
}
