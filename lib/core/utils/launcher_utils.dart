import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class LauncherUtils {
  static Future<void> makePhoneCall(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open dialer for $phone'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  static Future<void> openWhatsApp(
    BuildContext context,
    String phone, {
    String? message,
  }) async {
    // Format phone for international standard
    String cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.length == 10) {
      cleanDigits = '91$cleanDigits';
    }

    final query = message != null && message.isNotEmpty
        ? '?text=${Uri.encodeComponent(message)}'
        : '';
    final uri = Uri.parse('https://wa.me/$cleanDigits$query');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp is not installed on this device'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp for $phone'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  static Future<void> openMapLocation(
    BuildContext context,
    String query,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
