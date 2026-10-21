import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/chips/pro_badge.dart';
import '../domain/models/client_model.dart';
import '../data/client_repository.dart';
import '../../projects/domain/models/project_model.dart';
import '../../projects/data/project_repository.dart';
import '../../invoices/domain/models/invoice_model.dart';
import '../../invoices/data/invoice_repository.dart';

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

  Future<void> _launchEmail(String email) async {
    if (email.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _launchCall(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showMoreMenu(ClientModel? client) {
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
                  _confirmDelete(client);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(ClientModel? client) {
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
          'Deleting "${client?.name ?? 'this client'}" will permanently remove all linked projects '
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
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(clientRepositoryProvider).deleteClient(widget.clientId);
              if (mounted) context.pop();
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
    final clientAsync = ref.watch(clientByIdProvider(widget.clientId));
    final client = clientAsync.asData?.value;
    final projects = ref.watch(clientProjectsStreamProvider(widget.clientId)).asData?.value ?? [];
    final invoices = ref.watch(clientInvoicesStreamProvider(widget.clientId)).asData?.value ?? [];

    final name = client?.name ?? 'Client';
    final company = client?.company ?? '';
    final email = client?.email ?? '';
    final phone = client?.phone ?? '';
    final initials = client?.initials ?? 'CL';
    final presenceDot = client?.presenceDot ?? const Color(0xFF22C55E);

    final billed = invoices.fold<double>(0.0, (s, i) => s + i.totalAmount);
    final paid = invoices.fold<double>(0.0, (s, i) => s + i.amountPaid);
    final outstanding = (billed - paid).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(client),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile header ─────────────────────────────────────────
              _buildProfileHeader(name, company, initials, presenceDot),

              // ── Quick actions ──────────────────────────────────────────
              _buildQuickActions(email, phone),
              const SizedBox(height: 20),

              // ── Divider ────────────────────────────────────────────────
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 20),

              // ── Financial summary ──────────────────────────────────────
              _buildFinancialSummary(billed, paid, outstanding),
              const SizedBox(height: 20),

              // ── Payment history card ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPaymentHistoryCard(invoices),
              ),
              const SizedBox(height: 20),

              // ── Action buttons ─────────────────────────────────────────
              _buildActionButtons(),
              const SizedBox(height: 20),

              // ── Projects / Invoices tabs ───────────────────────────────
              _buildTabBar(projects.length, invoices.length),
              const SizedBox(height: 12),

              // ── Tab content ────────────────────────────────────────────
              _tabController.index == 0
                  ? _buildProjectsList(projects)
                  : _buildInvoicesList(invoices),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(ClientModel? client) {
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
          onPressed: () => _showMoreMenu(client),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Profile header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader(
      String name, String company, String initials, Color presenceDot) {
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
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
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
                    color: presenceDot,
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
            name,
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
          if (company.isNotEmpty)
            Text(
              company,
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

  Widget _buildQuickActions(String email, String phone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuickActionButton(
          icon: Icons.mail_outline_rounded,
          label: 'EMAIL',
          onTap: () => _launchEmail(email),
        ),
        const SizedBox(width: 24),
        _QuickActionButton(
          icon: Icons.phone_outlined,
          label: 'CALL',
          onTap: () => _launchCall(phone),
        ),
        const SizedBox(width: 24),
        _QuickActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'WHATSAPP',
          onTap: () => _launchWhatsApp(phone),
        ),
      ],
    );
  }

  // ── Financial summary ───────────────────────────────────────────────────────

  Widget _buildFinancialSummary(double billed, double paid, double outstanding) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FinancialMetric(
            label: 'BILLED',
            value: '\$${billed.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            valueColor: AppColors.textPrimary,
          ),
          _buildMetricDivider(),
          _FinancialMetric(
            label: 'PAID',
            value: '\$${paid.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            valueColor: AppColors.textPrimary,
          ),
          _buildMetricDivider(),
          _FinancialMetric(
            label: 'OUTSTANDING',
            value: '\$${outstanding.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
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

  Widget _buildPaymentHistoryCard(List<InvoiceModel> invoices) {
    final hasInvoices = invoices.isNotEmpty;
    final overdueCount = invoices.where((i) => i.isOverdue).length;
    final onTimeCount = invoices.length - overdueCount;
    final onTimePercent =
        hasInvoices ? ((onTimeCount / invoices.length) * 100).round() : 100;

    final totalOverdueDays = invoices
        .where((i) => i.isOverdue)
        .fold<int>(0, (s, i) => s + i.daysOverdue);
    final avgDaysLate =
        overdueCount > 0 ? (totalOverdueDays / overdueCount).round() : 0;

    final chipLabel = !hasInvoices
        ? 'No history'
        : (onTimePercent >= 90
            ? 'Usually pays on time'
            : (onTimePercent >= 60 ? 'Sometimes late' : 'High risk'));

    final chipBg = !hasInvoices
        ? AppColors.draftGreyBg
        : (onTimePercent >= 90
            ? AppColors.paidTealBg
            : (onTimePercent >= 60
                ? AppColors.dueSoonAmberBg
                : AppColors.overdueRedBg));

    final chipFg = !hasInvoices
        ? AppColors.draftGrey
        : (onTimePercent >= 90
            ? AppColors.paidTeal
            : (onTimePercent >= 60
                ? AppColors.dueSoonAmber
                : AppColors.overdueRed));

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
                  color: chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: chipFg,
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
                      '$avgDaysLate',
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
                      '$onTimePercent%',
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
                'Based on ${invoices.length} invoices',
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

  Widget _buildTabBar(int projectCount, int invoiceCount) {
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
                  _CountBadge(count: projectCount),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Invoices'),
                  const SizedBox(width: 6),
                  _CountBadge(count: invoiceCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Projects list ───────────────────────────────────────────────────────────

  Widget _buildProjectsList(List<ProjectModel> projects) {
    if (projects.isEmpty) {
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
        children: projects
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

  Widget _buildInvoicesList(List<InvoiceModel> invoices) {
    if (invoices.isEmpty) {
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
        children: invoices
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
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectRow({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusBg;
    final Color statusFg;
    final String statusLabel = project.status.label;
    final IconData statusIcon;

    switch (project.status) {
      case ProjectStatus.inProgress:
        statusBg = AppColors.sentBlueBg;
        statusFg = AppColors.sentBlue;
        statusIcon = Icons.access_time_rounded;
      case ProjectStatus.completed:
        statusBg = AppColors.paidTealBg;
        statusFg = AppColors.paidTeal;
        statusIcon = Icons.check_circle_outline_rounded;
      case ProjectStatus.onHold:
      case ProjectStatus.planning:
      case ProjectStatus.notStarted:
        statusBg = AppColors.dueSoonAmberBg;
        statusFg = AppColors.dueSoonAmber;
        statusIcon = Icons.pause_circle_outline_rounded;
    }

    final deadlineText = project.deadline != null
        ? 'Due ${DateFormat('MMM d').format(project.deadline!)}'
        : 'Ongoing';

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
                      deadlineText,
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
              const Icon(Icons.chevron_right_rounded,
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
  final InvoiceModel invoice;
  final VoidCallback onTap;

  const _InvoiceRow({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusBg;
    final Color statusFg;

    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusBg = AppColors.paidTealBg;
        statusFg = AppColors.paidTeal;
      case InvoiceStatus.overdue:
        statusBg = AppColors.overdueRedBg;
        statusFg = AppColors.overdueRed;
      case InvoiceStatus.sent:
      case InvoiceStatus.viewed:
        statusBg = AppColors.sentBlueBg;
        statusFg = AppColors.sentBlue;
      case InvoiceStatus.draft:
        statusBg = AppColors.draftGreyBg;
        statusFg = AppColors.draftGrey;
    }

    final dateFormatted = DateFormat('MMM d, yyyy').format(invoice.issueDate);

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
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_outlined,
                    size: 18, color: statusFg),
              ),
              const SizedBox(width: 12),
              // Number + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormatted,
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
                '\$${invoice.totalAmount.toStringAsFixed(0)}',
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
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.status.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusFg,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
