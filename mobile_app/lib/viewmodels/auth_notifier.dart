import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/core/providers/service_providers.dart';
import 'package:property_asset_management_app/services/demo_auth.dart';

class AuthState {
  final ViewStatus status;
  final String? errorMessage;
  final bool fromDemo;

  const AuthState({
    this.status = ViewStatus.idle,
    this.errorMessage,
    this.fromDemo = false,
  });

  AuthState copyWith({
    ViewStatus? status,
    String? errorMessage,
    bool? fromDemo,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fromDemo: fromDemo ?? this.fromDemo,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login({
    required String email,
    required String password,
    required String locale,
    bool adminEntry = false,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);

    final auth = ref.read(authServiceProvider);
    final profile = ref.read(userProfileServiceProvider);

    final res = await auth.login(
      email: email.trim(),
      password: password,
      locale: locale,
    );

    if (res.success) {
      await profile.load(refresh: true);
      state = state.copyWith(status: ViewStatus.success, fromDemo: false);
      return true;
    }

    final isDemo = adminEntry
        ? DemoAuth.matchesAdmin(email, password)
        : DemoAuth.matchesOwner(email, password);

    if (isDemo) {
      if (adminEntry) {
        await DemoAuth.signInAsAdmin(locale: locale);
      } else {
        await DemoAuth.signInAsOwner(locale: locale);
      }
      state = state.copyWith(status: ViewStatus.success, fromDemo: true);
      return true;
    }

    state = state.copyWith(
      status: ViewStatus.error,
      errorMessage: res.message.isNotEmpty ? res.message : 'Login failed',
    );
    return false;
  }

  Future<bool> demoLogin({
    required String locale,
    bool adminEntry = false,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    try {
      if (adminEntry) {
        await DemoAuth.signInAsAdmin(locale: locale);
      } else {
        await DemoAuth.signInAsOwner(locale: locale);
      }
      state = state.copyWith(status: ViewStatus.success, fromDemo: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    await ref.read(userProfileServiceProvider).clear();
    state = const AuthState();
  }

  Future<({bool success, Map<String, dynamic>? data, String message})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    required String userType,
    required String locale,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    final res = await ref.read(authServiceProvider).register(
          name: name,
          email: email.trim(),
          password: password,
          passwordConfirmation: passwordConfirmation,
          phone: phone,
          userType: userType,
          locale: locale,
        );
    if (res.success) {
      state = state.copyWith(status: ViewStatus.success);
      return (success: true, data: res.data, message: res.message);
    }
    state = state.copyWith(
      status: ViewStatus.error,
      errorMessage: res.message.isNotEmpty ? res.message : 'Registration failed',
    );
    return (success: false, data: null, message: res.message);
  }

  Future<({bool success, String message})> forgotPassword({
    required String email,
    String? locale,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    final res = await ref.read(authServiceProvider).forgotPassword(
          email: email.trim(),
          locale: locale,
        );
    if (res.success) {
      state = state.copyWith(status: ViewStatus.success);
      return (success: true, message: res.message);
    }
    state = state.copyWith(
      status: ViewStatus.error,
      errorMessage: res.message.isNotEmpty ? res.message : 'Request failed',
    );
    return (success: false, message: res.message);
  }

  Future<({bool success, String message})> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    final res = await ref.read(authServiceProvider).changePassword(
          currentPassword: currentPassword,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
    if (res.success) {
      state = state.copyWith(status: ViewStatus.success);
      return (success: true, message: res.message);
    }
    state = state.copyWith(
      status: ViewStatus.error,
      errorMessage: res.message.isNotEmpty ? res.message : 'Failed',
    );
    return (success: false, message: res.message);
  }

  Future<({bool success, String message})> verifyEmailCode(String code) async {
    state = state.copyWith(status: ViewStatus.loading, errorMessage: null);
    final res = await ref.read(authServiceProvider).verifyEmail(token: code.trim());
    if (res.success) {
      state = state.copyWith(status: ViewStatus.success);
      return (success: true, message: res.message);
    }
    state = state.copyWith(
      status: ViewStatus.error,
      errorMessage: res.message.isNotEmpty ? res.message : 'Verification failed',
    );
    return (success: false, message: res.message);
  }

  Future<({bool success, String message})> resendVerification({String? locale}) async {
    final res = await ref.read(authServiceProvider).resendVerification(locale: locale);
    return (success: res.success, message: res.message);
  }

  Future<({bool success, String message})> setTwoFactorEnabled(bool enabled) async {
    final res = await ref.read(authServiceProvider).setTwoFactorEnabled(enabled);
    return (success: res.success, message: res.message);
  }

  Future<bool> loadTwoFactorEnabled() =>
      ref.read(authServiceProvider).getTwoFactorEnabled();
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
