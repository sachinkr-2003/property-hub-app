import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/launcher_utils.dart';
import '../../../core/services/api_service.dart';
import '../../../providers/app_state_provider.dart';

class RentAgreementGeneratorScreen extends StatefulWidget {
  final String? initialOwnerName;
  final String? initialPropertyAddress;
  final double? initialRent;
  final double? initialDeposit;

  const RentAgreementGeneratorScreen({
    super.key,
    this.initialOwnerName,
    this.initialPropertyAddress,
    this.initialRent,
    this.initialDeposit,
  });

  @override
  State<RentAgreementGeneratorScreen> createState() =>
      _RentAgreementGeneratorScreenState();
}

class _RentAgreementGeneratorScreenState
    extends State<RentAgreementGeneratorScreen> {
  late TextEditingController _landlordController;
  late TextEditingController _tenantController;
  late TextEditingController _addressController;
  late TextEditingController _rentController;
  late TextEditingController _depositController;
  String _noticePeriod = '1 Month';
  String _lockInPeriod = '3 Months';
  bool _generated = false;
  bool _isProcessingPayment = false;
  Map<String, dynamic>? _stampTransaction;

  @override
  void initState() {
    super.initState();
    _landlordController = TextEditingController(
        text: widget.initialOwnerName ?? 'Rajesh Kumar');
    _tenantController = TextEditingController();
    _addressController = TextEditingController(
      text: widget.initialPropertyAddress ??
          'Flat No. 302, Green Heights, Sector 14, Indira Nagar, Lucknow, UP - 226016',
    );
    _rentController = TextEditingController(
      text: widget.initialRent != null
          ? widget.initialRent!.toStringAsFixed(0)
          : '16500',
    );
    _depositController = TextEditingController(
      text: widget.initialDeposit != null
          ? widget.initialDeposit!.toStringAsFixed(0)
          : '33000',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      if (_tenantController.text.isEmpty) {
        _tenantController.text =
            state.userName.isNotEmpty ? state.userName : 'Tenant';
      }
    });
  }

  @override
  void dispose() {
    _landlordController.dispose();
    _tenantController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  String _generateAgreementText() {
    final now = DateTime.now();
    final startDate = '${now.day}/${now.month}/${now.year}';
    final stampNum = _stampTransaction != null
        ? (_stampTransaction!['customId'] ?? 'TXN-8002')
        : 'UNREGISTERED-DRAFT';

    return '''
=====================================================
    GOVT OF UTTAR PRADESH E-STAMP DUTY AGREEMENT
    Ref No: $stampNum | Cert Date: $startDate
=====================================================

STANDARD 11-MONTH RESIDENTIAL LEASE & LICENSE AGREEMENT

This Rent Agreement is made and executed on this $startDate between:

FIRST PARTY (LANDLORD / OWNER):
Name: ${_landlordController.text}
Status: Verified Landlord (Property Hub Verified)
Hereinafter referred to as the "LANDLORD / LESSOR" (which expression shall include his legal heirs, successors, and representatives).

AND

SECOND PARTY (TENANT):
Name: ${_tenantController.text}
Status: Registered Tenant
Hereinafter referred to as the "TENANT / LESSEE".

WHEREAS the Landlord is the absolute owner of the premises situated at:
${_addressController.text}

TERMS AND CONDITIONS OF TENANCY:

1. TENANCY PERIOD:
The tenancy shall be for an agreed fixed term of 11 (Eleven) Months starting from $startDate. It may be renewed upon mutual consent of both parties with standard rental escalation.

2. MONTHLY RENT:
The Tenant agrees to pay a monthly rent of ₹${_rentController.text}/- (Rupees ${_rentController.text} only) on or before the 5th day of each calendar month.

3. SECURITY DEPOSIT:
The Tenant has paid an interest-free refundable security deposit of ₹${_depositController.text}/- to the Landlord, refundable upon peaceful handover of premises subject to wear-and-tear inspection.

4. NOTICE & LOCK-IN PERIOD:
Either party may terminate this agreement by providing $_noticePeriod advance written notice. An initial lock-in period of $_lockInPeriod applies.

5. MAINTENANCE & UTILITIES:
Electricity, water, and society maintenance charges shall be paid directly by the Tenant based on metered usage.

IN WITNESS WHEREOF the parties have set their hands on this agreement in the presence of witnesses.

First Party (Landlord): ${_landlordController.text}  [Signed Digitally]
Second Party (Tenant): ${_tenantController.text}    [Signed Digitally]
''';
  }

  void _openRazorpayModal(AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF38BDF8),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Razorpay',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0C2340),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C2340),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'TRUSTED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '100% Encrypted & Secure Payment Gateway',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Order Summary: Official e-Stamp Legal Agreement',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildPriceRow('Govt e-Stamp Paper (UP State)', '₹ 100'),
                _buildPriceRow('Legal Drafting & Verification', '₹ 299'),
                _buildPriceRow('Doorstep Delivery & Priority Dispatch', '₹ 100'),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Payable Amount',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '₹ 499.00',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Payment Options Pill
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: AppTheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'UPI (GPay / PhonePe / Paytm), Debit/Credit Card, Net Banking',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C2340),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isProcessingPayment
                        ? null
                        : () async {
                            setModalState(() {
                              _isProcessingPayment = true;
                            });

                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(ctx);

                            final txn = await ApiService.createTransaction(
                              userName: state.userName.isNotEmpty
                                  ? state.userName
                                  : _tenantController.text,
                              purpose: 'Govt e-Stamp Rent Agreement',
                              amount: 499,
                              userRole: 'Tenant',
                              gateway: 'Razorpay',
                            );

                            setModalState(() {
                              _isProcessingPayment = false;
                            });
                            navigator.pop();
                            if (mounted) {
                              setState(() {
                                _stampTransaction = txn;
                                _generated = true;
                              });
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Payment Successful! e-Stamp Agreement Generated.'),
                                  backgroundColor: AppTheme.verifiedGreen,
                                ),
                              );
                            }
                          },
                    child: _isProcessingPayment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Pay ₹499 via Razorpay',
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
          );
        },
      ),
    );
  }

  Widget _buildPriceRow(String title, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Rent Agreement Generator',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: Color(0xFF60A5FA),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legal 11-Month e-Stamp Agreement',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Government valid stamp paper, biometric/digital verification & home delivery.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agreement Parameters',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _landlordController,
                      decoration: const InputDecoration(
                        labelText: 'Landlord / Owner Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tenantController,
                      decoration: const InputDecoration(
                        labelText: 'Tenant Full Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Rented Property Address',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Monthly Rent (₹)',
                              prefixIcon: Icon(Icons.currency_rupee_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _depositController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Security Deposit (₹)',
                              prefixIcon:
                                  Icon(Icons.account_balance_wallet_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _noticePeriod,
                            decoration:
                                const InputDecoration(labelText: 'Notice Period'),
                            items: const [
                              DropdownMenuItem(
                                  value: '1 Month', child: Text('1 Month')),
                              DropdownMenuItem(
                                  value: '2 Months', child: Text('2 Months')),
                              DropdownMenuItem(
                                  value: '15 Days', child: Text('15 Days')),
                            ],
                            onChanged: (val) =>
                                setState(() => _noticePeriod = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _lockInPeriod,
                            decoration:
                                const InputDecoration(labelText: 'Lock-in Period'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'None', child: Text('None')),
                              DropdownMenuItem(
                                  value: '3 Months', child: Text('3 Months')),
                              DropdownMenuItem(
                                  value: '6 Months', child: Text('6 Months')),
                            ],
                            onChanged: (val) =>
                                setState(() => _lockInPeriod = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Free Draft'),
                            onPressed: () {
                              setState(() {
                                _generated = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                            ),
                            icon: const Icon(Icons.verified_rounded,
                                color: Color(0xFF38BDF8), size: 18),
                            label: const Text(
                              'e-Stamp (₹499)',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => _openRazorpayModal(state),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stamp duty certification if paid
              if (_stampTransaction != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.verifiedGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Govt e-Stamp Verified & Issued',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Receipt: ${_stampTransaction!['customId'] ?? 'TXN-8002'} | Gateway: Razorpay Payouts',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Generated Preview
              if (_generated) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agreement Document Preview',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Copy Text',
                          icon: const Icon(Icons.copy_rounded,
                              color: AppTheme.primary),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _generateAgreementText()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Agreement copied to clipboard!'),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Share via WhatsApp',
                          icon: const Icon(Icons.share_rounded,
                              color: Color(0xFF25D366)),
                          onPressed: () {
                            LauncherUtils.openWhatsApp(
                              context,
                              '',
                              message: _generateAgreementText(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: SelectableText(
                    _generateAgreementText(),
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11,
                      height: 1.5,
                      color: const Color(0xFF78350F),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
