import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/launcher_utils.dart';

class FinancialCalculatorScreen extends StatefulWidget {
  final double? initialRent;

  const FinancialCalculatorScreen({super.key, this.initialRent});

  @override
  State<FinancialCalculatorScreen> createState() =>
      _FinancialCalculatorScreenState();
}

class _FinancialCalculatorScreenState extends State<FinancialCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Rent Splitter State
  late TextEditingController _rentController;
  final TextEditingController _electricityController =
      TextEditingController(text: '1200');
  final TextEditingController _cookController =
      TextEditingController(text: '3000');
  final TextEditingController _wifiController =
      TextEditingController(text: '800');
  final TextEditingController _maidController =
      TextEditingController(text: '1000');
  int _roommateCount = 3;

  // EMI Calculator State
  double _loanAmount = 4500000; // 45 Lakhs
  double _interestRate = 8.5; // 8.5%
  int _tenureYears = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _rentController = TextEditingController(
      text: widget.initialRent != null
          ? widget.initialRent!.toStringAsFixed(0)
          : '18000',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rentController.dispose();
    _electricityController.dispose();
    _cookController.dispose();
    _wifiController.dispose();
    _maidController.dispose();
    super.dispose();
  }

  // Rent Splitter Calculations
  double get _totalRent => double.tryParse(_rentController.text) ?? 0;
  double get _electricity => double.tryParse(_electricityController.text) ?? 0;
  double get _cook => double.tryParse(_cookController.text) ?? 0;
  double get _wifi => double.tryParse(_wifiController.text) ?? 0;
  double get _maid => double.tryParse(_maidController.text) ?? 0;

  double get _totalMonthlyExpense =>
      _totalRent + _electricity + _cook + _wifi + _maid;
  double get _perPersonExpense =>
      _roommateCount > 0 ? _totalMonthlyExpense / _roommateCount : 0;

  // EMI Calculations
  double get _monthlyEmi {
    final principal = _loanAmount;
    final monthlyRate = (_interestRate / 12) / 100;
    final totalMonths = _tenureYears * 12;

    if (monthlyRate == 0) return principal / totalMonths;

    final emi = (principal *
            monthlyRate *
            pow(1 + monthlyRate, totalMonths)) /
        (pow(1 + monthlyRate, totalMonths) - 1);
    return emi;
  }

  double get _totalEmiPayable => _monthlyEmi * _tenureYears * 12;
  double get _totalInterestPayable => _totalEmiPayable - _loanAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Rent & EMI Calculator',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.group_outlined, size: 20),
              text: 'Roommate Rent Splitter',
            ),
            Tab(
              icon: Icon(Icons.calculate_outlined, size: 20),
              text: 'Home Loan EMI',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRentSplitterTab(),
          _buildEmiCalculatorTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Rent Splitter
  // ---------------------------------------------------------------------------
  Widget _buildRentSplitterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Highlight Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E6456), Color(0xFF134E4A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'EACH ROOMMATE PAYS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${_perPersonExpense.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'per month (Rent + Cook + Bills)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Total Expense',
                      '₹${_totalMonthlyExpense.toStringAsFixed(0)}',
                    ),
                    Container(width: 1, height: 28, color: Colors.white24),
                    _buildSummaryItem(
                      'Flatmates',
                      '$_roommateCount Persons',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text(
                      'Share Split on WhatsApp',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      final message =
                          '🏡 *Flat Expense Split Summary*\n\n'
                          '• Total Rent: ₹${_totalRent.toStringAsFixed(0)}\n'
                          '• Electricity: ₹${_electricity.toStringAsFixed(0)}\n'
                          '• Cook / Food: ₹${_cook.toStringAsFixed(0)}\n'
                          '• Wi-Fi & Maid: ₹${(_wifi + _maid).toStringAsFixed(0)}\n'
                          '--------------------------------\n'
                          '💰 *Total Bill:* ₹${_totalMonthlyExpense.toStringAsFixed(0)}\n'
                          '👥 *Roommates:* $_roommateCount\n'
                          '👉 *Per Person Share:* ₹${_perPersonExpense.toStringAsFixed(0)} /month\n\n'
                          'Calculated via Search App';
                      LauncherUtils.openWhatsApp(context, '', message: message);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Inputs Section
          Text(
            'Expense Breakdown',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

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
                // Roommates Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Number of Roommates',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: _roommateCount > 2
                              ? AppTheme.primary
                              : Colors.grey,
                          onPressed: _roommateCount > 2
                              ? () => setState(() => _roommateCount--)
                              : null,
                        ),
                        Text(
                          '$_roommateCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: _roommateCount < 8
                              ? AppTheme.primary
                              : Colors.grey,
                          onPressed: _roommateCount < 8
                              ? () => setState(() => _roommateCount++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),

                _buildInputField(
                  controller: _rentController,
                  label: 'Flat Rent (₹/month)',
                  icon: Icons.home_rounded,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _electricityController,
                  label: 'Electricity Bill (₹)',
                  icon: Icons.bolt_rounded,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _cookController,
                  label: 'Cook / Food Service (₹)',
                  icon: Icons.restaurant_rounded,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _wifiController,
                  label: 'Wi-Fi / Internet (₹)',
                  icon: Icons.wifi_rounded,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _maidController,
                  label: 'Maid / Cleaning (₹)',
                  icon: Icons.cleaning_services_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Home Loan EMI Calculator
  // ---------------------------------------------------------------------------
  Widget _buildEmiCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EMI Result Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'ESTIMATED MONTHLY EMI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${_monthlyEmi.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'for $_tenureYears years @ ${_interestRate.toStringAsFixed(1)}% p.a.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Principal',
                      '₹${(_loanAmount / 100000).toStringAsFixed(1)} L',
                    ),
                    Container(width: 1, height: 28, color: Colors.white24),
                    _buildSummaryItem(
                      'Total Interest',
                      '₹${(_totalInterestPayable / 100000).toStringAsFixed(1)} L',
                    ),
                    Container(width: 1, height: 28, color: Colors.white24),
                    _buildSummaryItem(
                      'Total Payable',
                      '₹${(_totalEmiPayable / 100000).toStringAsFixed(1)} L',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sliders
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
                // Loan Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loan Amount',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '₹${(_loanAmount / 100000).toStringAsFixed(1)} Lakhs',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _loanAmount,
                  min: 500000,
                  max: 20000000,
                  divisions: 39,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setState(() => _loanAmount = val),
                ),

                const SizedBox(height: 14),

                // Interest Rate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Interest Rate (% p.a.)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${_interestRate.toStringAsFixed(1)} %',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _interestRate,
                  min: 6.5,
                  max: 14.0,
                  divisions: 30,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setState(() => _interestRate = val),
                ),

                const SizedBox(height: 14),

                // Tenure
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tenure (Years)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '$_tenureYears Years',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _tenureYears.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 25,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setState(() => _tenureYears = val.toInt()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
