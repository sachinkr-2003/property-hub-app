import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';

// User Views
import 'user/home/user_home_screen.dart';
import 'user/properties/property_list_screen.dart';
import 'user/services/services_screen.dart';
import 'user/chat/chat_screen.dart';
import 'user/profile/user_profile_screen.dart';

// Owner Views
import 'owner/dashboard/owner_dashboard_screen.dart';
import 'owner/my_properties/my_properties_screen.dart';
import 'owner/leads/leads_screen.dart';
import 'owner/add_property/add_property_wizard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  DateTime? _lastBackPressTime;

  void _handleBackPress(AppStateProvider state) {
    // 1. If in Owner Mode and not on Dashboard tab, return to Dashboard tab
    if (state.currentRole == AppRole.owner) {
      if (state.ownerNavIndex != 0) {
        state.setOwnerNavIndex(0);
        return;
      } else {
        // If on Owner Dashboard, return to User Mode
        state.setRole(AppRole.user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Switched back to Tenant / Buyer Mode',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    // 2. If in User Mode and not on Home tab, return to Home tab
    if (state.userNavIndex != 0) {
      state.setUserNavIndex(0);
      return;
    }

    // 3. If on Home tab, require double tap to exit so user is never accidentally logged out or closed
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit Search',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppTheme.primaryDark,
        ),
      );
    } else {
      // Exit gracefully without logging out
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(state);
      },
      child: state.currentRole == AppRole.owner
          ? _buildOwnerNavigation(context, state)
          : _buildUserNavigation(context, state),
    );
  }

  // User Mode Navigation (Tenant / Buyer)
  Widget _buildUserNavigation(BuildContext context, AppStateProvider state) {
    final List<Widget> userScreens = [
      const UserHomeScreen(),
      const PropertyListScreen(),
      const ServicesScreen(),
      const ChatListScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.userNavIndex,
        children: userScreens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: state.userNavIndex,
          onTap: (index) => state.setUserNavIndex(index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apartment_rounded),
              label: 'Properties',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.room_service_rounded),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Owner Mode Navigation (Landlord / Seller)
  Widget _buildOwnerNavigation(BuildContext context, AppStateProvider state) {
    final List<Widget> ownerScreens = [
      const OwnerDashboardScreen(),
      const MyPropertiesScreen(),
      const LeadsScreen(),
      const ChatListScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.ownerNavIndex,
        children: ownerScreens,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPropertyWizardScreen()),
          );
        },
        child: const Icon(Icons.add_home_rounded, color: Colors.white),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: BottomNavigationBar(
            currentIndex: state.ownerNavIndex,
            onTap: (index) => state.setOwnerNavIndex(index),
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textMuted,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_work_rounded),
                label: 'Properties',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contact_mail_rounded),
                label: 'Leads',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
