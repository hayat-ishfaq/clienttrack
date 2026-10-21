import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../invoices/data/invoice_repository.dart';
import '../../invoices/domain/models/invoice_model.dart';
import '../data/project_repository.dart';
import '../domain/models/project_model.dart';

// ---------------------------------------------------------------------------
// Screen: Project Details
// Conforms to Visily Mockup — Project Details Screen
// ---------------------------------------------------------------------------

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  ProjectModel? _currentProject;

  String _formatBudget(double amount) {
    final s = amount.round().toString();
    if (s.length > 3) {
      return '\$${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return '\$$s';
  }

  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return 'No deadline';
    final now = DateTime.now();
    final diff = deadline.difference(now).inDays;
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff < 0) return '${-diff}d overdue';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[deadline.month - 1]} ${deadline.day}, ${deadline.year}';
  }

  Future<void> _showMoreMenu(TapDownDetails details) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      details.globalPosition & const Size(40, 40),
      Offset.zero & overlay.size,
    );

    final value = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Edit Project', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy_outlined, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Duplicate Project', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(Icons.archive_outlined, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Archive Project', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: AppColors.overdueRed),
              SizedBox(width: 12),
              Text(
                'Delete Project',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.overdueRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (value == null || !mounted) return;
    if (value == 'edit') {
      context.pushNamed(
        AppRoutes.editProjectName,
        pathParameters: {'id': widget.projectId},
      );
    } else if (value == 'duplicate') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project duplicated as draft'),
          backgroundColor: AppColors.primaryForest,
        ),
      );
    } else if (value == 'archive') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project archived'),
          backgroundColor: AppColors.primaryForest,
        ),
      );
    } else if (value == 'delete') {
      _confirmDelete(_currentProject);
    }
  }

  void _confirmDelete(ProjectModel? project) {
    final title = project?.title ?? 'Project';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Project?',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "$title"? All associated task data will be removed.',
          style: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (project != null) {
                await ref.read(projectRepositoryProvider).deleteProject(project.id);
              }
              if (mounted) {
                context.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.overdueRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectByIdProvider(widget.projectId));
    final project = projectAsync.asData?.value;
    _currentProject = project;

    final invoicesAsync = ref.watch(clientInvoicesStreamProvider(project?.clientId ?? ''));
    final invoices = invoicesAsync.asData?.value ?? [];
    final linkedInvoice = invoices.isNotEmpty ? invoices.first : null;

    final title = project?.title ?? 'Website Redesign';
    final status = project?.status.label.toUpperCase() ?? 'IN PROGRESS';
    final description = project?.description ?? '';
    final clientName = project?.clientName ?? 'Sarah Johnson';
    final clientId = project?.clientId ?? '';
    final deadline = _formatDeadline(project?.deadline);
    final rateType = project?.rateType == RateType.hourly ? 'HOURLY RATE' : 'FIXED RATE';
    final rateAmount = _formatBudget(project?.budget ?? 1200.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header: Title & Status Badge
                  _buildHeaderSection(title, status),
                  const SizedBox(height: 12),
                  // Description
                  _buildDescriptionSection(description),
                  const SizedBox(height: 20),
                  // Client Card
                  _buildClientCard(clientName, clientId),
                  const SizedBox(height: 16),
                  // Two-Column Stats Row: Deadline & Fixed Rate
                  _buildTwoColumnStatsRow(deadline, rateType, rateAmount),
                  const SizedBox(height: 24),
                  // Linked Invoices Section
                  _buildLinkedInvoicesSection(linkedInvoice, invoices.length),
                  const SizedBox(height: 20),
                  // Efficiency Insight Card
                  _buildEfficiencyInsightCard(),
                  const SizedBox(height: 24),
                ],
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
        'Project Details',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        GestureDetector(
          onTapDown: _showMoreMenu,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Header Section ─────────────────────────────────────────────────────────

  Widget _buildHeaderSection(String title, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // IN PROGRESS Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE), // Soft light cyan/blue
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Color(0xFF0284C7), // Vibrant blue
            ),
          ),
        ),
      ],
    );
  }

  // ── Description Section ────────────────────────────────────────────────────

  Widget _buildDescriptionSection(String description) {
    return Text(
      description.isNotEmpty
          ? description
          : 'No description provided for this project.',
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.45,
      ),
    );
  }

  // ── Client Card ────────────────────────────────────────────────────────────

  Widget _buildClientCard(String clientName, String clientId) {
    final initials = clientName.trim().isNotEmpty
        ? clientName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'CL';

    return InkWell(
      onTap: () {
        if (clientId.isNotEmpty) {
          context.pushNamed(
            AppRoutes.clientDetailName,
            pathParameters: {'id': clientId},
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1E293B),
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Client Name & Company
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CLIENT',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Tap to view client profile',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
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
    );
  }

  // ── Two-Column Stats Row ───────────────────────────────────────────────────

  Widget _buildTwoColumnStatsRow(
      String deadline, String rateType, String rateAmount) {
    return Row(
      children: [
        // Column 1: Deadline Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED), // Warm peach tint
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFFEA580C), // Orange
                    size: 18,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DEADLINE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  deadline,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706), // Warm amber
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Column 2: Fixed Rate Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5), // Light mint green tint
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.attach_money_rounded,
                    color: Color(0xFF059669), // Green
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  rateType,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rateAmount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Linked Invoices Section ────────────────────────────────────────────────

  Widget _buildLinkedInvoicesSection(
      InvoiceModel? linkedInvoice, int totalInvoices) {
    if (linkedInvoice == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined,
                color: AppColors.textTertiary, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No invoices generated for this client yet.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final invoiceNumber = linkedInvoice.invoiceNumber;
    final invoiceTitle = 'Invoice $invoiceNumber';
    final invoiceStatus = linkedInvoice.status.name.toUpperCase();
    final isOverdue = linkedInvoice.isOverdue;
    final statusDetail = isOverdue
        ? '${linkedInvoice.daysOverdue} days late'
        : linkedInvoice.status.name;
    final amountText = '\$${linkedInvoice.totalAmount.toStringAsFixed(2)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LINKED INVOICES',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$totalInvoices total',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Linked invoice card
        InkWell(
          onTap: () {
            context.pushNamed(
              AppRoutes.invoiceDetailName,
              pathParameters: {'id': linkedInvoice.id},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
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
            child: Row(
              children: [
                // Document Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Invoice Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$invoiceNumber ',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            invoiceTitle,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? const Color(0xFFFEE2E2)
                                  : AppColors.paidTealBg,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 10,
                                  color: isOverdue
                                      ? const Color(0xFFEF4444)
                                      : AppColors.paidTeal,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  invoiceStatus,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                    color: isOverdue
                                        ? const Color(0xFFEF4444)
                                        : AppColors.paidTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusDetail,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount & Chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Efficiency Insight Card ────────────────────────────────────────────────

  Widget _buildEfficiencyInsightCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Very pale green
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              color: AppColors.primaryForest,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EFFICIENCY INSIGHT',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.primaryForest,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You\'re completing tasks 20% faster than average for this client.',
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
                    // Trending Up Circle Badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: Color(0xFF16A34A),
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
            onPressed: () {
              context.push(AppRoutes.createInvoice);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Create invoice',
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
      ),
    );
  }
}
