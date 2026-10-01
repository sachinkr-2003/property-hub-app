import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_image.dart';
import '../../../providers/app_state_provider.dart';
import '../../auth/login_screen.dart';
import '../properties/property_detail_screen.dart';
import '../visits/my_visits_screen.dart';
import '../compare/property_compare_screen.dart';
import '../calculators/financial_calculator_screen.dart';
import '../agreement/rent_agreement_generator_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
          children: [
            // User Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: ClipOval(
                      child: state.currentUser?.hasProfileImage == true
                          ? AppImage(
                              path: state.userProfileImage,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppTheme.primaryLight,
                              child: Center(
                                child: Text(
                                  state.userName.isNotEmpty
                                      ? state.userName[0].toUpperCase()
                                      : 'U',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.userName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.currentUser != null && state.currentUser!.email.isNotEmpty
                              ? state.currentUser!.email
                              : state.userPhone.isNotEmpty
                                  ? state.userPhone
                                  : 'Not logged in',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            state.userRole,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Prominent Switch To Owner Mode Banner (Airbnb Hosting Style)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E6456), Color(0xFF0F766E)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.real_estate_agent, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch to Owner Mode',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage your properties & view buyer/tenant leads',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.currentRole == AppRole.owner,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppTheme.accent,
                    onChanged: (val) {
                      state.toggleRole();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.calendar_today_rounded,
                    title: 'My Scheduled Visits',
                    subtitle: '${state.visitBookings.length} Upcoming visits scheduled',
                    badge: state.visitBookings.isNotEmpty ? '${state.visitBookings.length}' : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyVisitsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  _buildMenuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Favorites & Shortlisted',
                    subtitle: '${state.favoriteProperties.length} properties saved',
                    onTap: () {
                      _showFavoritesSheet(context, state);
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  _buildMenuItem(
                    icon: Icons.calculate_outlined,
                    title: 'Rent & EMI Splitter',
                    subtitle: 'Calculate roommate shares & loans',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FinancialCalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: '11-Month Rent Agreement',
                    subtitle: 'Generate standard legal draft',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RentAgreementGeneratorScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  _buildMenuItem(
                    icon: Icons.compare_arrows_rounded,
                    title: 'Compare Properties',
                    subtitle: 'Side-by-side home analysis',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PropertyCompareScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  _buildMenuItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'My Service Bookings',
                    subtitle: '${state.bookings.length} active service bookings',
                    onTap: () {
                      _showServiceBookingsSheet(context, state);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Support
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: '24/7 WhatsApp & Call assistance',
                    onTap: () {},
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  _buildMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Privacy & Terms of Service',
                    onTap: () {},
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    textColor: AppTheme.errorRed,
                    iconColor: AppTheme.errorRed,
                    onTap: () {
                      state.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'BachelorHub • Property Hub App v1.0.0\n100% Genuine Direct Owner Platform',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primary).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
    );
  }

  void _showFavoritesSheet(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shortlisted Properties',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.favoriteProperties.isEmpty
                    ? const Center(child: Text('No favorites yet'))
                    : ListView.builder(
                        itemCount: state.favoriteProperties.length,
                        itemBuilder: (context, index) {
                          final p = state.favoriteProperties[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailScreen(property: p),
                                ),
                              );
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AppImage(path: p.images[0], width: 55, height: 55, fit: BoxFit.cover),
                            ),
                            title: Text(p.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                            subtitle: Text(p.formattedPrice, style: GoogleFonts.plusJakartaSans(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showServiceBookingsSheet(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bookings = state.bookings;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'My Service Bookings',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${bookings.length}',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No Active Bookings',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Book verified laundry, tiffin, cleaning, or cook services with 1-tap.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(modalCtx);
                                    state.setUserNavIndex(2);
                                  },
                                  child: const Text('Explore Services'),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: bookings.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final b = bookings[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            b.serviceTitle,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.verifiedGreen.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            b.status,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppTheme.verifiedGreen,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${b.date} • ${b.timeSlot}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            b.address,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹${b.price.round()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppTheme.errorRed,
                                            side: const BorderSide(color: Color(0xFFFECACA)),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(Icons.cancel_outlined, size: 14),
                                          label: Text(
                                            'Cancel',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (dialogCtx) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                title: Text(
                                                  'Cancel Booking?',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to cancel your booking for ${b.serviceTitle}?',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 13,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(dialogCtx),
                                                    child: const Text('Keep Booking'),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppTheme.errorRed,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(dialogCtx);
                                                      state.cancelServiceBooking(b.id);
                                                      setModalState(() {});
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '${b.serviceTitle} booking cancelled',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text('Yes, Cancel'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
