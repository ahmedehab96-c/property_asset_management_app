import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:property_asset_management_app/l10n/app_localizations.dart';

/// خدمة الذكاء الاصطناعي للمساعد الذكي.
/// يقرأ مفاتيح API من `.env` ويعود للردود المحاكاة المعرّبة عند غياب المفتاح.
class AIService {
  static String? get _openAiKey {
    try {
      final key = dotenv.env['OPENAI_API_KEY'];
      if (key != null && key.trim().isNotEmpty) return key.trim();
    } catch (_) {}
    return null;
  }

  static String? get _geminiKey {
    try {
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key != null && key.trim().isNotEmpty) return key.trim();
    } catch (_) {}
    return null;
  }

  static Future<String> sendMessage(
    String message, {
    required AppLocalizations l10n,
    required bool isArabic,
    Map<String, dynamic>? context,
  }) async {
    final openAiKey = _openAiKey;
    if (openAiKey != null) {
      try {
        return await _callOpenAIAPI(
          message,
          context,
          openAiKey,
          l10n: l10n,
          isArabic: isArabic,
        );
      } catch (_) {
        return _getSimulatedResponse(message, l10n);
      }
    }

    final geminiKey = _geminiKey;
    if (geminiKey != null) {
      try {
        return await _callGeminiAPI(
          message,
          context,
          geminiKey,
          l10n: l10n,
          isArabic: isArabic,
        );
      } catch (_) {
        return _getSimulatedResponse(message, l10n);
      }
    }

    return _getSimulatedResponse(message, l10n);
  }

  static Future<String> _callOpenAIAPI(
    String message,
    Map<String, dynamic>? context,
    String apiKey, {
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    final systemPrompt = _buildSystemPrompt(
      context,
      l10n: l10n,
      isArabic: isArabic,
    );
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message},
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    final content = choices?.first['message']?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw Exception('Empty OpenAI response');
    }
    return content.trim();
  }

  static Future<String> _callGeminiAPI(
    String message,
    Map<String, dynamic>? context,
    String apiKey, {
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    final systemPrompt = _buildSystemPrompt(
      context,
      l10n: l10n,
      isArabic: isArabic,
    );
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\n$message'},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final text = candidates?.first['content']?['parts']?.first['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty Gemini response');
    }
    return text.trim();
  }

  static String _buildSystemPrompt(
    Map<String, dynamic>? context, {
    required AppLocalizations l10n,
    required bool isArabic,
  }) {
    final buffer = StringBuffer(l10n.aiSystemPrompt);
    if (context != null && context.isNotEmpty) {
      final label = isArabic ? '\n\nسياق إضافي:\n' : '\n\nAdditional context:\n';
      buffer.write('$label${jsonEncode(context)}');
    }
    return buffer.toString();
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
