import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/launcher_utils.dart';
import '../../../core/widgets/app_image.dart';
import '../../../models/used_item_model.dart';
import '../../../providers/app_state_provider.dart';
import '../chat/chat_conversation_screen.dart';

class UsedItemsScreen extends StatelessWidget {
  const UsedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Used Items Marketplace',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primary),
            onPressed: () => _showPostItemDialog(context, state),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            await state.loadLiveUsedItemsFromBackend();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sell_rounded, color: Color(0xFFD97706), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Moving out? Sell your furniture & appliances!',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                            Text(
                              'Direct bachelor-to-bachelor sale with 0 commission.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Featured Used Items',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (state.isLoadingUsedItems && state.usedItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else if (state.usedItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No used items posted yet',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Be the first to list furniture or appliances for students & bachelors!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                            ),
                            onPressed: () => _showPostItemDialog(context, state),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Post Used Item Now'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // 2-Column Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.usedItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.64,
                    ),
                    itemBuilder: (context, index) {
                      final item = state.usedItems[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Stack(
                          children: [
                            AppImage(
                              path: item.imageUrl,
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.condition,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.formattedPrice,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 32,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryLight,
                                        foregroundColor: AppTheme.primary,
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatConversationScreen(
                                              participantName: item.sellerName,
                                              propertyTitle: 'Used Item: ${item.title}',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Chat',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.verifiedGreen.withOpacity(0.12),
                                      foregroundColor: AppTheme.verifiedGreen,
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => LauncherUtils.makePhoneCall(context, item.sellerPhone),
                                    child: const Icon(Icons.call_rounded, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showPostItemDialog(context, state),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Post Used Item',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  void _showPostItemDialog(BuildContext context, AppStateProvider state) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final locationController = TextEditingController(text: 'Indira Nagar, Lucknow');
    List<String> pickedImagePaths = [];
    String selectedCategory = 'Furniture';
    String selectedCondition = 'Good Condition';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickSingleCameraImage() async {
              try {
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  maxWidth: 1600,
                  maxHeight: 1600,
                );
                if (picked != null) {
                  setModalState(() {
                    pickedImagePaths.add(picked.path);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error taking photo: $e')),
                  );
                }
              }
            }

            Future<void> pickMultiGalleryImages() async {
              try {
                final picker = ImagePicker();
                final pickedList = await picker.pickMultiImage(
                  imageQuality: 80,
                  maxWidth: 1600,
                  maxHeight: 1600,
                );
                if (pickedList.isNotEmpty) {
                  setModalState(() {
                    for (final p in pickedList) {
                      if (!pickedImagePaths.contains(p.path)) {
                        pickedImagePaths.add(p.path);
                      }
                    }
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error picking images: $e')),
                  );
                }
              }
            }

            void showImageSourcePicker() {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primary),
                        title: Text(
                          'Choose Multiple from Gallery (Mark & Select)',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text('Tap & checkmark multiple photos'),
                        onTap: () {
                          Navigator.pop(ctx);
                          pickMultiGalleryImages();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
                        title: Text(
                          'Take Photo with Camera',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          pickSingleCameraImage();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Post an Item to Sell',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Multi-Image Picker Display
                    if (pickedImagePaths.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${pickedImagePaths.length} Photos Selected',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setModalState(() => pickedImagePaths.clear());
                                },
                                child: Text(
                                  'Clear All',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 95,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: pickedImagePaths.length + 1,
                              separatorBuilder: (context, index) => const SizedBox(width: 10),
                              itemBuilder: (context, idx) {
                                if (idx == pickedImagePaths.length) {
                                  return InkWell(
                                    onTap: showImageSourcePicker,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 85,
                                      height: 95,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primary, size: 24),
                                          SizedBox(height: 4),
                                          Text(
                                            'Add More',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final imgPath = pickedImagePaths[idx];
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: AppImage(
                                        path: imgPath,
                                        width: 95,
                                        height: 95,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            pickedImagePaths.removeAt(idx);
                                          });
                                        },
                                        child: CircleAvatar(
                                          radius: 11,
                                          backgroundColor: Colors.black.withOpacity(0.7),
                                          child: const Icon(Icons.close, size: 13, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    if (idx == 0)
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Cover',
                                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: showImageSourcePicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3), style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_rounded, size: 30, color: AppTheme.primary),
                              const SizedBox(height: 6),
                              Text(
                                'Add Photos (Mark & Select Multiple)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose multiple from Gallery or Camera',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Item Title (e.g. Study Chair, Mini Fridge)',
                        prefixIcon: Icon(Icons.shopping_bag_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price & Condition Row (Fixed 39px overflow)
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price (₹)',
                              prefixIcon: Icon(Icons.currency_rupee_rounded, size: 18),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 6,
                          child: DropdownButtonFormField<String>(
                            value: selectedCondition,
                            isExpanded: true, // Prevents overflow
                            decoration: const InputDecoration(
                              labelText: 'Condition',
                              prefixIcon: Icon(Icons.thumb_up_alt_outlined, size: 18),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Like New',
                                child: Text('Like New', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'Good Condition',
                                child: Text('Good Condition', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'Fair',
                                child: Text('Fair', overflow: TextOverflow.ellipsis),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedCondition = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Location',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final price = double.tryParse(priceController.text) ?? 1500;

                          // Upload image to backend if picked
                          String finalImage = 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=600&q=80';
                          if (pickedImagePaths.isNotEmpty) {
                            final uploaded = await ApiService.uploadSingleFile(pickedImagePaths.first);
                            finalImage = uploaded ?? pickedImagePaths.first;
                          }

                          state.addUsedItem(
                            UsedItem(
                              id: 'item-${DateTime.now().millisecondsSinceEpoch}',
                              title: titleController.text.isNotEmpty ? titleController.text : 'Study Table',
                              price: price,
                              condition: selectedCondition,
                              category: selectedCategory,
                              imageUrl: finalImage,
                              location: locationController.text.isNotEmpty ? locationController.text : 'Indira Nagar, Lucknow',
                              sellerName: '${state.userName} (You)',
                              sellerPhone: state.userPhone.isNotEmpty ? state.userPhone : '+91 98765 43210',
                              description: 'Clean and good condition',
                              postedAt: DateTime.now(),
                            ),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Used Item listed for bachelors successfully!'),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          }
                        },
                        child: const Text('Post Now Free'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
