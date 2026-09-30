class ChatMessage {
  final String id;
  final String text;
  final bool isSender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isSender,
    required this.timestamp,
  });
}

class ChatThread {
  final String id;
  final String participantName;
  final String participantRole; // Owner / Tenant / Seller / Roommate
  final String avatarUrl;
  final String propertyOrItemTitle;
  String lastMessage;
  DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.participantName,
    required this.participantRole,
    required this.avatarUrl,
    required this.propertyOrItemTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = true,
    required this.messages,
  });
}
