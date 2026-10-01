import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_image.dart';
import '../../../providers/app_state_provider.dart';

class OwnerKycScreen extends StatelessWidget {
  const OwnerKycScreen({super.key});

  void _showUpdateKycBottomSheet(
    BuildContext context,
    AppStateProvider state,
  ) {
    final aadhaarController =
        TextEditingController(text: 'XXXX-XXXX-8921');
    final panController = TextEditingController(text: 'ABCDE1234F');
    String? capturedPhotoPath;
    String? pickedAadhaarPath;
    String? pickedPanPath;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> pickSelfie(ImageSource source) async {
              try {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: source, imageQuality: 85);
                if (picked != null) {
                  setModalState(() {
                    capturedPhotoPath = picked.path;
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to capture photo: $e')),
                  );
                }
              }
            }

            Future<void> pickDoc(String docType) async {
              try {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (picked != null) {
                  setModalState(() {
                    if (docType == 'aadhaar') {
                      pickedAadhaarPath = picked.path;
                    } else {
                      pickedPanPath = picked.path;
                    }
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to pick document: $e')),
                  );
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Update Owner KYC Documents',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Government ID authentication ensures 100% genuine owner badge',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Aadhaar Number & Photo Document',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: aadhaarController,
                      decoration: InputDecoration(
                        hintText: 'Enter 12-digit Aadhaar number',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        suffixIcon: IconButton(
                          icon: Icon(
                            pickedAadhaarPath != null ? Icons.check_circle : Icons.attach_file_rounded,
                            color: pickedAadhaarPath != null ? AppTheme.verifiedGreen : AppTheme.primary,
                          ),
                          tooltip: 'Upload Aadhaar Scan / Photo',
                          onPressed: () => pickDoc('aadhaar'),
                        ),
                      ),
                    ),
                    if (pickedAadhaarPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '✓ Aadhaar document file attached',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.verifiedGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      'PAN Card Number & Photo Document',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: panController,
                      decoration: InputDecoration(
                        hintText: 'Enter 10-character PAN number',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        suffixIcon: IconButton(
                          icon: Icon(
                            pickedPanPath != null ? Icons.check_circle : Icons.attach_file_rounded,
                            color: pickedPanPath != null ? AppTheme.verifiedGreen : AppTheme.primary,
                          ),
                          tooltip: 'Upload PAN Scan / Photo',
                          onPressed: () => pickDoc('pan'),
                        ),
                      ),
                    ),
                    if (pickedPanPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '✓ PAN card file attached',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.verifiedGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 18),

                    // Live Selfie / Photo Verification box
                    Text(
                      'Selfie / Live Face Match Verification',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (capturedPhotoPath != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppImage(
                              path: capturedPhotoPath!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                onPressed: () {
                                  setModalState(() {
                                    capturedPhotoPath = null;
                                  });
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.verifiedGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Face Photo Captured',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.camera_alt_rounded, size: 18, color: AppTheme.primary),
                              label: Text(
                                'Camera Selfie',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () => pickSelfie(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.photo_library_rounded, size: 18, color: AppTheme.primary),
                              label: Text(
                                'Upload ID Photo',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () => pickSelfie(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setModalState(() => isSubmitting = true);
                                await state.submitKyc(
                                  name: state.userName,
                                  mobile: state.userMobile.isNotEmpty ? state.userMobile : '',
                                  aadhaar: aadhaarController.text.trim(),
                                  pan: panController.text.trim(),
                                  aadhaarFilePath: pickedAadhaarPath,
                                  panFilePath: pickedPanPath,
                                  selfieFilePath: capturedPhotoPath,
                                );
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'KYC Documents uploaded and submitted for live verification!',
                                      ),
                                      backgroundColor: AppTheme.primary,
                                    ),
                                  );
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Submit & Authenticate'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isVerified = state.kycStatus == 'Verified';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Owner KYC Verification',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Verified Badge Header
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isVerified
                        ? Icons.verified_rounded
                        : Icons.hourglass_top_rounded,
                    size: 54,
                    color: isVerified
                        ? AppTheme.verifiedGreen
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isVerified
                    ? 'KYC Verified Owner'
                    : 'KYC Pending Verification',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isVerified
                    ? 'Your documents have been verified. You can now post direct owner properties with zero brokerage badge.'
                    : 'Submit your government identity documents to get verified and start receiving tenant calls.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Verification Checkmarks List
              _buildVerificationStatusRow(
                'Identity Verified',
                'Aadhaar Card Authenticated',
                state.isAadhaarUploaded,
              ),
              const SizedBox(height: 16),
              _buildVerificationStatusRow(
                'Tax & Ownership Proof',
                'PAN Card & Title Deed Checked',
                state.isPanUploaded,
              ),
              const SizedBox(height: 16),
              _buildVerificationStatusRow(
                'Owner Approved',
                'Direct Owner Verified Badge Active',
                isVerified,
              ),

              const SizedBox(height: 32),

              // Document Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authenticated Records',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDocItem(
                      'Aadhaar Card (Front & Back)',
                      state.isAadhaarUploaded
                          ? 'XXXX-XXXX-8921 (Verified)'
                          : 'Pending',
                      state.isAadhaarUploaded,
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 16),
                    _buildDocItem(
                      'PAN Card',
                      state.isPanUploaded
                          ? 'ABCDE1234F (Verified)'
                          : 'Pending',
                      state.isPanUploaded,
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 16),
                    _buildDocItem(
                      'Selfie / Live Photo Verification',
                      state.isPhotoUploaded ? 'Completed' : 'Pending',
                      state.isPhotoUploaded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.upload_file_rounded,
                    color: AppTheme.primary, size: 18),
                label: Text(
                  'Update / Upload Documents',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                onPressed: () => _showUpdateKycBottomSheet(context, state),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStatusRow(
    String title,
    String subtitle,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.verifiedGreen
                  : const Color(0xFFCBD5E1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.hourglass_empty,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(String title, String status, bool isCompleted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.pending,
              size: 14,
              color: isCompleted
                  ? AppTheme.verifiedGreen
                  : const Color(0xFFD97706),
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? AppTheme.verifiedGreen
                    : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
