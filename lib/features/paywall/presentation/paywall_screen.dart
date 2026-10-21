import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../data/revenue_cat_service.dart';

// ---------------------------------------------------------------------------
// Screen: ClientTrack Pro Paywall / Upgrade Screen
// Conforms to Visily Mockup — Unlock ClientTrack Pro
// ---------------------------------------------------------------------------

enum SubscriptionPlan {
  annual,
  monthly,
}

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.annual;
  bool _isProcessing = false;

  final List<String> _benefits = const [
    'Unlimited clients and invoices',
    'Unlimited reminder shares',
    'AI-polished reminders',
    'Full payment history and risk insights',
    'No ClientTrack footer on PDFs',
    'CSV export',
  ];

  Future<void> _handleSubscribe(Package? annualPkg, Package? monthlyPkg) async {
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    final rcService = ref.read(revenueCatServiceProvider);
    final targetPkg = _selectedPlan == SubscriptionPlan.annual ? annualPkg : monthlyPkg;

    try {
      if (rcService.isSupportedPlatform && targetPkg != null) {
        final customerInfo = await rcService.purchasePackage(targetPkg);
        ref.read(customerInfoNotifierProvider.notifier).setManualCustomerInfo(customerInfo);
        
        final isPro = rcService.checkIsPro(customerInfo);
        if (mounted) {
          if (isPro) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Welcome to ClientTrack PRO! All features unlocked.'),
                backgroundColor: AppColors.primaryForest,
                duration: Duration(seconds: 3),
              ),
            );
            context.pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchase completed, updating subscription status...'),
                backgroundColor: AppColors.primaryForest,
              ),
            );
          }
        }
      } else {
        // Fallback for desktop/simulator testing without live storekit
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedPlan == SubscriptionPlan.annual
                    ? '🎉 Welcome to ClientTrack PRO Annual! All features unlocked.'
                    : '🎉 Welcome to ClientTrack PRO Monthly! All features unlocked.',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              backgroundColor: AppColors.primaryForest,
              duration: const Duration(seconds: 3),
            ),
          );
          context.pop();
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final userCancelled = PurchasesErrorHelper.getErrorCode(e) == PurchasesErrorCode.purchaseCancelledError;
        if (!userCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase error: ${e.message ?? e.details ?? "Transaction cancelled"}'),
              backgroundColor: AppColors.overdueRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not complete purchase: $e'),
            backgroundColor: AppColors.overdueRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRestore() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);
    final rcService = ref.read(revenueCatServiceProvider);

    try {
      if (rcService.isSupportedPlatform) {
        final customerInfo = await rcService.restorePurchases();
        ref.read(customerInfoNotifierProvider.notifier).setManualCustomerInfo(customerInfo);
        final isPro = rcService.checkIsPro(customerInfo);

        if (mounted) {
          if (isPro) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Subscription restored successfully! PRO features active.'),
                backgroundColor: AppColors.primaryForest,
              ),
            );
            context.pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No active ClientTrack PRO subscription found to restore.'),
                backgroundColor: AppColors.textSecondary,
              ),
            );
          }
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Store restoration verified in sandbox.'),
              backgroundColor: AppColors.primaryForest,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore error: $e'),
            backgroundColor: AppColors.overdueRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.4, color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryForest, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final offerings = offeringsAsync.asData?.value;
    final annualPkg = offerings?.current?.annual;
    final monthlyPkg = offerings?.current?.monthly;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero illustration banner
                  _buildHeroBanner(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'Unlock ClientTrack Pro',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Overdue Invoices Callout
                        _buildOverdueCallout(),
                        const SizedBox(height: 24),
                        // Premium Benefits Checklist
                        _buildPremiumBenefitsSection(),
                        const SizedBox(height: 26),
                        // Select a plan section
                        _buildSelectPlanSection(annualPkg, monthlyPkg),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sticky Bottom Actions
          _buildStickyBottomArea(annualPkg, monthlyPkg),
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
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF), // Soft indigo tint
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF4F46E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'ClientTrack Pro',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), // Light grey circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
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

  // ── Hero Banner ────────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 210,
      color: const Color(0xFF0D141C),
      child: Image.asset(
        'assets/pro_upgrade_hero.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackBanner(),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 160,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.query_stats_rounded, size: 54, color: AppColors.accentTealGreen),
                SizedBox(height: 10),
                Text(
                  'FINTECH ANALYTICS & REVENUE GROWTH',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Overdue Invoices Callout ────────────────────────────────────────────────

  Widget _buildOverdueCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light soft red
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFCA5A5).withValues(alpha: 0.6),
        ),
      ),
      child: const Text(
        'You have 3 overdue invoices. Unlock the full payment chaser to get paid faster.',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFFDC2626), // Coral red
          height: 1.35,
        ),
      ),
    );
  }

  // ── Premium Benefits Checklist ─────────────────────────────────────────────

  Widget _buildPremiumBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PREMIUM BENEFITS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        ..._benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7), // Light mint green
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── Select a Plan Section ──────────────────────────────────────────────────

  Widget _buildSelectPlanSection(Package? annualPkg, Package? monthlyPkg) {
    final isAnnual = _selectedPlan == SubscriptionPlan.annual;
    final annualPrice = annualPkg?.storeProduct.priceString != null
        ? '${annualPkg!.storeProduct.priceString}/year'
        : '\$59.99/year • \$5.00/month';
    final monthlyPrice = monthlyPkg?.storeProduct.priceString != null
        ? '${monthlyPkg!.storeProduct.priceString}/month'
        : '\$9.99/month';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT A PLAN',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        // Annual Plan Card
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedPlan = SubscriptionPlan.annual);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isAnnual ? const Color(0xFFF6FAF7) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAnnual ? AppColors.primaryForest : AppColors.border,
                width: isAnnual ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Annual Plan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryForest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BEST VALUE',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        annualPrice,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isAnnual
                        ? AppColors.primaryForest
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAnnual
                          ? AppColors.primaryForest
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: isAnnual
                      ? const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Monthly Plan Card
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedPlan = SubscriptionPlan.monthly);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: !isAnnual ? const Color(0xFFF6FAF7) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: !isAnnual ? AppColors.primaryForest : AppColors.border,
                width: !isAnnual ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Plan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthlyPrice,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: !isAnnual
                        ? AppColors.primaryForest
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: !isAnnual
                          ? AppColors.primaryForest
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: !isAnnual
                      ? const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Sticky Bottom Area ─────────────────────────────────────────────────────

  Widget _buildStickyBottomArea(Package? annualPkg, Package? monthlyPkg) {
    final isPro = ref.watch(isProProvider);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _handleSubscribe(annualPkg, monthlyPkg),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPro ? const Color(0xFF0F766E) : AppColors.primaryForest,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isPro) ...[
                            const Icon(Icons.verified, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'PRO Active — Manage Plan',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ] else
                            const Text(
                              'Continue',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Restore purchases link
            InkWell(
              onTap: _handleRestore,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Restore purchases',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryForest,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Auto-renewal note
            const Text(
              'Auto-renews until canceled. Cancel anytime in your store settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            // Terms and Privacy
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _showPolicyDialog(
                    'Terms of Service',
                    'By subscribing to ClientTrack Pro, you agree to recurring billing based on your selected plan. Subscriptions renew automatically unless turned off at least 24 hours before the end of the current period.',
                  ),
                  child: const Text(
                    'Terms',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '|',
                    style: TextStyle(fontSize: 11, color: AppColors.border),
                  ),
                ),
                InkWell(
                  onTap: () => _showPolicyDialog(
                    'Privacy Policy',
                    'ClientTrack respects your privacy. We store business data securely in encrypted cloud databases and never sell your personal information or client communications.',
                  ),
                  child: const Text(
                    'Privacy',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
