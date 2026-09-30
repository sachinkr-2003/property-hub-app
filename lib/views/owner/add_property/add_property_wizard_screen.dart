import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/property_model.dart';
import '../../../providers/app_state_provider.dart';

class AddPropertyWizardScreen extends StatefulWidget {
  const AddPropertyWizardScreen({super.key});

  @override
  State<AddPropertyWizardScreen> createState() => _AddPropertyWizardScreenState();
}

class _AddPropertyWizardScreenState extends State<AddPropertyWizardScreen> {
  int _currentStep = 0;

  // Step 1: Category
  String _selectedCategory = 'Flat';
  final List<Map<String, dynamic>> _categories = [
    {'title': 'Flat', 'icon': Icons.apartment_rounded},
    {'title': 'House', 'icon': Icons.home_rounded},
    {'title': 'PG', 'icon': Icons.hotel_rounded},
    {'title': 'Room', 'icon': Icons.meeting_room_rounded},
    {'title': 'Office', 'icon': Icons.business_rounded},
    {'title': 'Plot', 'icon': Icons.landscape_rounded},
  ];

  // Step 2: Details
  String _listingType = 'Rent';
  int _bhk = 2;
  final TextEditingController _titleController = TextEditingController(text: 'Spacious 2 BHK Apartment');
  final TextEditingController _areaController = TextEditingController(text: '1150');
  final TextEditingController _priceController = TextEditingController(text: '15000');
  final TextEditingController _depositController = TextEditingController(text: '30000');
  final TextEditingController _localityController = TextEditingController(text: 'Gomti Nagar, Lucknow');

  // Step 3: Amenities
  final List<String> _allAmenities = [
    'Parking',
    'Lift',
    'Security',
    'Gym',
    'Power Backup',
    'Garden',
    'Wi-Fi',
    'Water Supply 24/7',
  ];
  final Set<String> _selectedAmenities = {'Parking', 'Lift', 'Security', 'Wi-Fi'};

