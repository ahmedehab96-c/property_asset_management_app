import 'package:property_asset_management_app/services/owner_api_service.dart';

/// What happened to one tool call the agent made.
enum AgentActionStatus { completed, failed, pendingConfirmation, cancelled }

class AgentAction {
  final String tool;
  final AgentActionStatus status;

  const AgentAction({required this.tool, required this.status});

  factory AgentAction.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']?.toString()) {
      'completed' => AgentActionStatus.completed,
      'pending_confirmation' => AgentActionStatus.pendingConfirmation,
      'cancelled' => AgentActionStatus.cancelled,
      _ => AgentActionStatus.failed,
    };
    return AgentAction(tool: json['tool']?.toString() ?? '', status: status);
  }
}

/// A write the agent proposed. Nothing changes until the user confirms it.
class AgentPendingAction {
  final int id;
  final String summary;

  const AgentPendingAction({required this.id, required this.summary});

  static AgentPendingAction? fromJson(dynamic json) {
    if (json is! Map || json['id'] == null) return null;
    if ((json['status'] ?? 'pending') != 'pending') return null;
    return AgentPendingAction(
      id: (json['id'] as num).toInt(),
      summary: json['summary']?.toString() ?? '',
    );
  }
}

class AgentMessage {
  final String role;
  final String content;
  final List<AgentAction> actions;
  final int? pendingActionId;

  const AgentMessage({
    required this.role,
    required this.content,
    this.actions = const [],
    this.pendingActionId,
  });

  factory AgentMessage.fromJson(Map<String, dynamic> json) {
    final actions = (json['actions'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AgentAction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return AgentMessage(
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      actions: actions,
      pendingActionId: (json['pending_action_id'] as num?)?.toInt(),
    );
  }
}

class AgentReply {
  final int conversationId;
  final AgentMessage message;
  final AgentPendingAction? pendingAction;

  const AgentReply({
    required this.conversationId,
    required this.message,
    this.pendingAction,
  });
}

class AgentConversation {
  final int id;
  final List<AgentMessage> messages;
  final List<AgentPendingAction> pendingActions;

  const AgentConversation({
    required this.id,
    required this.messages,
    required this.pendingActions,
  });
}

/// Server message (already localized by Laravel) or a network error.
class AgentException implements Exception {
  final String message;
  const AgentException(this.message);

  @override
  String toString() => message;
}

/// AI agent — every request goes through Laravel; the Gemini key stays on the server.
class AIService {
  static final OwnerApiService _api = OwnerApiService();

  static Future<AgentReply> sendMessage(
    String message, {
    required bool isArabic,
    int? conversationId,
  }) async {
    final data = await _guard(
      () => _api.aiAgentChat(
        message: message,
        locale: isArabic ? 'ar' : 'en',
        conversationId: conversationId,
      ),
    );
    final raw = data['message'];
    if (raw is! Map || data['conversation_id'] == null) {
      throw const AgentException('Invalid response');
    }
    return AgentReply(
      conversationId: (data['conversation_id'] as num).toInt(),
      message: AgentMessage.fromJson(Map<String, dynamic>.from(raw)),
      pendingAction: AgentPendingAction.fromJson(data['pending_action']),
    );
  }

  /// The most recent conversation, so the chat survives closing the screen.
  static Future<AgentConversation?> loadLatest() async {
    final list = await _guardList(_api.aiAgentConversations);
    if (list.isEmpty || list.first['id'] == null) return null;
    final id = (list.first['id'] as num).toInt();
    final data = await _guard(() => _api.aiAgentConversation(id));
    return AgentConversation(
      id: id,
      messages: (data['messages'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => AgentMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pendingActions: (data['pending_actions'] as List? ?? const [])
          .map(AgentPendingAction.fromJson)
          .whereType<AgentPendingAction>()
          .toList(),
    );
  }

  /// Confirms or cancels a pending action; returns the agent's follow-up message.
  static Future<AgentMessage> resolveAction(
    int actionId, {
    required bool confirm,
    required bool isArabic,
  }) async {
    final data = await _guard(
      () => _api.aiAgentResolveAction(
        actionId,
        confirm: confirm,
        locale: isArabic ? 'ar' : 'en',
      ),
    );
    final raw = data['message'];
    if (raw is! Map) throw const AgentException('Invalid response');
    return AgentMessage.fromJson(Map<String, dynamic>.from(raw));
  }

  static Future<Map<String, dynamic>> _guard(
    Future<Map<String, dynamic>?> Function() call,
  ) async {
    try {
      final data = await call();
      if (data == null) throw const AgentException('Invalid response');
      return data;
    } on AgentException {
      rethrow;
    } catch (e) {
      // ApiService throws the server's message as a String.
      throw AgentException(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> _guardList(
    Future<List<Map<String, dynamic>>> Function() call,
  ) async {
    try {
      return await call();
    } catch (e) {
      throw AgentException(e.toString());
    }
  }
}
