import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/services/demo_mode.dart';
import 'package:property_asset_management_app/services/owner_api_service.dart';

class ConversationsLoadResult {
  final List<Map<String, dynamic>> conversations;
  final bool fromDemo;

  const ConversationsLoadResult({
    required this.conversations,
    required this.fromDemo,
  });
}

class MessagesLoadResult {
  final List<Map<String, dynamic>> messages;
  final bool fromDemo;

  const MessagesLoadResult({required this.messages, required this.fromDemo});
}

class ConversationsRepository {
  ConversationsRepository([OwnerApiService? api])
      : _api = api ?? OwnerApiService();

  final OwnerApiService _api;

  List<Map<String, dynamic>> _demoConversations(AppLocalizations l10n) => [
        {
          'id': 1,
          'subject': l10n.contactTenantTitle,
          'tenant_name': 'Ahmed Tenant',
          'last_message': l10n.noMessages,
        },
      ];

  Future<ConversationsLoadResult> load({
    required AppLocalizations l10n,
  }) async {
    if (DemoMode.isActive) {
      return ConversationsLoadResult(
        conversations: _demoConversations(l10n),
        fromDemo: true,
      );
    }

    try {
      final list = await _api.getConversations();
      return ConversationsLoadResult(conversations: list, fromDemo: false);
    } catch (_) {
      return const ConversationsLoadResult(conversations: [], fromDemo: false);
    }
  }

  Future<MessagesLoadResult> loadMessages({
    required int conversationId,
    required AppLocalizations l10n,
  }) async {
    if (DemoMode.isActive) {
      return MessagesLoadResult(
        messages: [
          {'id': 1, 'body': l10n.noMessages, 'is_from_admin': false},
        ],
        fromDemo: true,
      );
    }

    try {
      final list = await _api.getConversationMessages(conversationId);
      return MessagesLoadResult(messages: list, fromDemo: false);
    } catch (_) {
      return const MessagesLoadResult(messages: [], fromDemo: false);
    }
  }

  Future<bool> sendMessage({
    required int conversationId,
    required String body,
  }) async {
    if (DemoMode.isActive) return true;
    try {
      await _api.sendConversationMessage(conversationId, body);
      return true;
    } catch (_) {
      return false;
    }
  }
}
