import 'package:flutter/material.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/repositories/conversations_repository.dart';
import 'package:property_asset_management_app/theme/app_gradients.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/utils/ui_feedback.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _repo = ConversationsRepository();
  final _composer = TextEditingController();
  bool _loading = true;
  bool _fromDemo = false;
  bool _sending = false;
  List<Map<String, dynamic>> _conversations = const [];
  int? _openId;
  List<Map<String, dynamic>> _messages = const [];
  bool _loadingMessages = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _repo.load(l10n: AppLocalizations.of(context));
    if (!mounted) return;
    setState(() {
      _conversations = result.conversations;
      _fromDemo = result.fromDemo;
      _loading = false;
    });
  }

  Future<void> _open(Map<String, dynamic> conversation) async {
    final id = (conversation['id'] as num?)?.toInt();
    if (id == null) return;
    setState(() {
      _openId = id;
      _loadingMessages = true;
      _messages = const [];
      _composer.clear();
    });
    final result = await _repo.loadMessages(
      conversationId: id,
      l10n: AppLocalizations.of(context),
    );
    if (!mounted) return;
    setState(() {
      _messages = result.messages;
      _loadingMessages = false;
    });
  }

  Future<void> _send() async {
    final id = _openId;
    final body = _composer.text.trim();
    if (id == null || body.isEmpty || _sending) return;

    setState(() => _sending = true);
    final ok = await _repo.sendMessage(conversationId: id, body: body);
    if (!mounted) return;

    if (ok) {
      _composer.clear();
      final result = await _repo.loadMessages(
        conversationId: id,
        l10n: AppLocalizations.of(context),
      );
      if (!mounted) return;
      setState(() {
        _messages = result.messages;
        _sending = false;
      });
    } else {
      setState(() => _sending = false);
      UiFeedback.showError(
        context,
        AppLocalizations.of(context).errorOccurred,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.estate;

    return AppScaffold(
      appBar: glassAppBar(
        context: context,
        title: l10n.messages,
        leading: _openId == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _openId = null;
                  _messages = const [];
                }),
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _openId == null
                  ? _load
                  : () async {
                      final match = _conversations
                          .cast<Map<String, dynamic>?>()
                          .firstWhere(
                            (c) => (c?['id'] as num?)?.toInt() == _openId,
                            orElse: () => null,
                          );
                      if (match != null) await _open(match);
                    },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_fromDemo) const DemoDataBanner(),
                  if (_loading || _loadingMessages)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_openId == null) ...[
                    if (_conversations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Text(
                            l10n.noMessages,
                            style: TextStyle(color: palette.textSecondary),
                          ),
                        ),
                      )
                    else
                      ..._conversations.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DecoratedBox(
                            decoration: AppGradients.glassCardFor(context),
                            child: ListTile(
                              title: Text(
                                (c['subject'] ?? c['tenant_name'] ?? '-')
                                    .toString(),
                              ),
                              subtitle: Text(
                                (c['last_message'] ?? '').toString(),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _open(c),
                            ),
                          ),
                        );
                      }),
                  ] else ...[
                    if (_messages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Text(
                            l10n.noMessages,
                            style: TextStyle(color: palette.textSecondary),
                          ),
                        ),
                      )
                    else
                      ..._messages.map((m) {
                        final fromAdmin = m['is_from_admin'] == true;
                        return Align(
                          alignment: fromAdmin
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                            ),
                            decoration: BoxDecoration(
                              color: fromAdmin
                                  ? palette.surfaceElevated
                                  : AppColors.primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              (m['body'] ?? m['message'] ?? '').toString(),
                            ),
                          ),
                        );
                      }),
                  ],
                ],
              ),
            ),
          ),
          if (_openId != null && !_fromDemo)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12 + ResponsiveHelper.viewInsetsOf(context).bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _composer,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: l10n.messages,
                          filled: true,
                          fillColor: palette.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
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
