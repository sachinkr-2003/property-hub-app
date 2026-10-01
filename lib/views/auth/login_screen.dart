import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../providers/app_state_provider.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMsg;

  // ──────────────────────────────────────────────────────────────────────────
  // Login with Gmail (Real Google Sign In - Popup)
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _loginWithGmail() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the Google account selection popup
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Failed to get ID Token from Google';
        });
        return;
      }

      // Send the idToken to our backend for verification
      final session = await ApiService.googleLogin(
        idToken: googleAuth.idToken!,
        role: 'Tenant', // Default role
      );

      if (!mounted) return;

      if (session != null) {
        await Provider.of<AppStateProvider>(context, listen: false)
            .loginWithSession(session);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        // Sign out of google locally if backend failed so they can try again
        await googleSignIn.signOut();
        setState(() {
          _isLoading = false;
          _errorMsg = 'Backend verification failed. Check Client ID in backend.';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Google Sign In Error. Is Firebase configured properly?';
      });
      debugPrint('Google Sign In Error: $error');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Quick Demo Login (Hidden for dev fallback)
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _demoLogin() async {
    setState(() => _isLoading = true);
    // Fake a session using our new email OTP logic or hardcoded
    final session = await ApiService.emailRegister(
      email: 'demo@propertyhub.com',
      password: 'demo_password123',
      name: 'Demo User',
      mobile: '9999999999',
    ) ?? await ApiService.emailLogin(
      email: 'demo@propertyhub.com',
      password: 'demo_password123',
    );

    if (!mounted) return;
    if (session != null) {
      await Provider.of<AppStateProvider>(context, listen: false).loginWithSession(session);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
    } else {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Demo login failed';
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // ── Logo ──────────────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.home_work_rounded, size: 48, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Property Hub',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Find your perfect home easily.\nLogin directly with your Google account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // ── Error Message ────────────────────────────────────────────
              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Direct Gmail Login Button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loginWithGmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                          height: 24,
                        ),
                  label: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Continue with Google',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                ),
              ),
              
              const Spacer(),
              
              // ── Dev Demo Login (Small text at bottom) ──────────────────────────────────
              TextButton(
                onPressed: _demoLogin,
                child: Text(
                  'Skip for now (Demo Login)',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
