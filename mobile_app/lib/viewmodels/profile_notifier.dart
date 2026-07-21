import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/service_providers.dart';
import 'package:property_asset_management_app/services/user_profile_service.dart';

class ProfileState {
  final ViewStatus status;
  final CachedUserProfile profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ViewStatus.idle,
    this.profile = const CachedUserProfile(),
    this.errorMessage,
  });

  ProfileState copyWith({
    ViewStatus? status,
    CachedUserProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> load({bool refresh = true}) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      final profile =
          await ref.read(userProfileServiceProvider).load(refresh: refresh);
      state = ProfileState(status: ViewStatus.success, profile: profile);
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<({bool success, String message})> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    final res = await ref.read(userProfileServiceProvider).updateProfile(
          name: name,
          email: email,
          phone: phone,
          address: address,
        );
    if (res.success) {
      final profile = await ref.read(userProfileServiceProvider).getCached();
      state = ProfileState(status: ViewStatus.success, profile: profile);
      return (success: true, message: res.message);
    }
    state = state.copyWith(
      status: ViewStatus.error,
      errorMessage: res.message.isNotEmpty ? res.message : 'Update failed',
    );
    return (success: false, message: res.message);
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
