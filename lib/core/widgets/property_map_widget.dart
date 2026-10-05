import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/maps_service.dart';
import '../theme/app_theme.dart';

class PropertyMapWidget extends StatefulWidget {
  final String location;
  final String? address;

  const PropertyMapWidget({
    super.key,
    required this.location,
    this.address,
  });

  @override
  State<PropertyMapWidget> createState() => _PropertyMapWidgetState();
}

class _PropertyMapWidgetState extends State<PropertyMapWidget> {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;

  late final LatLng _targetCoordinates;
  late final Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _targetCoordinates = MapsService.getCoordinatesForLocality(widget.location);
    _markers = {
      Marker(
        markerId: const MarkerId('property_location'),
        position: _targetCoordinates,
        infoWindow: InfoWindow(
          title: widget.location.trim().isNotEmpty ? widget.location : 'Property Location',
          snippet: widget.address ?? 'Direct Owner Verified Property',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal)
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayLoc = widget.location.trim().isNotEmpty ? widget.location : 'Gomti Nagar';
    final fullAddr = (widget.address != null && widget.address!.trim().isNotEmpty)
        ? widget.address!
        : '$displayLoc, Lucknow';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interactive Property Map',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              fullAddr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Area',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Live Interactive Google Map
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _targetCoordinates,
                      zoom: 15.0,
                    ),
                    mapType: _currentMapType,
                    markers: _markers,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),

                  // Map Controls Top Floating Pill (Satellite Toggle)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: InkWell(
                      onTap: _toggleMapType,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _currentMapType == MapType.normal
                                  ? Icons.layers_outlined
                                  : Icons.map_outlined,
                              size: 13,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentMapType == MapType.normal ? 'Satellite' : 'Default',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Zoom In / Zoom Out Controls
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            _mapController?.animateCamera(CameraUpdate.zoomIn());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, size: 16, color: AppTheme.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {
                            _mapController?.animateCamera(CameraUpdate.zoomOut());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.remove, size: 16, color: AppTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Quick Navigation Action Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.textPrimary),
                    label: Text(
                      'Google Maps',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    onPressed: () => MapsService.openInGoogleMaps(context, displayLoc),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.directions_rounded, size: 15),
                    label: Text(
                      'Get Directions',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => MapsService.openDirections(context, displayLoc),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
