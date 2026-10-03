import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
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
    {'title': 'Flat', 'icon': Icons.apartment_rounded, 'desc': 'Apartment, Society Flat'},
    {'title': 'House', 'icon': Icons.home_rounded, 'desc': 'Villa, Kothi, Independent House'},
    {'title': 'PG', 'icon': Icons.hotel_rounded, 'desc': 'Paying Guest, Hostel, Co-living'},
    {'title': 'Room', 'icon': Icons.meeting_room_rounded, 'desc': 'Single Room, 1 RK Studio'},
    {'title': 'Office', 'icon': Icons.business_rounded, 'desc': 'Commercial Space, Shop, Cabin'},
    {'title': 'Plot', 'icon': Icons.landscape_rounded, 'desc': 'Residential Land, Colony Plot'},
  ];

  // Common Form Controllers
  late TextEditingController _titleController;
  late TextEditingController _areaController;
  late TextEditingController _priceController;
  late TextEditingController _depositController;
  late TextEditingController _localityController;

  // Category Specific States
  String _listingType = 'Rent'; // Rent or Buy
  int _bhk = 2; // Flat & House
  String _furnishing = 'Semi-Furnished'; // Flat, House, Room

  // House specific
  String _houseType = 'Independent Villa';
  String _parking = 'Car & Bike';

  // PG specific
  String _pgSharing = 'Double Sharing';
  String _pgTarget = 'Boys Only';
  String _pgMeals = 'All 3 Meals Included';
  String _pgWashroom = 'Attached Washroom';

  // Room specific
  String _roomType = '1 RK Studio';
  String _roomWashroom = 'Attached Washroom';
  String _roomBalcony = 'Attached Balcony';

  // Office specific
  String _officeType = 'Furnished Office Space';
  String _officeSeats = '10 - 25 Seats';
  String _officeWashroom = 'Private Washroom';

  // Plot specific
  String _plotType = 'Residential Plot';
  String _plotBoundary = 'Full Boundary Wall';
  String _plotRoadWidth = '40 Feet Road';

  // Amenities
  final Set<String> _selectedAmenities = {};

  // Photos
  final List<XFile> _pickedImages = [];

  // Documents
  String? _deedDocPath;
  String? _taxReceiptPath;
  String? _govIdPath;
  bool _isUploadingData = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Modern 2 BHK Flat in Gomti Nagar');
    _areaController = TextEditingController(text: '1150');
    _priceController = TextEditingController(text: '15000');
    _depositController = TextEditingController(text: '30000');
    _localityController = TextEditingController(text: 'Gomti Nagar, Lucknow');

    _resetCategorySpecificFields('Flat');
  }

  void _onCategorySelected(String cat) {
    setState(() {
      _selectedCategory = cat;
      _resetCategorySpecificFields(cat);
    });
  }

  void _resetCategorySpecificFields(String cat) {
    _selectedAmenities.clear();
    final defaultAmenities = _getAmenitiesForCategory(cat);
    _selectedAmenities.addAll(defaultAmenities.take(4));

    if (cat == 'Flat') {
      _listingType = 'Rent';
      _bhk = 2;
      _furnishing = 'Semi-Furnished';
      _titleController.text = 'Modern 2 BHK Flat with Balcony';
      _areaController.text = '1150';
      _priceController.text = '15000';
      _depositController.text = '30000';
    } else if (cat == 'House') {
      _listingType = 'Rent';
      _bhk = 3;
      _houseType = 'Independent Villa';
      _furnishing = 'Semi-Furnished';
      _parking = 'Car & Bike';
      _titleController.text = 'Spacious 3 BHK Independent House / Villa';
      _areaController.text = '1800';
      _priceController.text = '24000';
      _depositController.text = '48000';
    } else if (cat == 'PG') {
      _listingType = 'Rent';
      _pgSharing = 'Double Sharing';
      _pgTarget = 'Boys Only';
      _pgMeals = 'All 3 Meals Included';
      _pgWashroom = 'Attached Washroom';
      _titleController.text = 'Luxury PG with AC & Meals for Students';
      _areaController.text = '250';
      _priceController.text = '7500';
      _depositController.text = '7500';
    } else if (cat == 'Room') {
      _listingType = 'Rent';
      _roomType = '1 RK Studio';
      _roomWashroom = 'Attached Washroom';
      _furnishing = 'Furnished (Bed & Almirah)';
      _titleController.text = 'Cozy 1 RK Studio Room for Bachelors';
      _areaController.text = '350';
      _priceController.text = '6500';
      _depositController.text = '6500';
    } else if (cat == 'Office') {
      _listingType = 'Rent';
      _officeType = 'Furnished Office Space';
      _officeSeats = '10 - 25 Seats';
      _officeWashroom = 'Private Washroom';
      _titleController.text = 'Fully Furnished Commercial Office Space';
      _areaController.text = '1200';
      _priceController.text = '45000';
      _depositController.text = '90000';
    } else if (cat == 'Plot') {
      _listingType = 'Buy';
      _plotType = 'Residential Plot';
      _plotBoundary = 'Full Boundary Wall';
      _plotRoadWidth = '40 Feet Road';
      _titleController.text = 'Prime Gated Township Corner Plot';
      _areaController.text = '1500';
      _priceController.text = '2250000';
      _depositController.text = '50000';
    }
  }

  List<String> _getAmenitiesForCategory(String cat) {
    switch (cat) {
      case 'Flat':
        return [
          'Lift / Elevator',
          'Covered Car Parking',
          '100% Power Backup',
          '24/7 Security & CCTV',
          'Gym & Clubhouse',
          '24/7 Water Supply',
          'Piped Gas (PNG)',
          'Park Facing Balcony',
        ];
      case 'House':
        return [
          'Private Car Parking',
          'Private Garden / Lawn',
          'Full Power Backup',
          '24/7 Security & CCTV',
          'Private Terrace Access',
          'Borewell & Water Tank',
          'Pet Friendly',
          'Modular Kitchen',
        ];
      case 'PG':
        return [
          'High-Speed Wi-Fi',
          'Daily Room Cleaning',
          'Hygienic Meals / Mess',
          'RO Drinking Water',
          'Air Conditioner / Cooler',
          'Washing Machine',
          'Geyser / Hot Water',
          '24/7 CCTV & Biometric',
        ];
      case 'Room':
        return [
          'High-Speed Wi-Fi',
          'Attached Washroom',
          'Separate Private Entry',
          'Bike Parking',
          '24/7 Water Supply',
          'AC / Cooler Point',
          'Kitchen Space Allowed',
          'No Owner Interference',
        ];
      case 'Office':
        return [
          'High-Speed Fiber Internet',
          'Conference / Meeting Room',
          'Central Air Conditioning',
          'Pantry / Cafeteria',
          '100% DG Power Backup',
          '24/7 Security & CCTV',
          'Reserved Car Parking',
          'High-Speed Elevators',
        ];
      case 'Plot':
        return [
          'Immediate Registry & Mutation',
          'Gated Township with Gate',
          '30+ Ft Wide Concrete Road',
          'Street Lighting Installed',
          'Underground Drainage / Sewer',
          'Electricity Line Available',
          'Park Facing Corner Plot',
          'Water Pipeline Connected',
        ];
      default:
        return [
          'Parking',
          'Lift',
          'Security',
          'Gym',
          'Power Backup',
          'Garden',
          'Wi-Fi',
          'Water Supply 24/7',
        ];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await picker.pickMultiImage(
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 70,
        );
        if (images.isNotEmpty) {
          setState(() {
            _pickedImages.addAll(images);
          });
        }
      } else {
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 70,
        );
        if (image != null) {
          setState(() {
            _pickedImages.add(image);
          });
        }
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

  Future<void> _pickDocument(String type) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Ownership Document Source',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload official papers (PDF or Photo) to receive 100% Verified badge',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)),
                  ),
                  title: Text(
                    'Upload PDF Document',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Registry Deed, Electricity Bill (.pdf)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'PDF upload: Camera se ya Gallery se photo lo — PDF support jald aayega!',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                        backgroundColor: const Color(0xFF6366F1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
                  ),
                  title: Text(
                    'Choose Photo from Gallery',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    'JPG, PNG photo of original paper',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                    if (picked != null) {
                      setState(() {
                        if (type == 'deed') {
                          _deedDocPath = picked.path;
                        } else if (type == 'tax') {
                          _taxReceiptPath = picked.path;
                        } else if (type == 'id') {
                          _govIdPath = picked.path;
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF7C3AED)),
                  ),
                  title: Text(
                    'Take Photo with Camera',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Capture document right now',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                    if (picked != null) {
                      setState(() {
                        if (type == 'deed') {
                          _deedDocPath = picked.path;
                        } else if (type == 'tax') {
                          _taxReceiptPath = picked.path;
                        } else if (type == 'id') {
                          _govIdPath = picked.path;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
    // Step 4 is photos (_currentStep == 3)
    if (_currentStep == 3 && _pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kripya property ki kam se kam 1 photo select karein.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _submitProperty();
    }
  }

  Future<void> _submitProperty() async {
    if (_pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kripya property ki kam se kam 1 photo select karein.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _currentStep = 3);
      return;
    }

    setState(() => _isUploadingData = true);
    final state = Provider.of<AppStateProvider>(context, listen: false);

    List<String> finalImages = [];
    if (_pickedImages.isNotEmpty) {
      final uploadPaths = _pickedImages.map((f) => f.path).toList();
      final uploadedUrls = await ApiService.uploadPropertyImages(uploadPaths);
      if (uploadedUrls.isNotEmpty) {
        finalImages = uploadedUrls;
      } else {
        // Safe fallback: Limit to max 3 photos and under 1.5MB to prevent MongoDB 16MB BSON crash
        int count = 0;
        for (final file in _pickedImages) {
          if (count >= 3) break;
          try {
            final bytes = await File(file.path).readAsBytes();
            if (bytes.lengthInBytes <= 1.5 * 1024 * 1024) {
              final ext = file.path.split('.').last.toLowerCase();
              final mime = (ext == 'png') ? 'image/png' : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
              final base64Str = base64Encode(bytes);
              finalImages.add('data:$mime;base64,$base64Str');
              count++;
            }
          } catch (_) {
            finalImages.add(file.path);
          }
        }
      }
    }

    String uploadedDeedUrl = '';
    if (_deedDocPath != null && _deedDocPath!.isNotEmpty) {
      final dUrl = await ApiService.uploadDeedDoc(_deedDocPath!);
      if (dUrl != null && dUrl.isNotEmpty) {
        uploadedDeedUrl = dUrl;
      } else {
        try {
          final bytes = await File(_deedDocPath!).readAsBytes();
          final ext = _deedDocPath!.split('.').last.toLowerCase();
          final mime = (ext == 'pdf') ? 'application/pdf' : 'image/jpeg';
          final base64Str = base64Encode(bytes);
          uploadedDeedUrl = 'data:$mime;base64,$base64Str';
        } catch (_) {}
      }
    }

    String summaryDescription = '';
    if (_selectedCategory == 'Flat') {
      summaryDescription = '$_bhk BHK Flat with $_furnishing, located at ${_localityController.text}. Verified direct owner listing.';
    } else if (_selectedCategory == 'House') {
      summaryDescription = '$_houseType with $_bhk BHK, $_parking, located at ${_localityController.text}. Verified direct owner listing.';
    } else if (_selectedCategory == 'PG') {
      summaryDescription = '$_pgSharing PG for $_pgTarget with $_pgMeals and $_pgWashroom. Located at ${_localityController.text}.';
    } else if (_selectedCategory == 'Room') {
      summaryDescription = '$_roomType with $_roomWashroom and $_roomBalcony. Located at ${_localityController.text}.';
    } else if (_selectedCategory == 'Office') {
      summaryDescription = '$_officeType with $_officeSeats capacity and $_officeWashroom. Prime location at ${_localityController.text}.';
    } else if (_selectedCategory == 'Plot') {
      summaryDescription = '$_plotType on $_plotRoadWidth with $_plotBoundary. Total area ${_areaController.text} sqft at ${_localityController.text}.';
    }

    final ownerPhone = state.userMobile.trim().isNotEmpty 
        ? state.userMobile.trim() 
        : (state.userPhone.trim().isNotEmpty ? state.userPhone.trim() : '+91 91353 21898');
    final ownerName = state.userName.trim().isNotEmpty ? state.userName.trim() : 'Property Owner';

    final newProp = Property(
      id: 'prop-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      type: _selectedCategory,
      listingType: _listingType,
      price: double.tryParse(_priceController.text) ?? 15000,
      deposit: double.tryParse(_depositController.text) ?? 30000,
      bhk: (_selectedCategory == 'Flat' || _selectedCategory == 'House') ? _bhk : 1,
      areaSqFt: int.tryParse(_areaController.text) ?? 1000,
      address: _localityController.text.trim(),
      locality: _localityController.text.split(',').first.trim(),
      city: 'Lucknow',
      images: finalImages,
      isVerified: false, // Strict admin verification required first
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      ownerRole: 'Direct Owner',
      amenities: _selectedAmenities.toList(),
      furnishing: _furnishing,
      description: summaryDescription,
      postedAt: DateTime.now(),
      status: 'Pending Verification',
      deedDocUrl: uploadedDeedUrl,
      deedDocName: _deedDocPath != null ? _deedDocPath!.split(Platform.pathSeparator).last : 'Registry / Title Deed Document',
      deedStatus: uploadedDeedUrl.isNotEmpty ? 'Pending Verification' : 'Pending Verification',
    );

    final created = await state.addProperty(newProp);
    if (!mounted) return;
    setState(() => _isUploadingData = false);

    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Property listing submit nahi ho saki. Internet connection check karein ya dobara try karein.'),
          backgroundColor: Colors.red.shade700,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitProperty,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

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
                'Submitted for Admin Verification!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your $_selectedCategory listing has been submitted. Our admin team will verify title documents and approve it shortly.',
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
            'List Your $_selectedCategory',
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
                        onPressed: _isUploadingData ? null : _nextStep,
                        child: _isUploadingData
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _currentStep == 5 ? 'Submit for Admin Verification' : 'Next Step',
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
        return 'Select Category';
      case 1:
        return '$_selectedCategory Details';
      case 2:
        return '$_selectedCategory Amenities';
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
        return _buildStep2CategorySpecificDetails();
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

  // ---------------------------------------------------------------------------
  // STEP 1: CATEGORY SELECTION
  // ---------------------------------------------------------------------------
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
          'Choose the specific real estate type you want to list.',
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
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = _selectedCategory == cat['title'];
            return InkWell(
              onTap: () => _onCategorySelected(cat['title'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : const Color(0xFFCBD5E1),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 34,
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat['desc'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppTheme.textMuted,
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

  // ---------------------------------------------------------------------------
  // STEP 2: CATEGORY SPECIFIC DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildStep2CategorySpecificDetails() {
    switch (_selectedCategory) {
      case 'Flat':
        return _buildFlatForm();
      case 'House':
        return _buildHouseForm();
      case 'PG':
        return _buildPgForm();
      case 'Room':
        return _buildRoomForm();
      case 'Office':
        return _buildOfficeForm();
      case 'Plot':
        return _buildPlotForm();
      default:
        return _buildFlatForm();
    }
  }

  // A. FLAT DETAILS FORM
  Widget _buildFlatForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Apartment / Flat Details', 'Specify flat configuration, floor, and rent.'),
        const SizedBox(height: 16),
        _buildPurposeSelector(allowSale: true),
        const SizedBox(height: 16),
        _buildBhkSelector(),
        const SizedBox(height: 16),
        _buildFurnishingSelector(),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Listing Title', hintText: 'e.g. Modern 2 BHK Flat with Balcony'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Carpet Area (Sqft)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: _listingType == 'Rent' ? 'Monthly Rent (₹)' : 'Price (₹)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _depositController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Security Deposit (₹)'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _localityController,
          decoration: const InputDecoration(labelText: 'Locality & City', hintText: 'e.g. Sector 14, Indira Nagar, Lucknow'),
        ),
      ],
    );
  }

  // B. HOUSE / VILLA FORM
  Widget _buildHouseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Independent House / Villa Details', 'Configure independent property structure & parking.'),
        const SizedBox(height: 16),
        _buildPurposeSelector(allowSale: true),
        const SizedBox(height: 16),
        _buildBhkSelector(),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'House Architecture Type',
          options: ['Independent Villa', 'Duplex House', 'Builder Floor', 'Row House'],
          selected: _houseType,
          onSelected: (val) => setState(() => _houseType = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Private Parking Availability',
          options: ['Car & Bike', 'Bike Only', 'No Parking'],
          selected: _parking,
          onSelected: (val) => setState(() => _parking = val),
        ),
        const SizedBox(height: 16),
        _buildFurnishingSelector(),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Listing Title', hintText: 'e.g. Spacious 3 BHK Villa with Garden'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Plot / Built-up Area (Sqft)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: _listingType == 'Rent' ? 'Monthly Rent (₹)' : 'Total Price (₹)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _depositController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Security Deposit (₹)'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _localityController,
          decoration: const InputDecoration(labelText: 'Locality & City'),
        ),
      ],
    );
  }

  // C. PG / HOSTEL FORM
  Widget _buildPgForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PG / Hostel Accommodation Details', 'For students & working singles. 0% brokerage.'),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Room Sharing Configuration',
          options: ['Single Room', 'Double Sharing', 'Triple Sharing', '4+ Sharing'],
          selected: _pgSharing,
          onSelected: (val) => setState(() => _pgSharing = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Tenant Gender Preference',
          options: ['Boys Only', 'Girls Only', 'Co-ed / Any'],
          selected: _pgTarget,
          onSelected: (val) => setState(() => _pgTarget = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Food / Meals Facility',
          options: ['All 3 Meals Included', 'Breakfast & Dinner', 'No Food / Self Cook'],
          selected: _pgMeals,
          onSelected: (val) => setState(() => _pgMeals = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Washroom Type',
          options: ['Attached Washroom', 'Common Washroom'],
          selected: _pgWashroom,
          onSelected: (val) => setState(() => _pgWashroom = val),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'PG Title', hintText: 'e.g. Modern PG with Food & Wi-Fi for Boys'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Rent per Bed (₹)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Security Deposit (₹)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _localityController,
          decoration: const InputDecoration(labelText: 'PG Location & Nearest Landmark (e.g. Near Coaching / Metro)'),
        ),
      ],
    );
  }

  // D. ROOM / 1RK FORM
  Widget _buildRoomForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Single Room / 1 RK Studio Details', 'Affordable individual bachelor rooms.'),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Room Configuration',
          options: ['1 RK Studio', 'Private Room in Flat', 'Independent Room'],
          selected: _roomType,
          onSelected: (val) => setState(() => _roomType = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Washroom Facility',
          options: ['Attached Washroom', 'Shared Washroom'],
          selected: _roomWashroom,
          onSelected: (val) => setState(() => _roomWashroom = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Balcony / Window',
          options: ['Attached Balcony', 'Window Facing Open', 'No Balcony'],
          selected: _roomBalcony,
          onSelected: (val) => setState(() => _roomBalcony = val),
        ),
        const SizedBox(height: 16),
        _buildFurnishingSelector(),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Room Title', hintText: 'e.g. Cozy 1 RK Studio with Attached Bath'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Rent (₹)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Security Deposit (₹)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _localityController,
          decoration: const InputDecoration(labelText: 'Locality & City'),
        ),
      ],
    );
  }

  // E. COMMERCIAL OFFICE FORM
  Widget _buildOfficeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Commercial / Office Space Details', 'Commercial offices, shops, and corporate setups.'),
        const SizedBox(height: 16),
        _buildPurposeSelector(allowSale: true),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Commercial Space Type',
          options: ['Furnished Office Space', 'Bare Shell Office', 'Retail Shop / Showroom', 'Co-working Desks'],
          selected: _officeType,
          onSelected: (val) => setState(() => _officeType = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Estimated Seating Capacity',
          options: ['5 - 10 Seats', '10 - 25 Seats', '25 - 50 Seats', '50+ Seats'],
          selected: _officeSeats,
          onSelected: (val) => setState(() => _officeSeats = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Washroom Setup',
          options: ['Private Washroom', 'Shared Complex Washroom'],
          selected: _officeWashroom,
          onSelected: (val) => setState(() => _officeWashroom = val),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Commercial Title', hintText: 'e.g. Plug & Play Office Space with Conference Room'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Super Area (Sqft)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: _listingType == 'Rent' ? 'Monthly Lease (₹)' : 'Price (₹)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _depositController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Security Deposit (₹)'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _localityController,
          decoration: const InputDecoration(labelText: 'Commercial Complex / Road Location'),
        ),
      ],
    );
  }

  // F. PLOT / LAND FORM
  Widget _buildPlotForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Plot / Land Details', 'Residential colonies, commercial land & farmhouse plots.'),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Plot Usage Category',
          options: ['Residential Plot', 'Commercial Plot', 'Gated Township', 'Farmhouse Land'],
          selected: _plotType,
          onSelected: (val) => setState(() => _plotType = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Boundary Wall Status',
          options: ['Full Boundary Wall', 'Partial Boundary', 'Open Plot'],
          selected: _plotBoundary,
          onSelected: (val) => setState(() => _plotBoundary = val),
        ),
        const SizedBox(height: 16),
        _buildCustomSelector(
          title: 'Approach Road Width',
          options: ['30 Feet Road', '40 Feet Road', '60 Feet (Main Road)'],
          selected: _plotRoadWidth,
          onSelected: (val) => setState(() => _plotRoadWidth = val),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Plot Listing Title', hintText: 'e.g. 1500 Sqft Gated Society Corner Plot'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Plot Area (Sqft)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Asking Price (₹)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _localityController,
          decoration: const InputDecoration(labelText: 'Locality & Township Name (e.g. Kisan Path, Lucknow)'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS FOR CATEGORY FORMS
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPurposeSelector({bool allowSale = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Listing Purpose', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
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
            if (allowSale) ...[
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
          ],
        ),
      ],
    );
  }

  Widget _buildBhkSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BHK Configuration', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4].map((b) {
            final isSel = _bhk == b;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => setState(() => _bhk = b),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.primary : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? AppTheme.primary : const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: Text(
                        b == 4 ? '4+ BHK' : '$b BHK',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
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
      ],
    );
  }

  Widget _buildFurnishingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Furnishing Status', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Semi-Furnished', 'Fully Furnished', 'Unfurnished'].map((f) {
            final isSel = _furnishing == f;
            return ChoiceChip(
              label: Text(f),
              selected: isSel,
              selectedColor: AppTheme.primary,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                color: isSel ? Colors.white : AppTheme.textPrimary,
                fontSize: 12,
              ),
              onSelected: (val) => setState(() => _furnishing = f),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomSelector({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSel = selected == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSel,
              selectedColor: AppTheme.primary,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                color: isSel ? Colors.white : AppTheme.textPrimary,
                fontSize: 12,
              ),
              onSelected: (val) {
                if (val) onSelected(opt);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: AMENITIES (ADAPTIVE PER CATEGORY)
  // ---------------------------------------------------------------------------
  Widget _buildStep3Amenities() {
    final available = _getAmenitiesForCategory(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_selectedCategory Amenities & Features',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select the specific facilities available for this $_selectedCategory.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        Column(
          children: available.map((amenity) {
            final isChecked = _selectedAmenities.contains(amenity);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isChecked ? AppTheme.primaryLight.withOpacity(0.4) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isChecked ? AppTheme.primary : const Color(0xFFE2E8F0)),
              ),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                activeColor: AppTheme.primary,
                title: Text(
                  amenity,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 4: PHOTOS & VIDEO
  // ---------------------------------------------------------------------------
  Widget _buildStep4Photos() {
    String helperText = 'Properties with 3+ clear photos receive 5x more inquiries from tenants.';
    if (_selectedCategory == 'PG') {
      helperText = 'Upload clear photos of the bedroom/beds, attached washroom, mess dining hall, and building entry.';
    } else if (_selectedCategory == 'Plot') {
      helperText = 'Upload clear photos of the plot land, frontage road, colony gate, and neighborhood.';
    } else if (_selectedCategory == 'Office') {
      helperText = 'Upload photos of the workstations, conference room, reception, and parking.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_selectedCategory Photos & Media',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helperText,
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
                      '30-Sec Video Tour (Optional)',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      'Walkthrough video gives 10x faster bookings',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Choose'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 5: OWNERSHIP DOCUMENTS
  // ---------------------------------------------------------------------------
  Widget _buildStep5Documents() {
    String doc1Title = 'Title Deed / Registry Copy';
    if (_selectedCategory == 'Plot') doc1Title = 'Land Registry / Khasra-Khatauni Copy';
    if (_selectedCategory == 'PG' || _selectedCategory == 'Room') doc1Title = 'Property Title / Allotment Letter';
    if (_selectedCategory == 'Office') doc1Title = 'Commercial Deed / Master Lease Document';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_selectedCategory Ownership Proof',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Admin verifies these documents to give you the 100% Verified Direct Owner badge.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        _buildDocUploadTile(
          doc1Title,
          _deedDocPath,
          () => _pickDocument('deed'),
        ),
        _buildDocUploadTile(
          'Electricity Bill / Municipality Receipt',
          _taxReceiptPath,
          () => _pickDocument('tax'),
        ),
        _buildDocUploadTile(
          'Owner Aadhaar / Government ID Card',
          _govIdPath,
          () => _pickDocument('id'),
        ),
      ],
    );
  }

  Widget _buildDocUploadTile(String title, String? filePath, VoidCallback onTap) {
    final bool isUploaded = filePath != null && filePath.isNotEmpty;
    final bool isPdf = isUploaded && filePath.toLowerCase().endsWith('.pdf');
    final String fileName = isUploaded ? filePath.split('/').last.split('\\').last : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUploaded ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUploaded 
                  ? (isPdf ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7)) 
                  : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isUploaded 
                  ? (isPdf ? Icons.picture_as_pdf_rounded : Icons.check_circle_rounded) 
                  : Icons.upload_file_rounded,
                color: isUploaded 
                  ? (isPdf ? const Color(0xFFDC2626) : AppTheme.verifiedGreen) 
                  : AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (isUploaded)
                    Text(
                      fileName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isPdf ? const Color(0xFFDC2626) : AppTheme.verifiedGreen,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              isUploaded ? (isPdf ? 'PDF Attached ✓' : 'Attached ✓') : 'Upload',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isUploaded ? AppTheme.verifiedGreen : AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 6: REVIEW & SUBMIT
  // ---------------------------------------------------------------------------
  Widget _buildStep6Submit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.fact_check_rounded, size: 44, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Review & Submit Listing',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your $_selectedCategory listing will be sent to the Admin team for verification.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('Category', _selectedCategory),
              _buildSummaryRow('Title', _titleController.text),
              _buildSummaryRow('Purpose', _listingType == 'Rent' ? 'For Rent' : 'For Sale'),
              _buildSummaryRow('Price', '₹ ${_priceController.text}'),
              _buildSummaryRow('Location', _localityController.text),
              _buildSummaryRow('Amenities', '${_selectedAmenities.length} Selected'),
              _buildSummaryRow('Photos', '${_pickedImages.length} Uploaded'),
              _buildSummaryRow('Ownership Proof', _deedDocPath != null ? 'Attached ✓' : 'Pending'),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Admin will verify this $_selectedCategory before making it visible to users.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF92400E), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
