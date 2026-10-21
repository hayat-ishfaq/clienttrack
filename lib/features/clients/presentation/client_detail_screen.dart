import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/chips/pro_badge.dart';

// ---------------------------------------------------------------------------
// Demo data stub — replaced by Firestore (FT-007)
// ---------------------------------------------------------------------------

enum _ProjectStatus { inProgress, completed, onHold }

class _DemoProject {
  final String id;
  final String title;
  final String updatedLabel;
  final _ProjectStatus status;
  const _DemoProject({
    required this.id,
    required this.title,
    required this.updatedLabel,
    required this.status,
  });
}

class _DemoInvoice {
  final String id;
  final String number;
  final String amount;
  final String date;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  const _DemoInvoice({
    required this.id,
    required this.number,
    required this.amount,
    required this.date,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
  });
}

// ---------------------------------------------------------------------------
// Screen 10: Client Detail
// Conforms to visily-10-client-details.png
// ---------------------------------------------------------------------------

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Demo state (replaced by real Firestore streams in FT-007) ──────────────
  final String _name = 'Sarah Johnson';
  final String _company = 'Brightside Cafe';
  final String _email = 'sarah@brightsidecafe.com';
  final String _phone = '+1 (555) 234-5678';
  final String _whatsapp = '+15552345678';

  final double _billed = 1950;
  final double _paid = 1500;
  final double _outstanding = 450;

  final int _avgDaysLate = 4;
  final int _onTimePercent = 67;
  final int _invoiceCount = 6;

  final List<_DemoProject> _projects = const [
    _DemoProject(
      id: 'p1',
      title: 'Website Redesign',
      updatedLabel: 'Updated 2h ago',
      status: _ProjectStatus.inProgress,
    ),
    _DemoProject(
      id: 'p2',
      title: 'Landing Page Copy',
      updatedLabel: 'Closed Sep 12',
      status: _ProjectStatus.completed,
    ),
  ];

  final List<_DemoInvoice> _invoices = const [
    _DemoInvoice(
      id: 'inv1',
      number: 'INV-0042',
      amount: '\$950',
      date: 'Oct 1, 2026',
      statusLabel: 'Overdue',
      statusBg: AppColors.overdueRedBg,
      statusFg: AppColors.overdueRed,
    ),
    _DemoInvoice(
      id: 'inv2',
      number: 'INV-0038',
      amount: '\$1,000',
      date: 'Sep 5, 2026',
      statusLabel: 'Paid',
      statusBg: AppColors.paidTealBg,
      statusFg: AppColors.paidTeal,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Quick actions ──────────────────────────────────────────────────────────

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: _email);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _launchCall() async {
    final uri = Uri(scheme: 'tel', path: _phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/${_whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined,
                    color: AppColors.textPrimary),
                title: const Text('Edit Client',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/clients/${widget.clientId}/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined,
                    color: AppColors.primaryForest),
                title: const Text('Create Invoice',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryForest)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.createInvoice);
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.overdueRed),
                title: const Text('Delete Client',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: AppColors.overdueRed)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Client?',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(
          'Deleting "$_name" will permanently remove all linked projects '
          'and invoices. This cannot be undone.',
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Delete',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: AppColors.overdueRed)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile header ─────────────────────────────────────────
              _buildProfileHeader(),

              // ── Quick actions ──────────────────────────────────────────
              _buildQuickActions(),
              const SizedBox(height: 20),

              // ── Divider ────────────────────────────────────────────────
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 20),

              // ── Financial summary ──────────────────────────────────────
              _buildFinancialSummary(),
              const SizedBox(height: 20),

              // ── Payment history card ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPaymentHistoryCard(),
              ),
              const SizedBox(height: 20),

              // ── Action buttons ─────────────────────────────────────────
              _buildActionButtons(),
              const SizedBox(height: 20),

              // ── Projects / Invoices tabs ───────────────────────────────
              _buildTabBar(),
              const SizedBox(height: 12),

              // ── Tab content ────────────────────────────────────────────
              _tabController.index == 0
                  ? _buildProjectsList()
                  : _buildInvoicesList(),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Client Details',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              size: 22, color: AppColors.textPrimary),
          onPressed: _showMoreMenu,
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Profile header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8EEE8),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SJ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryForest,
                    ),
                  ),
                ),
              ),
              // Presence dot
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            _name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          // Company
          Text(
            _company,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick action row ────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuickActionButton(
          icon: Icons.mail_outline_rounded,
          label: 'EMAIL',
          onTap: _launchEmail,
        ),
        const SizedBox(width: 24),
        _QuickActionButton(
          icon: Icons.phone_outlined,
          label: 'CALL',
          onTap: _launchCall,
        ),
        const SizedBox(width: 24),
        _QuickActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'WHATSAPP',
          onTap: _launchWhatsApp,
        ),
      ],
    );
  }

  // ── Financial summary ───────────────────────────────────────────────────────

  Widget _buildFinancialSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FinancialMetric(
            label: 'BILLED',
            value: '\$${_billed.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            valueColor: AppColors.textPrimary,
          ),
          _buildMetricDivider(),
          _FinancialMetric(
            label: 'PAID',
            value: '\$${_paid.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            valueColor: AppColors.textPrimary,
          ),
          _buildMetricDivider(),
          _FinancialMetric(
            label: 'OUTSTANDING',
            value: '\$${_outstanding.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            valueColor: AppColors.overdueRed,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.border,
    );
  }

  // ── Payment history card ────────────────────────────────────────────────────

  Widget _buildPaymentHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PAYMENT HISTORY',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              // Reliability chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dueSoonAmberBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Sometimes late',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dueSoonAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metrics row
          Row(
            children: [
              // Avg days late
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avg. days late',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_avgDaysLate',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // On-time rate
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'On-time rate',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_onTimePercent%',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentTealGreen,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Based on $_invoiceCount invoices',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              // See full history + PRO badge
              GestureDetector(
                onTap: () => context.push(AppRoutes.paywall),
                child: Row(
                  children: [
                    const Text(
                      'See full history ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    ProBadge(
                      onTap: () => context.push(AppRoutes.paywall),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action buttons ──────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // New Project
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addProject),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryForest,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'New project',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // New Invoice
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.createInvoice),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side:
                      const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                label: const Text(
                  'New invoice',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Projects'),
                  const SizedBox(width: 6),
                  _CountBadge(count: _projects.length),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Invoices'),
                  const SizedBox(width: 6),
                  _CountBadge(count: _invoices.length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Projects list ───────────────────────────────────────────────────────────

  Widget _buildProjectsList() {
    if (_projects.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.work_outline_rounded,
        message: 'No projects yet',
        action: 'Add Project',
        onAction: () => context.push(AppRoutes.addProject),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _projects
            .map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ProjectRow(
                    project: p,
                    onTap: () => context.push('/projects/${p.id}'),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Invoices list ────────────────────────────────────────────────────────────

  Widget _buildInvoicesList() {
    if (_invoices.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.description_outlined,
        message: 'No invoices yet',
        action: 'Create Invoice',
        onAction: () => context.push(AppRoutes.createInvoice),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _invoices
            .map((inv) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _InvoiceRow(
                    invoice: inv,
                    onTap: () => context.push('/invoices/${inv.id}'),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyTabState({
    required IconData icon,
    required String message,
    required String action,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onAction,
              child: Text(
                action,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryForest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Action Button (Email / Call / WhatsApp)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Financial Metric Column
// ─────────────────────────────────────────────────────────────────────────────

class _FinancialMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _FinancialMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab count badge
// ─────────────────────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project row card
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectRow extends StatelessWidget {
  final _DemoProject project;
  final VoidCallback onTap;

  const _ProjectRow({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusBg;
    final Color statusFg;
    final String statusLabel;
    final IconData statusIcon;

    switch (project.status) {
      case _ProjectStatus.inProgress:
        statusBg = AppColors.sentBlueBg;
        statusFg = AppColors.sentBlue;
        statusLabel = 'In Progress';
        statusIcon = Icons.access_time_rounded;
      case _ProjectStatus.completed:
        statusBg = AppColors.paidTealBg;
        statusFg = AppColors.paidTeal;
        statusLabel = 'Completed';
        statusIcon = Icons.check_circle_outline_rounded;
      case _ProjectStatus.onHold:
        statusBg = AppColors.dueSoonAmberBg;
        statusFg = AppColors.dueSoonAmber;
        statusLabel = 'On Hold';
        statusIcon = Icons.pause_circle_outline_rounded;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, size: 18, color: statusFg),
              ),
              const SizedBox(width: 12),
              // Title + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.updatedLabel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status chip + chevron
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: statusFg,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invoice row card
// ─────────────────────────────────────────────────────────────────────────────

class _InvoiceRow extends StatelessWidget {
  final _DemoInvoice invoice;
  final VoidCallback onTap;

  const _InvoiceRow({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: invoice.statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_outlined,
                    size: 18, color: invoice.statusFg),
              ),
              const SizedBox(width: 12),
              // Number + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.number,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.date,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                invoice.amount,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // Status chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: invoice.statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.statusLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: invoice.statusFg,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
