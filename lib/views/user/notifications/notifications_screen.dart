import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/notification_item_model.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      state.loadLiveNotificationsFromBackend();
    });
  }

  void _handleNotificationTap(NotificationItem n, AppStateProvider state) {
    state.markNotificationAsRead(n.id);

    final type = n.type.toLowerCase();
    final link = n.deepLink.toLowerCase();

    if (type == 'chat' || link.contains('chat')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatListScreen()),
      );
    } else if (type == 'visit' || link.contains('visit')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyVisitsScreen()),
      );
    } else if (type == 'kyc' || link.contains('kyc')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OwnerKycScreen()),
      );
    } else if (type == 'service' || link.contains('service')) {
      state.setUserNavIndex(2); // Services tab
      Navigator.pop(context);
    } else {
      // General Broadcast / Detail alert
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(n.icon, color: n.color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  n.title,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.message,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Received: ${n.timeAgo}',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    }
  }

  void _clearAllNotifications(AppStateProvider state) {
    if (state.notifications.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Notifications?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to dismiss all current notifications from your feed?',
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
              state.clearAllNotifications();
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
    final state = Provider.of<AppStateProvider>(context);
    final notifications = state.notifications;
    final unreadCount = state.unreadNotificationsCount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: AppTheme.primary,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            IconButton(
              tooltip: 'Mark all as read',
              icon: const Icon(Icons.done_all_rounded, size: 20, color: AppTheme.primary),
              onPressed: () => state.markAllNotificationsAsRead(),
            ),
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () => _clearAllNotifications(state),
              icon: const Icon(Icons.clear_all_rounded, size: 18, color: AppTheme.errorRed),
              label: Text(
                'Clear',
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
        child: RefreshIndicator(
          onRefresh: () => state.loadLiveNotificationsFromBackend(),
          child: state.isLoadingNotifications && notifications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: const BoxDecoration(
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
                              'You have no pending notifications. Inquiries, KYC updates, and announcements will appear here.',
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final n = notifications[index];

                        return InkWell(
                          onTap: () => _handleNotificationTap(n, state),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: n.isRead ? Colors.white : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: n.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBBF7D0),
                                width: n.isRead ? 1 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: n.color.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(n.icon, color: n.color, size: 22),
                                    ),
                                    if (!n.isRead)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 9,
                                          height: 9,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
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
                                              n.title,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                                fontSize: 13,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            n.timeAgo,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: n.isRead ? AppTheme.textMuted : AppTheme.primary,
                                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
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
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
