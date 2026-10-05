import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/launcher_utils.dart';
import '../../../core/services/socket_service.dart';
import '../../../providers/app_state_provider.dart';

class ChatConversationScreen extends StatefulWidget {
  final String participantName;
  final String propertyTitle;

  const ChatConversationScreen({
    super.key,
    required this.participantName,
    required this.propertyTitle,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentThreadId;
  bool _isOtherTyping = false;

  @override
  void initState() {
    super.initState();
    SocketService.instance.addTypingListener(_handleTyping);
  }

  void _handleTyping(String threadId, String senderName, bool isTyping) {
    if (threadId == _currentThreadId && mounted) {
      setState(() {
        _isOtherTyping = isTyping;
      });
      if (isTyping) _scrollToBottom();
    }
  }

  @override
  void dispose() {
    if (_currentThreadId != null) {
      SocketService.instance.leaveThread(_currentThreadId!);
    }
    SocketService.instance.removeTypingListener(_handleTyping);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _sendMessage(AppStateProvider state, String threadId) {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      state.sendChatMessage(threadId, text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final thread = state.getOrCreateChatThread(
      participantName: widget.participantName,
      propertyTitle: widget.propertyTitle,
    );

    if (_currentThreadId != thread.id) {
      _currentThreadId = thread.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SocketService.instance.joinThread(thread.id);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                widget.participantName.isNotEmpty
                    ? widget.participantName[0]
                    : 'P',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.participantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _isOtherTyping ? AppTheme.primary : AppTheme.verifiedGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isOtherTyping ? 'typing...' : 'Online • ${thread.participantRole}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: _isOtherTyping ? AppTheme.primary : AppTheme.textSecondary,
                          fontWeight: _isOtherTyping ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded, color: AppTheme.primary),
            onPressed: () => LauncherUtils.makePhoneCall(
              context,
              '+91 98765 43210',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Property Context Chip
            if (widget.propertyTitle.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.primaryLight.withOpacity(0.5),
                child: Row(
                  children: [
                    const Icon(
                      Icons.home_work_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Inquiring about: ${widget.propertyTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: thread.messages.length,
                itemBuilder: (context, index) {
                  final msg = thread.messages[index];
                  final isSender = msg.isSender;
                  final timeStr = DateFormat('hh:mm a').format(msg.timestamp);

                  return Align(
                    alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSender ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isSender ? 16 : 0),
                          bottomRight: Radius.circular(isSender ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSender
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeStr,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSender
                                  ? Colors.white70
                                  : AppTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(state, thread.id),
                        onChanged: (val) {
                          if (_currentThreadId != null) {
                            SocketService.instance.sendTyping(
                              threadId: _currentThreadId!,
                              senderName: state.userName,
                              isTyping: val.trim().isNotEmpty,
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _sendMessage(state, thread.id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
