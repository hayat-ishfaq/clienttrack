import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/data/auth_repository.dart';

/// Screen 06: Profile Setup Screen.
/// Conforms to visily-06-profile-setup.png.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();

  String _selectedCurrency = 'USD';
  bool _isLoading = false;

  final List<Map<String, String>> _currencies = const [
    {'code': 'USD', 'symbol': r'$', 'label': r'USD ($) - US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'label': 'EUR (€) - Euro'},
    {'code': 'GBP', 'symbol': '£', 'label': 'GBP (£) - British Pound'},
    {'code': 'CAD', 'symbol': r'$', 'label': r'CAD ($) - Canadian Dollar'},
    {'code': 'AUD', 'symbol': r'$', 'label': r'AUD ($) - Australian Dollar'},
    {'code': 'INR', 'symbol': '₹', 'label': 'INR (₹) - Indian Rupee'},
    {'code': 'AED', 'symbol': 'AED', 'label': 'AED - UAE Dirham'},
    {'code': 'SGD', 'symbol': r'$', 'label': r'SGD ($) - Singapore Dollar'},
    {'code': 'PKR', 'symbol': 'Rs', 'label': 'PKR (Rs) - Pakistani Rupee'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.updateUserProfile(
        fullName: _nameController.text.trim(),
        businessName: _businessController.text.trim().isNotEmpty
            ? _businessController.text.trim()
            : null,
        currencyCode: _selectedCurrency,
      );

      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } catch (_) {
      // Fallback for offline or local preview
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSkip() {
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Banner Illustration
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/profile_setup_banner.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Header Section
                Center(
                  child: Column(
                    children: const [
                      Text(
                        "Let's set up your profile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Help us personalize your workspace for a better management experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Field 1: Your Name
                const Text(
                  'Your Name',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Alex Rivera',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF9CA3AF),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: Color(0xFF9CA3AF),
                    ),
                    fillColor: const Color(0xFFFAFAFA),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryForest, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.overdueRed, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.overdueRed, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Field 2: Business Name (Optional)
                const Text(
                  'Business Name (Optional)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _businessController,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Rivera Design Studio',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF9CA3AF),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.storefront_outlined,
                      size: 20,
                      color: Color(0xFF9CA3AF),
                    ),
                    fillColor: const Color(0xFFFAFAFA),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryForest, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Field 3: Preferred Currency
                const Text(
                  'Preferred Currency',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.language_rounded,
                      size: 20,
                      color: Color(0xFF9CA3AF),
                    ),
                    fillColor: const Color(0xFFFAFAFA),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryForest, width: 1.5),
                    ),
                  ),
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency['code'],
                      child: Text(
                        currency['label']!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCurrency = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'This will be the default currency for all your new invoices.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Informational Tip Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1EBE0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC7EADB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF2E5D31),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF26522B),
                              height: 1.35,
                            ),
                            children: [
                              TextSpan(text: 'You can always change these settings later in your '),
                              TextSpan(
                                text: 'Account Settings',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Complete Setup Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCompleteSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26522B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Complete Setup',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Skip for now Text Button
                Center(
                  child: TextButton(
                    onPressed: _onSkip,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Step Indicator Tag
                const Center(
                  child: Text(
                    'STEP 3 OF 3 • PROFESSIONAL IDENTITY',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