  // Step 4: Photos
  final List<XFile> _pickedImages = [];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Step 5: Docs
  final bool _titleDeedUploaded = true;
  final bool _taxReceiptUploaded = true;
  final bool _idProofUploaded = true;

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _submitProperty();
    }
  }

  void _submitProperty() {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final newProp = Property(
      id: 'prop-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      type: _selectedCategory,
      listingType: _listingType,
      price: double.tryParse(_priceController.text) ?? 15000,
      deposit: double.tryParse(_depositController.text) ?? 30000,
      bhk: _bhk,
      areaSqFt: int.tryParse(_areaController.text) ?? 1150,
      address: _localityController.text,
      locality: _localityController.text.split(',').first,
      city: 'Lucknow',
      images: _pickedImages.isNotEmpty
          ? _pickedImages.map((f) => f.path).toList()
          : [
              'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
              'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1000&q=80',
            ],
      isVerified: true,
      ownerName: 'Rajesh Kumar',
      ownerPhone: '+91 98765 43210',
      ownerRole: 'Direct Owner',
      amenities: _selectedAmenities.toList(),
      furnishing: 'Semi-Furnished',
      description: 'Brand new direct owner listing verified with title deed.',
      postedAt: DateTime.now(),
      status: 'Pending Verification',
    );

    state.addProperty(newProp);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.verifiedGreen, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Submitted for Verification!',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your property documents have been uploaded. Our verification team will verify it within 2 hours to give you the 100% Genuine Owner Badge.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // return to dashboard
                },
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmExitWizard(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Discard Property Listing?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Any details you entered for this listing will be lost.', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        } else {
          _confirmExitWizard(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'List Your Property',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                _confirmExitWizard(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
          // Step Progress Indicator Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.surfaceColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentStep + 1} of 6: ${_getStepTitle(_currentStep)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  '${((_currentStep + 1) / 6 * 100).toInt()}% Done',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 6,
            backgroundColor: const Color(0xFFE2E8F0),
            color: AppTheme.primary,
            minHeight: 4,
          ),

          // Step Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      child: Text('Back', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == 5 ? 'Submit for Verification' : 'Next Step',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Category';
      case 1:
        return 'Property Details';
      case 2:
        return 'Amenities';
      case 3:
        return 'Photos & Video';
      case 4:
        return 'Ownership Documents';
      case 5:
        return 'Review & Submit';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Category();
      case 1:
        return _buildStep2Details();
      case 2:
        return _buildStep3Amenities();
      case 3:
        return _buildStep4Photos();
      case 4:
        return _buildStep5Documents();
      case 5:
        return _buildStep6Submit();
      default:
        return const SizedBox();
    }
  }

  // Step 1: Category (Screen 5)
  Widget _buildStep1Category() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Property Category',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the type of real estate you want to list for rent or sale.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = _selectedCategory == cat['title'];
            return InkWell(
              onTap: () {
                setState(() => _selectedCategory = cat['title'] as String);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : const Color(0xFFCBD5E1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 36,
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Step 2: Property Details (Screen 6)
  Widget _buildStep2Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Details',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Listing Type (Rent vs Sell)
        Text(
          'Listing Purpose',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('For Rent')),
                selected: _listingType == 'Rent',
                onSelected: (val) => setState(() => _listingType = 'Rent'),
                selectedColor: AppTheme.primary,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: _listingType == 'Rent' ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('For Sale')),
                selected: _listingType == 'Buy',
                onSelected: (val) => setState(() => _listingType = 'Buy'),
                selectedColor: AppTheme.primary,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: _listingType == 'Buy' ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // BHK selector
        Text(
          'BHK Configuration',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4].map((b) {
            final isSel = _bhk == b;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => setState(() => _bhk = b),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.primary : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$b BHK',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Listing Title'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _areaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Carpet Area (in Sqft)'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _listingType == 'Rent' ? 'Monthly Rent (₹)' : 'Selling Price (₹)',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _localityController,
          decoration: const InputDecoration(labelText: 'Locality & City'),
        ),
      ],
    );
  }

  // Step 3: Amenities (Screen 7)
  Widget _buildStep3Amenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Amenities',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Check all facilities available at the property.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        Column(
          children: _allAmenities.map((amenity) {
            final isChecked = _selectedAmenities.contains(amenity);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.primary,
              title: Text(
                amenity,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedAmenities.add(amenity);
                  } else {
                    _selectedAmenities.remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 4: Photos & Video (Screen 8)
  Widget _buildStep4Photos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos & Video Tour',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Properties with 3+ clear photos receive 5x more inquiries from tenants.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        // Photo Upload Box
        InkWell(
          onTap: _showImageSourceDialog,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo_outlined, size: 36, color: AppTheme.primary),
                const SizedBox(height: 8),
                Text(
                  'Upload Photos (Camera or Gallery)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  _pickedImages.isEmpty
                      ? 'Tap here to pick photos from your phone'
                      : '${_pickedImages.length} Photos selected',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: _pickedImages.isEmpty ? AppTheme.textSecondary : AppTheme.verifiedGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_pickedImages.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedImages.length,
              itemBuilder: (context, index) {
                final img = _pickedImages[index];
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        image: DecorationImage(
                          image: FileImage(File(img.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: InkWell(
                        onTap: () => setState(() => _pickedImages.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Video Tour Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videocam_rounded, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Property Video Tour (Optional)',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      'Upload a 30-sec walkthrough video',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Choose File'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 5: Ownership Documents (Screen 9)
  Widget _buildStep5Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ownership Documents',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'To ensure 100% Direct Owner status and avoid fraud, please upload proof.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        _buildDocUploadTile('Title Deed / Registry Copy', _titleDeedUploaded),
        _buildDocUploadTile('Electricity / Property Tax Bill', _taxReceiptUploaded),
        _buildDocUploadTile('Aadhaar / Gov ID Proof', _idProofUploaded),
      ],
    );
  }

  Widget _buildDocUploadTile(String title, bool isUploaded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUploaded ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file_rounded,
            color: isUploaded ? AppTheme.verifiedGreen : AppTheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            isUploaded ? 'Uploaded' : 'Upload',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isUploaded ? AppTheme.verifiedGreen : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Step 6: Review & Submit (Screen 10)
  Widget _buildStep6Submit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.fact_check_rounded, size: 50, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Property is Ready for Verification',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'All 5 sections completed: Category, Details, Amenities, Photos, and Ownership Documents. Once submitted, our team will review the documents and activate your verified badge.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
