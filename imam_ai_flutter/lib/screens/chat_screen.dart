import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../l10n/l10n_scope.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String selectedMezhep;
  final String? initialPrompt;
  final VoidCallback? onClearInitialPrompt;

  const ChatScreen({
    super.key,
    required this.selectedMezhep,
    this.initialPrompt,
    this.onClearInitialPrompt,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> implements ChatScreenStateExt {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _sessionId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessionAndHistory().then((_) {
      if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
        _controller.text = widget.initialPrompt!;
        _sendMessage();
        if (widget.onClearInitialPrompt != null) {
          widget.onClearInitialPrompt!();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPrompt != null &&
        widget.initialPrompt!.isNotEmpty &&
        widget.initialPrompt != oldWidget.initialPrompt) {
      _controller.text = widget.initialPrompt!;
      _sendMessage();
      if (widget.onClearInitialPrompt != null) {
        widget.onClearInitialPrompt!();
      }
    }
  }

  Future<void> _loadSessionAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final storedSession = prefs.getString('session_id');
    if (storedSession != null) {
      setState(() {
        _sessionId = storedSession;
        _isLoading = true;
      });
      try {
        final history = await ApiService.getHistory(storedSession);
        setState(() {
          _messages.clear();
          for (var item in history) {
            _messages.add(Message(
              content: item['content'] ?? '',
              isUser: item['role'] == 'user',
              timestamp: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
            ));
          }
        });
      } catch (e) {
        // Silent catch
      } finally {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  Future<void> _saveSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
    _sessionId = sessionId;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add(Message(content: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final result = await ApiService.sendMessage(
        message: text,
        sessionId: _sessionId,
      );
      await _saveSession(result['session_id'] as String);
      setState(() {
        _messages.add(Message(
          content: result['reply'] as String,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          content: L10nScope.of(context).chatError,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Future<void> clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
    setState(() {
      _sessionId = null;
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Column(
      children: [
        // Message list
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(_messages[index], timeFormat),
                ),
        ),
        if (_isLoading) _buildTypingIndicator(),

        // Warning banner positioned exactly above the input area
        _buildWarningBanner(),

        // Input Area
        _buildInputArea(),
      ],
    );
  }

  Widget _buildEmptyState() {
    final l10n = L10nScope.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Hero gradient banner ───────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF005F41), Color(0xFF00B27A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            l10n.chatAssistant,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.chatWelcome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.chatWelcomeSubtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🕌', style: TextStyle(fontSize: 56)),
              ],
            ),
          ),

          // ─── Kategori başlığı ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 10),
            child: Text(
              l10n.popularQuestions,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          _buildSuggestionCard(
            icon: Icons.opacity_rounded,
            iconColor: const Color(0xFF3B82F6),
            iconBg: const Color(0xFFEFF6FF),
            text: l10n.qAblution,
          ),
          _buildSuggestionCard(
            icon: Icons.nightlight_round,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFF5F3FF),
            text: l10n.qFasting,
          ),
          _buildSuggestionCard(
            icon: Icons.mosque_rounded,
            iconColor: const Color(0xFF00B27A),
            iconBg: const Color(0xFFECFDF5),
            text: l10n.qPrayerSurah,
          ),
          _buildSuggestionCard(
            icon: Icons.volunteer_activism_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
            text: l10n.qZakat,
          ),
          _buildSuggestionCard(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFFEF4444),
            iconBg: const Color(0xFFFEF2F2),
            text: l10n.qQuranRead,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String text,
  }) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Eski chip metodu - hâlâ derleme uyumluluğu için
  Widget _buildSuggestionChip(String text) {
    return _buildSuggestionCard(
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: AppColors.primary,
      iconBg: AppColors.surface2,
      text: text,
    );
  }

  Widget _buildMessageBubble(Message message, DateFormat timeFormat) {
    final isUser = message.isUser;
    final timeStr = timeFormat.format(message.timestamp);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 50 : 12,
          right: isUser ? 12 : 50,
          bottom: 6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? AppColors.bubbleUser : AppColors.bubbleAI,
          border: isUser ? null : Border.all(color: AppColors.cardBorder, width: 0.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(isUser ? 10 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 10),
          ),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser) ...[
              Text(
                L10nScope.of(context).appName,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
            ],
            if (isUser)
              Text(
                message.content,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Colors.black87,
                ),
              )
            else
              MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14.5,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                  h3: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                  listBullet: const TextStyle(color: AppColors.primary, fontSize: 14.5),
                  code: TextStyle(
                    fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                    fontSize: 13.0,
                    backgroundColor: AppColors.scaffoldBg,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 11,
                    color: AppColors.primaryLight,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, right: 60, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              L10nScope.of(context).chatTyping,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    final l10n = L10nScope.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFD97706), size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.chatDisclaimer,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final l10n = L10nScope.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(top: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  style: const TextStyle(fontSize: 14.5, color: Color(0xFF1A1A1A)),
                  decoration: InputDecoration(
                    hintText: l10n.chatHint,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 4),
                      child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005F41), Color(0xFF00B27A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
