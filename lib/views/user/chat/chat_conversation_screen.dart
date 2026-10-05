import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/launcher_utils.dart';
import '../../../core/services/socket_service.dart';
import '../../../providers/app_state_provider.dart';

/// WhatsApp authentic doodle wallpaper painter
class WhatsAppWallpaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill background with authentic WhatsApp cream tone
    final bgPaint = Paint()..color = const Color(0xFFEFEAE2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.04)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const spacingX = 64.0;
    const spacingY = 74.0;
    int row = 0;

    for (double y = 20; y < size.height + 40; y += spacingY) {
      double offsetX = (row % 2 == 1) ? spacingX / 2 : 0;
      int col = 0;
      for (double x = 10; x < size.width + 40; x += spacingX) {
        final cx = x + offsetX;
        final motifType = (row + col) % 6;

        switch (motifType) {
          case 0:
            // Chat bubble
            final r = RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(cx, y), width: 18, height: 12),
              const Radius.circular(3),
            );
            canvas.drawRRect(r, linePaint);
            break;
          case 1:
            // House outline (Property Hub theme)
            final path = Path()
              ..moveTo(cx - 7, y + 5)
              ..lineTo(cx - 7, y - 2)
              ..lineTo(cx, y - 8)
              ..lineTo(cx + 7, y - 2)
              ..lineTo(cx + 7, y + 5)
              ..close();
            canvas.drawPath(path, linePaint);
            break;
          case 2:
            // Small clock
            canvas.drawCircle(Offset(cx, y), 6, linePaint);
            canvas.drawLine(Offset(cx, y), Offset(cx, y - 4), linePaint);
            canvas.drawLine(Offset(cx, y), Offset(cx + 3, y), linePaint);
            break;
          case 3:
            // Star
            canvas.drawCircle(Offset(cx, y), 3.5, fillPaint);
            break;
          case 4:
            // Smiley
            canvas.drawCircle(Offset(cx, y), 6, linePaint);
            canvas.drawCircle(Offset(cx - 2, y - 2), 0.8, fillPaint);
            canvas.drawCircle(Offset(cx + 2, y - 2), 0.8, fillPaint);
            final mouth = Path()
              ..addArc(
                Rect.fromCenter(center: Offset(cx, y + 0.5), width: 6, height: 5),
                0.2,
                2.7,
              );
            canvas.drawPath(mouth, linePaint);
            break;
          case 5:
            // Key / Location Pin
            canvas.drawCircle(Offset(cx, y - 2), 3, linePaint);
            canvas.drawLine(Offset(cx, y + 1), Offset(cx, y + 6), linePaint);
            canvas.drawLine(Offset(cx, y + 4), Offset(cx + 2.5, y + 4), linePaint);
            break;
        }
        col++;
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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

  void _sendMessage(AppStateProvider state, String threadId, {String? textOverride}) {
    final text = textOverride ?? _messageController.text.trim();
    if (text.isNotEmpty) {
      state.sendChatMessage(threadId, text);
      if (textOverride == null) {
        _messageController.clear();
      }
      setState(() {});
      _scrollToBottom();
    }
  }

  void _showAttachmentModal(BuildContext context, AppStateProvider state, String threadId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachOption(
                    Icons.insert_drive_file_rounded,
                    const Color(0xFF7F66FF),
                    'Document',
                    () {
                      Navigator.pop(ctx);
                      _sendMessage(state, threadId, textOverride: '📄 Sale_Deed_Verification_Doc.pdf (1.8 MB)');
                    },
                  ),
                  _buildAttachOption(
                    Icons.camera_alt_rounded,
                    const Color(0xFFD3396D),
                    'Camera',
                    () {
                      Navigator.pop(ctx);
                      _sendMessage(state, threadId, textOverride: '📷 [Live Room Photo Taken Just Now]');
                    },
                  ),
                  _buildAttachOption(
                    Icons.image_rounded,
                    const Color(0xFFAC44CF),
                    'Gallery',
                    () {
                      Navigator.pop(ctx);
                      _sendMessage(state, threadId, textOverride: '🖼️ [Attached 3 High-Res Property Photos]');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachOption(
                    Icons.location_on_rounded,
                    const Color(0xFF1FA855),
                    'Location',
                    () {
                      Navigator.pop(ctx);
                      _sendMessage(state, threadId, textOverride: '📍 Live Google Maps Location: Gomti Nagar Extension, Lucknow (26.8500° N, 80.9499° E)');
                    },
                  ),
                  _buildAttachOption(
                    Icons.calendar_month_rounded,
                    const Color(0xFF02A698),
                    'Site Visit',
                    () {
                      Navigator.pop(ctx);
                      _sendMessage(state, threadId, textOverride: '🔑 Site Visit Requested: Tomorrow 4:30 PM (Pass Code: 8821)');
                    },
                  ),
                  _buildAttachOption(
                    Icons.person_rounded,
                    const Color(0xFF007BFC),
                    'Contact',
                    () {
                      Navigator.pop(ctx);
                      _sendMessage(state, threadId, textOverride: '👤 Shared Landlord Direct Contact Card: +91 9135321898');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachOption(IconData icon, Color color, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF54656F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8696A0).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF008069),
            ),
          ),
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFEFEAE2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF008069), // Classic WhatsApp Green
        elevation: 1,
        titleSpacing: 0,
        leadingWidth: 36,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundImage: NetworkImage(thread.avatarUrl),
              backgroundColor: Colors.white24,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.participantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _isOtherTyping
                        ? 'typing...'
                        : (thread.isOnline ? 'online' : 'last seen today at 11:42 AM'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: _isOtherTyping
                          ? const Color(0xFF25D366)
                          : const Color(0xFFE2F4EA),
                      fontWeight:
                          _isOtherTyping ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Colors.white, size: 23),
            tooltip: 'Video Call',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Starting live WhatsApp video call with ${widget.participantName}...',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF008069),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.white, size: 21),
            tooltip: 'Voice Call',
            onPressed: () => LauncherUtils.makePhoneCall(context, '+91 98765 43210'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (val) {
              if (val == 'clear') {
                setState(() {
                  thread.messages.clear();
                });
              } else if (val == 'call') {
                LauncherUtils.makePhoneCall(context, '+91 98765 43210');
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'view', child: Text('View Property Info')),
              const PopupMenuItem(value: 'media', child: Text('Media, links, and docs')),
              const PopupMenuItem(value: 'search', child: Text('Search')),
              const PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
              const PopupMenuItem(value: 'clear', child: Text('Clear chat')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // WhatsApp Doodle Background Wallpaper
            Positioned.fill(
              child: CustomPaint(
                painter: WhatsAppWallpaperPainter(),
              ),
            ),

            // Chat Flow Content
            Column(
              children: [
                // Pinned Property Context Card (WhatsApp forwarded card style)
                if (widget.propertyTitle.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        left: BorderSide(color: Color(0xFF008069), width: 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.apartment_rounded,
                          color: Color(0xFF008069),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.propertyTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111B21),
                                ),
                              ),
                              Text(
                                'Direct Landlord Listing • Verified',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: const Color(0xFF667781),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Verified',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF008069),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Date Badge
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      'TODAY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF54656F),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: thread.messages.length,
                    itemBuilder: (context, index) {
                      final msg = thread.messages[index];
                      final isSender = msg.isSender;
                      final timeStr = DateFormat('hh:mm a').format(msg.timestamp);

                      return Align(
                        alignment:
                            isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
                          decoration: BoxDecoration(
                            // WhatsApp Outgoing: #E7FFDB / #DCF8C6, Incoming: #FFFFFF
                            color: isSender
                                ? const Color(0xFFE7FFDB)
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isSender ? 10 : 0),
                              topRight: Radius.circular(isSender ? 0 : 10),
                              bottomLeft: const Radius.circular(10),
                              bottomRight: const Radius.circular(10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 1.5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6, bottom: 2),
                                child: Text(
                                  msg.text,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF111B21),
                                    fontSize: 14.5,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeStr,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF667781),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  if (isSender) ...[
                                    const SizedBox(width: 3),
                                    // WhatsApp Double Blue Ticks
                                    const Icon(
                                      Icons.done_all_rounded,
                                      size: 16,
                                      color: Color(0xFF53BDEB),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Typing indicator bubble if other is typing
                if (_isOtherTyping)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 12, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'typing',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF008069),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF008069),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Quick Action Chips (WhatsApp Business style)
                Container(
                  height: 34,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      _buildQuickChip('📍 Share Location', () {
                        _sendMessage(state, thread.id,
                            textOverride:
                                '📍 Here is the exact location: Gomti Nagar Extension, Lucknow.');
                      }),
                      _buildQuickChip('📅 Book Visit', () {
                        _sendMessage(state, thread.id,
                            textOverride:
                                '📅 Hi, I would like to schedule a site visit for tomorrow.');
                      }),
                      _buildQuickChip('💰 Negotiable?', () {
                        _sendMessage(state, thread.id,
                            textOverride:
                                '💰 Is the asking rent/price slightly negotiable?');
                      }),
                      _buildQuickChip('🔑 Ready to Move?', () {
                        _sendMessage(state, thread.id,
                            textOverride:
                                '🔑 Is the property ready for immediate move-in?');
                      }),
                      _buildQuickChip('📄 Share Proof', () {
                        _sendMessage(state, thread.id,
                            textOverride:
                                '📄 Sale Deed and Electricity connection records verified.');
                      }),
                    ],
                  ),
                ),

                // Authentic WhatsApp Input Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Main WhatsApp Pill Input Field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: Color(0xFF8696A0),
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  textInputAction: TextInputAction.send,
                                  minLines: 1,
                                  maxLines: 5,
                                  onSubmitted: (_) =>
                                      _sendMessage(state, thread.id),
                                  onChanged: (val) {
                                    setState(() {});
                                    if (_currentThreadId != null) {
                                      SocketService.instance.sendTyping(
                                        threadId: _currentThreadId!,
                                        senderName: state.userName,
                                        isTyping: val.trim().isNotEmpty,
                                      );
                                    }
                                  },
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    color: const Color(0xFF111B21),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Message',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF8696A0),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Transform.rotate(
                                  angle: -0.7,
                                  child: const Icon(
                                    Icons.attach_file_rounded,
                                    color: Color(0xFF8696A0),
                                    size: 23,
                                  ),
                                ),
                                onPressed: () => _showAttachmentModal(
                                    context, state, thread.id),
                              ),
                              if (_messageController.text.trim().isEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Color(0xFF8696A0),
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _sendMessage(state, thread.id,
                                        textOverride:
                                            '📷 [Photo: Living Room & Balcony View]');
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Green WhatsApp Circular Send / Mic Button
                      GestureDetector(
                        onTap: () {
                          if (_messageController.text.trim().isNotEmpty) {
                            _sendMessage(state, thread.id);
                          } else {
                            _sendMessage(state, thread.id,
                                textOverride: '🎤 Voice Note (0:12)');
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A884), // Authentic WhatsApp Green
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _messageController.text.trim().isNotEmpty
                                ? Icons.send_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
