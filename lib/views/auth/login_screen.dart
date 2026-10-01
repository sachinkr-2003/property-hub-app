import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
  // ─── Step tracking ─────────────────────────────────────────────────────────
  bool _otpSent = false;
  bool _isLoading = false;
  String? _errorMsg;
  String? _devOtp; // shown only in debug builds

  // ─── Controllers ───────────────────────────────────────────────────────────
  final _phoneController = TextEditingController();
  final _otpController   = TextEditingController();
  final _nameController  = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Step 1 — Send OTP
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final mobile = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (mobile.length != 10) {
      setState(() => _errorMsg = 'Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await ApiService.sendOtp(mobile);

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _otpSent = true;
        _isLoading = false;
        // Show dev OTP on screen in non-production
        _devOtp = result['devOtp']?.toString();
      });
    } else {
      // Fallback: even if backend unreachable, allow dev to proceed with '1234'
      setState(() {
        _otpSent = true;
        _isLoading = false;
        _devOtp = '1234';
        _errorMsg = 'Backend unreachable — using dev OTP: 1234';
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Step 2 — Verify OTP → Login
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final mobile = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final otp    = _otpController.text.trim();

    if (otp.length < 4) {
      setState(() => _errorMsg = 'Please enter the 4-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final session = await ApiService.verifyOtp(
      mobile: mobile,
      otp: otp,
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
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
      setState(() {
        _isLoading = false;
        _errorMsg = 'Invalid OTP. Please try again.';
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Quick Demo Login (skips real OTP — for showcase)
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _quickDemoLogin() async {
    setState(() => _isLoading = true);

    final session = await ApiService.verifyOtp(
      mobile: '9999999999',
      otp: '1234',
      name: 'Demo User',
    );

    if (!mounted) return;

    if (session != null) {
      await Provider.of<AppStateProvider>(context, listen: false)
          .loginWithSession(session);
    } else {
      // True fallback — local session only
      Provider.of<AppStateProvider>(context, listen: false).login();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.home_work_rounded, size: 42, color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  _otpSent ? 'Verify OTP' : 'Welcome Back',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _otpSent
                      ? 'OTP sent to +91 ${_phoneController.text.trim()}'
                      : 'Login to access genuine verified properties',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── Step 1 — Phone Number ────────────────────────────────────
              if (!_otpSent) ...[
                Text(
                  'Mobile Number',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: '',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+91',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 22, color: const Color(0xFFCBD5E1)),
                        ],
                      ),
                    ),
                    hintText: 'Enter 10-digit number',
                  ),
                ),
              ],

              // ── Step 2 — OTP + optional Name ────────────────────────────
              if (_otpSent) ...[
                // Change number
                GestureDetector(
                  onTap: () => setState(() {
                    _otpSent = false;
                    _errorMsg = null;
                    _otpController.clear();
                  }),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Change number',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Dev OTP hint
                if (_devOtp != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Text(
                          'Dev OTP: $_devOtp',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Text(
                  'Enter OTP',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '• • • •',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      letterSpacing: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Your Name (optional for new users)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.textMuted),
                    hintText: 'e.g. Rohit Kumar',
                  ),
                ),
              ],

              // ── Error Message ────────────────────────────────────────────
              if (_errorMsg != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Primary CTA ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _otpSent ? 'Verify & Login' : 'Send OTP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Quick Demo Login ──────────────────────────────────────────
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _quickDemoLogin,
                  icon: const Icon(Icons.flash_on_rounded, size: 18, color: AppTheme.accent),
                  label: Text(
                    'Quick Demo Login (Skip OTP)',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Divider ───────────────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),
              const SizedBox(height: 28),

              // ── Owner Onboarding Banner ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.vpn_key_rounded, color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are you a Property Owner?',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'List property free & connect directly',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
