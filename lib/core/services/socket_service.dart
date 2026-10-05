import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

typedef OnMessageReceivedCallback = void Function(String threadId, Map<String, dynamic> messageData);
typedef OnTypingCallback = void Function(String threadId, String senderName, bool isTyping);

class SocketService {
  static SocketService? _instance;
  static SocketService get instance => _instance ??= SocketService._();

  SocketService._();

  io.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final List<OnMessageReceivedCallback> _messageListeners = [];
  final List<OnTypingCallback> _typingListeners = [];

  void addMessageListener(OnMessageReceivedCallback listener) {
    if (!_messageListeners.contains(listener)) {
      _messageListeners.add(listener);
    }
  }

  void removeMessageListener(OnMessageReceivedCallback listener) {
    _messageListeners.remove(listener);
  }

  void addTypingListener(OnTypingCallback listener) {
    if (!_typingListeners.contains(listener)) {
      _typingListeners.add(listener);
    }
  }

  void removeTypingListener(OnTypingCallback listener) {
    _typingListeners.remove(listener);
  }

  /// Initialize and connect socket to live backend server
  void connect() {
    if (_socket != null && _socket!.connected) return;

    try {
      final serverUrl = ApiService.serverRootUrl;
      debugPrint('[SocketService] Connecting to: $serverUrl');

      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(2000)
            .setReconnectionAttempts(10)
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        debugPrint('⚡ [SocketService] Connected to real-time chat server!');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        debugPrint('🔌 [SocketService] Disconnected from chat server');
      });

      _socket!.onConnectError((err) {
        _isConnected = false;
        debugPrint('[SocketService] Connection error: $err');
      });

      // Listen for incoming messages from other participant
      _socket!.on('receive_message', (data) {
        if (data is Map) {
          final threadId = data['threadId']?.toString() ?? '';
          final messageMap = (data['message'] is Map)
              ? Map<String, dynamic>.from(data['message'] as Map)
              : <String, dynamic>{};

          for (final listener in _messageListeners) {
            listener(threadId, messageMap);
          }
        }
      });

      // Listen for typing indicator
      _socket!.on('user_typing', (data) {
        if (data is Map) {
          final threadId = data['threadId']?.toString() ?? '';
          final senderName = data['senderName']?.toString() ?? '';
          final isTyping = data['isTyping'] == true;

          for (final listener in _typingListeners) {
            listener(threadId, senderName, isTyping);
          }
        }
      });
    } catch (e) {
      debugPrint('[SocketService] Failed initializing socket: $e');
    }
  }

  /// Join specific chat room for a property thread
  void joinThread(String threadId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_thread', threadId);
    }
  }

  /// Leave specific chat room
  void leaveThread(String threadId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave_thread', threadId);
    }
  }

  /// Send instant chat message through WebSocket
  void sendMessage({
    required String threadId,
    required String text,
    required String senderName,
    String? senderId,
    bool isSender = true,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', {
        'threadId': threadId,
        'text': text.trim(),
        'senderName': senderName,
        'senderId': senderId ?? 'user',
        'isSender': isSender,
      });
    }
  }

  /// Send real-time typing status
  void sendTyping({
    required String threadId,
    required String senderName,
    required bool isTyping,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing', {
        'threadId': threadId,
        'senderName': senderName,
        'isTyping': isTyping,
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }
}
