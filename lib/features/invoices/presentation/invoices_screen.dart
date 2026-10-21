import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../data/invoice_repository.dart';
import '../domain/models/invoice_model.dart';

// ---------------------------------------------------------------------------
// Filter for Invoices Screen
// ---------------------------------------------------------------------------

enum InvoiceFilterStatus {
  all,
  draft,
  sent,
  overdue,
  paid,
}

// ---------------------------------------------------------------------------
// Screen: Invoices Hub / List Screen
// Conforms to Visily Mockup — Invoices Screen
// ---------------------------------------------------------------------------

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  InvoiceFilterStatus _selectedFilter = InvoiceFilterStatus.all;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date', 'amount', 'name'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InvoiceModel> _filterInvoices(List<InvoiceModel> invoices) {
    return invoices.where((inv) {
      // Status filter
      if (_selectedFilter != InvoiceFilterStatus.all) {
        final matchesStatus = switch (_selectedFilter) {
          InvoiceFilterStatus.all => true,
          InvoiceFilterStatus.draft => inv.status == InvoiceStatus.draft,
          InvoiceFilterStatus.sent => inv.status == InvoiceStatus.sent,
          InvoiceFilterStatus.overdue =>
            inv.isOverdue || inv.status == InvoiceStatus.overdue,
          InvoiceFilterStatus.paid => inv.status == InvoiceStatus.paid,
        };
        if (!matchesStatus) return false;
      }
      // Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesClient = inv.clientName.toLowerCase().contains(q);
        final matchesNumber = inv.invoiceNumber.toLowerCase().contains(q);
        if (!matchesClient && !matchesNumber) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'amount') return b.totalAmount.compareTo(a.totalAmount);
        if (_sortBy == 'name') return a.clientName.compareTo(b.clientName);
        return b.issueDate.compareTo(a.issueDate);
      });
  }

  void _showSortFilterModal() {
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
                'Sort Invoices',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildSortOption(
                label: 'Sort by Date (Newest first)',
                value: 'date',
                icon: Icons.calendar_today_outlined,
              ),
              _buildSortOption(
                label: 'Sort by Amount (Highest first)',
                value: 'amount',
                icon: Icons.attach_money_rounded,
              ),
              _buildSortOption(
                label: 'Sort by Client Name (A-Z)',
                value: 'name',
                icon: Icons.sort_by_alpha_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryForest : AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primaryForest : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryForest) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);
    final allInvoices = invoicesAsync.asData?.value ?? kSeedInvoices;
    final filtered = _filterInvoices(allInvoices);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Search box (shown when active)
          if (_isSearchActive) ...[
            _buildSearchInput(),
            const SizedBox(height: 16),
          ],
          // Plan Usage Banner Card
          _buildPlanUsageBanner(allInvoices.length),
          const SizedBox(height: 20),
          // Horizontal Filter Chips
          _buildFilterChipsRow(),
          const SizedBox(height: 20),
          // Section Header: RECENT INVOICES + SORTED BY DATE
          _buildSectionHeader(),
          const SizedBox(height: 12),
          // Invoices List
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map((inv) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInvoiceCard(inv),
                )),
          const SizedBox(height: 20),
          // Footer note
          _buildFooterActivity(),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createInvoice),
        backgroundColor: const Color(0xFF00C853), // Bright energetic green matching mockup
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
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
        'Invoices',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearchActive ? Icons.close : Icons.search,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textPrimary),
          onPressed: _showSortFilterModal,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Search Input ───────────────────────────────────────────────────────────

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search invoices by client or #number...',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Plan Usage Banner ──────────────────────────────────────────────────────

  Widget _buildPlanUsageBanner(int count) {
    final usedCount = count.clamp(0, 5);
    final widthFactor = (count / 5.0).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5560EA), // Rich indigo
            Color(0xFF6B74F2), // Light indigo-purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5560EA).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: PLAN USAGE & UPGRADE Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PLAN USAGE',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFFD4D8FF), // Soft lavender
                ),
              ),
              InkWell(
                onTap: () => context.push(AppRoutes.paywall),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'UPGRADE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            '$usedCount of 5 free invoices used',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          // Progress bar
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom note
          const Text(
            'Upgrade to Pro for unlimited invoicing and AI reminders.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Color(0xFFE4E7FF),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips Row ───────────────────────────────────────────────────────

  Widget _buildFilterChipsRow() {
    final filters = [
      {'label': 'All', 'status': InvoiceFilterStatus.all},
      {'label': 'Draft', 'status': InvoiceFilterStatus.draft},
      {'label': 'Sent', 'status': InvoiceFilterStatus.sent},
      {'label': 'Overdue', 'status': InvoiceFilterStatus.overdue},
      {'label': 'Paid', 'status': InvoiceFilterStatus.paid},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final status = f['status'] as InvoiceFilterStatus;
          final label = f['label'] as String;
          final isSelected = _selectedFilter == status;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = status);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1B2A1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1B2A1E) : AppColors.border,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'RECENT INVOICES',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _sortBy == 'amount'
                ? 'SORTED BY AMOUNT'
                : (_sortBy == 'name' ? 'SORTED BY NAME' : 'SORTED BY DATE'),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Invoice Card ───────────────────────────────────────────────────────────

  Widget _buildInvoiceCard(InvoiceModel inv) {
    String statusDetail;
    if (inv.status == InvoiceStatus.paid) {
      final date = inv.paidAt ?? inv.updatedAt ?? DateTime.now();
      statusDetail = 'Paid on ${DateFormat.MMMd().format(date)}';
    } else if (inv.isOverdue || inv.status == InvoiceStatus.overdue) {
      statusDetail = '${inv.daysOverdue} days overdue';
    } else if (inv.status == InvoiceStatus.sent) {
      statusDetail = 'Due in ${inv.dueDate.difference(DateTime.now()).inDays.clamp(0, 365)} days';
    } else {
      statusDetail = 'Due ${DateFormat.MMMd().format(inv.dueDate)}';
    }

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
        onTap: () {
          context.pushNamed(
            AppRoutes.invoiceDetailName,
            pathParameters: {'id': inv.id},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Client Avatar
              _buildAvatar(inv),
              const SizedBox(width: 12),
              // Middle Info: #1023 Client Name + Status pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${inv.invoiceNumber} ',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            inv.clientName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _buildStatusBadge(inv.status, inv.isOverdue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            statusDetail,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
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
              const SizedBox(width: 8),
              // Right: Amount + Chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${inv.totalAmount.toStringAsFixed(2)}',
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
    );
  }

  Widget _buildAvatar(InvoiceModel inv) {
    final initials = inv.clientName.trim().isNotEmpty
        ? inv.clientName
            .trim()
            .split(RegExp(r'\s+'))
            .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
            .take(2)
            .join()
        : 'IN';

    final colors = [
      (const Color(0xFFDEEBF7), const Color(0xFF2C5E8A)),
      (const Color(0xFFE8F4EC), const Color(0xFF2E6D43)),
      (const Color(0xFFF3EBE1), const Color(0xFF7A5C3D)),
      (const Color(0xFFFCE7F3), const Color(0xFF9D174D)),
    ];
    final colorPair = colors[inv.clientName.hashCode.abs() % colors.length];

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorPair.$1,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorPair.$2,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status, bool isOverdue) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF64748B);
    String label = 'DRAFT';
    IconData icon = Icons.edit_note_rounded;

    if (status == InvoiceStatus.overdue || isOverdue) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFEF4444);
      label = 'OVERDUE';
      icon = Icons.access_time_rounded;
    } else if (status == InvoiceStatus.paid) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      label = 'PAID';
      icon = Icons.check_circle_outline_rounded;
    } else if (status == InvoiceStatus.sent) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF3B82F6);
      label = 'SENT';
      icon = Icons.access_time_rounded;
    } else if (status == InvoiceStatus.viewed) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      label = 'VIEWED';
      icon = Icons.visibility_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer Activity Note ───────────────────────────────────────────────────

  Widget _buildFooterActivity() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Showing your most recent business activity',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_outlined,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No invoices found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try switching filter tabs or creating a new invoice.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
