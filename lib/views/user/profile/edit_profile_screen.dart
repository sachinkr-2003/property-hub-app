import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_image.dart';
import '../../../providers/app_state_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _localityController;

  String? _selectedImagePath; // Local picked image file path
  bool _isSaving = false;

  final List<String> _popularCities = [
    'Lucknow',
    'Kanpur',
    'Noida',
    'Greater Noida',
    'Delhi',
    'Varanasi',
    'Prayagraj',
  ];

  final List<String> _popularLocalities = [
    'Gomti Nagar',
    'Indira Nagar',
    'Aliganj',
    'Hazratganj',
    'Mahanagar',
    'Janki Puram',
    'Vikas Nagar',
  ];

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final user = state.currentUser;

    _nameController = TextEditingController(text: state.userName);
    _phoneController = TextEditingController(
      text: user?.mobile.isNotEmpty == true ? user!.mobile : state.userPhone,
    );
    _emailController = TextEditingController(text: user?.email ?? '');
    _cityController = TextEditingController(text: user?.city ?? state.selectedCity);
    _localityController = TextEditingController(text: user?.locality ?? state.selectedLocality);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Profile Photo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a clear photo to help others recognize you',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Photo',
                    color: AppTheme.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Choose Gallery',
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedImagePath = null;
                    });
                  },
                  icon: const Icon(Icons.undo_rounded, size: 18, color: Colors.red),
                  label: Text(
                    'Revert to current photo',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = Provider.of<AppStateProvider>(context, listen: false);
    setState(() {
      _isSaving = true;
    });

    try {
      String? finalImageUrl;

      // 1. If user picked a new local image, upload it first
      if (_selectedImagePath != null && File(_selectedImagePath!).existsSync()) {
        finalImageUrl = await state.uploadProfileImage(_selectedImagePath!);
      }

      // 2. Update user profile data
      await state.updateUserProfile(
        name: _nameController.text.trim(),
        mobile: _phoneController.text.trim().replaceAll(' ', ''),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        locality: _localityController.text.trim(),
        profileImage: finalImageUrl ?? (state.userProfileImage.isNotEmpty ? state.userProfileImage : null),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Profile updated successfully!',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Failed to update profile: $e',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _handleSave,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── AVATAR PICKER SECTION ─────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: _showImagePickerModal,
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primary, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _selectedImagePath != null
                                    ? Image.file(
                                        File(_selectedImagePath!),
                                        width: 104,
                                        height: 104,
                                        fit: BoxFit.cover,
                                      )
                                    : (state.currentUser?.hasProfileImage == true
                                        ? AppImage(
                                            path: state.userProfileImage,
                                            width: 104,
                                            height: 104,
                                            fit: BoxFit.cover,
                                            isAvatar: true,
                                            initials: state.userName.isNotEmpty
                                                ? state.userName[0].toUpperCase()
                                                : 'U',
                                          )
                                        : Container(
                                            color: AppTheme.primaryLight,
                                            child: Center(
                                              child: Text(
                                                state.userName.isNotEmpty
                                                    ? state.userName[0].toUpperCase()
                                                    : 'U',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.primary,
                                                ),
                                              ),
                                            ),
                                          )),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImagePickerModal,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Text(
                          'Change Profile Photo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG, or WEBP supported',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ─── BASIC INFO CARD ───────────────────────────────────────
                _buildSectionCard(
                  title: 'Personal Information',
                  children: [
                    // Full Name
                    _buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (val.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone Number
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      hint: '9876543210',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      prefixText: '+91 ',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Mobile number is required';
                        }
                        final clean = val.trim().replaceAll(' ', '');
                        if (clean.length < 10) {
                          return 'Enter valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Address
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'name@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(val.trim())) {
                            return 'Enter a valid email address';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── LOCATION CARD ─────────────────────────────────────────
                _buildSectionCard(
                  title: 'Residence & City',
                  children: [
                    // City
                    _buildInputField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'e.g. Lucknow',
                      icon: Icons.location_city_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    // Quick City Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _popularCities.map((c) {
                        final isSelected = _cityController.text.trim().toLowerCase() == c.toLowerCase();
                        return ChoiceChip(
                          label: Text(c),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _cityController.text = c;
                              });
                            }
                          },
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                          selectedColor: AppTheme.primary,
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Locality
                    _buildInputField(
                      controller: _localityController,
                      label: 'Locality / Sector',
                      hint: 'e.g. Gomti Nagar',
                      icon: Icons.place_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your locality';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    // Quick Locality Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _popularLocalities.map((loc) {
                        final isSelected = _localityController.text.trim().toLowerCase() == loc.toLowerCase();
                        return ChoiceChip(
                          label: Text(loc),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _localityController.text = loc;
                              });
                            }
                          },
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                          selectedColor: AppTheme.primary,
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── ACCOUNT DETAILS CARD ──────────────────────────────────
                _buildSectionCard(
                  title: 'Account Role',
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_user_outlined, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Profile Role',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Role is governed by your primary app activity',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            state.userRole,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ─── SAVE BUTTON ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.primary.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Saving Profile...',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Save Changes',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
            prefixText: prefixText,
            prefixStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }
}
