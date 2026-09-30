import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/launcher_utils.dart';

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

  @override
  void initState() {
    super.initState();
    _landlordController = TextEditingController(
        text: widget.initialOwnerName ?? 'Rajesh Kumar');
    _tenantController =
        TextEditingController(text: 'Sachin Bhaskar');
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

    return '''
=====================================================
          STANDARD 11-MONTH RESIDENTIAL RENT AGREEMENT
=====================================================

This Rent Agreement is made and executed on this $startDate between:

FIRST PARTY (LANDLORD / OWNER):
Name: ${_landlordController.text}
Hereinafter referred to as the "LANDLORD / LESSOR" (which expression shall include his legal heirs, successors, and representatives).

AND

SECOND PARTY (TENANT):
Name: ${_tenantController.text}
Hereinafter referred to as the "TENANT / LESSEE".

WHEREAS the Landlord is the absolute owner of the premises situated at:
${_addressController.text}

TERMS AND CONDITIONS OF TENANCY:

1. TENANCY PERIOD:
The tenancy shall be for an agreed fixed term of 11 (Eleven) Months starting from $startDate. It may be renewed upon mutual consent of both parties with standard rental escalation.

2. MONTHLY RENT:
The Tenant agrees to pay a monthly rent of ₹${_rentController.text}/- (Rupees ${_rentController.text} only) on or before the 5th day of each calendar month.

3. SECURITY DEPOSIT:
The Tenant has deposited an interest-free refundable security deposit of ₹${_depositController.text}/- with the Landlord. This deposit shall be refunded at the time of vacating after adjusting any unpaid utility bills or structural damage repairs.

4. UTILITIES & ELECTRICITY:
Electricity, water consumption, and internet charges shall be paid directly by the Tenant as per actual meter readings. Regular building society maintenance shall be borne as per mutual agreement.

5. LOCK-IN & NOTICE PERIOD:
• Lock-in Period: $_lockInPeriod
• Notice Period: Either party may terminate this agreement by giving $_noticePeriod prior written notice.

6. USAGE & MAINTENANCE:
The leased premises shall be used exclusively for residential purposes. The Tenant shall maintain the property in clean and good tenantable state.

7. INSPECTION:
The Landlord or authorized representative may inspect the premises with reasonable advance notice.

IN WITNESS WHEREOF the parties have set their hands on the day and year first mentioned above.

_____________________________              _____________________________
SIGNATURE OF FIRST PARTY                    SIGNATURE OF SECOND PARTY
(Landlord: ${_landlordController.text})      (Tenant: ${_tenantController.text})

WITNESS 1:                                 WITNESS 2:
Name: ____________________                 Name: ____________________
Sign: ____________________                 Sign: ____________________
=====================================================
Generated via Property Hub - Zero Brokerage Platform
''';
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        color: Color(0xFF2563EB), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Standard 11-Month Legal Format',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                          Text(
                            'Legally vetted clauses for direct tenant and owner agreement with zero legal fees.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Inputs Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agreement Parties & Details',
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
                        labelText: 'Landlord / Owner Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _tenantController,
                      decoration: const InputDecoration(
                        labelText: 'Tenant Full Name',
                        prefixIcon: Icon(Icons.person_pin_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Complete Leased Property Address',
                        prefixIcon: Icon(Icons.location_on_outlined),
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
                              prefixIcon: Icon(Icons.currency_rupee),
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
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
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
                            decoration: const InputDecoration(labelText: 'Notice Period'),
                            items: const [
                              DropdownMenuItem(value: '1 Month', child: Text('1 Month')),
                              DropdownMenuItem(value: '2 Months', child: Text('2 Months')),
                              DropdownMenuItem(value: '15 Days', child: Text('15 Days')),
                            ],
                            onChanged: (val) => setState(() => _noticePeriod = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _lockInPeriod,
                            decoration: const InputDecoration(labelText: 'Lock-in Period'),
                            items: const [
                              DropdownMenuItem(value: 'None', child: Text('None')),
                              DropdownMenuItem(value: '3 Months', child: Text('3 Months')),
                              DropdownMenuItem(value: '6 Months', child: Text('6 Months')),
                            ],
                            onChanged: (val) => setState(() => _lockInPeriod = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.description_rounded),
                        label: const Text('Generate Agreement Draft'),
                        onPressed: () {
                          setState(() {
                            _generated = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Generated Preview
              if (_generated) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agreement Draft Preview',
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
                          icon: const Icon(Icons.copy_rounded, color: AppTheme.primary),
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
                          icon: const Icon(Icons.share_rounded, color: Color(0xFF25D366)),
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
