import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final String deepLink;
  final bool isRead;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.deepLink = 'app://home',
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    if (json['createdAt'] != null) {
      dt = DateTime.tryParse(json['createdAt'].toString());
    }
    return NotificationItem(
      id: json['customId'] ?? json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['subtitle'] ?? '',
      type: json['type'] ?? 'general',
      deepLink: json['deepLink'] ?? 'app://home',
      isRead: json['isRead'] ?? false,
      createdAt: dt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'deepLink': deepLink,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? deepLink,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      deepLink: deepLink ?? this.deepLink,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get timeAgo {
    if (createdAt == null) return 'Recently';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  IconData get icon {
    switch (type) {
      case 'kyc':
        return Icons.verified_user_rounded;
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'visit':
        return Icons.calendar_month_rounded;
      case 'service':
        return Icons.restaurant_rounded;
      case 'lead':
        return Icons.people_alt_rounded;
      case 'broadcast':
      default:
        return Icons.campaign_rounded;
    }
  }

  Color get color {
    switch (type) {
      case 'kyc':
        return AppTheme.verifiedGreen;
      case 'chat':
        return AppTheme.primary;
      case 'visit':
        return AppTheme.infoBlue;
      case 'service':
        return const Color(0xFFF97316);
      case 'lead':
        return const Color(0xFF8B5CF6);
      case 'broadcast':
      default:
        return const Color(0xFFEAB308);
    }
  }
}
