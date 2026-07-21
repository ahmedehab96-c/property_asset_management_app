import 'package:property_asset_management_app/services/demo_mode.dart';

/// Shared demo/API helpers for repositories.
mixin RepositoryMixin {
  bool get isDemoActive => DemoMode.isActive;

  /// Runs [api] unless demo mode is active.
  /// On API failure returns [onError] when provided; otherwise does **not**
  /// silently inject demo data (callers should show empty/error UI).
  Future<T> withApiFallback<T>({
    required Future<T> Function() api,
    required T Function() demo,
    T Function()? onError,
  }) async {
    if (isDemoActive) return demo();
    try {
      return await api();
    } catch (_) {
      if (onError != null) return onError();
      return demo(); // only when caller did not supply onError (legacy)
    }
  }
}
