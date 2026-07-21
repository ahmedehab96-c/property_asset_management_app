import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/widgets/app_root.dart';
import 'package:property_asset_management_app/services/api_service.dart';
import 'package:property_asset_management_app/ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. Using default API URL.');
  }

  await ApiService().initialize();

  runApp(
    const ProviderScope(
      child: PropertyAssetManagementApp(),
    ),
  );
}

class PropertyAssetManagementApp extends StatelessWidget {
  const PropertyAssetManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppRoot(
      title: 'Property Management App',
      home: SplashScreen(),
    );
  }
}
