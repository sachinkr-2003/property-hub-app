import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_state_provider.dart';
import '../chat/chat_screen.dart';
import '../visits/my_visits_screen.dart';
import '../../owner/kyc/owner_kyc_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif-1',
      'type': 'kyc',
      'title': 'Property Verification Approved',
      'subtitle': 'Your 3 BHK Flat in Indira Nagar has been verified and marked genuine.',
      'time': '10 mins ago',
      'icon': Icons.verified_user_rounded,
      'color': AppTheme.verifiedGreen,
    },
    {
      'id': 'notif-2',
      'type': 'chat',
      'title': 'New Message from Owner',
      'subtitle': 'Rohit Sharma: "Yes, it is available. Would you like to visit?"',
      'time': '35 mins ago',
      'icon': Icons.chat_bubble_rounded,
      'color': AppTheme.primary,
    },
    {
      'id': 'notif-3',
      'type': 'visit',
      'title': 'Visit Request Confirmed',
      'subtitle': 'Visit confirmed for tomorrow at 5:00 PM for Indira Nagar flat.',
      'time': '2 hours ago',
      'icon': Icons.calendar_month_rounded,
      'color': AppTheme.infoBlue,
    },
    {
      'id': 'notif-4',
      'type': 'service',
      'title': 'Tiffin Service Booked',
      'subtitle': 'Your monthly subscription has started. Lunch delivery arrives at 1:00 PM.',
      'time': 'Yesterday',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFF97316),
    },
  ];

  void _handleNotificationTap(Map<String, dynamic> n) {
    final type = n['type'] as String?;
    switch (type) {
      case 'chat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatListScreen()),
        );
        break;
      case 'visit':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyVisitsScreen()),
        );
        break;
      case 'kyc':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnerKycScreen()),
        );
        break;
      case 'service':
        final state = Provider.of<AppStateProvider>(context, listen: false);
        state.setUserNavIndex(2); // Services tab
        Navigator.pop(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(n['title'] as String)),
        );
    }
  }

  void _clearAllNotifications() {
    if (_notifications.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Notifications?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to dismiss all current notifications?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton.icon(
              onPressed: _clearAllNotifications,
              icon: const Icon(Icons.clear_all_rounded, size: 18, color: AppTheme.errorRed),
              label: Text(
                'Clear All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.errorRed,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All Caught Up!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You have no pending notifications. Inquiries and visit updates will appear here.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Home'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  final id = n['id'] as String;

                  return Dismissible(
                    key: Key(id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed),
                    ),
                    onDismissed: (_) {
                      setState(() {
                        _notifications.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${n['title']} dismissed'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () => _handleNotificationTap(n),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (n['color'] as Color).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n['title'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        n['time'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n['subtitle'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Tap to view details',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 12,
                                        color: AppTheme.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
