import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/services/ai_service.dart';
import 'package:property_asset_management_app/ui/screens/market_analysis_screen.dart';
import 'package:property_asset_management_app/ui/screens/image_analysis_screen.dart';
import 'package:property_asset_management_app/ui/screens/tenant_analysis_screen.dart';
import 'package:property_asset_management_app/ui/screens/financial_predictions_screen.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  int? _conversationId;
  AgentPendingAction? _pendingAction;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLatest() async {
    try {
      final conversation = await AIService.loadLatest();
      if (!mounted || conversation == null || _messages.isNotEmpty) return;
      setState(() {
        _conversationId = conversation.id;
        _messages.addAll(conversation.messages.map(ChatMessage.fromAgent));
        _pendingAction = conversation.pendingActions.isEmpty
            ? null
            : conversation.pendingActions.last;
      });
      _scrollToBottom();
    } catch (_) {
      // History is a convenience; the chat still works without it.
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _busy) return;
    _messageController.clear();
    setState(() => _messages.add(ChatMessage.user(text)));
    _generateAIResponse(text);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    final isArabic = ref.read(isArabicProvider);
    setState(() {
      _busy = true;
      _messages.add(ChatMessage.loading());
    });
    _scrollToBottom();

    try {
      final reply = await AIService.sendMessage(
        userMessage,
        isArabic: isArabic,
        conversationId: _conversationId,
      );
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _conversationId = reply.conversationId;
        _messages.add(ChatMessage.fromAgent(reply.message));
        _pendingAction = reply.pendingAction ?? _pendingAction;
      });
    } on AgentException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage.error(_errorText(e), retryText: userMessage));
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    _scrollToBottom();
  }

  void _retry(ChatMessage failed) {
    final text = failed.retryText;
    if (text == null || _busy) return;
    setState(() {
      _messages.remove(failed);
      // The user bubble for this text is already shown; drop it so it isn't doubled.
      if (_messages.isNotEmpty &&
          _messages.last.isUser &&
          _messages.last.text == text) {
        _messages.removeLast();
      }
      _messages.add(ChatMessage.user(text));
    });
    _generateAIResponse(text);
  }

  Future<void> _resolvePending(bool confirm) async {
    final action = _pendingAction;
    if (action == null || _busy) return;
    final isArabic = ref.read(isArabicProvider);
    setState(() => _busy = true);

    try {
      final message = await AIService.resolveAction(
        action.id,
        confirm: confirm,
        isArabic: isArabic,
      );
      if (!mounted) return;
      setState(() {
        _pendingAction = null;
        _messages.add(ChatMessage.fromAgent(message));
      });
    } on AgentException catch (e) {
      if (!mounted) return;
      setState(() {
        // Expired or already handled actions can't be retried — clear the card.
        _pendingAction = null;
        _messages.add(ChatMessage.error(_errorText(e)));
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    _scrollToBottom();
  }

  void _newChat() {
    if (_busy) return;
    setState(() {
      _messages.clear();
      _conversationId = null;
      _pendingAction = null;
    });
  }

  String _errorText(AgentException e) {
    final text = e.message.trim();
    return text.isEmpty || text == 'Invalid response'
        ? AppLocalizations.of(context).aiErrorGeneric
        : text;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.estate.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10nBuilder = AppLocalizations.of(context);
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10nBuilder.quickActions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.estate.textPrimary,
                ),
              ),
              SizedBox(height: 20),
              _QuickActionTile(
                icon: Icons.description,
                title: l10nBuilder.writeRentalContract,
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text = l10nBuilder.writeContractPrompt;
                  _sendMessage();
                },
              ),
              _QuickActionTile(
                icon: Icons.article,
                title: l10nBuilder.writePropertyAd,
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text = l10nBuilder.writeAdPrompt;
                  _sendMessage();
                },
              ),
              _QuickActionTile(
                icon: Icons.analytics,
                title: l10nBuilder.analyzePropertyPerformance,
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text =
                      l10nBuilder.analyzePerformancePrompt;
                  _sendMessage();
                },
              ),
              _QuickActionTile(
                icon: Icons.build,
                title: l10nBuilder.maintenanceRecommendations,
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text =
                      l10nBuilder.maintenanceRecommendationsPrompt;
                  _sendMessage();
                },
              ),
              _QuickActionTile(
                icon: Icons.attach_money,
                title: l10nBuilder.estimateRentPrice,
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text = l10nBuilder.estimateRentPrompt;
                  _sendMessage();
                },
              ),
              const Divider(color: AppColors.darkGrey),
              SizedBox(height: 10),
              Text(
                l10nBuilder.advancedFeatures,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.estate.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              _QuickActionTile(
                icon: Icons.analytics,
                title: l10nBuilder.realEstateMarketAnalysis,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: const MarketAnalysisScreen(),
                      direction: AxisDirection.left,
                    ),
                  );
                },
              ),
              _QuickActionTile(
                icon: Icons.camera_alt,
                title: l10nBuilder.smartImageAnalysis,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: const ImageAnalysisScreen(),
                      direction: AxisDirection.left,
                    ),
                  );
                },
              ),
              _QuickActionTile(
                icon: Icons.person_search,
                title: l10nBuilder.tenantAnalysis,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: const TenantAnalysisScreen(),
                      direction: AxisDirection.left,
                    ),
                  );
                },
              ),
              _QuickActionTile(
                icon: Icons.trending_up,
                title: l10nBuilder.financialPredictions,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: const FinancialPredictionsScreen(),
                      direction: AxisDirection.left,
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = [
      if (_messages.isEmpty) ChatMessage.assistant(l10n.aiWelcomeMessage),
      ..._messages,
    ];
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: context.estate.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.smart_toy,
                color: AppColors.accentGold,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              l10n.smartAssistant,
              style: TextStyle(color: context.estate.textPrimary),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_outlined, color: AppColors.accentGold),
            onPressed: _busy ? null : _newChat,
            tooltip: l10n.aiNewChat,
          ),
          IconButton(
            icon: Icon(Icons.bolt, color: AppColors.accentGold),
            onPressed: _showQuickActions,
            tooltip: l10n.quickActions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final message = items[index];
                return _ChatBubble(
                  message: message,
                  onRetry: message.retryText == null
                      ? null
                      : () => _retry(message),
                );
              },
            ),
          ),

          if (_pendingAction != null)
            _PendingActionCard(
              action: _pendingAction!,
              busy: _busy,
              onConfirm: () => _resolvePending(true),
              onCancel: () => _resolvePending(false),
            ),

          // Input Area
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + ResponsiveHelper.viewInsetsOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: context.estate.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: l10n.writeMessage,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: context.estate.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: AppColors.primaryBlue),
                      onPressed: _busy ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final bool isError;
  final List<AgentAction> actions;

  /// Set on failed replies so the bubble can offer a retry.
  final String? retryText;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.isError = false,
    this.actions = const [],
    this.retryText,
  });

  factory ChatMessage.user(String text) =>
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now());

  factory ChatMessage.assistant(String text) =>
      ChatMessage(text: text, isUser: false, timestamp: DateTime.now());

  factory ChatMessage.loading() => ChatMessage(
    text: '',
    isUser: false,
    timestamp: DateTime.now(),
    isLoading: true,
  );

  factory ChatMessage.error(String text, {String? retryText}) => ChatMessage(
    text: text,
    isUser: false,
    timestamp: DateTime.now(),
    isError: true,
    retryText: retryText,
  );

  factory ChatMessage.fromAgent(AgentMessage message) => ChatMessage(
    text: message.content,
    isUser: message.role == 'user',
    timestamp: DateTime.now(),
    actions: message.actions,
  );
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const _ChatBubble({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bubbleColor = message.isUser
        ? AppColors.accentGold
        : message.isError
        ? AppColors.terracotta.withValues(alpha: 0.18)
        : AppColors.cardDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.isError ? Icons.error_outline : Icons.smart_toy,
                color: message.isError
                    ? AppColors.terracotta
                    : AppColors.accentGold,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(20),
                  topEnd: const Radius.circular(20),
                  bottomStart: Radius.circular(message.isUser ? 20 : 4),
                  bottomEnd: Radius.circular(message.isUser ? 4 : 20),
                ),
              ),
              child: message.isLoading
                  ? Semantics(
                      label: '...',
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.actions.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: message.actions
                                .map((action) => _ActionChip(action: action))
                                .toList(),
                          ),
                          SizedBox(height: 10),
                        ],
                        SelectableText(
                          message.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: message.isUser
                                ? AppColors.primaryBlue
                                : AppColors.white,
                          ),
                        ),
                        if (onRetry != null) ...[
                          SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: onRetry,
                            icon: Icon(
                              Icons.refresh,
                              color: AppColors.accentGold,
                              size: 18,
                            ),
                            label: Text(
                              l10n.aiRetry,
                              style: TextStyle(color: AppColors.accentGold),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: AppColors.accentGold, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows which tool ran and whether it completed, failed, or awaits confirmation.
class _ActionChip extends StatelessWidget {
  final AgentAction action;

  const _ActionChip({required this.action});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color, status) = switch (action.status) {
      AgentActionStatus.completed => (
        Icons.check_circle,
        AppColors.lightGreen,
        l10n.aiActionCompleted,
      ),
      AgentActionStatus.pendingConfirmation => (
        Icons.hourglass_top,
        AppColors.accentGold,
        l10n.aiActionPending,
      ),
      AgentActionStatus.cancelled => (
        Icons.block,
        AppColors.white,
        l10n.aiActionCancelled,
      ),
      AgentActionStatus.failed => (
        Icons.error,
        AppColors.terracotta,
        l10n.aiActionFailed,
      ),
    };
    final label = l10n.aiToolLabel(action.tool);
    final tool = label.startsWith('ai_tool_') ? action.tool : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            '$tool · $status',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _PendingActionCard extends StatelessWidget {
  final AgentPendingAction action;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PendingActionCard({
    required this.action,
    required this.busy,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.estate.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.accentGold,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.aiNeedsConfirmation,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: context.estate.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            action.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.estate.textSecondary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onCancel,
                  child: Text(l10n.aiCancel),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryBlue,
                  ),
                  child: Text(l10n.aiConfirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.accentGold, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: context.estate.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: context.estate.textSecondary,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
