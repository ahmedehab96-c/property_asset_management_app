import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';

/// AI assistant — all requests go through Laravel (Gemini on server).
class AIService {
  static final OwnerApiService _api = OwnerApiService();

  static Future<String> sendMessage(
    String message, {
    required AppLocalizations l10n,
    required bool isArabic,
    List<Map<String, String>>? history,
  }) async {
    try {
      final result = await _api.aiChat(
        message: message,
        locale: isArabic ? 'ar' : 'en',
        history: history,
      );
      final reply = result?['reply']?.toString().trim();
      if (reply != null && reply.isNotEmpty) {
        return reply;
      }
    } catch (_) {}

    return _getSimulatedResponse(message, l10n);
  }

  static bool _containsAny(String message, List<String> keywords) {
    final normalized = message.toLowerCase();
    return keywords.any((keyword) => normalized.contains(keyword.toLowerCase()));
  }

  static String _getSimulatedResponse(String message, AppLocalizations l10n) {
    if (_containsAny(message, [
      'تقدير',
      'estimate',
      'valuation',
      'سعر',
      'price',
    ])) {
      return l10n.aiSimValuation;
    }

    if (_containsAny(message, [
      'عقد',
      'إيجار',
      'contract',
      'rent',
      'lease',
      'rental',
    ])) {
      return l10n.aiSimContract;
    }

    if (_containsAny(message, ['إعلان', 'ad', 'advert', 'listing'])) {
      return l10n.aiSimAd;
    }

    if (_containsAny(message, [
      'تحليل',
      'أداء',
      'analysis',
      'analyze',
      'performance',
    ])) {
      return l10n.aiSimAnalysis;
    }

    if (_containsAny(message, [
      'صيانة',
      'مشكلة',
      'maintenance',
      'repair',
      'issue',
    ])) {
      return l10n.aiSimMaintenance;
    }

    if (_containsAny(message, [
      'نصيحة',
      'مساعدة',
      'advice',
      'help',
      'recommend',
    ])) {
      return l10n.aiSimAdvice;
    }

    return l10n.aiSimDefault;
  }
}
