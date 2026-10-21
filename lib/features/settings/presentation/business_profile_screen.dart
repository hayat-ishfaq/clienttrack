import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Screen: Business Profile
// Conforms to Visily Mockup — Business Profile Screen
// ---------------------------------------------------------------------------

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Preferences
  String _selectedCurrency = 'USD - US Dollar';
  String _selectedPaymentTerms = 'Net 15';

  bool _isSaving = false;
  String? _uploadedLogoPath;

  final List<String> _currencies = const [
    'USD - US Dollar',
    'EUR - Euro',
    'GBP - British Pound',
    'CAD - Canadian Dollar',
    'AUD - Australian Dollar',
  ];

  final List<String> _paymentTerms = const [
    'Due on receipt',
    'Net 7',
    'Net 15',
    'Net 30',
    'Net 60',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Sarah Johnson');
    _businessNameController = TextEditingController(text: 'Brightside Cafe');
    _emailController = TextEditingController(text: 'sarah@brightside.cafe');
    _phoneController = TextEditingController(text: '+1 (555) 012-3456');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onUploadLogo() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Upload Business Logo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'High-resolution PNG or JPG recommended. Displayed at the header of your invoices.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primaryForest),
                ),
                title: const Text('Choose from Photo Library',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _uploadedLogoPath = 'assets/icons/logo_preview.png');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logo attached successfully!'),
                      backgroundColor: AppColors.primaryForest,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primaryForest),
                ),
                title: const Text('Take Photo',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _uploadedLogoPath = 'assets/icons/logo_preview.png');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logo attached successfully!'),
                      backgroundColor: AppColors.primaryForest,
                    ),
                  );
                },
              ),
              if (_uploadedLogoPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.overdueRedBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.overdueRed),
                  ),
                  title: const Text('Remove Current Logo',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: AppColors.overdueRed)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _uploadedLogoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Select Currency',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ..._currencies.map(
                (currency) => ListTile(
                  title: Text(
                    currency,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: currency == _selectedCurrency
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: currency == _selectedCurrency
                          ? AppColors.primaryForest
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: currency == _selectedCurrency
                      ? const Icon(Icons.check, color: AppColors.primaryForest)
                      : null,
                  onTap: () {
                    setState(() => _selectedCurrency = currency);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentTermsPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Default Payment Terms',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ..._paymentTerms.map(
                (term) => ListTile(
                  title: Text(
                    term,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: term == _selectedPaymentTerms
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: term == _selectedPaymentTerms
                          ? AppColors.primaryForest
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: term == _selectedPaymentTerms
                      ? const Icon(Icons.check, color: AppColors.primaryForest)
                      : null,
                  onTap: () {
                    setState(() => _selectedPaymentTerms = term);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business profile updated successfully!'),
          backgroundColor: AppColors.primaryForest,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Business Logo
                    _buildBusinessLogoSection(),
                    const SizedBox(height: 28),
                    // Section 2: Core Information
                    _buildCoreInformationSection(),
                    const SizedBox(height: 28),
                    // Section 3: Billing Preferences
                    _buildBillingPreferencesSection(),
                    const SizedBox(height: 24),
                    // Section 4: Growth Tip Card
                    _buildGrowthTipCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActionArea(),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Business profile',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        // PRO PLAN badge pill
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: InkWell(
              onTap: () => context.pushNamed(AppRoutes.paywallName),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryForest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'PRO PLAN',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Section 1: Business Logo ───────────────────────────────────────────────

  Widget _buildBusinessLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'BUSINESS LOGO',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            // PRO FEATURE Gold Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706), // Rich Gold / Amber
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 11,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'PRO FEATURE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Dashed border upload card
        InkWell(
          onTap: _onUploadLogo,
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: const Color(0xFFD5DFD7),
              radius: 16,
              strokeWidth: 1.5,
              dashLength: 6,
              dashGap: 4,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFCFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Upload circular icon button
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.file_upload_outlined,
                      size: 24,
                      color: AppColors.primaryForest,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _uploadedLogoPath != null
                        ? 'Logo attached (Tap to change)'
                        : 'Upload your logo',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Appears on all invoices and client\nreminders. PNG or JPG, max 5MB.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 2: Core Information ───────────────────────────────────────────

  Widget _buildCoreInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CORE INFORMATION',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        // Your Name
        _buildInputField(
          label: 'Your name',
          controller: _nameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        // Business Name
        _buildInputField(
          label: 'Business name',
          controller: _businessNameController,
          icon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 14),
        // Email
        _buildInputField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        // Phone
        _buildInputField(
          label: 'Phone',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 3: Billing Preferences ─────────────────────────────────────────

  Widget _buildBillingPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BILLING PREFERENCES',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        // Currency selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currency',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _showCurrencyPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCurrency,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Default payment terms selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default payment terms',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _showPaymentTermsPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.credit_card_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPaymentTerms,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'New invoices will use these terms by default.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Section 4: Growth Tip Card ─────────────────────────────────────────────

  Widget _buildGrowthTipCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F3), // Pale mint green
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4EBDC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left forest green vertical accent indicator
            Container(
              width: 5,
              color: AppColors.primaryForest,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'GROWTH TIP',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: AppColors.primaryForest,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Consistent branding can help you get paid up to 3x faster than non-branded invoices.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Checkmark in circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.primaryForest,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Action Area ─────────────────────────────────────────────────────

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save changes',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painter for Dashed Rounded Border
// ---------------------------------------------------------------------------

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double dashGap;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 16,
    this.dashLength = 6,
    this.dashGap = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path, dashLength, dashGap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double dashGap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashLength, metric.length - distance);
        dest.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashLength + dashGap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
