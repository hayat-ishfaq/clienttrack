import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Model for Invoices Screen
// ---------------------------------------------------------------------------

enum InvoiceFilterStatus {
  all,
  draft,
  sent,
  overdue,
  paid,
}

class _InvoiceListItem {
  final String id;
  final String number;
  final String clientName;
  final String clientAvatar;
  final InvoiceFilterStatus status;
  final String statusDetail;
  final double amount;
  final String date;

  const _InvoiceListItem({
    required this.id,
    required this.number,
    required this.clientName,
    required this.clientAvatar,
    required this.status,
    required this.statusDetail,
    required this.amount,
    required this.date,
  });
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

  final List<_InvoiceListItem> _allInvoices = const [
    _InvoiceListItem(
      id: '1023',
      number: '#1023',
      clientName: 'Sarah Johnson',
      clientAvatar: 'SJ',
      status: InvoiceFilterStatus.overdue,
      statusDetail: '3 days late',
      amount: 450.00,
      date: '2024-10-18',
    ),
    _InvoiceListItem(
      id: '1019',
      number: '#1019',
      clientName: 'Daniel Kim',
      clientAvatar: 'DK',
      status: InvoiceFilterStatus.overdue,
      statusDetail: '9 days late',
      amount: 250.00,
      date: '2024-10-12',
    ),
    _InvoiceListItem(
      id: '1026',
      number: '#1026',
      clientName: 'Daniel Kim',
      clientAvatar: 'DK',
      status: InvoiceFilterStatus.sent,
      statusDetail: 'Due in 6 days',
      amount: 900.00,
      date: '2024-10-20',
    ),
    _InvoiceListItem(
      id: '1018',
      number: '#1018',
      clientName: 'Sarah Johnson',
      clientAvatar: 'SJ',
      status: InvoiceFilterStatus.paid,
      statusDetail: 'Completed',
      amount: 1500.00,
      date: '2024-10-10',
    ),
    _InvoiceListItem(
      id: '1028',
      number: '#1028',
      clientName: 'Alex Rivera',
      clientAvatar: 'AR',
      status: InvoiceFilterStatus.draft,
      statusDetail: 'Saved as draft',
      amount: 850.00,
      date: '2024-10-21',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_InvoiceListItem> get _filteredInvoices {
    return _allInvoices.where((inv) {
      // Status filter
      if (_selectedFilter != InvoiceFilterStatus.all &&
          inv.status != _selectedFilter) {
        return false;
      }
      // Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesClient = inv.clientName.toLowerCase().contains(q);
        final matchesNumber = inv.number.toLowerCase().contains(q);
        if (!matchesClient && !matchesNumber) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'amount') return b.amount.compareTo(a.amount);
        if (_sortBy == 'name') return a.clientName.compareTo(b.clientName);
        return b.date.compareTo(a.date);
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
    final filtered = _filteredInvoices;

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
          _buildPlanUsageBanner(),
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

  Widget _buildPlanUsageBanner() {
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
          const Text(
            '3 of 5 free invoices used',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          // Progress bar (60% fill)
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 3 / 5,
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

  Widget _buildInvoiceCard(_InvoiceListItem inv) {
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
                          '${inv.number} ',
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
                        _buildStatusBadge(inv.status),
                        const SizedBox(width: 6),
                        Text(
                          inv.statusDetail,
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
              // Right: Amount + Chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${inv.amount.toStringAsFixed(2)}',
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

  Widget _buildAvatar(_InvoiceListItem inv) {
    Color bg = const Color(0xFFF3EBE1);
    Color fg = const Color(0xFF7A5C3D);

    if (inv.clientAvatar == 'DK') {
      bg = const Color(0xFFDEEBF7);
      fg = const Color(0xFF2C5E8A);
    } else if (inv.clientAvatar == 'AR') {
      bg = const Color(0xFFE8F4EC);
      fg = const Color(0xFF2E6D43);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          inv.clientAvatar,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceFilterStatus status) {
    Color bg = const Color(0xFFFEE2E2);
    Color fg = const Color(0xFFEF4444);
    String label = 'OVERDUE';
    IconData icon = Icons.access_time_rounded;

    if (status == InvoiceFilterStatus.sent) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF3B82F6);
      label = 'SENT';
      icon = Icons.access_time_rounded;
    } else if (status == InvoiceFilterStatus.paid) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      label = 'PAID';
      icon = Icons.check_circle_outline_rounded;
    } else if (status == InvoiceFilterStatus.draft) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      label = 'DRAFT';
      icon = Icons.edit_note_rounded;
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
