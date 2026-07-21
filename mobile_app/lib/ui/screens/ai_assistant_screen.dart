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
  List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // Get AI response
    _generateAIResponse(_messages.last.text);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    // Show loading indicator
    setState(() {
      _messages.add(
        ChatMessage(
          text: "...",
          isUser: false,
          timestamp: DateTime.now(),
          isLoading: true,
        ),
      );
    });
    _scrollToBottom();

    // Get response from AI service
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.read(isArabicProvider);
    final response = await AIService.sendMessage(
      userMessage,
      l10n: l10n,
      isArabic: isArabic,
    );
    
    setState(() {
      _messages.removeLast(); // Remove loading message
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
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
                _messageController.text = l10nBuilder.analyzePerformancePrompt;
                _sendMessage();
              },
            ),
            _QuickActionTile(
              icon: Icons.build,
              title: l10nBuilder.maintenanceRecommendations,
              onTap: () {
                Navigator.pop(context);
                _messageController.text = l10nBuilder.maintenanceRecommendationsPrompt;
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
    if (_messages.isEmpty) {
      _messages = [
        ChatMessage(
          text: l10n.aiWelcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary),
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
              child: Icon(Icons.smart_toy, color: AppColors.accentGold, size: 20),
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                      onPressed: _sendMessage,
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

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                Icons.smart_toy,
                color: AppColors.accentGold,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.accentGold
                    : AppColors.cardDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
              ),
              child: message.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Text(
                      message.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: message.isUser
                            ? AppColors.primaryBlue
                            : AppColors.white,
                      ),
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
              child: Icon(
                Icons.person,
                color: AppColors.accentGold,
                size: 18,
              ),
            ),
          ],
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
      trailing: Icon(Icons.arrow_forward_ios, color: context.estate.textSecondary, size: 16),
      onTap: onTap,
    );
  }
}

