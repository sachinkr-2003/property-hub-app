import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_state_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final currentPlan = state.ownerSubscriptionPlan;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Owner Listing Plans',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Get Tenants & Buyers 10x Faster',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a plan that fits your property portfolio with 0% brokerage.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Basic Plan (Free)
              _buildPlanCard(
                context,
                name: 'Basic Free',
                price: '₹ 0',
                period: 'Forever',
                features: [
                  '1 Active Property Listing',
                  'Standard Search Visibility',
                  'Direct Tenant Inquiries via Chat',
                  'Direct Owner Verified Badge',
                ],
                isCurrent: currentPlan == 'Basic Free',
                buttonText: currentPlan == 'Basic Free' ? 'Current Plan' : 'Downgrade to Free',
                onTap: () {
                  state.upgradeSubscription('Basic Free');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched to Basic Free Plan')),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Premium Plan (Most Popular)
              _buildPlanCard(
                context,
                name: 'Premium Owner',
                price: '₹ 949',
                period: '/ month',
                highlight: 'MOST POPULAR',
                features: [
                  'Up to 10 Active Listings',
                  '5 Featured Tags on Top Search',
                  'Instant SMS & WhatsApp Lead Alerts',
                  'Property Video Tour Enabled',
                  'Tenant Background Check Reports',
                ],
                isPopular: true,
                isCurrent: currentPlan == 'Premium Owner',
                buttonText: currentPlan == 'Premium Owner' ? 'Current Plan' : 'Upgrade to Premium',
                onTap: () {
                  _showCheckoutSheet(context, 'Premium Owner', 949, state);
                },
              ),

              const SizedBox(height: 16),

              // Pro Plan
              _buildPlanCard(
                context,
                name: 'Pro Real Estate',
                price: '₹ 1,999',
                period: '/ month',
                features: [
                  'Unlimited Property Listings',
                  'Top 1% Guaranteed Search Placement',
                  'Dedicated Relationship Manager',
                  'Legal Rent Agreement Assistance',
                  'Professional Photo & Video Shoot',
                ],
                isCurrent: currentPlan == 'Pro Real Estate',
                buttonText: currentPlan == 'Pro Real Estate' ? 'Current Plan' : 'Upgrade to Pro',
                onTap: () {
                  _showCheckoutSheet(context, 'Pro Real Estate', 1999, state);
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckoutSheet(
    BuildContext context,
    String planName,
    double basePrice,
    AppStateProvider state,
  ) {
    final gst = (basePrice * 0.18).round();
    final total = (basePrice + gst).round();
    int selectedPaymentMethod = 0; // 0: UPI, 1: Card, 2: NetBanking
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade Subscription',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Plan: $planName',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textMuted),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$planName (1 Month)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '₹${basePrice.round()}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Applicable GST (18%)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '₹$gst',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: Color(0xFFE2E8F0), height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Payable',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '₹$total',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Methods Selection
                    Text(
                      'Select Payment Method',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Method 1: UPI
                    _buildPaymentOptionTile(
                      title: 'UPI (Google Pay, PhonePe, Paytm)',
                      subtitle: 'Fastest & Instant Activation',
                      icon: Icons.account_balance_wallet_rounded,
                      isSelected: selectedPaymentMethod == 0,
                      onTap: () => setModalState(() => selectedPaymentMethod = 0),
                    ),
                    const SizedBox(height: 8),

                    // Method 2: Cards
                    _buildPaymentOptionTile(
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, MasterCard, RuPay accepted',
                      icon: Icons.credit_card_rounded,
                      isSelected: selectedPaymentMethod == 1,
                      onTap: () => setModalState(() => selectedPaymentMethod = 1),
                    ),
                    const SizedBox(height: 8),

                    // Method 3: Net Banking
                    _buildPaymentOptionTile(
                      title: 'Net Banking',
                      subtitle: 'All Major Indian Banks',
                      icon: Icons.account_balance_rounded,
                      isSelected: selectedPaymentMethod == 2,
                      onTap: () => setModalState(() => selectedPaymentMethod = 2),
                    ),
                    const SizedBox(height: 20),

                    // Trust Badge
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 16, color: AppTheme.verifiedGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '256-bit encrypted SSL checkout. Instant activation.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setModalState(() => isProcessing = true);
                                await Future.delayed(const Duration(milliseconds: 1200));
                                if (!sheetContext.mounted) return;
                                state.upgradeSubscription(planName);
                                Navigator.pop(sheetContext);

                                if (context.mounted) {
                                  _showSuccessDialog(context, planName);
                                }
                              },
                        child: isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Pay ₹$total & Activate Plan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
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

  static Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primary : AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String planName) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.verifiedGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.verifiedGreen,
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Plan Activated!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account has been upgraded to $planName. Your properties now receive top search priority!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Done',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String name,
    required String price,
    required String period,
    required List<String> features,
    required String buttonText,
    String? highlight,
    bool isCurrent = false,
    bool isPopular = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? AppTheme.verifiedGreen
              : (isPopular ? AppTheme.primary : const Color(0xFFE2E8F0)),
          width: (isPopular || isCurrent) ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (highlight != null || isCurrent) const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.verifiedGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.verifiedGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 16),
                Column(
                  children: features.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: AppTheme.verifiedGreen),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? const Color(0xFFF1F5F9)
                          : (isPopular ? AppTheme.primary : AppTheme.secondary),
                      foregroundColor: isCurrent ? AppTheme.textMuted : Colors.white,
                    ),
                    onPressed: isCurrent ? null : onTap,
                    child: Text(
                      buttonText,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (highlight != null && !isCurrent)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                child: Text(
                  highlight,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
