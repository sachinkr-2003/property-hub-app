import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsService {
  /// Google Maps Platform API Key
  static const String apiKey = 'AIzaSyBEss4wpsQ0o9WPBjDgHsSByUzFuo2oSNE';

  /// Get geographic coordinates for known city localities
  static LatLng getCoordinatesForLocality(String locality) {
    final clean = locality.toLowerCase();
    if (clean.contains('extension')) return const LatLng(26.8289, 81.0189);
    if (clean.contains('gomti')) return const LatLng(26.8526, 80.9995);
    if (clean.contains('indira')) return const LatLng(26.8778, 80.9856);
    if (clean.contains('aliganj')) return const LatLng(26.8887, 80.9431);
    if (clean.contains('hazratganj')) return const LatLng(26.8489, 80.9450);
    if (clean.contains('mahanagar')) return const LatLng(26.8755, 80.9576);
    if (clean.contains('vikas')) return const LatLng(26.8920, 80.9525);
    if (clean.contains('jankipuram')) return const LatLng(26.9142, 80.9388);
    if (clean.contains('golf') || clean.contains('sushant')) return const LatLng(26.7865, 80.9863);
    if (clean.contains('ashiyana')) return const LatLng(26.7861, 80.9089);
    if (clean.contains('polytechnic') || clean.contains('munshi')) return const LatLng(26.8789, 80.9982);
    if (clean.contains('charbagh')) return const LatLng(26.8322, 80.9234);
    // Default Lucknow city center
    return const LatLng(26.8467, 80.9462);
  }

  /// Generate high-resolution Google Static Map image URL with custom marker
  static String getStaticMapUrl({
    required String location,
    int width = 640,
    int height = 300,
    int zoom = 15,
    String markerColor = '0x0E6456', // App theme primary green
  }) {
    final query = Uri.encodeComponent('$location, Lucknow, Uttar Pradesh');
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$query'
        '&zoom=$zoom'
        '&size=${width}x$height'
        '&scale=2'
        '&maptype=roadmap'
        '&markers=color:$markerColor%7Clabel:P%7C$query'
        '&key=$apiKey';
  }

  /// Open location in native Google Maps app or fallback to browser
  static Future<void> openInGoogleMaps(BuildContext context, String location) async {
    final cleanLoc = location.trim().isNotEmpty ? location : 'Gomti Nagar, Lucknow';
    final query = Uri.encodeComponent('$cleanLoc, Lucknow, Uttar Pradesh');

    // 1. Native geo intent for Android/iOS Google Maps app
    final nativeUri = Uri.parse('geo:0,0?q=$query');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri);
        return;
      }
    } catch (_) {}

    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch Google Maps: $e')),
        );
      }
    }
  }

  /// Open turn-by-turn navigation directions in Google Maps
  static Future<void> openDirections(BuildContext context, String destination) async {
    final cleanDest = destination.trim().isNotEmpty ? destination : 'Gomti Nagar, Lucknow';
    final query = Uri.encodeComponent('$cleanDest, Lucknow, Uttar Pradesh');
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open directions: $e')),
        );
      }
    }
  }
}
