import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Screen: Settings
// Conforms to Visily Mockup — Settings Screen
// ---------------------------------------------------------------------------

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final String _userName = 'Alex Morgan';
  final String _userStudio = 'Morgan Studio';
  final String _currentPlan = 'Free plan';
  String _selectedPaymentTerms = 'Net 15';

  final List<String> _paymentTermsOptions = const [
    'Due on receipt',
    'Net 7',
    'Net 15',
    'Net 30',
    'Net 60',
  ];

  void _showDefaultPaymentTermsModal() {
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
              ..._paymentTermsOptions.map(
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Default payment terms set to $term'),
                        backgroundColor: AppColors.primaryForest,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRestorePurchases() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checking store for existing purchases...'),
        backgroundColor: AppColors.primaryForest,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleExportCsv() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting invoices and clients to CSV...'),
        backgroundColor: AppColors.primaryForest,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(
                    color: AppColors.primaryForest,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out of ClientTrack?',
          style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Log out',
                style: TextStyle(
                    color: AppColors.overdueRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account?',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will permanently delete your account, business profile, all client records, and invoice history. This action cannot be undone.',
          style: TextStyle(
              fontFamily: 'Inter', color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Delete permanently',
                style: TextStyle(
                    color: AppColors.overdueRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        children: [
          // User Profile Card
          _buildUserProfileCard(),
          const SizedBox(height: 24),
          // Subscription Section
          _buildSubscriptionSection(),
          const SizedBox(height: 24),
          // Business & Billing Section
          _buildBusinessAndBillingSection(),
          const SizedBox(height: 24),
          // Legal Section
          _buildLegalSection(),
          const SizedBox(height: 28),
          // Log Out Button
          _buildLogoutButton(),
          const SizedBox(height: 16),
          // Delete Account Button
          _buildDeleteAccountButton(),
          const SizedBox(height: 28),
          // Footer Branding
          _buildFooterBranding(),
          const SizedBox(height: 30),
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
      automaticallyImplyLeading: false,
      title: const Text(
        'Settings',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── User Profile Card ──────────────────────────────────────────────────────

  Widget _buildUserProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.businessProfile),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF1F5F9),
                child: const Text(
                  'AM',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryForest,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userStudio,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Subscription Section ───────────────────────────────────────────────────

  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUBSCRIPTION',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Plan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _currentPlan,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryForest,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.credit_card_outlined,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Upgrade to Pro Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.paywall),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryForest,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium_outlined,
                          size: 19, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Unlock unlimited clients, AI reminders, and risk insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Business & Billing Section ─────────────────────────────────────────────

  Widget _buildBusinessAndBillingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BUSINESS & BILLING',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildListRow(
                icon: Icons.storefront_outlined,
                iconColor: AppColors.primaryForest,
                title: 'Business profile',
                onTap: () => context.push(AppRoutes.businessProfile),
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildListRow(
                icon: Icons.history_rounded,
                iconColor: const Color(0xFF4A6FA5),
                title: 'Default payment terms',
                onTap: _showDefaultPaymentTermsModal,
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildListRow(
                icon: Icons.credit_card_outlined,
                iconColor: AppColors.textSecondary,
                title: 'Manage subscription',
                onTap: () => context.push(AppRoutes.paywall),
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildListRow(
                icon: Icons.file_download_outlined,
                iconColor: const Color(0xFF2F7A6A),
                title: 'Restore purchases',
                onTap: _handleRestorePurchases,
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildListRow(
                icon: Icons.description_outlined,
                iconColor: AppColors.textSecondary,
                title: 'Export CSV',
                trailingBadge: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: _handleExportCsv,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Legal Section ──────────────────────────────────────────────────────────

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LEGAL',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildListRow(
                icon: Icons.shield_outlined,
                iconColor: AppColors.textSecondary,
                title: 'Privacy Policy',
                onTap: () => _showPolicyDialog(
                  'Privacy Policy',
                  'ClientTrack protects your personal data and invoice information using industry-standard AES encryption. We do not sell your personal or financial data to third parties under any circumstances.',
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildListRow(
                icon: Icons.article_outlined,
                iconColor: AppColors.textSecondary,
                title: 'Terms of Service',
                onTap: () => _showPolicyDialog(
                  'Terms of Service',
                  'By using ClientTrack, you agree to our standard terms of service. ClientTrack provides freelance client management, project scheduling, invoice generation, and reminder delivery tools.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailingBadge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (trailingBadge != null) ...[
                    const SizedBox(width: 8),
                    trailingBadge,
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout Button ──────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _confirmLogout,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                size: 18, color: AppColors.textPrimary),
            SizedBox(width: 8),
            Text(
              'Log out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Account Button ──────────────────────────────────────────────────

  Widget _buildDeleteAccountButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _confirmDeleteAccount,
        icon: const Icon(Icons.delete_outline,
            size: 17, color: AppColors.overdueRed),
        label: const Text(
          'Delete account',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.overdueRed,
          ),
        ),
      ),
    );
  }

  // ── Footer Branding ────────────────────────────────────────────────────────

  Widget _buildFooterBranding() {
    return const Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up_rounded,
                  size: 14, color: AppColors.textTertiary),
              SizedBox(width: 5),
              Text(
                'CLIENTTRACK V1.0',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3),
          Text(
            'Made for professionals who get things done.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
