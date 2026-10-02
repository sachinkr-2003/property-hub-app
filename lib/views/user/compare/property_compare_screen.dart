import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_image.dart';
import '../../../models/property_model.dart';
import '../../../providers/app_state_provider.dart';
import '../properties/property_detail_screen.dart';

class PropertyCompareScreen extends StatefulWidget {
  final Property? initialPropertyA;
  final Property? initialPropertyB;

  const PropertyCompareScreen({
    super.key,
    this.initialPropertyA,
    this.initialPropertyB,
  });

  @override
  State<PropertyCompareScreen> createState() => _PropertyCompareScreenState();
}

class _PropertyCompareScreenState extends State<PropertyCompareScreen> {
  Property? _propertyA;
  Property? _propertyB;

  @override
  void initState() {
    super.initState();
    _propertyA = widget.initialPropertyA;
    _propertyB = widget.initialPropertyB;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final allProperties = state.properties;

    // Default selection if not provided
    if (_propertyA == null && allProperties.isNotEmpty) {
      _propertyA = allProperties[0];
    }
    if (_propertyB == null && allProperties.length > 1) {
      _propertyB = allProperties[1];
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Compare Properties',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector Row
              Row(
                children: [
                  Expanded(
                    child: _buildPropertySelector(
                      title: 'Property 1',
                      selected: _propertyA,
                      properties: allProperties,
                      onChanged: (prop) => setState(() => _propertyA = prop),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildPropertySelector(
                      title: 'Property 2',
                      selected: _propertyB,
                      properties: allProperties,
                      onChanged: (prop) => setState(() => _propertyB = prop),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_propertyA != null && _propertyB != null) ...[
                // Side by Side Cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPropertyPreviewCard(_propertyA!)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPropertyPreviewCard(_propertyB!)),
                  ],
                ),

                const SizedBox(height: 24),

                // Comparison Matrix Table
                Text(
                  'Key Comparison Highlights',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildComparisonRow(
                        'Monthly Rent',
                        _propertyA!.formattedPrice,
                        _propertyB!.formattedPrice,
                        highlightA: _propertyA!.price <= _propertyB!.price,
                        highlightB: _propertyB!.price < _propertyA!.price,
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildComparisonRow(
                        'Security Deposit',
                        _propertyA!.deposit != null
                            ? '₹${_propertyA!.deposit!.toStringAsFixed(0)}'
                            : 'N/A',
                        _propertyB!.deposit != null
                            ? '₹${_propertyB!.deposit!.toStringAsFixed(0)}'
                            : 'N/A',
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildComparisonRow(
                        'BHK & Size',
                        '${_propertyA!.bhk} BHK (${_propertyA!.areaSqFt} sq.ft)',
                        '${_propertyB!.bhk} BHK (${_propertyB!.areaSqFt} sq.ft)',
                        highlightA: _propertyA!.areaSqFt >= _propertyB!.areaSqFt,
                        highlightB: _propertyB!.areaSqFt > _propertyA!.areaSqFt,
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildComparisonRow(
                        'Furnishing',
                        _propertyA!.furnishing,
                        _propertyB!.furnishing,
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildComparisonRow(
                        'Tenant Allowed',
                        _propertyA!.targetTenant,
                        _propertyB!.targetTenant,
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildComparisonRow(
                        'Locality',
                        _propertyA!.locality,
                        _propertyB!.locality,
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildComparisonRow(
                        'Brokerage Fee',
                        'Zero (Direct Owner)',
                        'Zero (Direct Owner)',
                        isGreen: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Amenities Checklist Comparison
                Text(
                  'Amenities Comparison',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildAmenityCompareRow('Wi-Fi Internet', _propertyA!, _propertyB!, 'Wi-Fi'),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildAmenityCompareRow('Air Conditioning (AC)', _propertyA!, _propertyB!, 'AC'),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildAmenityCompareRow('Power Backup', _propertyA!, _propertyB!, 'Power Backup'),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildAmenityCompareRow('Parking', _propertyA!, _propertyB!, 'Parking'),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildAmenityCompareRow('Gated Security', _propertyA!, _propertyB!, 'Security'),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildAmenityCompareRow('Elevator / Lift', _propertyA!, _propertyB!, 'Lift'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySelector({
    required String title,
    required Property? selected,
    required List<Property> properties,
    required ValueChanged<Property?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Property>(
          isExpanded: true,
          value: selected,
          hint: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12)),
          items: properties.map((p) {
            return DropdownMenuItem<Property>(
              value: p,
              child: Text(
                p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPropertyPreviewCard(Property property) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(property: property),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: AppImage(
                path: property.firstImageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.formattedPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'View Details →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String valA,
    String valB, {
    bool highlightA = false,
    bool highlightB = false,
    bool isGreen = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              valA,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: highlightA ? FontWeight.w800 : FontWeight.w600,
                color: isGreen
                    ? AppTheme.verifiedGreen
                    : highlightA
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
              ),
            ),
          ),
          Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
          Expanded(
            flex: 2,
            child: Text(
              valB,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: highlightB ? FontWeight.w800 : FontWeight.w600,
                color: isGreen
                    ? AppTheme.verifiedGreen
                    : highlightB
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityCompareRow(
    String amenityName,
    Property a,
    Property b,
    String keyword,
  ) {
    final hasA = a.amenities.any((item) => item.toLowerCase().contains(keyword.toLowerCase()));
    final hasB = b.amenities.any((item) => item.toLowerCase().contains(keyword.toLowerCase()));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              amenityName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Icon(
              hasA ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: hasA ? AppTheme.verifiedGreen : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ),
          Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
          Expanded(
            flex: 2,
            child: Icon(
              hasB ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: hasB ? AppTheme.verifiedGreen : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
