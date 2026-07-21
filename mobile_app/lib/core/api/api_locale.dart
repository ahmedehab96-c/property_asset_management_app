/// Maps app language codes to Laravel API locale format.
class ApiLocale {
  ApiLocale._();

  /// Laravel expects BCP-47 tags (e.g. ar-AE, en-US).
  static String forApi(String appLanguageCode) {
    switch (appLanguageCode.split('-').first) {
      case 'ar':
        return 'ar-AE';
      case 'en':
      default:
        return 'en-US';
    }
  }

  /// Simple code for UI / SharedPreferences (ar | en).
  static String forApp(String? code) {
    if (code == null || code.isEmpty) return 'ar';
    return code.split('-').first;
  }
}
