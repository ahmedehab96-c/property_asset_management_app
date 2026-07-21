import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/services/auth_service.dart';
import 'package:property_asset_management_app/services/notification_preferences_service.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final ownerApiServiceProvider =
    Provider<OwnerApiService>((ref) => OwnerApiService());

final userProfileServiceProvider =
    Provider<UserProfileService>((ref) => UserProfileService());

final notificationPreferencesServiceProvider =
    Provider<NotificationPreferencesService>(
  (ref) => NotificationPreferencesService(),
);
