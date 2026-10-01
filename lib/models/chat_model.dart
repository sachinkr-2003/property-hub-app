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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime ts = DateTime.now();
    if (json['timestamp'] != null) {
      ts = DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now();
    }
    return ChatMessage(
      id: json['customId'] ?? json['_id'] ?? json['id'] ?? '',
      text: json['text'] ?? '',
      isSender: json['isSender'] ?? true,
      timestamp: ts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customId': id,
      'text': text,
      'isSender': isSender,
      'timestamp': timestamp.toIso8601String(),
    };
  }
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

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    DateTime ts = DateTime.now();
    if (json['lastMessageTime'] != null) {
      ts = DateTime.tryParse(json['lastMessageTime'].toString()) ?? DateTime.now();
    }
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    final parsedMessages = rawMessages
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();

    return ChatThread(
      id: json['customId'] ?? json['_id'] ?? json['id'] ?? '',
      participantName: json['participantName'] ?? 'Owner',
      participantRole: json['participantRole'] ?? 'Direct Owner',
      avatarUrl: json['avatarUrl'] ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      propertyOrItemTitle: json['propertyTitle'] ?? json['propertyOrItemTitle'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: ts,
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? true,
      messages: parsedMessages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customId': id,
      'participantName': participantName,
      'participantRole': participantRole,
      'avatarUrl': avatarUrl,
      'propertyTitle': propertyOrItemTitle,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
