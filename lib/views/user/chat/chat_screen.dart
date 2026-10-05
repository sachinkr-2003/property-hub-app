import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    final filteredChats = state.chats.where((c) {
      if (_selectedFilter == 'Unread' && c.unreadCount == 0) return false;
      if (_selectedFilter == 'Owners' && !c.participantRole.toLowerCase().contains('owner')) return false;
      if (_selectedFilter == 'Tenants' && !c.participantRole.toLowerCase().contains('tenant')) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = c.participantName.toLowerCase().contains(query);
        final matchesTitle = c.propertyOrItemTitle.toLowerCase().contains(query);
        final matchesMsg = c.lastMessage.toLowerCase().contains(query);
        return matchesName || matchesTitle || matchesMsg;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF008069), // Classic WhatsApp Green
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search chats or properties...',
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 15),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              )
            : Text(
                'Property Hub',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded, color: Colors.white),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            tooltip: 'Camera',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Property Camera for instant photo sharing...'),
                  backgroundColor: Color(0xFF008069),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'new_chat', child: Text('New chat')),
              const PopupMenuItem(value: 'leads', child: Text('Site visit inquiries')),
              const PopupMenuItem(value: 'starred', child: Text('Starred messages')),
              const PopupMenuItem(value: 'settings', child: Text('Chat settings')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // WhatsApp Filter Pills (All, Unread, Owners, Tenants)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterPill('All'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Unread'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Owners'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Tenants'),
                ],
              ),
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 1),

            // Chats List
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF008069),
                onRefresh: () => state.loadLiveConversationsFromBackend(),
                child: filteredChats.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 52,
                                    color: Color(0xFF008069),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No chats match "$_searchQuery"'
                                      : 'No conversations yet',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111B21),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 36),
                                  child: Text(
                                    'When users and owners connect about listings or roommate matching, their chats will appear here.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF667781),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredChats.length,
                        separatorBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(left: 80, right: 16),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          final timeStr = _formatChatListTime(chat.lastMessageTime);

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatConversationScreen(
                                    participantName: chat.participantName,
                                    propertyTitle: chat.propertyOrItemTitle,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // WhatsApp Circular Avatar with Online Dot
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundImage: NetworkImage(chat.avatarUrl),
                                        backgroundColor: const Color(0xFFE2E8F0),
                                      ),
                                      if (chat.isOnline)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 13,
                                            height: 13,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF25D366), // WhatsApp Online Green
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Chat Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                chat.participantName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15.5,
                                                  color: const Color(0xFF111B21),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              timeStr,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11.5,
                                                fontWeight: chat.unreadCount > 0
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: chat.unreadCount > 0
                                                    ? const Color(0xFF25D366)
                                                    : const Color(0xFF667781),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            // WhatsApp Double Blue Ticks
                                            const Icon(
                                              Icons.done_all_rounded,
                                              size: 16,
                                              color: Color(0xFF53BDEB),
                                            ),
                                            const SizedBox(width: 4),
                                            if (chat.propertyOrItemTitle.isNotEmpty) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5E9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  chat.propertyOrItemTitle,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF008069),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                            ],
                                            Expanded(
                                              child: Text(
                                                chat.lastMessage,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13,
                                                  color: const Color(0xFF667781),
                                                ),
                                              ),
                                            ),
                                            if (chat.unreadCount > 0)
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF25D366),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '${chat.unreadCount}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      // WhatsApp Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00A884), // WhatsApp FAB Green
        elevation: 4,
        onPressed: () {
          // Open new chat / contacts picker
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Select any property from the catalog and tap "Chat with Owner" to start a new chat!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF008069),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isSelected = _selectedFilter == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF008069) : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF008069) : const Color(0xFF54656F),
          ),
        ),
      ),
    );
  }

  String _formatChatListTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDate).inDays;

    if (diff == 0) {
      return DateFormat('hh:mm a').format(dt);
    } else if (diff == 1) {
      return 'Yesterday';
    } else if (diff < 7) {
      return DateFormat('EEEE').format(dt);
    } else {
      return DateFormat('dd/MM/yy').format(dt);
    }
  }
}
